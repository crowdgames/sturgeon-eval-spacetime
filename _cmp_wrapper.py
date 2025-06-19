import os, json, time, argparse, subprocess, re
from pathlib import Path

def extract_total_time_from_file(log_file):
    with open(log_file, "r") as f:
        for line in f:
            if "--TOTALTIME" in line:
                match = re.search(r"--TOTALTIME\s+([0-9.]+)", line)
                if match:
                    return float(match.group(1))
    return 0.0

def run_command(cmd):
    print(f"[Running] {cmd}")
    result = subprocess.run(cmd, shell=True)
    if result.returncode != 0:
        print(f"[Error] Command failed with code {result.returncode}")
    return result.returncode == 0

def parse_sturgeon_logs(outfile_dir, tries):
    setup_time = 0.0
    gen_total_time = 0.0
    runs_data = []

    # Setup
    for log_file in outfile_dir.glob("*.log"):
        if not log_file.name.startswith("out_"):
            setup_time += extract_total_time_from_file(log_file)

    # Generation
    for i in range(tries):
        log_file = outfile_dir / f"out_{i:02}.log"
        gen_time = extract_total_time_from_file(log_file)
        gen_total_time += gen_time
        runs_data.append({
            "run": i,
            "gen_time_sec": round(gen_time, 3),
            "gen_success": int(gen_time > 0.0)
        })

    total_time = setup_time + gen_total_time

    return {
        "setup_time_sec": round(setup_time, 3),
        "total_time_sec": round(total_time, 3),
        "runs": runs_data
    }

def run_stwfc(infile, outfile, tstep, orsz, ocsz, tries, metrics, game):
    print("Running STWFC...")
    success = run_command(f"rm -rf {outfile}/*")
    stwfc_cmd = (
        f"python stwfc/src/use_coac.py --game {game} --grid {tstep} {orsz-2} {ocsz-2} "
        f"--pattern 2 3 3 --infile {infile} --outfile {outfile} --tries {tries}"
    )
    success = run_command(stwfc_cmd)

    stats_file = Path(outfile) / "stats.json"

    with open(stats_file, "r") as f:
        stats = json.load(f)

    elapsed_all = stats.get("elapsed", {})
    total_time = float(elapsed_all.get("total", 0.0))
    run_times = [(int(k), float(v)) for k, v in elapsed_all.items() if k != "total"]

    fails_str = stats.get("num_fails", "0/0")
    try:
        num_fail = int(fails_str.split("/")[0])
    except:
        num_fail = 0

    runs_data = []
    for i in range(tries):
        gen_time = next((t for idx, t in run_times if idx == i), 0.0)
        runs_data.append({
            "run": i,
            "gen_time_sec": round(gen_time, 2),
            "gen_success": int(gen_time > 0 and (tries - num_fail) > i)
        })

    metrics["stwfc"] = {
        "setup_time_sec": None,
        "total_time_sec": round(total_time, 2),
        "runs": runs_data
    }

def run_sturgeon_block(outfile, game, tries, metrics):
    print("Running Sturgeon Block...")

    bash_script = f"_cmp_{game}_block.sh"
    cmd = f"bash {bash_script} {tries}"

    success = run_command(cmd)

    if not success:
        print("[Error] Bash script failed. No data will be parsed.")
        metrics["block"] = {
            "setup_time_sec": 0,
            "total_time_sec": 0,
            "runs": [{"run": i, "gen_time_sec": 0, "gen_success": 0} for i in range(tries)]
        }
        return

    metrics["block"] = parse_sturgeon_logs(outfile, tries)

def run_sturgeon_diff(outfile, game, tries, metrics):
    print("Running Sturgeon Diff...")

    bash_script = f"_cmp_{game}_diff.sh"
    cmd = f"bash {bash_script} {tries}"

    success = run_command(cmd)

    if not success:
        print("[Error] Bash script failed. No data will be parsed.")
        metrics["diff"] = {
            "setup_time_sec": 0,
            "total_time_sec": 0,
            "runs": [{"run": i, "gen_time_sec": 0, "gen_success": 0} for i in range(tries)]
        }
        return

    metrics["diff"] = parse_sturgeon_logs(outfile, tries)

def main(args):
    game = args.game
    tries = args.tries    
    orsz, ocsz, tstep = args.outgrid
    infile = game_params(game)
    stwfc_outfile = Path("_out/cmp") / game / Path("stwfc")
    block_outfile = Path("_out/cmp") / game / Path("block")
    diff_outfile = Path("_out/cmp") / game / Path("diff")
    os.makedirs(stwfc_outfile, exist_ok=True)

    metrics_path = Path("_out/cmp/") / game / "metrics.json"
    metrics = {}

    if metrics_path.exists():
        with open(metrics_path, "r") as f:
            metrics = json.load(f)
    else:
        print("[Warning] metrics.json not found, creating new one.")
        metrics = {"stwfc": {}, "block": {}, "diff": {}}

    run_sturgeon_block(block_outfile, game, tries, metrics)
    run_sturgeon_diff(diff_outfile, game, tries, metrics)
    run_stwfc(infile, stwfc_outfile, tstep, orsz, ocsz, tries, metrics, game)

    metrics_path = Path("_out/cmp/") / game / "metrics.json"
    with open(metrics_path, "w") as f:
        json.dump(metrics, f, indent=2)
    print(f"\nSaved metrics to {metrics_path}")

    run_command(f"python postprocess.py --game {game} --out cmp")

def game_params(game):
    paths = {
        "field": "stwfc/training_data/field/path_3_2_nw.json",
        "maze": "stwfc/training_data/maze/small_maze.json",
        "soko": "stwfc/training_data/soko/soko_0.json",
    }
    return paths.get(game)

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--game", required=True, help="Which Game to run - field, maze, soko")
    parser.add_argument("--tries", type=int, default=10, help="Number of generation runs")    
    parser.add_argument("--outgrid", required=True, type=int, nargs=3, help="Output size (rows x cols x time)")

    args = parser.parse_args()
    main(args)
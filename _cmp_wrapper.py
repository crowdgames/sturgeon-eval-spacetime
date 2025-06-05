import os, json, time, argparse, subprocess
from pathlib import Path

def parse_sturgeon_log(logfile):
    runs_data = []
    gen_total_time = 0

    with open(logfile, "r") as f:
        for line in f:
            parts = line.strip().split(",")
            if len(parts) != 3:
                continue
            run_idx, duration, exit_code = parts
            duration = float(duration)
            success = int(exit_code) == 0
            gen_total_time += duration
            runs_data.append({
                "run": int(run_idx),
                "gen_time_sec": duration,
                "gen_success": int(success)
            })

    return runs_data, gen_total_time

def run_command(cmd):
    """Runs a command and prints output live, returns (success, time_taken)."""
    print(f"[Running] {cmd}")
    start = time.time()
    result = subprocess.run(cmd, shell=True)
    elapsed = time.time() - start
    if result.returncode != 0:
        print(f"[Error] Command failed with code {result.returncode}")
    return result.returncode == 0, elapsed

def run_stwfc(infile, outfile, tstep, orsz, ocsz, tries, metrics):
    print("Running STWFC...")

    stwfc_cmd = f"python stwfc/src/use_coac.py --grid {tstep} {orsz} {ocsz} --pattern 2 3 3 --infile {infile} --outfile {outfile} --tries {tries}"
    success, elapsed = run_command(stwfc_cmd)

    metrics["stwfc"] = {
        "success": int(success),
        "time_sec": elapsed
    }

def run_sturgeon_block(game, tries, metrics):
    print("Running Sturgeon Block...")

    log_path = "_out/cmp/field/block/gen_log.csv"
    Path(log_path).parent.mkdir(parents=True, exist_ok=True)
    Path(log_path).unlink(missing_ok=True)  # clear old log

    bash_script = f"_cmp_{game}_block.sh"
    cmd = f"bash {bash_script} {tries}"

    success, total_time = run_command(cmd)

    if not success:
        print("[Error] Bash script failed. No data will be parsed.")
        metrics["sturgeon"]["block"] = {
            "setup_time_sec": 0,
            "total_time_sec": total_time,
            "runs": [{"run": i, "gen_time_sec": 0, "gen_success": 0} for i in range(tries)]
        }
        return

    runs_data, gen_total_time = parse_sturgeon_log(log_path)
    setup_time = total_time - gen_total_time

    metrics["sturgeon"]["block"] = {
        "setup_time_sec": setup_time,
        "total_time_sec": total_time,
        "runs": runs_data
    }


def run_sturgeon_diff(game, tries, metrics):
    log_path = "_out/cmp/field/diff/gen_log.csv"
    Path(log_path).parent.mkdir(parents=True, exist_ok=True)
    Path(log_path).unlink(missing_ok=True)  # clear old log

    bash_script = f"_cmp_{game}_diff.sh"
    cmd = f"bash {bash_script} {tries}"

    success, total_time = run_command(cmd)

    if not success:
        print("[Error] Bash script failed. No data will be parsed.")
        metrics["sturgeon"]["diff"] = {
            "setup_time_sec": 0,
            "total_time_sec": total_time,
            "runs": [{"run": i, "gen_time_sec": 0, "gen_success": 0} for i in range(tries)]
        }
        return

    runs_data, gen_total_time = parse_sturgeon_log(log_path)
    setup_time = total_time - gen_total_time

    metrics["sturgeon"]["diff"] = {
        "setup_time_sec": setup_time,
        "total_time_sec": total_time,
        "runs": runs_data
    }

def main(args):
    game = args.game
    tries = args.tries    
    tstep, orsz, ocsz = args.outgrid
    infile = game_params(game)
    outfile = Path("_out/cmp") / game / Path("stwfc")
    os.makedirs(outfile, exist_ok=True)

    metrics = {"stwfc": {}, "sturgeon": {}}

    run_sturgeon_block(game, tries, metrics)
    run_sturgeon_diff(game, tries, metrics)
    run_stwfc(infile, outfile, tstep, orsz, ocsz, tries, metrics)

    metrics_path = Path("results") / "metrics.json"
    with open(metrics_path, "w") as f:
        json.dump(metrics, f, indent=2)
    print(f"\nSaved metrics to {metrics_path}")

def game_params(game):
    if(game == "field"):
        infile = "stwfc/training_data/field/path_3_2_nw.json"
    elif(game == "maze"):
        infile = "stwfc/training_data/maze/small_maze.json"
    elif(game == "soko"):
        infile = "stwfc/training_data/soko/soko_0.json"
    return infile

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--game", required=True, help="Which Game to run - field, maze, soko")
    parser.add_argument("--tries", type=int, default=10, help="Number of generation runs")    
    parser.add_argument("--outgrid", required=True, type=int, nargs=3, help="Output size (time x rows x cols)")

    args = parser.parse_args()
    main(args)
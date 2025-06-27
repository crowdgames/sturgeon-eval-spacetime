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

def run_sturgeon_diff(base_dir, game, tries):
    print("Running Sturgeon Diff...")

    bash_script = f"_run_{game}_diff.sh"
    cmd = f"bash {bash_script} {tries}"

    success = run_command(cmd)

    if not success:
        print("[Error] Bash script failed. No data will be parsed.")
        return

    for size_dir in sorted(base_dir.iterdir()):
        if size_dir.name == "setup":
            continue
        
        if size_dir.is_dir():
            print(f"[Parsing] Size folder: {size_dir.name}")
            diff_dir = size_dir / "diff"
            result = parse_sturgeon_logs(diff_dir, tries)

            metrics = {
                "diff": result
            }

            metrics_path = size_dir / "metrics.json"
            with open(metrics_path, "w") as f:
                json.dump(metrics, f, indent=2)
            print(f"Saved metrics to {metrics_path}")

def main(args):
    game = args.game
    tries = args.tries
    base_dir = Path("_out/run") / game

    run_sturgeon_diff(base_dir, game, tries)

    run_command(f"python postprocess.py --game {game} --out run")

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--game", required=True, help="Which Game to run - soko, blockdude")
    parser.add_argument("--tries", type=int, default=10, help="Number of generation runs")    

    args = parser.parse_args()
    main(args)
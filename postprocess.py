import os, json, subprocess, re, argparse
import numpy as np
from pathlib import Path

def run_command(cmd):
    print(f"[Running] {cmd}")
    result = subprocess.run(cmd, shell=True)
    if result.returncode != 0:
        print(f"[Error] Command failed with code {result.returncode}")
    return result.returncode == 0

def parse_lvl_file(filepath):
    with open(filepath, "r", encoding="utf-8") as f:
        lines = f.read().splitlines()

    grids, current_grid = [], []
    for line in lines:
        if line.startswith("META"):
            break
        if not line.strip():
            if current_grid:
                grids.append(current_grid)
                current_grid = []
        else:
            current_grid.append(list(line.strip()))
    if current_grid:
        grids.append(current_grid)

    ref_shape = (len(grids[0]), len(grids[0][0]))
    for g in grids:
        if (len(g), len(g[0])) != ref_shape:
            raise ValueError(f"Inconsistent grid shape in {filepath}")
    return np.array(grids)

def analyze_lvl_array(arr):
    T = arr.shape[0]
    return {
        "effective_length": int(T),
        "trivial": bool(T <= 3),
        "success": bool(not np.all(arr[-1] == "_")),
        "density_non_blank": float(round(np.sum(arr != "_") / (T * np.prod(arr[0].shape)), 4)),
        "has_extra_P": bool(np.any([np.sum(frame == "P") > 1 for frame in arr]))
    }

def update_metrics(base_dir, metrics_input, methods):
    """
    Build a new metrics_pp dict by:
    -copying setup_time_sec & total_time_sec from metrics_input
    -for each run, pulling gen_time_sec from metrics_input["<method>"]["runs"]
    -recomputing only the lvl_stats from the .lvl files (or stats.json)
    """
    out = {}
    for method in methods:
        src = metrics_input.get(method, {})

        setup_time = src.get("setup_time_sec")
        total_time = src.get("total_time_sec")

        original = {r["run"]: r for r in src.get("runs", [])}

        data = {
            "setup_time_sec": setup_time,
            "total_time_sec": total_time,
            "runs": []
        }

        method_path = Path(base_dir) / method

        if method in ("block", "diff"):
            for lvl_file in sorted(method_path.rglob("out_*.lvl")):
                m = re.search(r"out_(\d+)\.lvl", lvl_file.name)
                if not m:
                    continue
                run_num = int(m.group(1))
                arr = parse_lvl_file(lvl_file)
                stats = analyze_lvl_array(arr)

                gen_time = original.get(run_num, {}).get("gen_time_sec")
                data["runs"].append({
                    "run": run_num,
                    "gen_time_sec": gen_time,
                    "lvl_stats": [stats]
                })

        elif method == "stwfc":
            # subdirectories "0", "1", "2", …
            run_dirs = [
                p for p in method_path.iterdir()
                if p.is_dir() and p.name.isdigit()
            ]
            for run_folder in sorted(run_dirs, key=lambda p: int(p.name)):
                stats_path = run_folder / "stats.json"
                if not stats_path.exists():
                    continue
                with open(stats_path, "r", encoding="utf-8") as f:
                    s = json.load(f)

                lvl_stats = {
                    "effective_length": s.get("effective_length", 0),
                    "trivial": s.get("trivial", False),
                    "success": s.get("gen_success", True),
                    "density_non_blank": s.get("density_non_blank"),
                    "has_extra_P": s.get("has_extra_P", False)
                }

                run_num = int(run_folder.name)
                gen_time = original.get(run_num, {}).get("gen_time_sec")

                data["runs"].append({
                    "run": run_num,
                    "gen_time_sec": gen_time,
                    "lvl_stats": [lvl_stats]
                })

        out[method] = data

    return out

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--game", required=True)
    args = parser.parse_args()

    game = args.game
    base_dir = f"_out/cmp/{game}"
    metrics_path = Path(base_dir) / "metrics.json"
    output_path  = Path(base_dir) / "metrics_pp.json"

    with open(metrics_path, "r", encoding="utf-8") as f:
        raw_metrics = json.load(f)

    run_command(f"python st_datavis.py --game {game} --outdir {base_dir}/stwfc")

    methods    = ["stwfc", "block", "diff"]
    metrics_pp = update_metrics(base_dir, raw_metrics, methods)

    with open(output_path, "w", encoding="utf-8") as f:
        json.dump(metrics_pp, f, indent=2)

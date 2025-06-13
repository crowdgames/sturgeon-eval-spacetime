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

def analyze_lvl_array(arr, method):
    unique_values, counts = np.unique(arr[0], return_counts=True)
    value_counts = dict(zip(unique_values, counts))
    sum_counts = sum(value_counts.values())
    sum_non_blank = sum(v for k, v in value_counts.items() if k != "_")
    density = sum_non_blank / sum_counts if sum_counts > 0 else 0

    has_extra_P = any(np.sum(frame == "P") > 1 for frame in arr)

    if method == "block":
        t = len(arr) - 2  # padding at end
    elif method == "diff":
        t = len(arr) - 1  # last frame is valid

    final_timestep = arr[t]
    while t > 0 and np.array_equal(arr[t - 1], final_timestep):
        t -= 1
    eff_len = t + 1

    trivial = eff_len <= 3
    success = not np.all(arr[-1] == "_")

    return {
        "effective_length": int(eff_len),
        "trivial": trivial,
        "success": success,
        "density_non_blank": round(density, 4),
        "has_extra_P": has_extra_P
    }

def update_metrics(base_dir, metrics_input, methods):
    """
    Build a new metrics_pp dict by:
    -copying setup_time_sec & total_time_sec from metrics_input
    -for each run, pulling gen_time_sec from metrics_input["<method>"]["runs"]
    -recomputing only the lvl_stats from the .lvl files (or stats.json)
    """
    out_metrics = {}
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
                stats = analyze_lvl_array(arr, method)

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

        out_metrics[method] = data

    return out_metrics

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--game", required=True, help="Game to analyze: field, maze, soko, blockdude")
    parser.add_argument("--out", required=True, help="'cmp' for comparison, 'run' for individual runs")
    args = parser.parse_args()

    base_dir = Path(f"_out/{args.out}/{args.game}")
    metrics_path = base_dir / "metrics.json"
    output_path  = base_dir / "metrics_pp.json"

    with metrics_path.open("r", encoding="utf-8") as f:
        raw_metrics = json.load(f)

    if args.out == "cmp":
        run_command(f"python st_datavis.py --game {args.game} --outdir {base_dir}/stwfc")

    methods = {
        "cmp": ["stwfc", "block", "diff"],
        "run": ["diff"]
    }.get(args.out, [])

    metrics_pp = update_metrics(base_dir, raw_metrics, methods)

    with output_path.open("w", encoding="utf-8") as f:
        json.dump(metrics_pp, f, indent=2)

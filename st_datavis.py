from pathlib import Path
import os
import numpy as np
import pandas as pd
import json
from stwfc.src.use_coac import board_to_str
import argparse


def save_lvl_displays(paths):
    for path in paths:
        if os.path.isfile(path):
            if path.endswith(".json"):
                with open(path) as f:
                    level = np.array(json.load(f))
                level_str = f"{level.shape}\n"
                level = level.tolist()
                name = Path(path).stem
                dir = os.path.dirname(path)
                Path(f"{dir}/{name}").mkdir(parents=True, exist_ok=True)
                for i, board in enumerate(level):
                    board_str = board_to_str(board)
                    i_str = f"{i}"
                    if i < 100:
                        i_str = f"0{i_str}"
                    if i < 10:
                        i_str = f"0{i_str}"
                    with open(f"{dir}/{name}/{i_str}.lvl", "w", encoding="utf-8") as f:
                        f.write(board_str)
                    level_str += board_str
                    level_str += "\n\n***\n\n"
                with open(f"{dir}/{name}.txt", "w", encoding="utf-8") as f:
                    f.write(level_str)

        else:
            for subpath in os.listdir(path):
                save_lvl_displays([f"{path}/{subpath}"])


def process(d_results):
    overall_num_trivial = 0
    overall_num_success = 0
    overall_num_has_extra_P = 0

    stats_path = Path(d_results) / "stats.json"
    if not stats_path.exists():
        print(f"[Error] Missing stats.json at: {stats_path}")
        return

    with open(stats_path) as f:
        top_stats = json.load(f)

    average_time = top_stats["elapsed"]["total"] / 10 if top_stats["elapsed"]["total"] > 0 else 0

    for run in sorted(os.listdir(d_results)):
        d_run = Path(d_results) / run
        if not d_run.is_dir():
            continue

        if not (d_run / "init_raw.json").exists() or not (d_run / "final_raw.json").exists():
            continue

        print(f"Processing: {d_run}")

        with open(d_run / "init_raw.json") as f:
            init_lvl = np.array(json.load(f))
        with open(d_run / "final_raw.json") as f:
            final_lvl = np.array(json.load(f))

        lvl_str = ""
        for board in final_lvl.tolist():
            lvl_str += board_to_str(board) + "\n\n***\n\n"
        with open(d_run / "final.txt", "w", encoding="utf-8") as f:
            f.write(lvl_str)

        run_stats = {
            "elapsed": None,
            "gen_success": True,
            "effective_length": None,
            "unbroken_effective_length": None,
            "trivial": False,
            "trivial_unbroken": False,
            "has_extra_P": False,
            "density_non_blank": 0,
            "char_counts": {}
        }

        if np.any(final_lvl == ""):
            run_stats["gen_success"] = False
        else:
            overall_num_success += 1

            unique_values, counts = np.unique(final_lvl[0], return_counts=True)
            value_counts = dict(zip(unique_values, counts))
            sum_counts = sum(value_counts.values())
            sum_non_blank = sum([v for k, v in value_counts.items() if k != "_"])
            density = sum_non_blank / sum_counts if sum_counts > 0 else 0

            run_stats["char_counts"] = {k: str(v) for k, v in value_counts.items()}
            run_stats["density_non_blank"] = round(density, 4)
            run_stats["elapsed"] = round(top_stats["elapsed"].get(run, 0), 2)

            if value_counts.get("P", 0) > 1:
                run_stats["has_extra_P"] = True
                overall_num_has_extra_P += 1

            t = len(final_lvl) - 2
            final_timestep = final_lvl[t]
            while t > 0 and np.array_equal(final_lvl[t - 1], final_timestep):
                t -= 1
            eff_len = t + 1
            run_stats["effective_length"] = eff_len
            if not run_stats["has_extra_P"]:
                run_stats["unbroken_effective_length"] = eff_len

            if eff_len <= 3:
                run_stats["trivial"] = True
                overall_num_trivial += 1
                if not run_stats["has_extra_P"]:
                    run_stats["trivial_unbroken"] = True

        with open(d_run / "stats.json", "w", encoding="utf-8") as f:
            json.dump(run_stats, f, indent=2)

    overall_stats = {
        "overall_num_success": overall_num_success,
        "overall_num_trivial": overall_num_trivial,
        "overall_pct_trivial": overall_num_trivial / overall_num_success if overall_num_success > 0 else 0,
        "overall_num_has_extra_P": overall_num_has_extra_P,
        "overall_pct_has_extra_P": overall_num_has_extra_P / overall_num_success if overall_num_success > 0 else 0,
    }

    with open(Path(d_results) / "stats_plus.json", "w", encoding="utf-8") as f:
        json.dump(overall_stats, f, indent=2)


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--outdir", required=True, help="Where the stats_plus.json should be stored")
    parser.add_argument("--game", required=True, help="Which Game to run - field, maze, soko")
    args = parser.parse_args()
    # The folder containing the level json files and stats.json files organized game:run:generation
    # e.g. results_by_game/game/run contains all files generated by one execution of use_coac (saved to src/results/timestamp) (individual level folders with init_raw.json and final_raw.json and the overall stats.json file) The game would be field, maze, etc
    results_folder = Path(args.outdir)
    process(results_folder)
    # save_lvl_displays("../AIIDE/training")

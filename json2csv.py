import json, os
import pandas as pd
from pathlib import Path

cmp_games = ["field", "maze", "soko"]
run_games = ["soko", "blockdude"]
methods = ["stwfc", "block", "diff"]

output_dir = Path("_out/metrics")
os.makedirs(output_dir, exist_ok=True)


def extract_runs(method_data):
    rows = []
    for run in method_data["runs"]:
        lvl_stats = run["lvl_stats"][0]
        rows.append({
            "run": run["run"],
            "gen_time_sec": run["gen_time_sec"],
            "success": lvl_stats["success"],
            "trivial": lvl_stats["trivial"],
            "effective_length": lvl_stats["effective_length"] or 0,
            "density_non_blank": lvl_stats["density_non_blank"],
            "has_extra_P": lvl_stats["has_extra_P"],
        })
    return pd.DataFrame(rows)


def compute_summary(df, method_name):
    fmt = lambda x: f"{x.mean():.3f} ({x.std(ddof=0):.3f})"
    summary = {"method": method_name}
    summary["avg_gen_time_sec"] = fmt(df["gen_time_sec"])

    if "success" in df.columns:
        summary["success_rate"] = df["success"].mean()
        df = df[df["success"] == True]
        summary["has_extra_P_rate"] = df["has_extra_P"].mean()
        summary["trivial_rate"] = df["trivial"].mean()

    for col, name in [
        ("effective_length", "avg_effective_length"),
        ("density_non_blank", "avg_density_non_blank"), 
    ]:
        if col in df.columns:
            summary[name] = fmt(df[col])

    return summary



# CMP games
for game in cmp_games:
    with open(f"_out/cmp/{game}/metrics_pp.json", "r") as f:
        cmp_data = json.load(f)

    summary_rows = []
    for method in methods:
        df = extract_runs(cmp_data[method])
        df.to_csv(output_dir / f"{game}_{method}_runs.csv", index=False)
        print(f"Saved: {game}_{method}_runs.csv")

        summary_rows.append(compute_summary(df, method))

    summary_df = pd.DataFrame(summary_rows)
    summary_df.to_csv(output_dir / f"{game}_summary.csv", index=False)
    print(f"Saved summary: {game}_summary.csv")

# RUN games
for game in run_games:
    with open(f"_out/run/{game}/metrics_pp.json", "r") as f:
        run_data = json.load(f)

    df = extract_runs(run_data["diff"])
    df = df[["run", "gen_time_sec", "effective_length", "density_non_blank"]]
    df.to_csv(output_dir / f"{game}_run.csv", index=False)
    print(f"Saved: {game}_run.csv")

    summary = compute_summary(df, "diff")
    pd.DataFrame([summary]).to_csv(output_dir / f"{game}_run_summary.csv", index=False)
    print(f"Saved summary: {game}_run_summary.csv")


for path in output_dir.glob("*_summary.csv"):
    game = path.stem.replace("_summary", "")
    df = pd.read_csv(path)
    print(f"% --- {game} summary ---")
    print(df.to_latex(index=False, float_format="%.3f"))
    print()

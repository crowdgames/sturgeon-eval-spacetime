import os, json, time, argparse, subprocess
from pathlib import Path

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
    stwfc_in_file = Path("setup") / f"{infile}.json"
    stwfc_out_dir = Path("results/stwfc") / outfile
    os.makedirs(stwfc_out_dir, exist_ok=True)

    stwfc_cmd = f"python stwfc/src/use_coac.py --grid {tstep} {orsz} {ocsz} --pattern 2 3 3 --infile {stwfc_in_file} --outfile {stwfc_out_dir} --tries {tries}"
    # stwfc_cmd = f"python stwfc/src/use_coac.py --grid 6 {orsz} {ocsz} --pattern 2 3 3 --infile {stwfc_in_file} --outfile {stwfc_out_dir} --tries {tries}"
    success, elapsed = run_command(stwfc_cmd)

    metrics["stwfc"] = {
        "success": int(success),
        "time_sec": elapsed
    }

def run_sturgeon_block(infile, outfile, irsz, tries, metrics):
    print("Running Sturgeon Block...")
    method_metrics_block = []
    for i in range(tries):
        sturgeonB_out_dir = Path("results/sturgeon/sturgeon_block") / f"{outfile}_{i}"
        os.makedirs(sturgeonB_out_dir, exist_ok=True)

        cmds = [
            f"python sturgeon/taggenerator.py --playthrough setup/{infile}.lvl --outfile setup/{infile}.tag --gap 2",
            f"python sturgeon/input2tile.py --outfile {sturgeonB_out_dir}.tile --textfile setup/{infile}.lvl",
            f"python sturgeon/tile2scheme.py --outfile {sturgeonB_out_dir}.scheme --tilefile {sturgeonB_out_dir}.tile --pattern block-rst-noout,2,3,3,{irsz+2}",
            f"python sturgeon/scheme2output.py --outfile _{sturgeonB_out_dir}/out --schemefile {sturgeonB_out_dir}.scheme --solver pysat-gluecard41 --out-result-none --out-tlvl-none --pattern-hard --tagfile setup/{infile}.tag --random {i}"
        ]

        total_time = 0
        all_success = True
        for cmd in cmds:
            success, t = run_command(cmd)
            total_time += t
            if not success:
                all_success = False
                break

        method_metrics_block.append({
            "run": i,
            "success": int(all_success),
            "time_sec": total_time
        })

    metrics["sturgeon"]["block"] = method_metrics_block

def run_sturgeon_diff(infile, outfile, irsz, tries, metrics):
    print("Running Sturgeon Diff...")
    method_metrics_diff = []
    for i in range(tries):
        sturgeonD_out_dir = Path("results/sturgeon/sturgeon_diff") / f"{outfile}_{i}"
        os.makedirs(sturgeonD_out_dir, exist_ok=True)

        cmds = [
            f"python sturgeon/lvl2game.py --infile setup/{infile}.lvl --outfile setup/{infile}.game --gap 2",
            f"python sturgeon/input2tile.py --outfile {sturgeonD_out_dir}.tile --textfile setup/{infile}.lvl --gamefile setup/{infile}.game --text-key-only",
            f"python sturgeon/tile2scheme.py --outfile {sturgeonD_out_dir}-P.scheme --tilefile {sturgeonD_out_dir}.tile --pattern 0=nbr-l 2=single X=single",
            f"python sturgeon/tilediff2scheme.py --outfile {sturgeonD_out_dir}-D.scheme --tilefile {sturgeonD_out_dir}.tile --diff-offset-row {irsz+2} --game 1",
            f"python sturgeon/scheme2merge.py --outfile {sturgeonD_out_dir}-M.scheme --schemefile {sturgeonD_out_dir}-P.scheme {sturgeonD_out_dir}-D.scheme",
            f"python sturgeon/scheme2output.py --outfile {sturgeonD_out_dir}/out --schemefile {sturgeonD_out_dir}-M.scheme --solver pysat-gluecard41 --out-result-none --out-tlvl-none --pattern-hard --pattern-single --tagfile setup/{infile}.tag --gamefile setup/{infile}.game --random {i}"
        ]

        total_time = 0
        all_success = True
        for cmd in cmds:
            success, t = run_command(cmd)
            total_time += t
            if not success:
                all_success = False
                break

        method_metrics_diff.append({
            "run": i,
            "success": int(all_success),
            "time_sec": total_time
        })

    metrics["sturgeon"]["diff"] = method_metrics_diff

def main(args):
    irsz, icsz = args.insize
    tstep, orsz, ocsz = args.outgrid
    infile = args.infile
    outfile = args.outfile
    tries = args.tries

    os.makedirs(Path("results/stwfc") / outfile, exist_ok=True)
    os.makedirs(Path("results/sturgeon/sturgeon_block"), exist_ok=True)
    os.makedirs(Path("results/sturgeon/sturgeon_diff"), exist_ok=True)

    metrics = {"stwfc": {}, "sturgeon": {}}

    run_stwfc(infile, outfile, orsz, ocsz, tries, metrics)
    run_sturgeon_block(infile, outfile, irsz, tries, metrics)
    run_sturgeon_diff(infile, outfile, irsz, tries, metrics)

    metrics_path = Path("sturgeon") / "metrics.json"
    with open(metrics_path, "w") as f:
        json.dump(metrics, f, indent=2)
    print(f"\nSaved metrics to {metrics_path}")

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--infile", required=True, help="Folder containing level.json and level.lvl (relative to setup/)")
    parser.add_argument("--outfile", required=True, help="Where to save results (subfolder name)")
    parser.add_argument("--tries", type=int, default=10, help="Number of generation runs")
    parser.add_argument("--insize", required=True, type=int, nargs=2, help="Input size (rows cols)")
    parser.add_argument("--outgrid", required=True, type=int, nargs=3, help="Output size (time x rows x cols)")
    args = parser.parse_args()
    main(args)
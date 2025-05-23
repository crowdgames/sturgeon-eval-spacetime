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
    success, elapsed = run_command(stwfc_cmd)

    metrics["stwfc"] = {
        "success": int(success),
        "time_sec": elapsed
    }

def run_sturgeon_block(infile, outfile, irsz, icsz, orsz, ocsz, tstep, tries, metrics):
    print("Running Sturgeon Block...")
    runs_data = []

    sturgeonB_setup_dir = Path("results/sturgeon/sturgeon_block/setup") / outfile
    os.makedirs(sturgeonB_setup_dir.parent, exist_ok=True)

    setup_cmds = [
        f"python sturgeon/taggenerator.py --tagsize {orsz} {ocsz} --blockcount {tstep} --outfile setup/{infile}.tag --gap 2",
        f"python sturgeon/input2tile.py --outfile {sturgeonB_setup_dir}.tile --textfile setup/{infile}.lvl",
        f"python sturgeon/tile2scheme.py --outfile {sturgeonB_setup_dir}_{irsz}.scheme --tilefile {sturgeonB_setup_dir}.tile --pattern block-rst-noout,3,3,2,{irsz+2}",
        f"python sturgeon/scheme2merge.py --outfile {sturgeonB_setup_dir}_{orsz}.scheme --schemefile {sturgeonB_setup_dir}_{irsz}.scheme --remap-row \"0,2=0\" \"{irsz+2},{irsz+4}={orsz-irsz}\"",
    ]

    setup_time = 0
    setup_success = True

    for cmd in setup_cmds:
        success, t = run_command(cmd)
        setup_time += t
        if not success:
            setup_success = False
            break

    gen_total_time = 0

    if not setup_success:
        print("Setup failed. Skipping generation.")
        for i in range(tries):
            runs_data.append({
                "run": i,
                "gen_time_sec": 0,
                "gen_success": 0
            })
    else:
        for i in range(tries):
            run_out_dir = Path("results/sturgeon/sturgeon_block") / f"{outfile}_{i}"
            os.makedirs(run_out_dir, exist_ok=True)

            gen_cmd = (
                f"python sturgeon/scheme2output.py --outfile {run_out_dir}/out "
                f"--schemefile {sturgeonB_setup_dir}_{orsz}.scheme "
                f"--solver pysat-gluecard41 --out-result-none --out-tlvl-none --pattern-hard "
                f"--custom text-count 0 0 {orsz} {ocsz} \"P\" 1 1 hard "
                f"--custom text-count 0 0 {orsz} {ocsz} \"B\" 1 1 hard "
                f"--custom text-count 0 0 {orsz} {ocsz} \"O\" 1 1 hard "
                f"--pattern-range 0 2 0 2 1 1 "
                f"--tagfile setup/{infile}.tag --random 00{i}"
            )

            success, gen_time = run_command(gen_cmd)
            gen_total_time += gen_time

            runs_data.append({
                "run": i,
                "gen_time_sec": gen_time,
                "gen_success": int(success)
            })

    metrics["sturgeon"]["block"] = {
        "setup_time_sec": setup_time,
        "total_time_sec": setup_time + gen_total_time,
        "runs": runs_data
    }


def run_sturgeon_diff(infile, outfile, irsz, icsz, orsz, ocsz, tstep, tries, metrics):
    print("Running Sturgeon Diff...")
    runs_data = []

    sturgeonD_setup_dir = Path("results/sturgeon/sturgeon_diff/setup") / outfile
    os.makedirs(sturgeonD_setup_dir.parent, exist_ok=True)

    setup_cmds = [
        f"python sturgeon/lvl2game.py --infile setup/{infile}.lvl --outfile setup/{infile}-{irsz}.game --gap 2",
        f"python sturgeon/level2concat.py --outfile setup/{infile}-{orsz} --game 0 1 2 X --padding 2 --term-inst {tstep} --size {orsz} {ocsz}",
        f"python sturgeon/input2tile.py --outfile {sturgeonD_setup_dir}.tile --textfile setup/{infile}.lvl --gamefile setup/{infile}-{irsz}.game --text-key-only",
        f"python sturgeon/tile2scheme.py --outfile {sturgeonD_setup_dir}-P.scheme --tilefile {sturgeonD_setup_dir}.tile --pattern 0=nbr-l 2=single X=single",
        f"python sturgeon/tilediff2scheme.py --outfile {sturgeonD_setup_dir}-D.scheme --tilefile {sturgeonD_setup_dir}.tile --diff-offset-row {irsz+2} --game 1",
        f"python sturgeon/scheme2merge.py --outfile {sturgeonD_setup_dir}-M.scheme --schemefile {sturgeonD_setup_dir}-P.scheme {sturgeonD_setup_dir}-D.scheme",
        f"python sturgeon/scheme2merge.py --outfile {sturgeonD_setup_dir}_{orsz}.scheme --schemefile {sturgeonD_setup_dir}-M.scheme --remap-row \" -{irsz+4},-{irsz}={irsz-orsz}\" \" -2,2=0\" \"{irsz},{irsz+4}={orsz-irsz}\""
    ]

    setup_time = 0
    setup_success = True

    for cmd in setup_cmds:
        success, t = run_command(cmd)
        setup_time += t
        if not success:
            setup_success = False
            break

    gen_total_time = 0

    if not setup_success:
        print("Setup failed. Skipping generation.")
        for i in range(tries):
            runs_data.append({
                "run": i,
                "gen_time_sec": 0,
                "gen_success": 0
            })
    else:
        for i in range(tries):
            run_out_dir = Path("results/sturgeon/sturgeon_diff") / f"{outfile}_{i}"
            os.makedirs(run_out_dir, exist_ok=True)

            gen_cmd = (
                f"python sturgeon/scheme2output.py --outfile {run_out_dir}/out "
                f"--schemefile {sturgeonD_setup_dir}_{orsz}.scheme "
                f"--solver pysat-gluecard41 --out-result-none --out-tlvl-none "
                f"--pattern-hard --pattern-single "
                f"--tagfile setup/{infile}-{orsz}.tag "
                f"--gamefile setup/{infile}-{orsz}.game "
                f"--custom text-count 0 0 {orsz} {ocsz} \"P\" 1 1 hard "
                f"--custom text-count 0 0 {orsz} {ocsz} \"B\" 1 1 hard "
                f"--custom text-count 0 0 {orsz} {ocsz} \"O\" 1 1 hard "
                f"--pattern-range 0 2 0 2 1 1 "
                f"--random {i}"
            )

            success, gen_time = run_command(gen_cmd)
            gen_total_time += gen_time

            runs_data.append({
                "run": i,
                "gen_time_sec": gen_time,
                "gen_success": int(success)
            })

    metrics["sturgeon"]["diff"] = {
        "setup_time_sec": setup_time,
        "total_time_sec": setup_time + gen_total_time,
        "runs": runs_data
    }

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

    run_sturgeon_block(infile, outfile, irsz, icsz, orsz, ocsz, tstep, tries, metrics)
    run_sturgeon_diff(infile, outfile, irsz, icsz, orsz, ocsz, tstep, tries, metrics)
    run_stwfc(infile, outfile, tstep, orsz, ocsz, tries, metrics)

    metrics_path = Path("results") / "metrics.json"
    with open(metrics_path, "w") as f:
        json.dump(metrics, f, indent=2)
    print(f"\nSaved metrics to {metrics_path}")

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--infile", required=True, help="Folder containing level.json and level.lvl (relative to setup/)")
    parser.add_argument("--outfile", required=True, help="Where to save results (subfolder name)")
    parser.add_argument("--tries", type=int, default=10, help="Number of generation runs")
    parser.add_argument("--insize", required=True, type=int, nargs=2, help="Input size (rows x cols)")
    parser.add_argument("--outgrid", required=True, type=int, nargs=3, help="Output size (time x rows x cols)")
    args = parser.parse_args()
    main(args)



# sample_field_command : python wrapper.py --infile field/path_1_nw --outfile field/field --tries 1 --insize 12 12 --outgrid 10 6 6
    ## diff merge values : --remap-row \"0,2=0\" \"{irsz+2},{irsz+4}={orsz-irsz}\"
    ## diff merge values : --remap-row \" -{irsz+3},-{irsz+1}={irsz-orsz}\" \" -1,1=0\" \"{irsz+1},{irsz+3}={orsz-irsz}\"

# sample_soko_command : python wrapper.py --infile soko/soko_1 --outfile soko/soko_1 --tries 1 --insize 7 6 --outgrid 10 6 6
    ## diff merge values : --remap-row \"0,2=0\" \"{irsz+2},{irsz+4}={orsz-irsz}\"
    ## diff merge values : --remap-row \" -{irsz+4},-{irsz}={irsz-orsz}\" \" -2,2=0\" \"{irsz},{irsz+4}={orsz-irsz}\"
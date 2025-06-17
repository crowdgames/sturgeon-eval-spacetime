set -ex

if [[ $# -ne 0 ]]; then exit; fi

python sturgeon/app_editor.py --outfile _out/run/soko/diff/out_edit \
       --schemefile _out/run/soko/diff/setup_9x.scheme \
       --out-result-none --out-tlvl-none \
       --pattern-hard --pattern-ignore-no-in \
       --custom text-count 0 0 9 9 "P" 1 1 hard \
       --custom text-count 0 0 9 9 "B" 2 2 hard \
       --custom text-level _out/run/soko/diff/setup_9x9x10.lvl hard \
       --tagfile _out/run/soko/diff/setup_9x9x10.tag \
       --gamefile _out/run/soko/diff/setup_9x9x10.game \
       --solver pysat-gluecard41 \
       --pattern-single \
       --app --app-hard

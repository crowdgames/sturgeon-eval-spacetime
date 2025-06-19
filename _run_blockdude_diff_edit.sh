set -ex

if [[ $# -ne 0 ]]; then exit; fi

python sturgeon/app_editor.py --outfile _out/run/blockdude/diff/out_edit \
       --schemefile _out/run/blockdude/diff/setup_6x.scheme \
       --out-result-none --out-tlvl-none \
       --pattern-hard --pattern-ignore-no-in \
       --custom text-count 0  0   6 12 "P" 1 1 hard \
       --custom text-count 0  0   6  2 "P" 1 1 hard \
       --custom text-count 0  0   6 12 "D" 1 1 hard \
       --custom text-count 0 10   6 12 "D" 1 1 hard \
       --custom text-count 0  2   6 10 "B" 1 1 hard \
       --custom text-level _out/run/blockdude/diff/setup_6x12x15.lvl hard \
       --tagfile _out/run/blockdude/diff/setup_6x12x15.tag \
       --gamefile _out/run/blockdude/diff/setup_6x12x15.game \
       --solver pysat-gluecard41 \
       --pattern-single \
       --app --out-no-hash --app-hard

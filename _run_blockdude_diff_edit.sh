set -ex

if [[ $# -ne 0 ]]; then exit; fi

python sturgeon/app_editor.py --outfile _out/run/blockdude/diff/out_edit \
       --schemefile _out/run/blockdude/diff/setup_6x.scheme \
       --out-result-none --out-tlvl-none \
       --pattern-hard --pattern-ignore-no-in \
       --custom text-count 0  0 6 20 "P" 1 1 hard \
       --custom text-count 0  0 6  3 "P" 1 1 hard \
       --custom text-count 0  0 6 20 "D" 1 1 hard \
       --custom text-count 0 17 6 20 "D" 1 1 hard \
       --custom text-count 0  0 6 20 "B" 2 2 hard \
       --tagfile _out/run/blockdude/diff/setup_6x20x21.tag \
       --gamefile _out/run/blockdude/diff/setup_6x20x21.game \
       --solver pysat-gluecard41 \
       --pattern-single \
       --app --app-hard

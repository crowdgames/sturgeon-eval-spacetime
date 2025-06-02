python sturgeon/app_editor.py --outfile _out/run/soko/diff/out_edit \
       --schemefile _out/run/soko/diff/setup_9x.scheme \
       --solver pysat-gluecard41 --out-result-none --out-tlvl-none \
       --pattern-hard --pattern-ignore-no-in \
       --custom text-count 0 0 9 9 "P" 1 1 hard \
       --custom text-count 0 0 9 9 "B" 2 2 hard \
       --tagfile _out/run/soko/diff/setup_9x9x10.tag \
       --gamefile _out/run/soko/diff/setup_9x9x10.game \
       --pattern-single

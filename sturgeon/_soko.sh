set -ex

if [ ! -d _soko/levels ]; then
    mkdir -p _soko/levels
    rm -rf _soko/concat
    rm -rf _soko/setup
    rm -rf _soko/out

    python input2tile.py --outfile _soko/levels/soko.tile --textfile levels/mkiii/soko.lvl
    python tile2scheme.py --outfile _soko/levels/soko.scheme --tilefile _soko/levels/soko.tile

    for sz in 6 8; do
        for ii in `seq -f '%03g' 0 4`; do
            python scheme2output.py --outfile _soko/levels/soko-${sz}-${ii} --schemefile _soko/levels/soko.scheme \
                   --solver pysat-minicard \
                   --out-result-none --out-tlvl-none \
                   --mkiii-example soko2 --size ${sz} ${sz} --mkiii-layers 15 \
                   --random ${ii}
        done
    done
fi

if [ ! -d _soko/concat ]; then
    mkdir -p _soko/concat
    rm -rf _soko/setup
    rm -rf _soko/out

    for sz in 6 8; do
        for ii in `seq -f '%03g' 0 4`; do
            python level2concat.py --game 0 1 2 X --padding 2 --term-inst 3 --outfile _soko/concat/soko-${sz}-${ii} --textfile _soko/levels/soko-${sz}-${ii}_play/*.lvl
        done
    done
fi

if [ ! -d _soko/setup ]; then
    mkdir -p _soko/setup
    rm -rf _soko/out

    python input2tile.py --outfile _soko/setup/soko.tileset --textfile levels/kenney/soko-tile.lvl --imagefile levels/kenney/soko-tile-16.png --out-tileset

    for sz in 6 8; do
        python input2tile.py --outfile _soko/setup/soko-${sz}.tile --textfile _soko/concat/soko-${sz}-*.lvl --gamefile _soko/concat/soko-${sz}-*.game --tileset _soko/setup/soko.tileset --text-key-only
        python tile2scheme.py --outfile _soko/setup/soko-${sz}-P.scheme --tilefile _soko/setup/soko-${sz}.tile --pattern 0=nbr-l 2=single X=single
        python tilediff2scheme.py --outfile _soko/setup/soko-${sz}-D.scheme --tilefile _soko/setup/soko-${sz}.tile --diff-offset-row $((sz+2)) --game 1
        python scheme2merge.py --outfile _soko/setup/soko-${sz}-M.scheme --schemefile _soko/setup/soko-${sz}-P.scheme _soko/setup/soko-${sz}-D.scheme
    done

    python scheme2merge.py --outfile _soko/setup/soko-8f6-M.scheme --schemefile _soko/setup/soko-6-M.scheme \
           --remap-row " -10,-6=-2" " -2,2=0" "6,10=2"

    python scheme2merge.py --outfile _soko/setup/soko-8.scheme --schemefile _soko/setup/soko-8-M.scheme _soko/setup/soko-8f6-M.scheme
    # python scheme2merge.py --outfile _soko/setup/soko-7.scheme --schemefile _soko/setup/soko-8.scheme \
    #        --remap-row " -12,-8=1" " -2,2=0" "8,12=-1"
    python scheme2merge.py --outfile _soko/setup/soko-5.scheme --schemefile _soko/setup/soko-8.scheme \
           --remap-row " -12,-8=3" " -2,2=0" "8,12=-3"       
    # python scheme2merge.py --outfile _soko/setup/soko-9.scheme --schemefile _soko/setup/soko-8.scheme \
    #        --remap-row " -12,-8=-1" " -2,2=0" "8,12=1"

    for sz in 5 7 9; do
        python level2concat.py --outfile _soko/setup/soko-tpl-${sz} --game 0 1 2 X --padding 2 --term-inst 20 --size ${sz} ${sz}
    done
fi

if [ ! -d _soko/out ]; then
    mkdir -p _soko/out

    # for ii in `seq -f '%03g' 0 2`; do
    #     python scheme2output.py --outfile _soko/out/soko-out-7-${ii} --schemefile _soko/setup/soko-7.scheme \
    #            --solver pysat-gluecard41 \
    #            --out-result-none --out-tlvl-none \
    #            --pattern-hard --pattern-single \
    #            --tagfile _soko/setup/soko-tpl-7.tag \
    #            --gamefile _soko/setup/soko-tpl-7.game \
    #            --custom text-count 0 0 7 7 "@" 1 1 hard \
    #            --custom text-count 0 0 7 7 "#" 3 3 hard \
    #            --custom text-count 0 0 7 7 "o" 3 3 hard \
    #            --custom text-count 0 0 7 7 "O" 0 0 hard \
    #            --random ${ii}
    # done

    # for ii in `seq -f '%03g' 0 2`; do
    #     python scheme2output.py --outfile _soko/out/soko-out-9-${ii} --schemefile _soko/setup/soko-9.scheme \
    #            --solver pysat-gluecard41 \
    #            --out-result-none --out-tlvl-none \
    #            --pattern-hard --pattern-single \
    #            --tagfile _soko/setup/soko-tpl-9.tag \
    #            --gamefile _soko/setup/soko-tpl-9.game \
    #            --custom text-count 0 0 9 9 "@" 1 1 hard \
    #            --custom text-count 0 0 9 9 "#" 3 3 hard \
    #            --custom text-count 0 0 9 9 "o" 3 3 hard \
    #            --custom text-count 0 0 9 9 "O" 0 0 hard \
    #            --random ${ii}
    # done

    for ii in `seq -f '%03g' 0 2`; do
        python scheme2output.py --outfile _soko/out/soko-out-5-${ii} --schemefile _soko/setup/soko-5.scheme \
               --solver pysat-gluecard41 \
               --out-result-none --out-tlvl-none \
               --pattern-hard --pattern-single \
               --tagfile _soko/setup/soko-tpl-5.tag \
               --gamefile _soko/setup/soko-tpl-5.game \
               --custom text-count 0 0 5 5 "@" 1 1 hard \
               --custom text-count 0 0 5 5 "#" 1 1 hard \
               --custom text-count 0 0 5 5 "o" 1 1 hard \
               --custom text-count 0 0 5 5 "O" 0 0 hard \
               --random ${ii}
    done
fi

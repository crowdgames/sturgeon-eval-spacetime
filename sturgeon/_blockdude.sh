set -ex

if [ ! -d _blockdude/concat ]; then
    mkdir -p _blockdude/concat
    rm -rf _blockdude/setup
    rm -rf _blockdude/out

    cp levels/custom/blockdude/block_0.lvl _blockdude/concat/block_0.lvl
    python level2concat.py --game 0 1 2 X --padding 1 --term-inst 37 --size 6 18 --outfile _blockdude/concat/block_0
fi

if [ ! -d _blockdude/setup ]; then
    mkdir -p _blockdude/setup
    rm -rf _blockdude/out

    python input2tile.py --outfile _blockdude/setup/blockdude.tileset --textfile levels/kenney/blockdude-tile.lvl --imagefile levels/kenney/blockdude-tile-16.png --out-tileset
    python input2tile.py --outfile _blockdude/setup/blockdude.tile --textfile _blockdude/concat/block_0.lvl --gamefile _blockdude/concat/block_0.game --tileset _blockdude/setup/blockdude.tileset --text-key-only

    python tile2scheme.py --outfile _blockdude/setup/blockdude_1.scheme --tilefile _blockdude/setup/blockdude.tile --pattern 0=nbr-2 2=single X=single

    python tilediff2scheme.py --outfile _blockdude/setup/blockdude.scheme --tilefile _blockdude/setup/blockdude.tile --schemefile _blockdude/setup/blockdude_1.scheme --diff-offset-row 7 --context "-1 0, 1 0"

    python level2concat.py --game 0 1 2 X --padding 1 --term-inst 37 --size 6 18 --outfile _blockdude/setup/blockdude-tpl
fi

if [ ! -d _blockdude/out ]; then
    mkdir -p _blockdude/out

    python scheme2output.py --outfile _blockdude/out/blockdude-out --schemefile _blockdude/setup/blockdude.scheme \
           --solver pysat-gluecard41 \
           --out-result-none --out-tlvl-none \
           --pattern-hard --pattern-single \
           --tagfile _blockdude/setup/blockdude-tpl.tag \
           --gamefile _blockdude/setup/blockdude-tpl.game \
           --custom text-count 0 0 6 18 "P" 1 1 hard \
           --custom text-count 0 0 6 18 "B" 1 3 hard \
           --custom text-count 0 0 6 18 "W" 25 30 hard \
           --random 0
fi

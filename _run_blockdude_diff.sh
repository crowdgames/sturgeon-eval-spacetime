set -ex

rm -rf _out/run/blockdude/diff
mkdir -p _out/run/blockdude/diff

if [[ $# -ne 1 ]]; then exit; fi
count="$1"

# make transformed and concatenated levels

python sturgeon/level2concat.py --outfile _out/run/blockdude/diff/in_00_6x.lvl --pad-between 2 --game 0 1 2 X --term-inst 3 --jsonfile setup/blockdude.json
python sturgeon/level2concat.py --outfile _out/run/blockdude/diff/in_01_6x.lvl --pad-between 2 --game 0 1 2 X --term-inst 3 --jsonfile setup/blockdude.json --xform-flip-cols

# get tileset

python sturgeon/input2tile.py --outfile _out/run/blockdude/diff/setup_ts.tileset --out-tileset --textfile setup/blockdude-tiles.lvl --imagefile sturgeon/levels/kenney/blockdude-tile-16.png

# make tile and scheme files for each height

python sturgeon/input2tile.py --outfile _out/run/blockdude/diff/setup_6x.tile --textfile _out/run/blockdude/diff/in_*_6x.lvl --gamefile _out/run/blockdude/diff/in_*_6x.game --tileset _out/run/blockdude/diff/setup_ts.tileset --text-key-only

python sturgeon/tile2scheme.py --outfile _out/run/blockdude/diff/setup_P_6x.scheme --tilefile _out/run/blockdude/diff/setup_6x.tile --pattern 0=nbr-plus 2=nbr-plus X=single

python sturgeon/scheme2merge.py --outfile _out/run/blockdude/diff/setup_P.scheme --schemefile _out/run/blockdude/diff/setup_P_6x.scheme

python sturgeon/tilediff2scheme.py --outfile _out/run/blockdude/diff/setup_D_6x.scheme --tilefile _out/run/blockdude/diff/setup_6x.tile --diff-offset-row 8 --game 1 --context " -1 0, 1 0"

# remap scheme files to output height and merge

python sturgeon/scheme2merge.py --outfile _out/run/blockdude/diff/setup_6x.scheme --schemefile _out/run/blockdude/diff/setup_P.scheme _out/run/blockdude/diff/setup_D_6x.scheme

# create tag file and text constraint

python sturgeon/level2concat.py --outfile _out/run/blockdude/diff/setup_6x20x21.tag --pad-between 2 --size 6 20 --term-inst 21 --game 0 1 2 X

# generate level

for ii in `seq -f '%02g' 0 $((${count}-1))`; do
    python sturgeon/scheme2output.py --outfile _out/run/blockdude/diff/out_${ii} \
	   --schemefile _out/run/blockdude/diff/setup_6x.scheme \
	   --solver pysat-gluecard41 --out-result-none --out-tlvl-none \
	   --pattern-hard --pattern-ignore-no-in \
	   --custom text-count 0  0 6 20 "P" 1 1 hard \
	   --custom text-count 0  0 6  3 "P" 1 1 hard \
	   --custom text-count 0  0 6 20 "D" 1 1 hard \
	   --custom text-count 0 17 6 20 "D" 1 1 hard \
	   --custom text-count 0  0 6 20 "B" 2 2 hard \
	   --tagfile _out/run/blockdude/diff/setup_6x20x21.tag \
	   --gamefile _out/run/blockdude/diff/setup_6x20x21.game \
	   --pattern-single \
	   --random ${ii}
done

set -ex

if [[ $# -ne 1 ]]; then exit; fi
count="$1"

rm -rf _out/run/blockdude/*
mkdir -p _out/run/blockdude/setup
mkdir -p _out/run/blockdude/6x12x15/diff
mkdir -p _out/run/blockdude/6x18x24/diff

# make transformed and concatenated levels

bash sturgeon/log.sh level2concat.py --outfile _out/run/blockdude/setup/in_00_6x.lvl --pad-between 1 --game 0 1 2 X --term-inst 3 --jsonfile setup/blockdude.json
bash sturgeon/log.sh level2concat.py --outfile _out/run/blockdude/setup/in_01_6x.lvl --pad-between 1 --game 0 1 2 X --term-inst 3 --jsonfile setup/blockdude.json --xform-flip-cols

# get tileset

bash sturgeon/log.sh input2tile.py --outfile _out/run/blockdude/setup/setup_ts.tileset --out-tileset --textfile setup/blockdude-tiles.lvl --imagefile setup/blockdude-tiles.png

# make tile and scheme files for each height

bash sturgeon/log.sh input2tile.py --outfile _out/run/blockdude/setup/setup_6x.tile --textfile _out/run/blockdude/setup/in_*_6x.lvl --gamefile _out/run/blockdude/setup/in_*_6x.game --tileset _out/run/blockdude/setup/setup_ts.tileset --text-key-only

bash sturgeon/log.sh tile2scheme.py --outfile _out/run/blockdude/setup/setup_P_6x.scheme --tilefile _out/run/blockdude/setup/setup_6x.tile --pattern 0=block-noout,2,1 2=block-noout,2,1 X=single

bash sturgeon/log.sh scheme2merge.py --outfile _out/run/blockdude/setup/setup_P.scheme --schemefile _out/run/blockdude/setup/setup_P_6x.scheme

bash sturgeon/log.sh tilediff2scheme.py --outfile _out/run/blockdude/setup/setup_D_6x.scheme --tilefile _out/run/blockdude/setup/setup_6x.tile --diff-offset-row 7 --game 1 --context " -1 0, 1 0"

# remap scheme files to output height and merge

bash sturgeon/log.sh scheme2merge.py --outfile _out/run/blockdude/setup/setup_6x.scheme --schemefile _out/run/blockdude/setup/setup_P.scheme _out/run/blockdude/setup/setup_D_6x.scheme --remove-void

# create tag file and text constraint 6 x 12 x 15

bash sturgeon/log.sh level2concat.py --outfile _out/run/blockdude/setup/setup_6x12x15.tag --pad-between 1 --size 6 12 --term-inst 15 --game 0 1 2 X
bash sturgeon/log.sh level2concat.py --outfile _out/run/blockdude/setup/setup_6x12x15.lvl --pad-between 1 --size 4 10 --term-inst 15 --game 0 1 2 X --pad-around W _ W W W W W W

# generate level

for ii in `seq -f '%02g' 0 $((${count}-1))`; do
    bash sturgeon/log.sh scheme2output.py --outfile _out/run/blockdude/6x12x15/diff/out_${ii} \
	   --schemefile _out/run/blockdude/setup/setup_6x.scheme \
	   --out-result-none --out-tlvl-none \
	   --pattern-hard --pattern-ignore-no-in \
	   --custom text-count 0  0   6 12 "P" 1 1 hard \
	   --custom text-count 0  0   6  2 "P" 1 1 hard \
	   --custom text-count 0  0   6 12 "D" 1 1 hard \
	   --custom text-count 0 10   6 12 "D" 1 1 hard \
	   --custom text-count 0  2   6 10 "B" 1 1 hard \
	   --custom text-level _out/run/blockdude/setup/setup_6x12x15.lvl hard \
	   --tagfile _out/run/blockdude/setup/setup_6x12x15.tag \
	   --gamefile _out/run/blockdude/setup/setup_6x12x15.game \
	   --solver pysat-gluecard41 \
	   --pattern-single \
	   --random ${ii}
done


# create tag file and text constraint 6 x 18 x 24

bash sturgeon/log.sh level2concat.py --outfile _out/run/blockdude/setup/setup_6x18x24.tag --pad-between 1 --size 6 18 --term-inst 24 --game 0 1 2 X
bash sturgeon/log.sh level2concat.py --outfile _out/run/blockdude/setup/setup_6x18x24.lvl --pad-between 1 --size 4 16 --term-inst 24 --game 0 1 2 X --pad-around W _ W W W W W W

# generate level

for ii in `seq -f '%02g' 0 $((${count}-1))`; do
    bash sturgeon/log.sh scheme2output.py --outfile _out/run/blockdude/6x18x24/diff/out_${ii} \
	   --schemefile _out/run/blockdude/setup/setup_6x.scheme \
	   --out-result-none --out-tlvl-none \
	   --pattern-hard --pattern-ignore-no-in \
	   --custom text-count 0  0   6 18 "P" 1 1 hard \
	   --custom text-count 0  0   6  2 "P" 1 1 hard \
	   --custom text-count 0  0   6 18 "D" 1 1 hard \
	   --custom text-count 0 16   6 18 "D" 1 1 hard \
	   --custom text-count 0  2   6 18 "B" 2 2 hard \
	   --custom text-level _out/run/blockdude/setup/setup_6x18x24.lvl hard \
	   --tagfile _out/run/blockdude/setup/setup_6x18x24.tag \
	   --gamefile _out/run/blockdude/setup/setup_6x18x24.game \
	   --solver pysat-gluecard41 \
	   --pattern-single \
	   --random ${ii}
done

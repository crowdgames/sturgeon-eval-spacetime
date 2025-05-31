set -ex

rm -rf _out/soko/diff
mkdir -p _out/soko/diff

# make transformed and concatenated levels

python sturgeon/level2concat.py --outfile _out/soko/diff/in_00_8x.lvl --pad-between 2 --pad-around _ --game 0 1 2 X --jsonfile stwfc/AIIDE/training/soko/soko_0.json
python sturgeon/level2concat.py --outfile _out/soko/diff/in_01_8x.lvl --pad-between 2 --pad-around _ --game 0 1 2 X --jsonfile stwfc/AIIDE/training/soko/soko_0.json --xform-flip-rows
python sturgeon/level2concat.py --outfile _out/soko/diff/in_02_8x.lvl --pad-between 2 --pad-around _ --game 0 1 2 X --jsonfile stwfc/AIIDE/training/soko/soko_0.json --xform-flip-cols
python sturgeon/level2concat.py --outfile _out/soko/diff/in_03_8x.lvl --pad-between 2 --pad-around _ --game 0 1 2 X --jsonfile stwfc/AIIDE/training/soko/soko_0.json --xform-flip-rows --xform-flip-cols

python sturgeon/level2concat.py --outfile _out/soko/diff/in_04_7x.lvl --pad-between 2 --pad-around _ --game 0 1 2 X --jsonfile stwfc/AIIDE/training/soko/soko_0.json --xform-rotate 1
python sturgeon/level2concat.py --outfile _out/soko/diff/in_05_7x.lvl --pad-between 2 --pad-around _ --game 0 1 2 X --jsonfile stwfc/AIIDE/training/soko/soko_0.json --xform-rotate 1 --xform-flip-rows
python sturgeon/level2concat.py --outfile _out/soko/diff/in_06_7x.lvl --pad-between 2 --pad-around _ --game 0 1 2 X --jsonfile stwfc/AIIDE/training/soko/soko_0.json --xform-rotate 1 --xform-flip-cols
python sturgeon/level2concat.py --outfile _out/soko/diff/in_07_7x.lvl --pad-between 2 --pad-around _ --game 0 1 2 X --jsonfile stwfc/AIIDE/training/soko/soko_0.json --xform-rotate 1 --xform-flip-rows --xform-flip-cols

python sturgeon/level2concat.py --outfile _out/soko/diff/in_08_8x.lvl --pad-between 2 --pad-around _ --game 0 1 2 X --jsonfile stwfc/AIIDE/training/soko/soko_0.json --xform-rotate 2
python sturgeon/level2concat.py --outfile _out/soko/diff/in_09_8x.lvl --pad-between 2 --pad-around _ --game 0 1 2 X --jsonfile stwfc/AIIDE/training/soko/soko_0.json --xform-rotate 2 --xform-flip-rows
python sturgeon/level2concat.py --outfile _out/soko/diff/in_10_8x.lvl --pad-between 2 --pad-around _ --game 0 1 2 X --jsonfile stwfc/AIIDE/training/soko/soko_0.json --xform-rotate 2 --xform-flip-cols
python sturgeon/level2concat.py --outfile _out/soko/diff/in_11_8x.lvl --pad-between 2 --pad-around _ --game 0 1 2 X --jsonfile stwfc/AIIDE/training/soko/soko_0.json --xform-rotate 2 --xform-flip-rows --xform-flip-cols

python sturgeon/level2concat.py --outfile _out/soko/diff/in_12_7x.lvl --pad-between 2 --pad-around _ --game 0 1 2 X --jsonfile stwfc/AIIDE/training/soko/soko_0.json --xform-rotate 3
python sturgeon/level2concat.py --outfile _out/soko/diff/in_13_7x.lvl --pad-between 2 --pad-around _ --game 0 1 2 X --jsonfile stwfc/AIIDE/training/soko/soko_0.json --xform-rotate 3 --xform-flip-rows
python sturgeon/level2concat.py --outfile _out/soko/diff/in_14_7x.lvl --pad-between 2 --pad-around _ --game 0 1 2 X --jsonfile stwfc/AIIDE/training/soko/soko_0.json --xform-rotate 3 --xform-flip-cols
python sturgeon/level2concat.py --outfile _out/soko/diff/in_15_7x.lvl --pad-between 2 --pad-around _ --game 0 1 2 X --jsonfile stwfc/AIIDE/training/soko/soko_0.json --xform-rotate 3 --xform-flip-rows --xform-flip-cols

# get tileset

python sturgeon/input2tile.py --outfile _out/soko/diff/setup_ts.tileset --out-tileset --textfile _out/soko/diff/in_*.lvl

# make tile and scheme files for each height

python sturgeon/input2tile.py --outfile _out/soko/diff/setup_0_7x.tile --textfile _out/soko/diff/in_*_7x.lvl --game 0 0 0 0 0 0 0 0 --tileset _out/soko/diff/setup_ts.tileset
python sturgeon/input2tile.py --outfile _out/soko/diff/setup_0_8x.tile --textfile _out/soko/diff/in_*_8x.lvl --game 0 0 0 0 0 0 0 0 --tileset _out/soko/diff/setup_ts.tileset

python sturgeon/input2tile.py --outfile _out/soko/diff/setup_G_7x.tile --textfile _out/soko/diff/in_*_7x.lvl --gamefile _out/soko/diff/in_*_7x.game --tileset _out/soko/diff/setup_ts.tileset
python sturgeon/input2tile.py --outfile _out/soko/diff/setup_G_8x.tile --textfile _out/soko/diff/in_*_8x.lvl --gamefile _out/soko/diff/in_*_8x.game --tileset _out/soko/diff/setup_ts.tileset

python sturgeon/tile2scheme.py --outfile _out/soko/diff/setup_P0_7x.scheme --tilefile _out/soko/diff/setup_0_7x.tile --pattern 0=block-noout,3
python sturgeon/tile2scheme.py --outfile _out/soko/diff/setup_P0_8x.scheme --tilefile _out/soko/diff/setup_0_8x.tile --pattern 0=block-noout,3

python sturgeon/tile2scheme.py --outfile _out/soko/diff/setup_PG_7x.scheme --tilefile _out/soko/diff/setup_G_7x.tile --pattern 2=block-noout,3 X=single
python sturgeon/tile2scheme.py --outfile _out/soko/diff/setup_PG_8x.scheme --tilefile _out/soko/diff/setup_G_8x.tile --pattern 2=block-noout,3 X=single

python sturgeon/scheme2merge.py --outfile _out/soko/diff/setup_P.scheme --schemefile _out/soko/diff/setup_P0_7x.scheme _out/soko/diff/setup_P0_8x.scheme _out/soko/diff/setup_PG_7x.scheme _out/soko/diff/setup_PG_8x.scheme

python sturgeon/tilediff2scheme.py --outfile _out/soko/diff/setup_D_7x.scheme --tilefile _out/soko/diff/setup_G_7x.tile --diff-offset-row 9 --game 1
python sturgeon/tilediff2scheme.py --outfile _out/soko/diff/setup_D_8x.scheme --tilefile _out/soko/diff/setup_G_8x.tile --diff-offset-row 10 --game 1

# remap scheme files to output height and merge

python sturgeon/scheme2merge.py --outfile _out/soko/diff/setup_D_6x-A.scheme --schemefile _out/soko/diff/setup_D_7x.scheme --remap-row " -11,-7=1" " -2,2=0" "7,11=-1"
python sturgeon/scheme2merge.py --outfile _out/soko/diff/setup_D_6x-B.scheme --schemefile _out/soko/diff/setup_D_8x.scheme --remap-row " -12,-8=2" " -2,2=0" "8,12=-2"
python sturgeon/scheme2merge.py --outfile _out/soko/diff/setup_6x.scheme --schemefile _out/soko/diff/setup_P.scheme _out/soko/diff/setup_D_6x-A.scheme _out/soko/diff/setup_D_6x-B.scheme --remove-void

# create tag file and text constraint

python sturgeon/level2concat.py --outfile _out/soko/diff/setup_6x6x6.tag --pad-between 2 --size 6 6 --term-inst 6 --game 0 1 2 X
python sturgeon/level2concat.py --outfile _out/soko/diff/setup_6x6x6.lvl --pad-between 2 --size 4 4 --term-inst 6 --pad-around _

# generate level

for ii in `seq -f '%02g' 0 2`; do
    python sturgeon/scheme2output.py --outfile _out/soko/diff/out_${ii} \
	   --schemefile _out/soko/diff/setup_6x.scheme \
	   --solver pysat-gluecard41 --out-result-none --out-tlvl-none \
	   --pattern-hard --pattern-ignore-no-in \
	   --custom text-count 0 0 6 6 "P" 1 1 hard \
	   --custom text-count 0 0 6 6 "B" 1 1 hard \
	   --custom text-count 0 0 6 6 "O" 1 1 hard \
	   --custom text-level _out/soko/diff/setup_6x6x6.lvl hard \
	   --tagfile _out/soko/diff/setup_6x6x6.tag \
	   --gamefile _out/soko/diff/setup_6x6x6.game \
	   --pattern-single \
	   --random ${ii}
done

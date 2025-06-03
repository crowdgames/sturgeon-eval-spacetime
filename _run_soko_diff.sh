set -ex

rm -rf _out/run/soko/diff
mkdir -p _out/run/soko/diff

if [[ $# -ne 1 ]]; then exit; fi
count="$1"

# make transformed and concatenated levels

python sturgeon/level2concat.py --outfile _out/run/soko/diff/in_00_7x.lvl --pad-between 2 --game 0 1 2 X --jsonfile stwfc/AIIDE/training/soko/soko_1.json
python sturgeon/level2concat.py --outfile _out/run/soko/diff/in_01_7x.lvl --pad-between 2 --game 0 1 2 X --jsonfile stwfc/AIIDE/training/soko/soko_1.json --xform-flip-rows
python sturgeon/level2concat.py --outfile _out/run/soko/diff/in_02_7x.lvl --pad-between 2 --game 0 1 2 X --jsonfile stwfc/AIIDE/training/soko/soko_1.json --xform-flip-cols
python sturgeon/level2concat.py --outfile _out/run/soko/diff/in_03_7x.lvl --pad-between 2 --game 0 1 2 X --jsonfile stwfc/AIIDE/training/soko/soko_1.json --xform-flip-rows --xform-flip-cols

python sturgeon/level2concat.py --outfile _out/run/soko/diff/in_04_6x.lvl --pad-between 2 --game 0 1 2 X --jsonfile stwfc/AIIDE/training/soko/soko_1.json --xform-rotate 1
python sturgeon/level2concat.py --outfile _out/run/soko/diff/in_05_6x.lvl --pad-between 2 --game 0 1 2 X --jsonfile stwfc/AIIDE/training/soko/soko_1.json --xform-rotate 1 --xform-flip-rows
python sturgeon/level2concat.py --outfile _out/run/soko/diff/in_06_6x.lvl --pad-between 2 --game 0 1 2 X --jsonfile stwfc/AIIDE/training/soko/soko_1.json --xform-rotate 1 --xform-flip-cols
python sturgeon/level2concat.py --outfile _out/run/soko/diff/in_07_6x.lvl --pad-between 2 --game 0 1 2 X --jsonfile stwfc/AIIDE/training/soko/soko_1.json --xform-rotate 1 --xform-flip-rows --xform-flip-cols

python sturgeon/level2concat.py --outfile _out/run/soko/diff/in_08_7x.lvl --pad-between 2 --game 0 1 2 X --jsonfile stwfc/AIIDE/training/soko/soko_1.json --xform-rotate 2
python sturgeon/level2concat.py --outfile _out/run/soko/diff/in_09_7x.lvl --pad-between 2 --game 0 1 2 X --jsonfile stwfc/AIIDE/training/soko/soko_1.json --xform-rotate 2 --xform-flip-rows
python sturgeon/level2concat.py --outfile _out/run/soko/diff/in_10_7x.lvl --pad-between 2 --game 0 1 2 X --jsonfile stwfc/AIIDE/training/soko/soko_1.json --xform-rotate 2 --xform-flip-cols
python sturgeon/level2concat.py --outfile _out/run/soko/diff/in_11_7x.lvl --pad-between 2 --game 0 1 2 X --jsonfile stwfc/AIIDE/training/soko/soko_1.json --xform-rotate 2 --xform-flip-rows --xform-flip-cols

python sturgeon/level2concat.py --outfile _out/run/soko/diff/in_12_6x.lvl --pad-between 2 --game 0 1 2 X --jsonfile stwfc/AIIDE/training/soko/soko_1.json --xform-rotate 3
python sturgeon/level2concat.py --outfile _out/run/soko/diff/in_13_6x.lvl --pad-between 2 --game 0 1 2 X --jsonfile stwfc/AIIDE/training/soko/soko_1.json --xform-rotate 3 --xform-flip-rows
python sturgeon/level2concat.py --outfile _out/run/soko/diff/in_14_6x.lvl --pad-between 2 --game 0 1 2 X --jsonfile stwfc/AIIDE/training/soko/soko_1.json --xform-rotate 3 --xform-flip-cols
python sturgeon/level2concat.py --outfile _out/run/soko/diff/in_15_6x.lvl --pad-between 2 --game 0 1 2 X --jsonfile stwfc/AIIDE/training/soko/soko_1.json --xform-rotate 3 --xform-flip-rows --xform-flip-cols

# get tileset

python sturgeon/input2tile.py --outfile _out/run/soko/diff/setup_ts.tileset --out-tileset --textfile setup/soko-tiles.lvl --imagefile sturgeon/levels/kenney/soko-tile-16.png

# make tile and scheme files for each height

python sturgeon/input2tile.py --outfile _out/run/soko/diff/setup_6x.tile --textfile _out/run/soko/diff/in_*_6x.lvl --gamefile _out/run/soko/diff/in_*_6x.game --tileset _out/run/soko/diff/setup_ts.tileset --text-key-only
python sturgeon/input2tile.py --outfile _out/run/soko/diff/setup_7x.tile --textfile _out/run/soko/diff/in_*_7x.lvl --gamefile _out/run/soko/diff/in_*_7x.game --tileset _out/run/soko/diff/setup_ts.tileset --text-key-only

python sturgeon/tile2scheme.py --outfile _out/run/soko/diff/setup_P_6x.scheme --tilefile _out/run/soko/diff/setup_6x.tile --pattern 0=nbr-plus 2=nbr-plus X=single
python sturgeon/tile2scheme.py --outfile _out/run/soko/diff/setup_P_7x.scheme --tilefile _out/run/soko/diff/setup_7x.tile --pattern 0=nbr-plus 2=nbr-plus X=single

python sturgeon/scheme2merge.py --outfile _out/run/soko/diff/setup_P.scheme --schemefile _out/run/soko/diff/setup_P_6x.scheme _out/run/soko/diff/setup_P_7x.scheme

python sturgeon/tilediff2scheme.py --outfile _out/run/soko/diff/setup_D_6x.scheme --tilefile _out/run/soko/diff/setup_6x.tile --diff-offset-row 8 --game 1
python sturgeon/tilediff2scheme.py --outfile _out/run/soko/diff/setup_D_7x.scheme --tilefile _out/run/soko/diff/setup_7x.tile --diff-offset-row 9 --game 1

# remap scheme files to output height and merge

python sturgeon/scheme2merge.py --outfile _out/run/soko/diff/setup_D_9x-A.scheme --schemefile _out/run/soko/diff/setup_D_6x.scheme --remap-row " -10,-6=-3" " -2,2=0" "6,10=3"
python sturgeon/scheme2merge.py --outfile _out/run/soko/diff/setup_D_9x-B.scheme --schemefile _out/run/soko/diff/setup_D_7x.scheme --remap-row " -11,-7=-2" " -2,2=0" "7,11=2"
python sturgeon/scheme2merge.py --outfile _out/run/soko/diff/setup_9x.scheme --schemefile _out/run/soko/diff/setup_P.scheme _out/run/soko/diff/setup_D_9x-A.scheme _out/run/soko/diff/setup_D_9x-B.scheme

# create tag file and text constraint

python sturgeon/level2concat.py --outfile _out/run/soko/diff/setup_9x9x15.tag --pad-between 2 --size 9 9 --term-inst 10 --game 0 1 2 X

# generate level

for ii in `seq -f '%02g' 0 $((${count}-1))`; do
    python sturgeon/scheme2output.py --outfile _out/run/soko/diff/out_${ii} \
	   --schemefile _out/run/soko/diff/setup_9x.scheme \
	   --solver pysat-gluecard41 --out-result-none --out-tlvl-none \
	   --pattern-hard --pattern-ignore-no-in \
	   --custom text-count 0 0 9 9 "P" 1 1 hard \
	   --custom text-count 0 0 9 9 "B" 2 2 hard \
	   --tagfile _out/run/soko/diff/setup_9x9x15.tag \
	   --gamefile _out/run/soko/diff/setup_9x9x15.game \
	   --pattern-single \
	   --random ${ii}
done

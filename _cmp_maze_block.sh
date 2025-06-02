set -ex

rm -rf _out/maze/block
mkdir -p _out/maze/block

if [[ $# -ne 1 ]]; then exit; fi
count="$1"

# make transformed and concatenated levels

python sturgeon/level2concat.py --outfile _out/maze/block/in_00_8x.lvl --pad-between 2 --pad-around W --pad-end T --jsonfile stwfc/AIIDE/training/maze/small_maze.json
python sturgeon/level2concat.py --outfile _out/maze/block/in_01_8x.lvl --pad-between 2 --pad-around W --pad-end T --jsonfile stwfc/AIIDE/training/maze/small_maze.json --xform-flip-rows
python sturgeon/level2concat.py --outfile _out/maze/block/in_02_8x.lvl --pad-between 2 --pad-around W --pad-end T --jsonfile stwfc/AIIDE/training/maze/small_maze.json --xform-flip-cols
python sturgeon/level2concat.py --outfile _out/maze/block/in_03_8x.lvl --pad-between 2 --pad-around W --pad-end T --jsonfile stwfc/AIIDE/training/maze/small_maze.json --xform-flip-rows --xform-flip-cols

python sturgeon/level2concat.py --outfile _out/maze/block/in_04_7x.lvl --pad-between 2 --pad-around W --pad-end T --jsonfile stwfc/AIIDE/training/maze/small_maze.json --xform-rotate 1
python sturgeon/level2concat.py --outfile _out/maze/block/in_05_7x.lvl --pad-between 2 --pad-around W --pad-end T --jsonfile stwfc/AIIDE/training/maze/small_maze.json --xform-rotate 1 --xform-flip-rows
python sturgeon/level2concat.py --outfile _out/maze/block/in_06_7x.lvl --pad-between 2 --pad-around W --pad-end T --jsonfile stwfc/AIIDE/training/maze/small_maze.json --xform-rotate 1 --xform-flip-cols
python sturgeon/level2concat.py --outfile _out/maze/block/in_07_7x.lvl --pad-between 2 --pad-around W --pad-end T --jsonfile stwfc/AIIDE/training/maze/small_maze.json --xform-rotate 1 --xform-flip-rows --xform-flip-cols

python sturgeon/level2concat.py --outfile _out/maze/block/in_08_8x.lvl --pad-between 2 --pad-around W --pad-end T --jsonfile stwfc/AIIDE/training/maze/small_maze.json --xform-rotate 2
python sturgeon/level2concat.py --outfile _out/maze/block/in_09_8x.lvl --pad-between 2 --pad-around W --pad-end T --jsonfile stwfc/AIIDE/training/maze/small_maze.json --xform-rotate 2 --xform-flip-rows
python sturgeon/level2concat.py --outfile _out/maze/block/in_10_8x.lvl --pad-between 2 --pad-around W --pad-end T --jsonfile stwfc/AIIDE/training/maze/small_maze.json --xform-rotate 2 --xform-flip-cols
python sturgeon/level2concat.py --outfile _out/maze/block/in_11_8x.lvl --pad-between 2 --pad-around W --pad-end T --jsonfile stwfc/AIIDE/training/maze/small_maze.json --xform-rotate 2 --xform-flip-rows --xform-flip-cols

python sturgeon/level2concat.py --outfile _out/maze/block/in_12_7x.lvl --pad-between 2 --pad-around W --pad-end T --jsonfile stwfc/AIIDE/training/maze/small_maze.json --xform-rotate 3
python sturgeon/level2concat.py --outfile _out/maze/block/in_13_7x.lvl --pad-between 2 --pad-around W --pad-end T --jsonfile stwfc/AIIDE/training/maze/small_maze.json --xform-rotate 3 --xform-flip-rows
python sturgeon/level2concat.py --outfile _out/maze/block/in_14_7x.lvl --pad-between 2 --pad-around W --pad-end T --jsonfile stwfc/AIIDE/training/maze/small_maze.json --xform-rotate 3 --xform-flip-cols
python sturgeon/level2concat.py --outfile _out/maze/block/in_15_7x.lvl --pad-between 2 --pad-around W --pad-end T --jsonfile stwfc/AIIDE/training/maze/small_maze.json --xform-rotate 3 --xform-flip-rows --xform-flip-cols

# get tileset

python sturgeon/input2tile.py --outfile _out/maze/block/setup_ts.tileset --out-tileset --textfile _out/maze/block/in_*.lvl

# make tile and scheme files for each height

python sturgeon/input2tile.py --outfile _out/maze/block/setup_7x.tile --textfile _out/maze/block/in_*_7x.lvl --tileset _out/maze/block/setup_ts.tileset
python sturgeon/input2tile.py --outfile _out/maze/block/setup_8x.tile --textfile _out/maze/block/in_*_8x.lvl --tileset _out/maze/block/setup_ts.tileset

python sturgeon/tile2scheme.py --outfile _out/maze/block/setup_7x.scheme --tilefile _out/maze/block/setup_7x.tile --pattern block-rst-noout,3,3,2,9
python sturgeon/tile2scheme.py --outfile _out/maze/block/setup_8x.scheme --tilefile _out/maze/block/setup_8x.tile --pattern block-rst-noout,3,3,2,10

# remap scheme files to output height and merge

python sturgeon/scheme2merge.py --outfile _out/maze/block/setup_6x-A.scheme --schemefile _out/maze/block/setup_7x.scheme --remap-row "0,2=0" "9,11=-1"
python sturgeon/scheme2merge.py --outfile _out/maze/block/setup_6x-B.scheme --schemefile _out/maze/block/setup_8x.scheme --remap-row "0,2=0" "10,12=-2"
python sturgeon/scheme2merge.py --outfile _out/maze/block/setup_6x.scheme --schemefile _out/maze/block/setup_6x-A.scheme _out/maze/block/setup_6x-B.scheme --remove-void

# create tag file and text constraint

python sturgeon/level2concat.py --outfile _out/maze/block/setup_6x6x7.tag --pad-between 2 --size 6 6 --term-inst 7
python sturgeon/level2concat.py --outfile _out/maze/block/setup_6x6x7.lvl --pad-between 2 --size 4 4 --term-inst 6 --pad-around W --pad-end T

# generate levels

for ii in `seq -f '%02g' 0 $((${count}-1))`; do
    python sturgeon/scheme2output.py --outfile _out/maze/block/out_${ii} \
	   --schemefile _out/maze/block/setup_6x.scheme \
	   --solver pysat-gluecard41 --out-result-none --out-tlvl-none \
	   --pattern-hard --pattern-ignore-no-in \
	   --custom text-count 0 0 6 6 "P" 1 1 hard \
	   --custom text-count 0 0 6 6 "D" 1 1 hard \
	   --custom text-level _out/maze/block/setup_6x6x7.lvl hard \
	   --tagfile _out/maze/block/setup_6x6x7.tag \
	   --random ${ii}
done

set -ex

rm -rf _out/maze/diff
mkdir -p _out/maze/diff

# make transformed and concatenated levels

python sturgeon/level2concat.py --outfile _out/maze/diff/in_0_00_8x.lvl --pad-between 2 --pad-around W --game 0 1 2 X --jsonfile stwfc/AIIDE/training/maze/small_maze.json
python sturgeon/level2concat.py --outfile _out/maze/diff/in_0_01_8x.lvl --pad-between 2 --pad-around W --game 0 1 2 X --jsonfile stwfc/AIIDE/training/maze/small_maze.json --xform-flip-rows
python sturgeon/level2concat.py --outfile _out/maze/diff/in_0_02_8x.lvl --pad-between 2 --pad-around W --game 0 1 2 X --jsonfile stwfc/AIIDE/training/maze/small_maze.json --xform-flip-cols
python sturgeon/level2concat.py --outfile _out/maze/diff/in_0_03_8x.lvl --pad-between 2 --pad-around W --game 0 1 2 X --jsonfile stwfc/AIIDE/training/maze/small_maze.json --xform-flip-rows --xform-flip-cols

python sturgeon/level2concat.py --outfile _out/maze/diff/in_0_04_7x.lvl --pad-between 2 --pad-around W --game 0 1 2 X --jsonfile stwfc/AIIDE/training/maze/small_maze.json --xform-rotate 1
python sturgeon/level2concat.py --outfile _out/maze/diff/in_0_05_7x.lvl --pad-between 2 --pad-around W --game 0 1 2 X --jsonfile stwfc/AIIDE/training/maze/small_maze.json --xform-rotate 1 --xform-flip-rows
python sturgeon/level2concat.py --outfile _out/maze/diff/in_0_06_7x.lvl --pad-between 2 --pad-around W --game 0 1 2 X --jsonfile stwfc/AIIDE/training/maze/small_maze.json --xform-rotate 1 --xform-flip-cols
python sturgeon/level2concat.py --outfile _out/maze/diff/in_0_07_7x.lvl --pad-between 2 --pad-around W --game 0 1 2 X --jsonfile stwfc/AIIDE/training/maze/small_maze.json --xform-rotate 1 --xform-flip-rows --xform-flip-cols

python sturgeon/level2concat.py --outfile _out/maze/diff/in_0_08_8x.lvl --pad-between 2 --pad-around W --game 0 1 2 X --jsonfile stwfc/AIIDE/training/maze/small_maze.json --xform-rotate 2
python sturgeon/level2concat.py --outfile _out/maze/diff/in_0_09_8x.lvl --pad-between 2 --pad-around W --game 0 1 2 X --jsonfile stwfc/AIIDE/training/maze/small_maze.json --xform-rotate 2 --xform-flip-rows
python sturgeon/level2concat.py --outfile _out/maze/diff/in_0_10_8x.lvl --pad-between 2 --pad-around W --game 0 1 2 X --jsonfile stwfc/AIIDE/training/maze/small_maze.json --xform-rotate 2 --xform-flip-cols
python sturgeon/level2concat.py --outfile _out/maze/diff/in_0_11_8x.lvl --pad-between 2 --pad-around W --game 0 1 2 X --jsonfile stwfc/AIIDE/training/maze/small_maze.json --xform-rotate 2 --xform-flip-rows --xform-flip-cols

python sturgeon/level2concat.py --outfile _out/maze/diff/in_0_12_7x.lvl --pad-between 2 --pad-around W --game 0 1 2 X --jsonfile stwfc/AIIDE/training/maze/small_maze.json --xform-rotate 3
python sturgeon/level2concat.py --outfile _out/maze/diff/in_0_13_7x.lvl --pad-between 2 --pad-around W --game 0 1 2 X --jsonfile stwfc/AIIDE/training/maze/small_maze.json --xform-rotate 3 --xform-flip-rows
python sturgeon/level2concat.py --outfile _out/maze/diff/in_0_14_7x.lvl --pad-between 2 --pad-around W --game 0 1 2 X --jsonfile stwfc/AIIDE/training/maze/small_maze.json --xform-rotate 3 --xform-flip-cols
python sturgeon/level2concat.py --outfile _out/maze/diff/in_0_15_7x.lvl --pad-between 2 --pad-around W --game 0 1 2 X --jsonfile stwfc/AIIDE/training/maze/small_maze.json --xform-rotate 3 --xform-flip-rows --xform-flip-cols

# get tileset

python sturgeon/input2tile.py --outfile _out/maze/diff/maze.tileset --out-tileset --textfile _out/maze/diff/in_*.lvl

# make tile and scheme files for each height

python sturgeon/input2tile.py --outfile _out/maze/diff/maze_0_7x.tile --textfile _out/maze/diff/in_*_7x.lvl --game 0 0 0 0 0 0 0 0 --tileset _out/maze/diff/maze.tileset
python sturgeon/input2tile.py --outfile _out/maze/diff/maze_0_8x.tile --textfile _out/maze/diff/in_*_8x.lvl --game 0 0 0 0 0 0 0 0 --tileset _out/maze/diff/maze.tileset

python sturgeon/input2tile.py --outfile _out/maze/diff/maze_G_7x.tile --textfile _out/maze/diff/in_*_7x.lvl --gamefile _out/maze/diff/in_*_7x.game --tileset _out/maze/diff/maze.tileset
python sturgeon/input2tile.py --outfile _out/maze/diff/maze_G_8x.tile --textfile _out/maze/diff/in_*_8x.lvl --gamefile _out/maze/diff/in_*_8x.game --tileset _out/maze/diff/maze.tileset

python sturgeon/tile2scheme.py --outfile _out/maze/diff/maze-P0_7x.scheme --tilefile _out/maze/diff/maze_0_7x.tile --pattern 0=block-noout,3
python sturgeon/tile2scheme.py --outfile _out/maze/diff/maze-P0_8x.scheme --tilefile _out/maze/diff/maze_0_8x.tile --pattern 0=block-noout,3

python sturgeon/tile2scheme.py --outfile _out/maze/diff/maze-PG_7x.scheme --tilefile _out/maze/diff/maze_G_7x.tile --pattern 2=block-noout,3 X=single
python sturgeon/tile2scheme.py --outfile _out/maze/diff/maze-PG_8x.scheme --tilefile _out/maze/diff/maze_G_8x.tile --pattern 2=block-noout,3 X=single

python sturgeon/scheme2merge.py --outfile _out/maze/diff/maze-P.scheme --schemefile _out/maze/diff/maze-P0_7x.scheme _out/maze/diff/maze-P0_8x.scheme _out/maze/diff/maze-PG_7x.scheme _out/maze/diff/maze-PG_8x.scheme

python sturgeon/tilediff2scheme.py --outfile _out/maze/diff/maze-D_7x.scheme --tilefile _out/maze/diff/maze_G_7x.tile --diff-offset-row 9 --game 1
python sturgeon/tilediff2scheme.py --outfile _out/maze/diff/maze-D_8x.scheme --tilefile _out/maze/diff/maze_G_8x.tile --diff-offset-row 10 --game 1

# remap scheme files to output height and merge

python sturgeon/scheme2merge.py --outfile _out/maze/diff/maze-D_6x-A.scheme --schemefile _out/maze/diff/maze-D_7x.scheme --remap-row " -10,-8=1" " -1,1=0" "8,10=-1"
python sturgeon/scheme2merge.py --outfile _out/maze/diff/maze-D_6x-B.scheme --schemefile _out/maze/diff/maze-D_8x.scheme --remap-row " -11,-9=2" " -1,1=0" "9,11=-2"
python sturgeon/scheme2merge.py --outfile _out/maze/diff/maze_6x.scheme --schemefile _out/maze/diff/maze-P.scheme _out/maze/diff/maze-D_6x-A.scheme _out/maze/diff/maze-D_6x-B.scheme --remove-void

# create tag file and text constraint

python sturgeon/level2concat.py --outfile _out/maze/diff/maze_6x6x6.tag --pad-between 2 --size 6 6 --term-inst 6 --game 0 1 2 X
python sturgeon/level2concat.py --outfile _out/maze/diff/maze_6x6x6.lvl --pad-between 2 --size 4 4 --term-inst 6 --pad-around W

# generate level

for ii in `seq -f '%03g' 0 2`; do
    python sturgeon/scheme2output.py --outfile _out/maze/diff/maze \
	   --schemefile _out/maze/diff/maze_6x.scheme \
	   --solver pysat-gluecard41 --out-result-none --out-tlvl-none \
	   --pattern-hard --pattern-ignore-no-in \
	   --custom text-count 0 0 6 6 "P" 1 1 hard \
	   --custom text-count 0 0 6 6 "D" 1 1 hard \
	   --custom text-level _out/maze/diff/maze_6x6x6.lvl hard \
	   --tagfile _out/maze/diff/maze_6x6x6.tag \
	   --gamefile _out/maze/diff/maze_6x6x6.game \
	   --pattern-single \
	   --random ${ii}
done

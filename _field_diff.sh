set -ex

rm -rf _out/field/diff
mkdir -p _out/field/diff

# make transformed and concatenated levels

python sturgeon/level2concat.py --outfile _out/field/diff/in_0_00_10x.lvl --pad-between 2 --pad-around _ --game 0 1 2 X --jsonfile stwfc/AIIDE/training/field/path_3_2_nw.json
python sturgeon/level2concat.py --outfile _out/field/diff/in_0_01_10x.lvl --pad-between 2 --pad-around _ --game 0 1 2 X --jsonfile stwfc/AIIDE/training/field/path_3_2_nw.json --xform-flip-rows
python sturgeon/level2concat.py --outfile _out/field/diff/in_0_02_10x.lvl --pad-between 2 --pad-around _ --game 0 1 2 X --jsonfile stwfc/AIIDE/training/field/path_3_2_nw.json --xform-flip-cols
python sturgeon/level2concat.py --outfile _out/field/diff/in_0_03_10x.lvl --pad-between 2 --pad-around _ --game 0 1 2 X --jsonfile stwfc/AIIDE/training/field/path_3_2_nw.json --xform-flip-rows --xform-flip-cols

python sturgeon/level2concat.py --outfile _out/field/diff/in_0_04_10x.lvl --pad-between 2 --pad-around _ --game 0 1 2 X --jsonfile stwfc/AIIDE/training/field/path_3_2_nw.json --xform-rotate 1
python sturgeon/level2concat.py --outfile _out/field/diff/in_0_05_10x.lvl --pad-between 2 --pad-around _ --game 0 1 2 X --jsonfile stwfc/AIIDE/training/field/path_3_2_nw.json --xform-rotate 1 --xform-flip-rows
python sturgeon/level2concat.py --outfile _out/field/diff/in_0_06_10x.lvl --pad-between 2 --pad-around _ --game 0 1 2 X --jsonfile stwfc/AIIDE/training/field/path_3_2_nw.json --xform-rotate 1 --xform-flip-cols
python sturgeon/level2concat.py --outfile _out/field/diff/in_0_07_10x.lvl --pad-between 2 --pad-around _ --game 0 1 2 X --jsonfile stwfc/AIIDE/training/field/path_3_2_nw.json --xform-rotate 1 --xform-flip-rows --xform-flip-cols

python sturgeon/level2concat.py --outfile _out/field/diff/in_0_08_10x.lvl --pad-between 2 --pad-around _ --game 0 1 2 X --jsonfile stwfc/AIIDE/training/field/path_3_2_nw.json --xform-rotate 2
python sturgeon/level2concat.py --outfile _out/field/diff/in_0_09_10x.lvl --pad-between 2 --pad-around _ --game 0 1 2 X --jsonfile stwfc/AIIDE/training/field/path_3_2_nw.json --xform-rotate 2 --xform-flip-rows
python sturgeon/level2concat.py --outfile _out/field/diff/in_0_10_10x.lvl --pad-between 2 --pad-around _ --game 0 1 2 X --jsonfile stwfc/AIIDE/training/field/path_3_2_nw.json --xform-rotate 2 --xform-flip-cols
python sturgeon/level2concat.py --outfile _out/field/diff/in_0_11_10x.lvl --pad-between 2 --pad-around _ --game 0 1 2 X --jsonfile stwfc/AIIDE/training/field/path_3_2_nw.json --xform-rotate 2 --xform-flip-rows --xform-flip-cols

python sturgeon/level2concat.py --outfile _out/field/diff/in_0_12_10x.lvl --pad-between 2 --pad-around _ --game 0 1 2 X --jsonfile stwfc/AIIDE/training/field/path_3_2_nw.json --xform-rotate 3
python sturgeon/level2concat.py --outfile _out/field/diff/in_0_13_10x.lvl --pad-between 2 --pad-around _ --game 0 1 2 X --jsonfile stwfc/AIIDE/training/field/path_3_2_nw.json --xform-rotate 3 --xform-flip-rows
python sturgeon/level2concat.py --outfile _out/field/diff/in_0_14_10x.lvl --pad-between 2 --pad-around _ --game 0 1 2 X --jsonfile stwfc/AIIDE/training/field/path_3_2_nw.json --xform-rotate 3 --xform-flip-cols
python sturgeon/level2concat.py --outfile _out/field/diff/in_0_15_10x.lvl --pad-between 2 --pad-around _ --game 0 1 2 X --jsonfile stwfc/AIIDE/training/field/path_3_2_nw.json --xform-rotate 3 --xform-flip-rows --xform-flip-cols

# get tileset

python sturgeon/input2tile.py --outfile _out/field/diff/field.tileset --out-tileset --textfile _out/field/diff/in_*.lvl

# make tile and scheme files for each height

python sturgeon/input2tile.py --outfile _out/field/diff/field_0_10x.tile --textfile _out/field/diff/in_*_10x.lvl --game 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 --tileset _out/field/diff/field.tileset

python sturgeon/input2tile.py --outfile _out/field/diff/field_G_10x.tile --textfile _out/field/diff/in_*_10x.lvl --gamefile _out/field/diff/in_*_10x.game --tileset _out/field/diff/field.tileset

python sturgeon/tile2scheme.py --outfile _out/field/diff/field-P0_10x.scheme --tilefile _out/field/diff/field_0_10x.tile --pattern 0=block-noout,3

python sturgeon/tile2scheme.py --outfile _out/field/diff/field-PG_10x.scheme --tilefile _out/field/diff/field_G_10x.tile --pattern 2=block-noout,3 X=single

python sturgeon/scheme2merge.py --outfile _out/field/diff/field-P.scheme --schemefile _out/field/diff/field-P0_10x.scheme _out/field/diff/field-PG_10x.scheme

python sturgeon/tilediff2scheme.py --outfile _out/field/diff/field-D_10x.scheme --tilefile _out/field/diff/field_G_10x.tile --diff-offset-row 12 --game 1

# remap scheme files to output height and merge

python sturgeon/scheme2merge.py --outfile _out/field/diff/field-D_6x-A.scheme --schemefile _out/field/diff/field-D_10x.scheme --remap-row " -13,-11=4" " -1,1=0" "11,13=-4"
python sturgeon/scheme2merge.py --outfile _out/field/diff/field_6x.scheme --schemefile _out/field/diff/field-P.scheme _out/field/diff/field-D_6x-A.scheme --remove-void

# create tag file and text constraint

python sturgeon/level2concat.py --outfile _out/field/diff/field_6x6x6.tag --pad-between 2 --size 6 6 --term-inst 6 --game 0 1 2 X
python sturgeon/level2concat.py --outfile _out/field/diff/field_6x6x6.lvl --pad-between 2 --size 4 4 --term-inst 6 --pad-around _

# generate level

for ii in `seq -f '%03g' 0 2`; do
    python sturgeon/scheme2output.py --outfile _out/field/diff/field \
	   --schemefile _out/field/diff/field_6x.scheme \
	   --solver pysat-gluecard41 --out-result-none --out-tlvl-none \
	   --pattern-hard --pattern-ignore-no-in \
	   --custom text-count 0 0 8 8 "P" 1 1 hard \
	   --custom text-count 0 0 6 6 "D" 1 1 hard \
	   --custom text-level _out/field/diff/field_6x6x6.lvl hard \
	   --tagfile _out/field/diff/field_6x6x6.tag \
	   --gamefile _out/field/diff/field_6x6x6.game \
	   --pattern-single \
	   --random ${ii}
done

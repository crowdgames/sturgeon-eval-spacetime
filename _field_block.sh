set -ex

rm -rf _out/field/block
mkdir -p _out/field/block

# make transformed and concatenated levels

python sturgeon/level2concat.py --outfile _out/field/block/in_0_00_10x.lvl --pad-between 2 --pad-around _ --pad-end T --jsonfile stwfc/AIIDE/training/field/path_3_2_nw.json
python sturgeon/level2concat.py --outfile _out/field/block/in_0_01_10x.lvl --pad-between 2 --pad-around _ --pad-end T --jsonfile stwfc/AIIDE/training/field/path_3_2_nw.json --xform-flip-rows
python sturgeon/level2concat.py --outfile _out/field/block/in_0_02_10x.lvl --pad-between 2 --pad-around _ --pad-end T --jsonfile stwfc/AIIDE/training/field/path_3_2_nw.json --xform-flip-cols
python sturgeon/level2concat.py --outfile _out/field/block/in_0_03_10x.lvl --pad-between 2 --pad-around _ --pad-end T --jsonfile stwfc/AIIDE/training/field/path_3_2_nw.json --xform-flip-rows --xform-flip-cols

python sturgeon/level2concat.py --outfile _out/field/block/in_0_04_10x.lvl --pad-between 2 --pad-around _ --pad-end T --jsonfile stwfc/AIIDE/training/field/path_3_2_nw.json --xform-rotate 1
python sturgeon/level2concat.py --outfile _out/field/block/in_0_05_10x.lvl --pad-between 2 --pad-around _ --pad-end T --jsonfile stwfc/AIIDE/training/field/path_3_2_nw.json --xform-rotate 1 --xform-flip-rows
python sturgeon/level2concat.py --outfile _out/field/block/in_0_06_10x.lvl --pad-between 2 --pad-around _ --pad-end T --jsonfile stwfc/AIIDE/training/field/path_3_2_nw.json --xform-rotate 1 --xform-flip-cols
python sturgeon/level2concat.py --outfile _out/field/block/in_0_07_10x.lvl --pad-between 2 --pad-around _ --pad-end T --jsonfile stwfc/AIIDE/training/field/path_3_2_nw.json --xform-rotate 1 --xform-flip-rows --xform-flip-cols

python sturgeon/level2concat.py --outfile _out/field/block/in_0_08_10x.lvl --pad-between 2 --pad-around _ --pad-end T --jsonfile stwfc/AIIDE/training/field/path_3_2_nw.json --xform-rotate 2
python sturgeon/level2concat.py --outfile _out/field/block/in_0_09_10x.lvl --pad-between 2 --pad-around _ --pad-end T --jsonfile stwfc/AIIDE/training/field/path_3_2_nw.json --xform-rotate 2 --xform-flip-rows
python sturgeon/level2concat.py --outfile _out/field/block/in_0_10_10x.lvl --pad-between 2 --pad-around _ --pad-end T --jsonfile stwfc/AIIDE/training/field/path_3_2_nw.json --xform-rotate 2 --xform-flip-cols
python sturgeon/level2concat.py --outfile _out/field/block/in_0_11_10x.lvl --pad-between 2 --pad-around _ --pad-end T --jsonfile stwfc/AIIDE/training/field/path_3_2_nw.json --xform-rotate 2 --xform-flip-rows --xform-flip-cols

python sturgeon/level2concat.py --outfile _out/field/block/in_0_12_10x.lvl --pad-between 2 --pad-around _ --pad-end T --jsonfile stwfc/AIIDE/training/field/path_3_2_nw.json --xform-rotate 3
python sturgeon/level2concat.py --outfile _out/field/block/in_0_13_10x.lvl --pad-between 2 --pad-around _ --pad-end T --jsonfile stwfc/AIIDE/training/field/path_3_2_nw.json --xform-rotate 3 --xform-flip-rows
python sturgeon/level2concat.py --outfile _out/field/block/in_0_14_10x.lvl --pad-between 2 --pad-around _ --pad-end T --jsonfile stwfc/AIIDE/training/field/path_3_2_nw.json --xform-rotate 3 --xform-flip-cols
python sturgeon/level2concat.py --outfile _out/field/block/in_0_15_10x.lvl --pad-between 2 --pad-around _ --pad-end T --jsonfile stwfc/AIIDE/training/field/path_3_2_nw.json --xform-rotate 3 --xform-flip-rows --xform-flip-cols

# get tileset

python sturgeon/input2tile.py --outfile _out/field/block/field.tileset --out-tileset --textfile _out/field/block/in_*.lvl

# make tile and scheme files for each height

python sturgeon/input2tile.py --outfile _out/field/block/field_10x.tile --textfile _out/field/block/in_*_10x.lvl --tileset _out/field/block/field.tileset

python sturgeon/tile2scheme.py --outfile _out/field/block/field_10x.scheme --tilefile _out/field/block/field_10x.tile --pattern block-rst-noout,3,3,2,12

# remap scheme files to output height and merge

python sturgeon/scheme2merge.py --outfile _out/field/block/field_6x-A.scheme --schemefile _out/field/block/field_10x.scheme --remap-row "0,2=0" "12,14=-4"
python sturgeon/scheme2merge.py --outfile _out/field/block/field_6x.scheme --schemefile _out/field/block/field_6x-A.scheme --remove-void

# create tag file and text constraint

python sturgeon/level2concat.py --outfile _out/field/block/field_6x6x7.tag --pad-between 2 --size 6 6 --term-inst 7
python sturgeon/level2concat.py --outfile _out/field/block/field_6x6x7.lvl --pad-between 2 --size 4 4 --term-inst 6 --pad-around _ --pad-end T

# generate levels

for ii in `seq -f '%03g' 0 2`; do
    python sturgeon/scheme2output.py --outfile _out/field/block/field \
	   --schemefile _out/field/block/field_6x.scheme \
	   --solver pysat-gluecard41 --out-result-none --out-tlvl-none \
	   --pattern-hard --pattern-ignore-no-in \
	   --custom text-count 0 0 6 6 "P" 1 1 hard \
	   --custom text-count 0 0 6 6 "D" 1 1 hard \
	   --custom text-level _out/field/block/field_6x6x7.lvl hard \
	   --tagfile _out/field/block/field_6x6x7.tag \
	   --random ${ii}
done

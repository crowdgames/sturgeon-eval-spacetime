set -ex

if [[ $# -ne 1 ]]; then exit; fi
count="$1"

rm -rf _out/cmp/field/block
mkdir -p _out/cmp/field/block

# make transformed and concatenated levels

bash sturgeon/log.sh level2concat.py --outfile _out/cmp/field/block/in_00_10x.lvl --pad-between 2 --pad-around _ --pad-end T --jsonfile stwfc/training_data/field/path_3_2_nw.json
bash sturgeon/log.sh level2concat.py --outfile _out/cmp/field/block/in_01_10x.lvl --pad-between 2 --pad-around _ --pad-end T --jsonfile stwfc/training_data/field/path_3_2_nw.json --xform-flip-rows
bash sturgeon/log.sh level2concat.py --outfile _out/cmp/field/block/in_02_10x.lvl --pad-between 2 --pad-around _ --pad-end T --jsonfile stwfc/training_data/field/path_3_2_nw.json --xform-flip-cols
bash sturgeon/log.sh level2concat.py --outfile _out/cmp/field/block/in_03_10x.lvl --pad-between 2 --pad-around _ --pad-end T --jsonfile stwfc/training_data/field/path_3_2_nw.json --xform-flip-rows --xform-flip-cols

bash sturgeon/log.sh level2concat.py --outfile _out/cmp/field/block/in_04_10x.lvl --pad-between 2 --pad-around _ --pad-end T --jsonfile stwfc/training_data/field/path_3_2_nw.json --xform-rotate 1
bash sturgeon/log.sh level2concat.py --outfile _out/cmp/field/block/in_05_10x.lvl --pad-between 2 --pad-around _ --pad-end T --jsonfile stwfc/training_data/field/path_3_2_nw.json --xform-rotate 1 --xform-flip-rows
bash sturgeon/log.sh level2concat.py --outfile _out/cmp/field/block/in_06_10x.lvl --pad-between 2 --pad-around _ --pad-end T --jsonfile stwfc/training_data/field/path_3_2_nw.json --xform-rotate 1 --xform-flip-cols
bash sturgeon/log.sh level2concat.py --outfile _out/cmp/field/block/in_07_10x.lvl --pad-between 2 --pad-around _ --pad-end T --jsonfile stwfc/training_data/field/path_3_2_nw.json --xform-rotate 1 --xform-flip-rows --xform-flip-cols

bash sturgeon/log.sh level2concat.py --outfile _out/cmp/field/block/in_08_10x.lvl --pad-between 2 --pad-around _ --pad-end T --jsonfile stwfc/training_data/field/path_3_2_nw.json --xform-rotate 2
bash sturgeon/log.sh level2concat.py --outfile _out/cmp/field/block/in_09_10x.lvl --pad-between 2 --pad-around _ --pad-end T --jsonfile stwfc/training_data/field/path_3_2_nw.json --xform-rotate 2 --xform-flip-rows
bash sturgeon/log.sh level2concat.py --outfile _out/cmp/field/block/in_10_10x.lvl --pad-between 2 --pad-around _ --pad-end T --jsonfile stwfc/training_data/field/path_3_2_nw.json --xform-rotate 2 --xform-flip-cols
bash sturgeon/log.sh level2concat.py --outfile _out/cmp/field/block/in_11_10x.lvl --pad-between 2 --pad-around _ --pad-end T --jsonfile stwfc/training_data/field/path_3_2_nw.json --xform-rotate 2 --xform-flip-rows --xform-flip-cols

bash sturgeon/log.sh level2concat.py --outfile _out/cmp/field/block/in_12_10x.lvl --pad-between 2 --pad-around _ --pad-end T --jsonfile stwfc/training_data/field/path_3_2_nw.json --xform-rotate 3
bash sturgeon/log.sh level2concat.py --outfile _out/cmp/field/block/in_13_10x.lvl --pad-between 2 --pad-around _ --pad-end T --jsonfile stwfc/training_data/field/path_3_2_nw.json --xform-rotate 3 --xform-flip-rows
bash sturgeon/log.sh level2concat.py --outfile _out/cmp/field/block/in_14_10x.lvl --pad-between 2 --pad-around _ --pad-end T --jsonfile stwfc/training_data/field/path_3_2_nw.json --xform-rotate 3 --xform-flip-cols
bash sturgeon/log.sh level2concat.py --outfile _out/cmp/field/block/in_15_10x.lvl --pad-between 2 --pad-around _ --pad-end T --jsonfile stwfc/training_data/field/path_3_2_nw.json --xform-rotate 3 --xform-flip-rows --xform-flip-cols

# get tileset

bash sturgeon/log.sh input2tile.py --outfile _out/cmp/field/block/setup_ts.tileset --out-tileset --textfile _out/cmp/field/block/in_*.lvl

# make tile and scheme files for each height

bash sturgeon/log.sh input2tile.py --outfile _out/cmp/field/block/setup_10x.tile --textfile _out/cmp/field/block/in_*_10x.lvl --tileset _out/cmp/field/block/setup_ts.tileset

bash sturgeon/log.sh tile2scheme.py --outfile _out/cmp/field/block/setup_10x.scheme --tilefile _out/cmp/field/block/setup_10x.tile --pattern block-rst-noout,3,3,2,12

# remap scheme files to output height and merge

bash sturgeon/log.sh scheme2merge.py --outfile _out/cmp/field/block/setup_6x-A.scheme --schemefile _out/cmp/field/block/setup_10x.scheme --remap-row "0,2=0" "12,14=-4"
bash sturgeon/log.sh scheme2merge.py --outfile _out/cmp/field/block/setup_6x.scheme --schemefile _out/cmp/field/block/setup_6x-A.scheme --remove-void

# create tag file and text constraint

bash sturgeon/log.sh level2concat.py --outfile _out/cmp/field/block/setup_6x6x7.tag --pad-between 2 --size 6 6 --term-inst 7
bash sturgeon/log.sh level2concat.py --outfile _out/cmp/field/block/setup_6x6x7.lvl --pad-between 2 --size 4 4 --term-inst 6 --pad-around _ --pad-end T

# generate levels

for ii in `seq -f '%02g' 0 $((${count}-1))`; do
    bash sturgeon/log.sh scheme2output.py --outfile _out/cmp/field/block/out_${ii} \
	   --schemefile _out/cmp/field/block/setup_6x.scheme \
	   --out-result-none --out-tlvl-none \
	   --pattern-hard --pattern-ignore-no-in \
	   --custom text-count 0 0 6 6 "P" 1 1 hard \
	   --custom text-count 0 0 6 6 "D" 1 1 hard \
	   --custom text-level _out/cmp/field/block/setup_6x6x7.lvl hard \
	   --tagfile _out/cmp/field/block/setup_6x6x7.tag \
	   --solver pysat-gluecard41 \
	   --random ${ii}
done

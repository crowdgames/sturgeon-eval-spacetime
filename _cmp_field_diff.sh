set -ex

if [[ $# -ne 1 ]]; then exit; fi
count="$1"

rm -rf _out/cmp/field/diff
mkdir -p _out/cmp/field/diff

# make transformed and concatenated levels

bash sturgeon/log.sh level2concat.py --outfile _out/cmp/field/diff/in_00_10x.lvl --pad-between 2 --pad-around _ --game 0 1 2 X --jsonfile stwfc/training_data/field/path_3_2_nw.json
bash sturgeon/log.sh level2concat.py --outfile _out/cmp/field/diff/in_01_10x.lvl --pad-between 2 --pad-around _ --game 0 1 2 X --jsonfile stwfc/training_data/field/path_3_2_nw.json --xform-flip-rows
bash sturgeon/log.sh level2concat.py --outfile _out/cmp/field/diff/in_02_10x.lvl --pad-between 2 --pad-around _ --game 0 1 2 X --jsonfile stwfc/training_data/field/path_3_2_nw.json --xform-flip-cols
bash sturgeon/log.sh level2concat.py --outfile _out/cmp/field/diff/in_03_10x.lvl --pad-between 2 --pad-around _ --game 0 1 2 X --jsonfile stwfc/training_data/field/path_3_2_nw.json --xform-flip-rows --xform-flip-cols

bash sturgeon/log.sh level2concat.py --outfile _out/cmp/field/diff/in_04_10x.lvl --pad-between 2 --pad-around _ --game 0 1 2 X --jsonfile stwfc/training_data/field/path_3_2_nw.json --xform-rotate 1
bash sturgeon/log.sh level2concat.py --outfile _out/cmp/field/diff/in_05_10x.lvl --pad-between 2 --pad-around _ --game 0 1 2 X --jsonfile stwfc/training_data/field/path_3_2_nw.json --xform-rotate 1 --xform-flip-rows
bash sturgeon/log.sh level2concat.py --outfile _out/cmp/field/diff/in_06_10x.lvl --pad-between 2 --pad-around _ --game 0 1 2 X --jsonfile stwfc/training_data/field/path_3_2_nw.json --xform-rotate 1 --xform-flip-cols
bash sturgeon/log.sh level2concat.py --outfile _out/cmp/field/diff/in_07_10x.lvl --pad-between 2 --pad-around _ --game 0 1 2 X --jsonfile stwfc/training_data/field/path_3_2_nw.json --xform-rotate 1 --xform-flip-rows --xform-flip-cols

bash sturgeon/log.sh level2concat.py --outfile _out/cmp/field/diff/in_08_10x.lvl --pad-between 2 --pad-around _ --game 0 1 2 X --jsonfile stwfc/training_data/field/path_3_2_nw.json --xform-rotate 2
bash sturgeon/log.sh level2concat.py --outfile _out/cmp/field/diff/in_09_10x.lvl --pad-between 2 --pad-around _ --game 0 1 2 X --jsonfile stwfc/training_data/field/path_3_2_nw.json --xform-rotate 2 --xform-flip-rows
bash sturgeon/log.sh level2concat.py --outfile _out/cmp/field/diff/in_10_10x.lvl --pad-between 2 --pad-around _ --game 0 1 2 X --jsonfile stwfc/training_data/field/path_3_2_nw.json --xform-rotate 2 --xform-flip-cols
bash sturgeon/log.sh level2concat.py --outfile _out/cmp/field/diff/in_11_10x.lvl --pad-between 2 --pad-around _ --game 0 1 2 X --jsonfile stwfc/training_data/field/path_3_2_nw.json --xform-rotate 2 --xform-flip-rows --xform-flip-cols

bash sturgeon/log.sh level2concat.py --outfile _out/cmp/field/diff/in_12_10x.lvl --pad-between 2 --pad-around _ --game 0 1 2 X --jsonfile stwfc/training_data/field/path_3_2_nw.json --xform-rotate 3
bash sturgeon/log.sh level2concat.py --outfile _out/cmp/field/diff/in_13_10x.lvl --pad-between 2 --pad-around _ --game 0 1 2 X --jsonfile stwfc/training_data/field/path_3_2_nw.json --xform-rotate 3 --xform-flip-rows
bash sturgeon/log.sh level2concat.py --outfile _out/cmp/field/diff/in_14_10x.lvl --pad-between 2 --pad-around _ --game 0 1 2 X --jsonfile stwfc/training_data/field/path_3_2_nw.json --xform-rotate 3 --xform-flip-cols
bash sturgeon/log.sh level2concat.py --outfile _out/cmp/field/diff/in_15_10x.lvl --pad-between 2 --pad-around _ --game 0 1 2 X --jsonfile stwfc/training_data/field/path_3_2_nw.json --xform-rotate 3 --xform-flip-rows --xform-flip-cols

# get tileset

bash sturgeon/log.sh input2tile.py --outfile _out/cmp/field/diff/setup_ts.tileset --out-tileset --textfile _out/cmp/field/diff/in_*.lvl

# make tile and scheme files for each height

bash sturgeon/log.sh input2tile.py --outfile _out/cmp/field/diff/setup_0_10x.tile --textfile _out/cmp/field/diff/in_*_10x.lvl --game 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 --tileset _out/cmp/field/diff/setup_ts.tileset

bash sturgeon/log.sh input2tile.py --outfile _out/cmp/field/diff/setup_G_10x.tile --textfile _out/cmp/field/diff/in_*_10x.lvl --gamefile _out/cmp/field/diff/in_*_10x.game --tileset _out/cmp/field/diff/setup_ts.tileset

bash sturgeon/log.sh tile2scheme.py --outfile _out/cmp/field/diff/setup_P0_10x.scheme --tilefile _out/cmp/field/diff/setup_0_10x.tile --pattern 0=block-noout,3

bash sturgeon/log.sh tile2scheme.py --outfile _out/cmp/field/diff/setup_PG_10x.scheme --tilefile _out/cmp/field/diff/setup_G_10x.tile --pattern 2=block-noout,3 X=single

bash sturgeon/log.sh scheme2merge.py --outfile _out/cmp/field/diff/setup_P.scheme --schemefile _out/cmp/field/diff/setup_P0_10x.scheme _out/cmp/field/diff/setup_PG_10x.scheme

bash sturgeon/log.sh tilediff2scheme.py --outfile _out/cmp/field/diff/setup_D_10x.scheme --tilefile _out/cmp/field/diff/setup_G_10x.tile --diff-offset-row 12 --game 1

# remap scheme files to output height and merge

bash sturgeon/log.sh scheme2merge.py --outfile _out/cmp/field/diff/setup_D_6x-A.scheme --schemefile _out/cmp/field/diff/setup_D_10x.scheme --remap-row " -13,-11=4" " -1,1=0" "11,13=-4"
bash sturgeon/log.sh scheme2merge.py --outfile _out/cmp/field/diff/setup_6x.scheme --schemefile _out/cmp/field/diff/setup_P.scheme _out/cmp/field/diff/setup_D_6x-A.scheme --remove-void

# create tag file and text constraint

bash sturgeon/log.sh level2concat.py --outfile _out/cmp/field/diff/setup_6x6x6.tag --pad-between 2 --size 6 6 --term-inst 6 --game 0 1 2 X
bash sturgeon/log.sh level2concat.py --outfile _out/cmp/field/diff/setup_6x6x6.lvl --pad-between 2 --size 4 4 --term-inst 6 --pad-around _

# generate level

for ii in `seq -f '%02g' 0 $((${count}-1))`; do
    bash sturgeon/log.sh scheme2output.py --outfile _out/cmp/field/diff/out_${ii} \
	   --schemefile _out/cmp/field/diff/setup_6x.scheme \
	   --out-result-none --out-tlvl-none \
	   --pattern-hard --pattern-ignore-no-in \
	   --custom text-count 0 0 8 8 "P" 1 1 hard \
	   --custom text-count 0 0 6 6 "D" 1 1 hard \
	   --custom text-level _out/cmp/field/diff/setup_6x6x6.lvl hard \
	   --tagfile _out/cmp/field/diff/setup_6x6x6.tag \
	   --gamefile _out/cmp/field/diff/setup_6x6x6.game \
	   --solver pysat-gluecard41 \
	   --pattern-single \
	   --random ${ii}
done

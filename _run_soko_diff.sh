set -ex

if [[ $# -ne 1 ]]; then exit; fi
count="$1"

rm -rf _out/run/soko/*
mkdir -p _out/run/soko/setup
mkdir -p _out/run/soko/9x9x10/diff
mkdir -p _out/run/soko/12x12x20/diff

# make transformed and concatenated levels

bash sturgeon/log.sh level2concat.py --outfile _out/run/soko/setup/in_00_11x.lvl --pad-between 1 --game 0 1 2 X --term-inst 3 --jsonfile setup/soko_og.json
bash sturgeon/log.sh level2concat.py --outfile _out/run/soko/setup/in_01_11x.lvl --pad-between 1 --game 0 1 2 X --term-inst 3 --jsonfile setup/soko_og.json --xform-flip-rows
bash sturgeon/log.sh level2concat.py --outfile _out/run/soko/setup/in_02_11x.lvl --pad-between 1 --game 0 1 2 X --term-inst 3 --jsonfile setup/soko_og.json --xform-flip-cols
bash sturgeon/log.sh level2concat.py --outfile _out/run/soko/setup/in_03_11x.lvl --pad-between 1 --game 0 1 2 X --term-inst 3 --jsonfile setup/soko_og.json --xform-flip-rows --xform-flip-cols

bash sturgeon/log.sh level2concat.py --outfile _out/run/soko/setup/in_04_19x.lvl --pad-between 1 --game 0 1 2 X --term-inst 3 --jsonfile setup/soko_og.json --xform-rotate 1
bash sturgeon/log.sh level2concat.py --outfile _out/run/soko/setup/in_05_19x.lvl --pad-between 1 --game 0 1 2 X --term-inst 3 --jsonfile setup/soko_og.json --xform-rotate 1 --xform-flip-rows
bash sturgeon/log.sh level2concat.py --outfile _out/run/soko/setup/in_06_19x.lvl --pad-between 1 --game 0 1 2 X --term-inst 3 --jsonfile setup/soko_og.json --xform-rotate 1 --xform-flip-cols
bash sturgeon/log.sh level2concat.py --outfile _out/run/soko/setup/in_07_19x.lvl --pad-between 1 --game 0 1 2 X --term-inst 3 --jsonfile setup/soko_og.json --xform-rotate 1 --xform-flip-rows --xform-flip-cols

bash sturgeon/log.sh level2concat.py --outfile _out/run/soko/setup/in_08_11x.lvl --pad-between 1 --game 0 1 2 X --term-inst 3 --jsonfile setup/soko_og.json --xform-rotate 2
bash sturgeon/log.sh level2concat.py --outfile _out/run/soko/setup/in_09_11x.lvl --pad-between 1 --game 0 1 2 X --term-inst 3 --jsonfile setup/soko_og.json --xform-rotate 2 --xform-flip-rows
bash sturgeon/log.sh level2concat.py --outfile _out/run/soko/setup/in_10_11x.lvl --pad-between 1 --game 0 1 2 X --term-inst 3 --jsonfile setup/soko_og.json --xform-rotate 2 --xform-flip-cols
bash sturgeon/log.sh level2concat.py --outfile _out/run/soko/setup/in_11_11x.lvl --pad-between 1 --game 0 1 2 X --term-inst 3 --jsonfile setup/soko_og.json --xform-rotate 2 --xform-flip-rows --xform-flip-cols

bash sturgeon/log.sh level2concat.py --outfile _out/run/soko/setup/in_12_19x.lvl --pad-between 1 --game 0 1 2 X --term-inst 3 --jsonfile setup/soko_og.json --xform-rotate 3
bash sturgeon/log.sh level2concat.py --outfile _out/run/soko/setup/in_13_19x.lvl --pad-between 1 --game 0 1 2 X --term-inst 3 --jsonfile setup/soko_og.json --xform-rotate 3 --xform-flip-rows
bash sturgeon/log.sh level2concat.py --outfile _out/run/soko/setup/in_14_19x.lvl --pad-between 1 --game 0 1 2 X --term-inst 3 --jsonfile setup/soko_og.json --xform-rotate 3 --xform-flip-cols
bash sturgeon/log.sh level2concat.py --outfile _out/run/soko/setup/in_15_19x.lvl --pad-between 1 --game 0 1 2 X --term-inst 3 --jsonfile setup/soko_og.json --xform-rotate 3 --xform-flip-rows --xform-flip-cols

# get tileset

bash sturgeon/log.sh input2tile.py --outfile _out/run/soko/setup/setup_ts.tileset --out-tileset --textfile setup/soko_og-tiles.lvl --imagefile setup/soko_og-tiles.png

# make tile and scheme files for each height

bash sturgeon/log.sh input2tile.py --outfile _out/run/soko/setup/setup_11x.tile --textfile _out/run/soko/setup/in_*_11x.lvl --gamefile _out/run/soko/setup/in_*_11x.game --tileset _out/run/soko/setup/setup_ts.tileset --text-key-only
bash sturgeon/log.sh input2tile.py --outfile _out/run/soko/setup/setup_19x.tile --textfile _out/run/soko/setup/in_*_19x.lvl --gamefile _out/run/soko/setup/in_*_19x.game --tileset _out/run/soko/setup/setup_ts.tileset --text-key-only

bash sturgeon/log.sh tile2scheme.py --outfile _out/run/soko/setup/setup_P_11x.scheme --tilefile _out/run/soko/setup/setup_11x.tile --pattern 0=single 2=single X=single
bash sturgeon/log.sh tile2scheme.py --outfile _out/run/soko/setup/setup_P_19x.scheme --tilefile _out/run/soko/setup/setup_19x.tile --pattern 0=single 2=single X=single

bash sturgeon/log.sh scheme2merge.py --outfile _out/run/soko/setup/setup_P.scheme --schemefile _out/run/soko/setup/setup_P_19x.scheme _out/run/soko/setup/setup_P_11x.scheme

bash sturgeon/log.sh tilediff2scheme.py --outfile _out/run/soko/setup/setup_D_11x.scheme --tilefile _out/run/soko/setup/setup_11x.tile --diff-offset-row 12 --game 1
bash sturgeon/log.sh tilediff2scheme.py --outfile _out/run/soko/setup/setup_D_19x.scheme --tilefile _out/run/soko/setup/setup_19x.tile --diff-offset-row 20 --game 1

# remap scheme files to output height and merge 9 x 9 x 10

bash sturgeon/log.sh scheme2merge.py --outfile _out/run/soko/setup/setup_D_9x-B.scheme --schemefile _out/run/soko/setup/setup_D_11x.scheme --remap-row " -14,-10=2" " -2,2=0" "10,14=-2"
bash sturgeon/log.sh scheme2merge.py --outfile _out/run/soko/setup/setup_D_9x-A.scheme --schemefile _out/run/soko/setup/setup_D_19x.scheme --remap-row " -22,-18=10" " -2,2=0" "18,22=-10"
bash sturgeon/log.sh scheme2merge.py --outfile _out/run/soko/setup/setup_9x.scheme --schemefile _out/run/soko/setup/setup_P.scheme _out/run/soko/setup/setup_D_9x-A.scheme _out/run/soko/setup/setup_D_9x-B.scheme --remove-void

# create tag file and text constraint

bash sturgeon/log.sh level2concat.py --outfile _out/run/soko/setup/setup_9x9x10.tag --pad-between 1 --size 9 9 --term-inst 10 --game 0 1 2 X
bash sturgeon/log.sh level2concat.py --outfile _out/run/soko/setup/setup_9x9x10.lvl --pad-between 1 --size 7 7 --term-inst 10 --game 0 1 2 X --pad-around W

# generate level

for ii in `seq -f '%02g' 0 $((${count}-1))`; do
    bash sturgeon/log.sh scheme2output.py --outfile _out/run/soko/9x9x10/diff/out_${ii} \
	   --schemefile _out/run/soko/setup/setup_9x.scheme \
	   --out-result-none --out-tlvl-none \
	   --pattern-hard --pattern-ignore-no-in \
	   --custom text-count 0 0 9 9 "P" 1 1 hard \
	   --custom text-count 0 0 9 9 "B" 2 2 hard \
	   --custom text-level _out/run/soko/setup/setup_9x9x10.lvl hard \
	   --tagfile _out/run/soko/setup/setup_9x9x10.tag \
	   --gamefile _out/run/soko/setup/setup_9x9x10.game \
	   --solver pysat-gluecard41 \
	   --pattern-single \
	   --random ${ii}
done



# remap scheme files to output height and merge 12 x 12 x 20

bash sturgeon/log.sh scheme2merge.py --outfile _out/run/soko/setup/setup_D_12x-B.scheme --schemefile _out/run/soko/setup/setup_D_11x.scheme --remap-row " -14,-10=-1" " -2,2=0" "10,14=1"
bash sturgeon/log.sh scheme2merge.py --outfile _out/run/soko/setup/setup_D_12x-A.scheme --schemefile _out/run/soko/setup/setup_D_19x.scheme --remap-row " -22,-18=7" " -2,2=0" "18,22=-7"
bash sturgeon/log.sh scheme2merge.py --outfile _out/run/soko/setup/setup_12x.scheme --schemefile _out/run/soko/setup/setup_P.scheme _out/run/soko/setup/setup_D_12x-A.scheme _out/run/soko/setup/setup_D_12x-B.scheme --remove-void

# create tag file and text constraint

bash sturgeon/log.sh level2concat.py --outfile _out/run/soko/setup/setup_12x12x20.tag --pad-between 1 --size 12 12 --term-inst 20 --game 0 1 2 X
bash sturgeon/log.sh level2concat.py --outfile _out/run/soko/setup/setup_12x12x20.lvl --pad-between 1 --size 10 10 --term-inst 20 --game 0 1 2 X --pad-around W

# generate level

for ii in `seq -f '%02g' 0 $((${count}-1))`; do
    bash sturgeon/log.sh scheme2output.py --outfile _out/run/soko/12x12x20/diff/out_${ii} \
	   --schemefile _out/run/soko/setup/setup_12x.scheme \
	   --out-result-none --out-tlvl-none \
	   --pattern-hard --pattern-ignore-no-in \
	   --custom text-count 0 0 12 12 "P" 1 1 hard \
	   --custom text-count 0 0 12 12 "B" 2 3 hard \
	   --custom text-level _out/run/soko/setup/setup_12x12x20.lvl hard \
	   --tagfile _out/run/soko/setup/setup_12x12x20.tag \
	   --gamefile _out/run/soko/setup/setup_12x12x20.game \
	   --solver pysat-gluecard41 \
	   --pattern-single \
	   --random ${ii}
done
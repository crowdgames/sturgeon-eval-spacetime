set -ex

if [[ $# -ne 1 ]]; then exit; fi
count="$1"

rm -rf _out/run/soko/diff
mkdir -p _out/run/soko/diff

# make transformed and concatenated levels

bash sturgeon/log.sh level2concat.py --outfile _out/run/soko/diff/in_00_11x.lvl --pad-between 2 --game 0 1 2 X --jsonfile setup/soko_og.json
bash sturgeon/log.sh level2concat.py --outfile _out/run/soko/diff/in_01_11x.lvl --pad-between 2 --game 0 1 2 X --jsonfile setup/soko_og.json --xform-flip-rows
bash sturgeon/log.sh level2concat.py --outfile _out/run/soko/diff/in_02_11x.lvl --pad-between 2 --game 0 1 2 X --jsonfile setup/soko_og.json --xform-flip-cols
bash sturgeon/log.sh level2concat.py --outfile _out/run/soko/diff/in_03_11x.lvl --pad-between 2 --game 0 1 2 X --jsonfile setup/soko_og.json --xform-flip-rows --xform-flip-cols

bash sturgeon/log.sh level2concat.py --outfile _out/run/soko/diff/in_04_19x.lvl --pad-between 2 --game 0 1 2 X --jsonfile setup/soko_og.json --xform-rotate 1
bash sturgeon/log.sh level2concat.py --outfile _out/run/soko/diff/in_05_19x.lvl --pad-between 2 --game 0 1 2 X --jsonfile setup/soko_og.json --xform-rotate 1 --xform-flip-rows
bash sturgeon/log.sh level2concat.py --outfile _out/run/soko/diff/in_06_19x.lvl --pad-between 2 --game 0 1 2 X --jsonfile setup/soko_og.json --xform-rotate 1 --xform-flip-cols
bash sturgeon/log.sh level2concat.py --outfile _out/run/soko/diff/in_07_19x.lvl --pad-between 2 --game 0 1 2 X --jsonfile setup/soko_og.json --xform-rotate 1 --xform-flip-rows --xform-flip-cols

bash sturgeon/log.sh level2concat.py --outfile _out/run/soko/diff/in_08_11x.lvl --pad-between 2 --game 0 1 2 X --jsonfile setup/soko_og.json --xform-rotate 2
bash sturgeon/log.sh level2concat.py --outfile _out/run/soko/diff/in_09_11x.lvl --pad-between 2 --game 0 1 2 X --jsonfile setup/soko_og.json --xform-rotate 2 --xform-flip-rows
bash sturgeon/log.sh level2concat.py --outfile _out/run/soko/diff/in_10_11x.lvl --pad-between 2 --game 0 1 2 X --jsonfile setup/soko_og.json --xform-rotate 2 --xform-flip-cols
bash sturgeon/log.sh level2concat.py --outfile _out/run/soko/diff/in_11_11x.lvl --pad-between 2 --game 0 1 2 X --jsonfile setup/soko_og.json --xform-rotate 2 --xform-flip-rows --xform-flip-cols

bash sturgeon/log.sh level2concat.py --outfile _out/run/soko/diff/in_12_19x.lvl --pad-between 2 --game 0 1 2 X --jsonfile setup/soko_og.json --xform-rotate 3
bash sturgeon/log.sh level2concat.py --outfile _out/run/soko/diff/in_13_19x.lvl --pad-between 2 --game 0 1 2 X --jsonfile setup/soko_og.json --xform-rotate 3 --xform-flip-rows
bash sturgeon/log.sh level2concat.py --outfile _out/run/soko/diff/in_14_19x.lvl --pad-between 2 --game 0 1 2 X --jsonfile setup/soko_og.json --xform-rotate 3 --xform-flip-cols
bash sturgeon/log.sh level2concat.py --outfile _out/run/soko/diff/in_15_19x.lvl --pad-between 2 --game 0 1 2 X --jsonfile setup/soko_og.json --xform-rotate 3 --xform-flip-rows --xform-flip-cols

# get tileset

bash sturgeon/log.sh input2tile.py --outfile _out/run/soko/diff/setup_ts.tileset --out-tileset --textfile setup/soko_og-tiles.lvl --imagefile setup/soko_og-tiles.png

# make tile and scheme files for each height

bash sturgeon/log.sh input2tile.py --outfile _out/run/soko/diff/setup_11x.tile --textfile _out/run/soko/diff/in_*_11x.lvl --gamefile _out/run/soko/diff/in_*_11x.game --tileset _out/run/soko/diff/setup_ts.tileset --text-key-only
bash sturgeon/log.sh input2tile.py --outfile _out/run/soko/diff/setup_19x.tile --textfile _out/run/soko/diff/in_*_19x.lvl --gamefile _out/run/soko/diff/in_*_19x.game --tileset _out/run/soko/diff/setup_ts.tileset --text-key-only

bash sturgeon/log.sh tile2scheme.py --outfile _out/run/soko/diff/setup_P_11x.scheme --tilefile _out/run/soko/diff/setup_11x.tile --pattern 0=single 2=single X=single
bash sturgeon/log.sh tile2scheme.py --outfile _out/run/soko/diff/setup_P_19x.scheme --tilefile _out/run/soko/diff/setup_19x.tile --pattern 0=single 2=single X=single

bash sturgeon/log.sh scheme2merge.py --outfile _out/run/soko/diff/setup_P.scheme --schemefile _out/run/soko/diff/setup_P_19x.scheme _out/run/soko/diff/setup_P_11x.scheme

bash sturgeon/log.sh tilediff2scheme.py --outfile _out/run/soko/diff/setup_D_11x.scheme --tilefile _out/run/soko/diff/setup_11x.tile --diff-offset-row 13 --game 1
bash sturgeon/log.sh tilediff2scheme.py --outfile _out/run/soko/diff/setup_D_19x.scheme --tilefile _out/run/soko/diff/setup_19x.tile --diff-offset-row 21 --game 1

# remap scheme files to output height and merge

bash sturgeon/log.sh scheme2merge.py --outfile _out/run/soko/diff/setup_D_9x-B.scheme --schemefile _out/run/soko/diff/setup_D_11x.scheme --remap-row " -15,-11=2" " -2,2=0" "11,15=-2"
bash sturgeon/log.sh scheme2merge.py --outfile _out/run/soko/diff/setup_D_9x-A.scheme --schemefile _out/run/soko/diff/setup_D_19x.scheme --remap-row " -23,-19=10" " -2,2=0" "19,23=-10"
bash sturgeon/log.sh scheme2merge.py --outfile _out/run/soko/diff/setup_9x.scheme --schemefile _out/run/soko/diff/setup_P.scheme _out/run/soko/diff/setup_D_9x-A.scheme _out/run/soko/diff/setup_D_9x-B.scheme --remove-void

# create tag file and text constraint

bash sturgeon/log.sh level2concat.py --outfile _out/run/soko/diff/setup_9x9x15.tag --pad-between 2 --size 9 9 --term-inst 10 --game 0 1 2 X
bash sturgeon/log.sh level2concat.py --outfile _out/run/soko/diff/setup_9x9x15.lvl --pad-between 2 --size 7 7 --term-inst 10 --game 0 1 2 X --pad-around W

# generate level

for ii in `seq -f '%02g' 0 $((${count}-1))`; do
    bash sturgeon/log.sh scheme2output.py --outfile _out/run/soko/diff/out_${ii} \
	   --schemefile _out/run/soko/diff/setup_9x.scheme \
	   --out-result-none --out-tlvl-none \
	   --pattern-hard --pattern-ignore-no-in \
	   --custom text-count 0 0 9 9 "P" 1 1 hard \
	   --custom text-count 0 0 9 9 "B" 2 2 hard \
	   --custom text-level _out/run/soko/diff/setup_9x9x15.lvl hard \
	   --tagfile _out/run/soko/diff/setup_9x9x15.tag \
	   --gamefile _out/run/soko/diff/setup_9x9x15.game \
	   --solver pysat-gluecard41 \
	   --pattern-single \
	   --random ${ii}
done

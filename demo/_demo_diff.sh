set -ex

if [[ $# -ne 1 ]]; then exit; fi
count="$1"

rm -rf _out/diff
mkdir -p _out/diff

bash ../sturgeon/log.sh input2tile.py --outfile _out/diff/setup.tile --textfile setup/demo.lvl --gamefile setup/demo.game

bash ../sturgeon/log.sh tile2scheme.py --outfile _out/diff/setup_P.scheme --tilefile _out/diff/setup.tile --pattern 0=single 2=single X=single
bash ../sturgeon/log.sh tilediff2scheme.py --outfile _out/diff/setup_D.scheme --tilefile _out/diff/setup.tile --diff-offset-row 2 --game 1

bash ../sturgeon/log.sh scheme2merge.py --outfile _out/diff/setup.scheme --schemefile _out/diff/setup_P.scheme _out/diff/setup_D.scheme --remove-void

# create tag file and text constraint

bash ../sturgeon/log.sh level2concat.py --outfile _out/diff/setup_1x7x7.tag --pad-between 1 --size 1 7 --term-inst 7 --game 0 1 2 X

# generate level

for ii in `seq -f '%02g' 0 $((${count}-1))`; do
    bash ../sturgeon/log.sh scheme2output.py --outfile _out/diff/out_${ii} \
	   --schemefile _out/diff/setup.scheme \
	   --out-result-none --out-tlvl-none \
	   --pattern-hard --pattern-ignore-no-in \
	   --custom text-count 0 0 1 7 "P" 1 1 hard \
	   --custom text-count 0 0 1 1 "P" 1 1 hard \
	   --custom text-count 0 0 1 7 "D" 1 1 hard \
	   --custom text-count 0 6 1 7 "D" 1 1 hard \
	   --tagfile _out/diff/setup_1x7x7.tag \
	   --gamefile _out/diff/setup_1x7x7.game \
	   --solver pysat-gluecard41 \
	   --pattern-single \
	   --random ${ii}
done

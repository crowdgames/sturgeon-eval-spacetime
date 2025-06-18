set -ex

if [[ $# -ne 1 ]]; then exit; fi
count="$1"

rm -rf _out/block
mkdir -p _out/block

bash ../sturgeon/log.sh level2concat.py --outfile _out/block/in.lvl --pad-between 1 --pad-end T --term-inst 3 --jsonfile setup/demo.json

bash ../sturgeon/log.sh input2tile.py --outfile _out/block/setup.tile --textfile _out/block/in.lvl

bash ../sturgeon/log.sh tile2scheme.py --outfile _out/block/setup_P.scheme --tilefile _out/block/setup.tile --pattern block-rst-noout,1,2,2,2

bash ../sturgeon/log.sh scheme2merge.py --outfile _out/block/setup.scheme --schemefile _out/block/setup_P.scheme --remove-void

# create tag file and text constraint

bash ../sturgeon/log.sh level2concat.py --outfile _out/block/setup_1x8x7.tag --pad-between 1 --size 1 8 --term-inst 7
bash ../sturgeon/log.sh level2concat.py --outfile _out/block/setup_1x8x7.lvl --pad-between 1 --size 1 6 --term-inst 6 --pad-around _ _ --pad-end T

# generate level

for ii in `seq -f '%02g' 0 $((${count}-1))`; do
    bash ../sturgeon/log.sh scheme2output.py --outfile _out/block/out_${ii} \
	   --schemefile _out/block/setup.scheme \
	   --out-result-none --out-tlvl-none \
	   --pattern-hard --pattern-ignore-no-in \
	   --custom text-count 0 0 1 8 "P" 1 1 hard \
	   --custom text-count 0 1 1 2 "P" 1 1 hard \
	   --custom text-count 0 0 1 8 "D" 1 1 hard \
	   --custom text-count 0 6 1 7 "D" 1 1 hard \
	   --custom text-level _out/block/setup_1x8x7.lvl hard \
	   --tagfile _out/block/setup_1x8x7.tag \
	   --solver pysat-gluecard41 \
	   --random ${ii}
done

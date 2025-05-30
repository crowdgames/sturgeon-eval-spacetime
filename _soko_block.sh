set -ex

rm -rf work
mkdir -p work

# make transformed and concatenated levels

python sturgeon/level2concat.py --outfile work/in_0_00_8x.lvl --pad-between 2 --pad-around _ --pad-end T --jsonfile setup/soko/soko_0.json
python sturgeon/level2concat.py --outfile work/in_0_01_8x.lvl --pad-between 2 --pad-around _ --pad-end T --jsonfile setup/soko/soko_0.json --xform-flip-rows
python sturgeon/level2concat.py --outfile work/in_0_02_8x.lvl --pad-between 2 --pad-around _ --pad-end T --jsonfile setup/soko/soko_0.json --xform-flip-cols
python sturgeon/level2concat.py --outfile work/in_0_03_8x.lvl --pad-between 2 --pad-around _ --pad-end T --jsonfile setup/soko/soko_0.json --xform-flip-rows --xform-flip-cols

python sturgeon/level2concat.py --outfile work/in_0_04_7x.lvl --pad-between 2 --pad-around _ --pad-end T --jsonfile setup/soko/soko_0.json --xform-rotate 1
python sturgeon/level2concat.py --outfile work/in_0_05_7x.lvl --pad-between 2 --pad-around _ --pad-end T --jsonfile setup/soko/soko_0.json --xform-rotate 1 --xform-flip-rows
python sturgeon/level2concat.py --outfile work/in_0_06_7x.lvl --pad-between 2 --pad-around _ --pad-end T --jsonfile setup/soko/soko_0.json --xform-rotate 1 --xform-flip-cols
python sturgeon/level2concat.py --outfile work/in_0_07_7x.lvl --pad-between 2 --pad-around _ --pad-end T --jsonfile setup/soko/soko_0.json --xform-rotate 1 --xform-flip-rows --xform-flip-cols

python sturgeon/level2concat.py --outfile work/in_0_08_8x.lvl --pad-between 2 --pad-around _ --pad-end T --jsonfile setup/soko/soko_0.json --xform-rotate 2
python sturgeon/level2concat.py --outfile work/in_0_09_8x.lvl --pad-between 2 --pad-around _ --pad-end T --jsonfile setup/soko/soko_0.json --xform-rotate 2 --xform-flip-rows
python sturgeon/level2concat.py --outfile work/in_0_10_8x.lvl --pad-between 2 --pad-around _ --pad-end T --jsonfile setup/soko/soko_0.json --xform-rotate 2 --xform-flip-cols
python sturgeon/level2concat.py --outfile work/in_0_11_8x.lvl --pad-between 2 --pad-around _ --pad-end T --jsonfile setup/soko/soko_0.json --xform-rotate 2 --xform-flip-rows --xform-flip-cols

python sturgeon/level2concat.py --outfile work/in_0_12_7x.lvl --pad-between 2 --pad-around _ --pad-end T --jsonfile setup/soko/soko_0.json --xform-rotate 3
python sturgeon/level2concat.py --outfile work/in_0_13_7x.lvl --pad-between 2 --pad-around _ --pad-end T --jsonfile setup/soko/soko_0.json --xform-rotate 3 --xform-flip-rows
python sturgeon/level2concat.py --outfile work/in_0_14_7x.lvl --pad-between 2 --pad-around _ --pad-end T --jsonfile setup/soko/soko_0.json --xform-rotate 3 --xform-flip-cols
python sturgeon/level2concat.py --outfile work/in_0_15_7x.lvl --pad-between 2 --pad-around _ --pad-end T --jsonfile setup/soko/soko_0.json --xform-rotate 3 --xform-flip-rows --xform-flip-cols

# get tileset

python sturgeon/input2tile.py --outfile work/soko_test.tileset --out-tileset --textfile work/in_*.lvl

# make tile and scheme files for each height

python sturgeon/input2tile.py --outfile work/soko_test-7x.tile --textfile work/in_*_7x.lvl --tileset work/soko_test.tileset
python sturgeon/input2tile.py --outfile work/soko_test-8x.tile --textfile work/in_*_8x.lvl --tileset work/soko_test.tileset

python sturgeon/tile2scheme.py --outfile work/soko_test-7x.scheme --tilefile work/soko_test-7x.tile --pattern block-rst-noout,3,3,2,9
python sturgeon/tile2scheme.py --outfile work/soko_test-8x.scheme --tilefile work/soko_test-8x.tile --pattern block-rst-noout,3,3,2,10

# remap scheme files to output height and merge

python sturgeon/scheme2merge.py --outfile work/soko_test-6x-A.scheme --schemefile work/soko_test-7x.scheme --remap-row "0,2=0" "9,11=-1" --remove-void
python sturgeon/scheme2merge.py --outfile work/soko_test-6x-B.scheme --schemefile work/soko_test-8x.scheme --remap-row "0,2=0" "10,12=-2" --remove-void
python sturgeon/scheme2merge.py --outfile work/soko_test-6x.scheme --schemefile work/soko_test-6x-A.scheme work/soko_test-6x-B.scheme

# create tag file and text constraint

python sturgeon/level2concat.py --outfile work/soko_test-6x6x7.tag --pad-between 2 --size 6 6 --term-inst 8
python sturgeon/level2concat.py --outfile work/soko_test-6x6x7.lvl --pad-between 2 --size 4 4 --term-inst 7 --pad-around _ --pad-end T

# generate level

python sturgeon/scheme2output.py --outfile work/soko_test \
    --schemefile work/soko_test-6x.scheme \
    --solver pysat-gluecard41 --out-result-none --out-tlvl-none \
    --pattern-hard --pattern-ignore-no-in \
    --custom text-count 0 0 6 6 "P" 1 1 hard \
    --custom text-count 0 0 6 6 "B" 1 2 hard \
    --custom text-count 0 0 6 6 "O" 1 2 hard \
    --custom text-count 0 0 6 6 "G" 0 0 hard \
    --custom text-level work/soko_test-6x6x7.lvl hard \
    --tagfile work/soko_test-6x6x7.tag \
    --random 000

set -ex




PIPENV_PIPFILE=../level2image/Pipfile pipenv run python ../level2image/level2image.py --blank-color black --fmt png --cell-size 16 --cfg ../setup/cfg-lvl.json setup/tile*.lvl
PIPENV_PIPFILE=../level2image/Pipfile pipenv run python ../level2image/level2image.py --blank-color black --fmt png --cell-size 16 --cfg ../setup/cfg-lvl.json setup/demo.lvl --suffix .lvl.out
PIPENV_PIPFILE=../level2image/Pipfile pipenv run python ../level2image/level2image.py --blank-color black --fmt png --cell-size 16 --cfg ../setup/cfg-game.json setup/demo.game --suffix .game.out
PIPENV_PIPFILE=../level2image/Pipfile pipenv run python ../level2image/level2image.py --blank-color black --fmt png --cell-size 16 --cfg ../setup/cfg-lvl.json _out/diff/setup_1x7x7.tag --suffix .tag.out
PIPENV_PIPFILE=../level2image/Pipfile pipenv run python ../level2image/level2image.py --blank-color black --fmt png --cell-size 16 --cfg ../setup/cfg-game.json _out/diff/setup_1x7x7.game --suffix .game.out
PIPENV_PIPFILE=../level2image/Pipfile pipenv run python ../level2image/level2image.py --blank-color black --fmt png --cell-size 16 --cfg ../setup/cfg-lvl.json _out/diff/out_00.lvl --suffix .lvl.out
PIPENV_PIPFILE=../level2image/Pipfile pipenv run python ../level2image/level2image.py --blank-color black --fmt png --cell-size 16 --cfg ../setup/cfg-lvl.json _out/block/out_00.lvl --suffix .lvl.out

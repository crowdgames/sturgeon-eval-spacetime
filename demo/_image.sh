set -ex




PIPENV_PIPFILE=../level2image/Pipfile pipenv run python ../level2image/level2image.py --blank-color black --fmt png --cell-size 16 --cfg ../setup/cfg-lvl.json setup/tile*.lvl

PIPENV_PIPFILE=../level2image/Pipfile pipenv run python ../level2image/level2image.py --blank-color black --fmt png --cell-size 16 --cfg ../setup/cfg-lvl.json _out/*/*.lvl --suffix .lvl.out
PIPENV_PIPFILE=../level2image/Pipfile pipenv run python ../level2image/level2image.py --blank-color black --fmt png --cell-size 16 --cfg ../setup/cfg-lvl.json _out/*/*.tag --suffix .tag.out
PIPENV_PIPFILE=../level2image/Pipfile pipenv run python ../level2image/level2image.py --blank-color black --fmt png --cell-size 16 --cfg ../setup/cfg-game.json _out/*/*.game --suffix .game.out

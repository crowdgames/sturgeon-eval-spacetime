set -ex

if [[ $# -ne 1 ]]; then exit; fi
count="$1"

for game in field maze soko; do
    rm -rf "_out/cmp/$game/*"
    for method in block diff stwfc; do
        mkdir -p "_out/cmp/$game/$method"
    done
    python _cmp_wrapper.py --game "$game" --tries "$count" --outgrid 6 6 6
done

for game in soko blockdude; do
    rm -rf "_out/run/$game/*"
    mkdir -p "_out/cmp/$game/diff"
    python _run_wrapper.py --game "$game" --tries "$count"
done

python json2csv.py
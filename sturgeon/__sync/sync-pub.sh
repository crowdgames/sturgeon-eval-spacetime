if [ "$#" -ne 1 ]; then
    echo "Destination folder required."
    exit
fi

dst=$1

git status

for file in `ls "${dst}"`
do
    if [ "${file}" == ".git" ]
    then
	continue
    fi

    if [[ "${file}" = __* ]]
    then
	continue
    fi

    echo Removing "${dst}/${file}"
    rm -rf -- "${dst}/${file}"
done

for file in `git ls-files`
do
    if [[ "${file}" = __* ]]
    then
	continue
    fi

    echo Updating "${dst}/${file}"
    mkdir -p `dirname "${dst}/${file}"`
    cp "${file}" "${dst}/${file}"
done

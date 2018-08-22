#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"

cd $DIR/../user_output

declare -a arr=("input_catalog_with_spontaneous" "mojave_m7" "spontaneous_only")

for name in "${arr[@]}";do
	echo "doing $name"
	if [[ -e $name ]];then
		rm -r $name
	fi
	cp -r ../example_output/$name .
	
	u3etas_plot_generator.sh ../${name}_example.json $name/results_complete.bin
	
	rsync -a $name ../example_output/
done

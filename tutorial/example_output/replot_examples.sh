#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"

cd $DIR/../user_output

declare -a arr=("input_catalog_with_spontaneous" "mojave_m7" "spontaneous_only" "comcat-ridgecrest-m7.1-example")

for name in "${arr[@]}";do
	echo "doing $name"
	if [[ -e $name ]];then
		rm -r $name
	fi
	cp -r ../example_output/$name .
	
	JSON="../${name}_example.json"
	if [[ ! -e $JSON ]];then
		JSON="${name}/config.json"
	fi
	u3etas_plot_generator.sh $JSON $name/results_complete.bin
	
	rsync -a $name ../example_output/
done

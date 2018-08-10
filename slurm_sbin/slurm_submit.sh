#!/bin/bash

if [[ ! -e $1 ]];then
	echo "file not specified or not found: $1"
	exit 2
fi

sbatch -o ${1}.o%j -e ${1}.e%j $1

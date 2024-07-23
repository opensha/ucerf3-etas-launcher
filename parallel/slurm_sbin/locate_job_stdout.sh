#!/bin/bash

set -o errexit

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"

if [[ $# -ne 1 ]];then
#	echo "USAGE: <job-id>"
#	exit 2
#	echo "didn't supply job ID, detecting..."
	ID=`$DIR/detect_first_running.sh`
#	echo "detected ID: $ID"
else
	ID=$1
fi

if [[ ! $ID -gt 0 ]];then
	echo "Job ID not supplied or not found: $ID"
	exit 1
fi

# try to get it directly
OUT=`scontrol show jobID $ID | grep StdOut | cut -d "=" -f2-` 2> /dev/null

if [[ -e $OUT ]];then
	DIR=`squeue -h -j $ID -o %Z`
	
	if [[ ! -e $DIR ]];then
		echo "Dir for job $ID doesn't exist: $DIR"
		exit 1
	fi
	
	OUT=`find $DIR -maxdepth 1 -name "*.o${ID}"`
	
	if [[ ! -e $OUT ]];then
		# try another format
		OUT=`find $DIR -maxdepth 1 -name "*${ID}.out"`
	fi
	
	if [[ ! -e $OUT ]];then
		echo "Output not found for $ID in $DIR: $OUT"
		exit 1
	fi
fi

echo $OUT

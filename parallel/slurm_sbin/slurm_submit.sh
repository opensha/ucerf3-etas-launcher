#!/bin/bash

if [[ ! -e $1 ]];then
	echo "file not specified or not found: $1"
	exit 2
fi

DIR=`dirname ${1}`
SCRIPT=`basename ${1}`

if [[ ! -d $DIR ]];then
	echo "$DIR doesn't exist"
	exit 2
fi
cd $DIR

ACCT_ARG=""
if [[ ! -z $SLRUM_ACCT ]];then
	ACCT_ARG="-A $SLURM_ACCT"
fi

sbatch $ACCT_ARG -o ${SCRIPT}.o%j -e ${SCRIPT}.e%j $SCRIPT

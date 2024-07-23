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

if [[ $# -lt 2 ]];then
	SLURM_ID_FILE=~/.slurm_submit_prev_id
	if [[ -e $SLURM_ID_FILE ]];then
		JOB_ID=`cat $SLURM_ID_FILE`
		echo "Detected previously submitted Job ID=$JOB_ID"
	else
		echo "Did not specify a depenecy Job ID and no record of previously submitted in $SLURM_ID_FILE"
		exit 1
	fi
else
	JOB_ID=$2
fi

ACCT_ARG=""
if [[ ! -z $SLURM_ACCT ]];then
	ACCT_ARG="-A $SLURM_ACCT"
fi

sbatch $ACCT_ARG -o ${SCRIPT}.o%j -e ${SCRIPT}.e%j --dependency=afterok:$JOB_ID $SCRIPT
exit $?

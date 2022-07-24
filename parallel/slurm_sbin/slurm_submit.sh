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

SLURM_ID_FILE=~/.slurm_submit_prev_id

OUTPUT=`sbatch $ACCT_ARG -o ${SCRIPT}.o%j -e ${SCRIPT}.e%j $SCRIPT`
RET=$?
echo $OUTPUT
if [[ $RET -eq 0 ]];then
	JOB_ID=`echo $OUTPUT | awk '{print $4}'`
#	echo "job id: $JOB_ID"
	if [[ $JOB_ID -gt 0 ]];then
		echo $JOB_ID > $SLURM_ID_FILE
	fi
fi
exit $RET

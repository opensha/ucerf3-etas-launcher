#!/bin/bash

set -o errexit

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"

if [[ $# -ne 1 ]];then
#	echo "USAGE: <job-id>"
#	exit 2
	echo "didn't supply job ID, detecting..."
	ID=`$DIR/detect_first_running.sh`
	echo "detected ID: $ID"
else
	ID=$1
fi

FILE=`$DIR/locate_job_stdout.sh $ID`

echo "Job STDOUT: $FILE"

$DIR/log_parse.sh $FILE
echo -n "Exception count: "
grep -c xception $FILE

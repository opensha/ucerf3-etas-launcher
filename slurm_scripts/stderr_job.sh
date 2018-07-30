#!/bin/bash

ID=$1

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"

FILE=`$DIR/locate_job_stderr.sh $ID`
cat $FILE

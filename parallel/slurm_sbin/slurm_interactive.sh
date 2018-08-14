#!/bin/bash

MINS=${1-60}
QUEUE=${2}

if [[ ! -z $QUEUE ]];then
	QUEUE="-p $QUEUE"
fi

salloc -N 1 $QUEUE -t 00:$MINS:00

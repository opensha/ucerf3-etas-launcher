#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"

JAR="$DIR/../../opensha/opensha-all.jar"

java -Xmx500M -cp ${JAR} edu.usc.kmilner.mpj.taskDispatch.MPJTaskLogStatsGen $@

RESULTS=`dirname ${@: -1}`
RESULTS="$RESULTS/results"
if [[ -e $RESULTS ]];then
	# we're in an ETAS dir
	echo
	echo -n "results dir item count: "
	ls $RESULTS/ | wc -l
	
	ZIPS=`find $RESULTS/ -maxdepth 1 -name "*.zip" 2> /dev/null | grep -c zip`
	if [[ $ZIPS -gt 0 ]];then
		echo "results top level zip files: $ZIPS"
	fi
fi

#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"

JAR="$DIR/../opensha-ucerf3-all.jar"

java -cp ${JAR} edu.usc.kmilner.mpj.taskDispatch.MPJTaskLogStatsGen $@

if [[ -e results ]];then
	# we're in an ETAS dir
	echo
	echo -n "results dir item count: "
	ls results/ | wc -l
	
	ZIPS=`find results/ -name "*.zip" 2> /dev/null | grep -c zip`
	if [[ $ZIPS -gt 0 ]];then
		echo "zip files: $ZIPS"
	fi
fi

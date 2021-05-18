#!/bin/bash

# this is a utility script for jaunching a java process with the UCERF3-ETAS jar file in the classpath
# it will be called by other scripts

# maxmimum memory. should be close to, but not over, total memory available
# can set externally with ETAS_MEM_GB environmental variable
if [[ ! -z "$ETAS_MEM_GB" ]];then
	if ! [[ "$ETAS_MEM_GB" =~ ^[0-9]+$ ]];then
	        # it's a fraction, convert to megabytes
		MEM_MB=`bc <<< $ETAS_MEM_GB*1024/1`
		echo "Converting fractional ETAS_MEM_GB to megabytes: $ETAS_MEM_GB GB = $MEM_MB MB"
		MEM_ARG="-Xmx${MEM_MB}M"
	else
		echo "Using global ETAS_MEM_GB=$ETAS_MEM_GB"
		MEM_ARG="-Xmx${ETAS_MEM_GB}G"
	fi
else
	echo "ETAS_MEM_GB is not set, will automatically detect maximum memory as 80% of total system memory"
	TOT_MEM=`free | grep Mem | awk '{print $2}'`
	TOT_MEM_MB=`expr $TOT_MEM / 1024`
	TARGET_MEM_MB=`expr $TOT_MEM_MB \* 8 / 10`
	MEM_GIGS=`expr $TARGET_MEM_MB / 1024`
	echo "     will use up to $MEM_GIGS GB of memory"
	MEM_ARG="-Xmx{MEM_GIGS}G"
fi

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )/../"

# check for updates
$DIR/sbin/u3etas_opensha_update.sh

java -Djava.awt.headless=true $MEM_ARG -cp $DIR/opensha/opensha-all.jar $@
exit $?

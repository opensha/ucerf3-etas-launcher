#!/bin/bash

set -o errexit

# this is a utility script for jaunching a java process with the USCERF3-ETAS jar file in the classpath
# will be called by other scripts

# maxmimum memory in gigabytes. should be close to, but not over, total memory available
# can set externally with ETAS_MEM_GB environmental variable
if [[ ! -z "$ETAS_MEM_GB" ]];then
	MEM_GIGS=$ETAS_MEM_GB
	echo "Using global ETAS_MEM_GB=$ETAS_MEM_GB"
else
	echo "ETAS_MEM_GB is not set, will automatically detect maximum memory as 80% of total system memory"
	TOT_MEM=`free | grep Mem | awk '{print $2}'`
	TOT_MEM_MB=`expr $TOT_MEM / 1024`
	TARGET_MEM_MB=`expr $TOT_MEM_MB \* 8 / 10`
	MEM_GIGS=`expr $TARGET_MEM_MB / 1024`
	echo "     will use up to $MEM_GIGS GB of memory"
fi

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )/../"

java -Xmx${MEM_GIGS}G -cp $DIR/lib/opensha-ucerf3-all.jar $@
exit $?

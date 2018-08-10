#!/bin/bash

# this is a utility script for jaunching a java process with the USCERF3-ETAS jar file in the classpath
# will be called by other scripts

# maxmimum memory in gigabytes. should be close to, but not over, total memory available
# can set externally with ETAS_MEM_GB environmental variable
if [[ ! -z "$ETAS_MEM_GB" ]];then
	MEM_GIGS=$ETAS_MEM_GB
	echo "Using global ETAS_MEM_GB=$ETAS_MEM_GB"
else
	MEM_GIGS=12
fi

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )/../"

java -Xmx${MEM_GIGS}G -cp $DIR/opensha-ucerf3-all.jar $@
exit $?

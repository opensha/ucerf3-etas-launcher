#!/bin/bash

# maxmimum memory in gigabytes. should be close to, but not over, total memory available
# can set externally with ETAS_MEM_GB environmental variable
if [[ ! -z "$ETAS_MEM_GB" ]];then
	MEM_GIGS=$ETAS_MEM_GB
	echo "Using global ETAS_MEM_GB=$ETAS_MEM_GB"
else
	MEM_GIGS=12
fi

# number of etas threads. should be approximately MEM_GIGS/4, and no more than the total number of threads available
# can be set externally with ETAS_THREADS environmental variable, else it will be automatically choosen from threads available and MEM_GIGS
# can alternatively set via command line: ./etas_launcher --threads <num-threads> <etas-config.json>
if [[ ! -z "$ETAS_THREADS" ]];then
	echo "Using global ETAS_THREADS=$ETAS_THREADS"
	THREADS="--threads $ETAS_THREADS"
fi
#THREADS=8

if [[ $# -lt 1 ]];then
	echo "USAGE: $0 [--threads <num-threads>]  <etas-config.json>"
	exit 2
fi

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"

java -Xmx${MEM_GIGS}G -cp $DIR/opensha-ucerf3-all.jar scratch.UCERF3.erf.ETAS.launcher.ETAS_Launcher $THREADS $@

#!/bin/bash

echo "Testing environmental variables..."

if [[ ! -z $ETAS_MEM_GB ]];then
	echo "	You have set ETAS_MEM_GB to $ETAS_MEM_GB gigabytes" 
else
	echo "	ETAS_MEM_GB is not set, will use default"
fi

if [[ ! -z $ETAS_THREADS ]];then
	echo "	You have set ETAS_THREADS to $ETAS_THREADS threads"
else
	echo "	ETAS_THREADS has not been set, will use default (calculated from available memory) or specify at runtime with --threads <num-threads> to u3etas_launcher.sh"
fi

if [[ ! -z $ETAS_LAUNCHER ]];then
	echo "	You have set the ETAS_LAUNCHER path to $ETAS_LAUNCHER"
	if [[ -d $ETAS_LAUNCHER ]];then
		echo "	$ETAS_LAUNCHER exists!"
	else
		echo "	$ETAS_LAUNCHER doesn't exist, fix and try again"
	fi
else
	echo "	You have not set the $ETAS_LAUNCHER path (but should)"
fi

echo
echo "Looking for java in PATH"
java_path=$(which java)
if [[ -x "$java_path" ]]; then
	echo "	found java: $java_path"
	echo "	checking java version wtih 'java -version', ensure that the version is Java 11 or above (will print below)"
	java -version
	JAVA_VERSION=`java -version 2>&1 | head -1 | cut -d'"' -f2 | sed '/^1\./s///' | cut -d'.' -f1`
	echo "	detected Java $JAVA_VERSION"
	if [[ $JAVA_VERSION -lt 11 ]];then
		echo "	WARNING: Java version $JAVA_VERSION detected, we require 11 or greater"
	fi
else
	echo "	java not found in PATH! Fix and try again"
	exit 2
fi

echo
echo "Testing running java, the following output should be multiple lines ending with 'ETAS_EnvTest DONE'"
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"

$DIR/u3etas_jar_wrapper.sh scratch.UCERF3.erf.ETAS.launcher.util.ETAS_EnvTest

ret=$?
if [[ $ret -ne 0 ]];then
	echo "Nonzero return value, likely failed: $ret"
fi

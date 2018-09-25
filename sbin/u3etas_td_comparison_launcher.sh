#!/bin/bash

if [[ $# -lt 1 ]];then
	echo "USAGE: $0 [options]  <output-dir>"
	exit 2
fi

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"

$DIR/u3etas_jar_wrapper.sh scratch.UCERF3.erf.ETAS.launcher.util.U3TD_ComparisonLauncher $@

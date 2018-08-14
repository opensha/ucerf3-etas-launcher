#!/bin/bash

LINE=`tput lines`
let LINE=LINE-3

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"

watch -n 60 "$DIR/log_parse_running.sh $@ | tail -n $LINE"

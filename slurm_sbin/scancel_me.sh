#!/bin/bash

squeue -u $USER | grep $USER | awk '{ print $1 }' | awk -F"." '{print $1}' | xargs scancel

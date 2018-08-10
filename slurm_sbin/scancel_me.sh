#!/bin/bash

squeue -u $USER | grep $user | awk '{ print $1 }' | awk -F"." '{print $1}' | xargs scancel

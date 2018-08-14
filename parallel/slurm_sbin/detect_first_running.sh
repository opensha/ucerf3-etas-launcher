#!/bin/bash

squeue -t R -u $USER -o %A -h | sort | head -n 1

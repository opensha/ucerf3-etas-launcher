#!/bin/bash

######################
## INPUT PARAMETERS ##
######################

## ETAS PARAMETERS ##

ETAS_CONF_JSON=/path/to/etas_conf.json

## SLURM PARAMETERS ##

# NOTE: These are supposed to start with a '#', do not remove that character before 'SBATCH'

# this is the total wall clock time with format hh:mm:ss
# I usuall specify fully in minutes, so 00:1440:00 means 1440 minutes = 24 hours
#SBATCH -t 00:1440:00

# this is the total number of nodes
#SBATCH -N 18

# this is the queue to submit to, remove this line if you want the default queue
#SBATCH -p scec

# SLURM option that should not be changed for HPCC
#SBATCH --mem 0

## JAVA/MPJ PARAMETERS ##

# maxmimum memory in gigabytes. should be close to, but not over, total memory available
MEM_GIGS=60

# number of etas threads. should be approximately MEM_GIGS/8, and no more thatn the total number of threads available
THREADS=8

# your MPJ_HOME directory. copy mine to your own directory and change this line
# you can also fetch this directory via Git by cloning https://github.com/kevinmilner/mpj-express.git
MPJ_HOME=/home/scec-00/kmilner/mpj-current

JAR_FILE=/home/scec-02/kmilner/ucerf3-etas-launcher/opensha-ucerf3-all.jar

# simulations are sent out in batches to each compute node. these paramters control the size of those batches
MIN_DISPATCH=$THREADS
MAX_DISPATCH=500

##########################
## END INPUT PARAMETERS ##
##   DO NOT EDIT BELOW  ##
##########################

PBS_NODEFILE="/tmp/${USER}-hostfile-${SLURM_JOBID}"
echo "creating PBS_NODEFILE: $PBS_NODEFILE"
scontrol show hostnames $SLURM_NODELIST > $PBS_NODEFILE

export MPJ_HOME=/home/scec-00/kmilner/mpj-current
export PATH=$PATH:$MPJ_HOME/bin

date
echo "RUNNING MPJ"
mpjrun_errdetect_wrapper.sh $PBS_NODEFILE -dev hybdev -Djava.library.path=$MPJ_HOME/lib -Xmx${MEM_GIGS}G -cp $JAR_FILE scratch.UCERF3.erf.ETAS.launcher.MPJ_ETAS_Launcher --min-dispatch $MIN_DISPATCH --max-dispatch $MAX_DISPATCH --threads $THREADS $ETAS_CONF_JSON
ret=$?
date

exit $ret

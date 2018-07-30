#!/bin/bash

#SBATCH -t 00:1440:00
#SBATCH -N 18
#SBATCH -p scec
#SBATCH --mem 0

######################
## INPUT PARAMETERS ##
######################

# the above '#SBATCH' lines are requred, and are supposed to start with a '#'. They must be at the beginning of the file
# the '-t hh:mm:ss' argument is the wall clock time of the job
# the '-N 18' argument specifies the number of nodes required, in this case 18
# the 'p scec' argument specifies the queue, this line can be removed if you want the default queue
# the '--mem 0' argument fixes some USC HPC weirdness and shouldn't be removed

## ETAS PARAMETERS ##

ETAS_CONF_JSON=/path/to/etas_conf.json

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

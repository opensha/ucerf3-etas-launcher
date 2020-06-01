#!/bin/bash

#SBATCH -t 06:00:00
#SBATCH -N 10
#SBATCH -n 960
#SBATCH -p skx-normal

######################
## INPUT PARAMETERS ##
######################

# the above '#SBATCH' lines are requred, and are supposed to start with a '#'. They must be at the beginning of the file
# the '-t hh:mm:ss' argument is the wall clock time of the job
# the '-N 10' argument specifies the number of nodes required, in this case 10
# the '-n 960' argument specifies the number of cores, required by TACC. Set it to 96*the number of nodes for SKX nodes
# the 'p skx-normal' argument specifies the queue, in this case we want the SKX nodes

## ETAS PARAMETERS ##

# path to the JSON configuration file
ETAS_CONF_JSON=/path/to/etas_config.json

## JAVA/MPJ PARAMETERS ##

# maxmimum memory in gigabytes. should be close to, but not over, total memory available
MEM_GIGS=160

# number of etas threads. should be approximately MEM_GIGS/5, and no more than the total number of threads available
THREADS=18

# FMPJ_HOME directory, fine to use mine
FMPJ_HOME=/home1/00950/kevinm/FastMPJ

# path to the opensha-ucerf3 jar file
JAR_FILE=${ETAS_LAUNCHER}/lib/opensha-ucerf3-all.jar

# simulations are sent out in batches to each compute node. these paramters control the size of those batches
# smaller max size will allow for better checking of progress with watch_logparse.sh, but more wasted time at the end of batches waiting on a single calculation to finish
MIN_DISPATCH=$THREADS
MAX_DISPATCH=100

# this allows for catalogs to be written locally on each compute node in a temporary directory, then only copied back onto shared storage after they complete. this reduces I/O load, but makes it harder to track progress of individual simulations. comment this out to disable this option
TEMP_OPTION="--temp-dir /tmp/etas-results-tmp"

# this allows for the results directory to be hosted on a different filesystem, in this case the $SCRATCH filesystem. this will prevent many files from being written to $WORK, as well as reducing I/O load
SCRATCH_OPTION="--scratch-dir $SCRATCH/etas-results-tmp"

# this automatically deletes subdirectories of the results directory once a catalog has been sucessfully written to the master binary file. comment out to disable
CLEAN_OPTION="--clean"

##########################
## END INPUT PARAMETERS ##
##   DO NOT EDIT BELOW  ##
##########################

NEW_JAR="`dirname ${ETAS_CONF_JSON}`/`basename $JAR_FILE`"
cp $JAR_FILE $NEW_JAR
if [[ -e $NEW_JAR ]];then
	JAR_FILE=$NEW_JAR
fi

PBS_NODEFILE="/tmp/${USER}-hostfile-${SLURM_JOBID}"
echo "creating PBS_NODEFILE: $PBS_NODEFILE"
scontrol show hostnames $SLURM_NODELIST > $PBS_NODEFILE

NEW_NODEFILE="/tmp/${USER}-hostfile-fmpj-${PBS_JOBID}"
echo "creating PBS_NODEFILE: $NEW_NODEFILE"
hname=$(hostname)
if [ "$hname" == "" ]
then
  echo "Error getting hostname. Exiting"
  exit 1
else
  cat $PBS_NODEFILE | sort | uniq | fgrep -v $hname > $NEW_NODEFILE
fi

export PBS_NODEFILE=$NEW_NODEFILE
export FMPJ_HOME=/home1/00950/kevinm/FastMPJ
export PATH=$PATH:$FMPJ_HOME/bin

if [[ -e $PBS_NODEFILE ]]; then
  #count the number of processors assigned by PBS
  NP=`wc -l < $PBS_NODEFILE`
  echo "Running on $NP processors: "`cat $PBS_NODEFILE`
else
  echo "This script must be submitted to PBS with 'qsub -l nodes=X'"
  exit 1
fi

if [[ $NP -le 0 ]]; then
  echo "invalid NP: $NP"
  exit 1
fi

JVM_MEM_MB=26624

date
echo "RUNNING FMPJ"
fmpjrun_errdetect_wrapper.sh -machinefile $PBS_NODEFILE -np $NP -dev niodev -Djava.library.path=$FMPJ_HOME/lib -Xmx${MEM_GIGS}G -cp $JAR_FILE -class scratch.UCERF3.erf.ETAS.launcher.MPJ_ETAS_Launcher --min-dispatch $MIN_DISPATCH --max-dispatch $MAX_DISPATCH --threads $THREADS $TEMP_OPTION $SCRATCH_OPTION $CLEAN_OPTION --end-time `scontrol show job $SLURM_JOB_ID | egrep --only-matching 'EndTime=[^ ]+' | cut -c 9-` $ETAS_CONF_JSON
ret=$?
date

exit $ret

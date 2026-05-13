#!/bin/bash

#SBATCH --time 24:00:00
#SBATCH --nodes 14
#SBATCH --ntasks 14
#SBATCH --cpus-per-task=56
#SBATCH --partition normal
#SBATCH --mem 0

######################
## INPUT PARAMETERS ##
######################

# the above '#SBATCH' lines are requred, and are supposed to start with a '#'. They must be at the beginning of the file
# the '--time hh:mm:ss' argument is the wall clock time of the job
# the '--nodes 14' argument specifies the number of nodes required, in this case 14
# the '--ntasks 14' argument specifies the number of tasks, required by TACC. 1 task per node.
# the '--cpus-per-task=56' argument specifies that we need access to all 56 cores on each node
# the '--partition normal' argument specifies the queue, this line can be removed if you want the default queue
# the '--mem 0' argument specifies that we want access to all available memory on the compute nodes

## ETAS PARAMETERS ##

# path to the JSON configuration file
ETAS_CONF_JSON=/path/to/etas_config.json

## JAVA/MPJ PARAMETERS ##

# maxmimum memory in gigabytes. should be close to, but not over, total memory available
MEM_GIGS=160

# number of etas threads. should be approximately MEM_GIGS/5, and no more than the total number of threads available
THREADS=20

# MPJ_HOME directory, fine to use mine
MPJ_HOME=/work2/10177/bhatthal/frontera/mpj-express

# path to the opensha-ucerf3 jar file
JAR_FILE=${ETAS_LAUNCHER}/opensha/opensha-all.jar

# simulations are sent out in batches to each compute node. these paramters control the size of those batches
# smaller max size will allow for better checking of progress with watch_logparse.sh, but more wasted time at the end of batches waiting on a single calculation to finish
MIN_DISPATCH=$THREADS
MAX_DISPATCH=500

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
export PATH=$PATH:$MPJ_HOME/bin

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

t1=$(date +%s) # epoch start time in seconds

date
echo "RUNNING MPJ"
mpjrun_errdetect_wrapper.sh $PBS_NODEFILE -dev hybdev -Djava.library.path=$MPJ_HOME/lib -Xmx${MEM_GIGS}G -cp $JAR_FILE scratch.UCERF3.erf.ETAS.launcher.MPJ_ETAS_Launcher --min-dispatch $MIN_DISPATCH --max-dispatch $MAX_DISPATCH --threads $THREADS $TEMP_OPTION $SCRATCH_OPTION $CLEAN_OPTION --end-time `scontrol show job $SLURM_JOB_ID | egrep --only-matching 'EndTime=[^ ]+' | cut -c 9-` $ETAS_CONF_JSON
ret=$?
date

t2=$(date +%s) # epoch end time in seconds
numSec=$(echo $t2 - $t1 | bc -q ) # the number of seconds the process took.
runTime=$(date -ud @$numSec +%T) # Convert the seconds into Hours:Mins:Sec
echo "Time to build: $runTime ($numSec seconds)"

exit $ret



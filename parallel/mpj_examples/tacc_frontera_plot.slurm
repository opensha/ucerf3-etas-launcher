#!/bin/bash

#SBATCH -t 3:00:00
#SBATCH -N 1
#SBATCH -n 56
#SBATCH -p normal

######################
## INPUT PARAMETERS ##
######################

# the above '#SBATCH' lines are requred, and are supposed to start with a '#'. They must be at the beginning of the file
# the '-t hh:mm:ss' argument is the wall clock time of the job
# the '-N 1' argument specifies the number of nodes required, in this case 1
# the '-n 56' argument specifies the number of cores, required by TACC. Set it to at most 56*the number of nodes for SKX nodes
# the '-p normal' argument specifies the queue, in this case we use the normal queue

## ETAS PARAMETERS ##

# path to the JSON configuration file
ETAS_CONF_JSON=/path/to/etas_config.json

# path to ComCat catalog for ComCat comparison plots. this only applies to simulation configuration which include the ComCat metadata files, and where the compute nodes cannot reach the outside world (e.g. for USC HPC). If the compute node can see the outside world, you can leave this as blank (or comment out) and events will be fetched at runtime
# this file is generated with the 'u3etas_comcat_catalog_fetcher.sh <config.json>' command
#COMCAT_CATALOG=/path/to/comcat-events.txt

# no maps option - uncomment this to skip any map generation which requires access to a servlet on opensha.usc.edu. this option should be enabled if your compute nodes cannot reach the outside world (e.g. for USC HPC), or if the opensha server is down or otherwise inaccessible
#NO_MAPS_OPTION="--no-maps"

# uncomment this if you want to force it to regenerate all plots on subsequent reruns of this script
#FORCE_UPDATE_OPTION="--force-update"

## JAVA PARAMETERS ##

# maxmimum memory in gigabytes. should be close to, but not over, total memory available
MEM_GIGS=160

# number of processing threads to handle plots, can be up to 56
THREADS=56

# path to the opensha-ucerf3 jar file
JAR_FILE=${ETAS_LAUNCHER}/opensha/opensha-all.jar

##########################
## END INPUT PARAMETERS ##
##   DO NOT EDIT BELOW  ##
##########################

if [[ -e $COMCAT_CATALOG ]];then
	COMCAT_OPTION="--comcat-catalog $COMCAT_CATALOG"
fi

java -Djava.awt.headless=true -Xmx${MEM_GIGS}G -cp $JAR_FILE scratch.UCERF3.erf.ETAS.analysis.SimulationMarkdownGenerator --threads $THREADS $NO_MAPS_OPTION $FORCE_UPDATE_OPTION $COMCAT_OPTION $ETAS_CONF_JSON

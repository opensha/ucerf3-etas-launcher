# Running ETAS simulations in parallel on HPC resources

## Overview

Many UCERF3-ETAS simulations are often required in order to sufficiently sample the probabilities of rare events. This is often intractable on a single machine in a reasonable timeframe, so we run simulations on many machines in parallel. This requires access to HPC resources, some additional libraries, and knowledge if submitting and managing batch jobs in a parallel environment.

## Assumptions/prerequisites

* You have access to a linux cluster running the [Slurm workload manager](https://slurm.schedmd.com/)
* You have completed the main UCERF3-ETAS Launcher installation instructions on this HPC resource and are familiar with running ETAS simulations on a single computer
* You have installed, configured, and tested either MPJ Express or FastMPJ
  * These have already been configured at [USC HPC](https://hpcc.usc.edu/) and [TACC Stampede2](https://portal.tacc.utexas.edu/user-guides/stampede2)
* All commands below assume that you are in a terminal and have SSH'd into the HPC resource
* You have access to a parallel filesystem with a large (hundreds of gigabytes for large simulations) disk quota. This directory must be visible on all compute nodes
  * On USC HPC, this is `/home/scec-00/<your-username>` or `/home/scec-02/<your-username>`
* You know how to edit text files on a command line using vim, emacs, or similar

## Slurm helper scripts

The [slurm_sbin](slurm_sbin) subdirectory contains many helper scripts which will make submitting and monitoring ETAS simulations much easier on HPC resources. You should add this directory to your PATH. Here is an example on USC HPCC, along with the other UCERF3-ETAS environmental variables:

Put this in your .bash_profile script (replacing paths with your own paths):
```
export ETAS_LAUNCHER=/home/scec-02/kmilner/ucerf3/ucerf3-etas-launcher
export ETAS_SIM_DIR=/home/scec-02/kmilner/ucerf3/etas_sim
export PATH=$ETAS_LAUNCHER/parallel/slurm_sbin/:$ETAS_LAUNCHER/sbin/:$PATH
```

Verify that it works by logging out of the system, logging back in, and typing `echo $ETAS_LAUNCHER`. You should see your ETAS Launcher path:

```
[kmilner@hpc-login3 ~]$ echo $ETAS_LAUNCHER
/home/scec-02/kmilner/ucerf3/ucerf3-etas-launcher
[kmilner@hpc-login3 ~]$
```

## Configuring a parallel ETAS script

We'll use the Mojave M7 example from the [tutorial](../tutorial/). First create a directory on your large shared filesystem for this simulation. I like to include the current date in my directories in order to keep things straight later on (and quickly locate recent simulations):

```
[kmilner@hpc-login3 etas_sim]$ pwd
/home/scec-02/kmilner/ucerf3/etas_sim
[kmilner@hpc-login3 etas_sim]$ mkdir 2018_08_30-MojaveM7
[kmilner@hpc-login3 etas_sim]$ cd 2018_08_30-MojaveM7
[kmilner@hpc-login3 2018_08_30-MojaveM7]$
```

Now create an ETAS JSON configuration file. For this one, we'll modify the tutorial Mojave M7 file:

```
[kmilner@hpc-login3 2018_08_30-MojaveM7]$ cp $ETAS_LAUNCHER/tutorial/mojave_m7_example.json config.json
```

That tutorial file was only for 10 simulations, so we need to make some edits. Lets do 1000 simulations, and we also want to set the output directory to this new simulation directory. Here are my edits:

```
  "numSimulations": 1000
  "outputDir": "/home/scec-02/kmilner/ucerf3/etas_sim/2018_08_30-MojaveM7"
```

Next, you need to create a Slurm batch script which will execute the ETAS launcher in parallel mode. Example scripts are located in the [mpj_examples](mpj_examples) directory. We'll modify the `usc_hpcc_mpj_express.slurm` script.

```
[kmilner@hpc-login3 2018_08_30-MojaveM7]$ cp $ETAS_LAUNCHER/parallel/mpj_examples/usc_hpcc_mpj_express.slurm etas_parallel.slurm
```

Read through the "INPUT PARAMETERS" section of this Slurm script, updating variables as needed. On USC HPC, you should only need to update the path to the etas configuration file, as well as the Slurm node count and job limits. For this demo, lets run on 5 compute nodes with 2 hour max runtime:

```
#!/bin/bash

#SBATCH -t 2:00:00
#SBATCH -N 5
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

# path to the JSON configuration file
ETAS_CONF_JSON=/home/scec-02/kmilner/ucerf3/etas_sim/2018_08_30-MojaveM7/config.json
...continued...
```

## Submitting the Slurm parallel ETAS job

You are now ready to submit the Slurm simulation to the job scheduler. Use the `slurm_submit.sh` command from my [helper scripts](slurm_sbin/slurm_submit.sh), as it will place the job command line output (STDOUT/STDERR) in the correct places in order to easily monitor job progress later on.

```
[kmilner@hpc-login3 2018_08_30-MojaveM7]$ slurm_submit.sh etas_parallel.slurm 
Submitted batch job 1434824
[kmilner@hpc-login3 2018_08_30-MojaveM7]$ squeue -u $USER
             JOBID PARTITION     NAME     USER ST       TIME  NODES NODELIST(REASON)
           1434824      scec etas_par  kmilner PD       0:00      5 (Priority)
```

The second command (`squeue -u $USER`) checks the status of all of your running jobs. You can replace `$USER` with your username if it's easier for you. In this case, the job is not yet running as the state ('ST') is PD which means that the job is pending. A list of all Slurm job state codes can be found [here](https://slurm.schedmd.com/squeue.html#lbAG). Once your job has started running, it will look something like this:

```
[kmilner@hpc-login3 2018_08_30-MojaveM7]$ squeue -u $USER
             JOBID PARTITION     NAME     USER ST       TIME  NODES NODELIST(REASON)
           1434824      scec supra_pl  kmilner  R      5:31      5 hpc[4191-4195]
```

In this example, the job has been running for 5 minutes and 31 seconds. Depending on if other people are using the system (in this case the SCEC queue), it may start immediately or take a long time. For the SCEC queue at USC, the `scec_queue_check.py` script will let you know how many nodes are currently in use (out of a total of 38):

```
[kmilner@hpc-login3 ~]$ scec_queue_check.py 
1 users running 6 jobs on 36 nodes, 14 queued jobs
user: kmilner,	running: 6 (36 nodes),	queued: 14
Total nodes in use: 36
```

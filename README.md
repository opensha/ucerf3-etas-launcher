# UCERF3-ETAS Launcher

UCERF3-ETAS Launcher binaries, documentation, and scripts

## Prerequisites

* Java (either JRE or JDK) 8 or above in your path: https://java.com/en/download/
  * confirm by typing `java -version` in a terminal
* Unix-like environment (Linux, Mac OS X, possibly Cygwin though untested)
* Basic command line skills (changing directories, defining environmental variables, editing text files, running scripts)

## Setup

First, clone this entire repository from GitHub or download it as a zip file. Here's the command to do it in a terminal:

`git clone https://github.com/opensha/ucerf3-etas-launcher.git`

Then define the following environmental variables in your login script (outside the scope of this documentation, for most users editing `~/.bash_profile` is a good place to do this)

  * `ETAS_LAUNCHER`: the path to the `ucerf3-etas-launcher` directory. Optional but recommended as it allows for the use of relative paths in ETAS configuration files
    * You may also want to add `$ETAS_LAUNCHER/sbin` to your PATH for easy access to ETAS launcher/processing scripts
  * `ETAS_MEM_GB`: maximum amount of memory to assign to ETAS calculations in gigabytes (integer value, e.g. set to 10 for 10 GB). ETAS simulations require a lot of memory (about 5 GB per calculation thread), set as high as possible with a small buffer for other OS software. I typically set it to system memory minus 2 GB
  * `ETAS_THREADS`: the number of threads to spawn during ETAS calculations. Setting it globally here is optional, otherwise it can either be specified on the command line when running ETAS calculations via the `--threads <threads>` argument or it will be determined on-the-fly from the total amount of memory available
  
### .bash_profile example

Here is an example `~/.bash_profile` script defining these variables. This assumes a system with 16 GB of memory.

```
export ETAS_MEM_GB=14
export ETAS_LAUNCHER=/home/kevin/git/ucerf3-etas-launcher
export ETAS_THREADS=3
export PATH=$PATH:$ETAS_LAUNCHER/sbin/
```

### Test your environment

Once you have followed the above steps, you can test your environment with the `u3etas_env_test.sh` script. Here is my output from this command with the above lines in my .bash_profile file:

```
kevin@steel:~$ u3etas_env_test.sh 
Testing environmental variables...
	You have set ETAS_MEM_GB to 14 gigabytes
	You have set ETAS_THREADS to 3 threads
	You have set the ETAS_LAUNCHER path to /home/kevin/git/ucerf3-etas-launcher
	/home/kevin/git/ucerf3-etas-launcher exists!

Looking for java in PATH
	found java: /usr/lib/jvm/java-8-openjdk-amd64//jre/bin/java
	checking java version wtih 'java -version', ensure that the version is Java 8 (1.8) or above (will print below)
openjdk version "1.8.0_181"
OpenJDK Runtime Environment (build 1.8.0_181-8u181-b13-0ubuntu0.16.04.1-b13)
OpenJDK 64-Bit Server VM (build 25.181-b13, mixed mode)

Testing running java, the following output should be multiple lines ending with 'ETAS_EnvTest DONE'
Using global ETAS_MEM_GB=14
Running ETAS_EnvTest java class
	Maximum available memory to java (after overhead): 12743 MB
	$ETAS_LAUNCHER defined? true, Value: /home/kevin/git/ucerf3-etas-launcher
ETAS_EnvTest DONE
```

## Configuring ETAS Simulations

UCERF3-ETAS simulations are defined with [JSON](https://beginnersbook.com/2015/04/json-tutorial/) configuration files. These files describe the simulation parameters (start time, inclusion of spontaneous ruptures, etc), optional input 'trigger' ruptures (if you are simulating the aftermath of a scenario or real event), output directory, and path to various required UCERF3 inputs and cache files (located in the [inputs directory](inputs)).

While cumbersome, you can create configuration files from scratch or modify an example in the [json_examples directory](json_examples) after reading the [file format documentation](json_examples/README.md). A simpler approach is often to use [helper scripts defined here](CONFIGURING_SIMULATIONS.md) which generate JSON configuration files for either [ComCat events](CONFIGURING_SIMULATIONS.md#configuring-simulations-for-comcat-events) or [scenario ruptures/spontaneous simulations](CONFIGURING_SIMULATIONS.md#configuring-simulations-for-scenarios-or-spontaneous-events).

## Running Single-Machine ETAS Simulations

Once you have defined a [JSON ETAS configuration file](json_examples), you can use the scripts in the [sbin directory](sbin). More detailed information on these scripts is available in the [README](sbin/README.md). Commands shown below assume that you have added the sbin direcotory to your PATH.

To run a set of ETAS simulations on a single machine (but possibly with multiple threads), use the `u3etas_launcher.sh` command:

`u3etas_launcher.sh [--threads <num-threads>] </path/to/etas_configuration.json>`

For example, to run ETAS simulations for a JSON file in the current directory named "config.json" with 3 threads:

`u3etas_launcher.sh --threads 3 config.json`

Output files for each catalog will be written in the "results" subdirectory of the simulation output directory (which is defined in the JSON configuration file). If [binary output filters](json_examples/README.md#binary-output-filters) are configured in the JSON file, then results will be consolidated as they complete into one or more binary files in the top level simulation output directory.

## Plotting Simulation Output

Once you have completed a set of ETAS Simulations, you can generate standard plots such as magnitude frequency distributions (MFDs), section participation rates, and nucleation maps. This is done with the `u3etas_plot_generator.sh` script, which creats plots (along with some CSV file tables) in the "plots" subdirectory of the simulation output directory. It also generates both Makrdown "README.md" HTML "index.html" files for viewing plots and metdata in the the main simulation output directory.

To run the plot generator, use this command:

`u3etas_plot_generator.sh </path/to/etas_configuration.json> [</path/to/etas_output.bin or /path/to/results>]`

For example, if config.json exists in the current directory:

`u3etas_plot_generator.sh config.json`

You can also specify an optional path to either a binary catalogs file or the results directory. If omitted, it will search for catalogs (either in binary files or the results subdirectory) in the output directory.

## Try it out

Now that you're familiar with the commands and have your environment set up, try out a [tutorial](tutorial).

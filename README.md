# UCERF3-ETAS Launcher

UCERF3-ETAS Launcher binaries, documentation, and scripts

## Prerequisites

* Java (JDK strongly recommended) 11 or above in your path, 64-bit: [AdoptOpenJDK](https://adoptopenjdk.net/) or [OpenJDK](https://jdk.java.net/)
  * confirm by typing `java -version` in a terminal
* Unix-like environment (Linux, Mac OS X, possibly Cygwin though untested)
* Basic command line skills (changing directories, defining environmental variables, editing text files, running scripts)

### Recommended

UCERF3-ETAS Launcher will attempt to build the `etas-launcher-stable` branch of the upstream [OpenSHA](https://github.com/opensha/opensha/tree/etas-launcher-stable) project that contains all of the code for the UCERF3-ETAS model, and automatically pull in new updates to that code. In order for this to work, the following recommended requirements must also be met:

* Java Development Kit (JDK, as opposed to just a Java Runtime Environment) 11 or above in your path
* A recent version of [Git](https://git-scm.com/downloads)
    - Git is included in the macOS [developer tools](https://developer.apple.com/xcode/)

If these recommended prerequisites are not met, we will instead periodically downlod the latest pre-built version of the OpenSHA library. You can control how often this happens by setting the `ETAS_JAR_UPDATE_DAYS` environmental variable to the number of days you wish to wait between updates.

## Setup

First, clone this entire repository from GitHub (preferred) or download it as a zip file. Here's the command to do it in a terminal:

`git clone https://github.com/opensha/ucerf3-etas-launcher.git`

Then define the following environmental variables in your login script (outside the scope of this documentation, for most users editing `~/.bash_profile` is a good place to do this)

  * `ETAS_LAUNCHER`: the path to the `ucerf3-etas-launcher` directory. Optional but recommended as it allows for the use of relative paths in ETAS configuration files
    * You may also want to add `$ETAS_LAUNCHER/sbin` to your PATH for easy access to ETAS launcher/processing scripts
  * `ETAS_MEM_GB`: maximum amount of memory to assign to ETAS calculations in gigabytes (integer value, e.g. set to 10 for 10 GB). ETAS simulations require a lot of memory (about 5 GB per calculation thread), set as high as possible with a small buffer for other OS software. I typically set it to system memory minus 2 GB
  * `ETAS_THREADS`: the number of threads to spawn during ETAS calculations. Setting it globally here is optional, otherwise it can either be specified on the command line when running ETAS calculations via the `--threads <threads>` argument or it will be determined on-the-fly from the total amount of memory available
  * `ETAS_SIM_DIR`: directory where you plan to store ETAS simulations. This is optional but highly recommended, as it will allow you to use relative paths in configuration files and easily copy simulations between systems for processing
  
### .bash_profile example

Here is an example `~/.bash_profile` script defining these variables. This assumes a system with 16 GB of memory.

```
export ETAS_MEM_GB=14
export ETAS_LAUNCHER=/home/kevin/git/ucerf3-etas-launcher
export ETAS_THREADS=3
export ETAS_SIM_DIR=/home/kevin/ucerf3-etas-simulations
export PATH=$PATH:$ETAS_LAUNCHER/sbin/
```

### Test your environment

Once you have followed the above steps, you can test your environment with the `u3etas_env_test.sh` script. This will also attempt to fetch and build the OpenSHA project, a required dependency. Here is my output from this command with the above lines in my .bash_profile file:

```
kevin@steel:~$ u3etas_env_test.sh 
Testing environmental variables...
	You have set ETAS_MEM_GB to 14 gigabytes
	You have set ETAS_THREADS to 3 threads
	You have set the ETAS_LAUNCHER path to /home/kevin/git/ucerf3-etas-launcher
	/home/kevin/git/ucerf3-etas-launcher exists!

Looking for java in PATH
	found java: /usr/lib/jvm/default-java/bin/java
	checking java version wtih 'java -version', ensure that the version is Java 11 or above (will print below)
openjdk version "11.0.10" 2021-01-19
OpenJDK Runtime Environment AdoptOpenJDK (build 11.0.10+9)
OpenJDK 64-Bit Server VM AdoptOpenJDK (build 11.0.10+9, mixed mode)
	detected Java 11

Testing running java, the following output should be multiple lines ending with 'ETAS_EnvTest DONE'
Using global ETAS_MEM_GB=14
creating /home/kevin/git/ucerf3-etas-launcher/sbin/../opensha
Checking for updates to OpenSHA. You can disable these checks by setting the environmental variable ETAS_JAR_DISABLE_UPDATE=1
We need to download and/or build OpenSHA. The preferred method is to checkout the OpenSHA project from GitHub and build it. Checking if we have java compilers available (must have version 11 or greater):
javac 11.0.10
	Checking if we have git installed:
git version 2.25.1
javac and git are available and building is preferred for smart update checking, but you can optionally download (and routinely re-download) nightly builds instead.
	Would you like to use nightly builds instead? [y/N] N
Need to check out OpenSHA from GitHub (this may take a little while and only needs to happen once)
Cloning into 'opensha'...
remote: Enumerating objects: 16029, done.
remote: Counting objects: 100% (97/97), done.
remote: Compressing objects: 100% (79/79), done.
remote: Total 16029 (delta 29), reused 67 (delta 13), pack-reused 15932
Receiving objects: 100% (16029/16029), 165.21 MiB | 32.88 MiB/s, done.
Resolving deltas: 100% (6812/6812), done.
Updating files: 100% (4737/4737), done.
Branch 'etas-launcher-stable' set up to track remote branch 'etas-launcher-stable' from 'origin'.
Switched to a new branch 'etas-launcher-stable'
Building OpenSHA jar with Gradle in /home/kevin/git/ucerf3-etas-launcher/opensha/git/opensha

> Task :compileJava
Note: Some input files use or override a deprecated API.
Note: Recompile with -Xlint:deprecation for details.
Note: Some input files use unchecked or unsafe operations.
Note: Recompile with -Xlint:unchecked for details.

BUILD SUCCESSFUL in 18s
3 actionable tasks: 3 executed
Running ETAS_EnvTest java class
        Maximum available memory to java (after overhead): 12743 MB
	$ETAS_LAUNCHER defined? true, Value: /home/kevin/git/ucerf3-etas-launcher
ETAS_EnvTest DONE
```

## Configuring ETAS Simulations

UCERF3-ETAS simulations are defined with [JSON](https://beginnersbook.com/2015/04/json-tutorial/) configuration files. These files describe the simulation parameters (start time, inclusion of spontaneous ruptures, etc), optional input 'trigger' ruptures (if you are simulating the aftermath of a scenario or real event), output directory, and path to various required UCERF3 inputs and cache files (located in the [inputs directory](inputs)).

While cumbersome, you can create configuration files from scratch or modify an example in the [json_examples directory](json_examples) after reading the [file format documentation](doc/json_configuration_format.md). A simpler approach is often to use [helper scripts defined here](doc/configuring_simulations.md) which generate JSON configuration files for either [ComCat events](doc/configuring_simulations.md#configuring-simulations-for-comcat-events) or [scenario ruptures/spontaneous simulations](doc/configuring_simulations.md#configuring-simulations-for-scenarios-or-spontaneous-events).

## Running Single-Machine ETAS Simulations

Once you have defined a [JSON ETAS configuration file](json_examples), you can use the scripts in the [sbin directory](sbin). More detailed information on these scripts is available in the [README](doc/scripts.md). Commands shown below assume that you have added the sbin direcotory to your PATH.

To run a set of ETAS simulations on a single machine (but possibly with multiple threads), use the `u3etas_launcher.sh` command:

`u3etas_launcher.sh [--threads <num-threads>] </path/to/etas_configuration.json>`

For example, to run ETAS simulations for a JSON file in the current directory named "config.json" with 3 threads:

`u3etas_launcher.sh --threads 3 config.json`

Output files for each catalog will be written in the "results" subdirectory of the simulation output directory (which is defined in the JSON configuration file). If [binary output filters](doc/json_configuration_format.md#binary-output-filters) are configured in the JSON file, then results will be consolidated as they complete into one or more binary files in the top level simulation output directory.

## Plotting Simulation Output

Once you have completed a set of ETAS Simulations, you can generate standard plots such as magnitude frequency distributions (MFDs), section participation rates, and nucleation maps. This is done with the `u3etas_plot_generator.sh` script, which creats plots (along with some CSV file tables) in the "plots" subdirectory of the simulation output directory. It also generates both Makrdown "README.md" HTML "index.html" files for viewing plots and metdata in the the main simulation output directory.

To run the plot generator, use this command:

`u3etas_plot_generator.sh </path/to/etas_configuration.json> [</path/to/etas_output.bin or /path/to/results>]`

For example, if config.json exists in the current directory:

`u3etas_plot_generator.sh config.json`

You can also specify an optional path to either a binary catalogs file or the results directory. If omitted, it will search for catalogs (either in binary files or the results subdirectory) in the output directory.

## Try it out

Now that you're familiar with the commands and have your environment set up, try out a [tutorial](tutorial).

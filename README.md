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
  * `ETAS_MEM_GB`: maximum amount of memory to assign to ETAS calculations. ETAS simulations require lots of memory (about 5 GB per calculation thread), set as high as possible with a small buffer for other OS software. I typically set it to system memory minus 2 Gb
  * `ETAS_THREADS`: the number of threads to spawn during ETAS calculations. Setting it globally here is optional, otherwise it can either be specified on the command line when running ETAS calculations via the `--threads <threads>` argument or it will be determined on-the-fly from the total amount of memory available
  
### .bash_profile example

Here is an example `~/.bash_profile` script defining these variables. This assumes a system with 16 GB of memory.

```
export ETAS_MEM_GB=14
export ETAS_LAUNCHER=/home/kevin/git/ucerf3-etas-launcher
export ETAS_THREADS=3
export PATH=$PATH:$ETAS_LAUNCHER/sbin/
```

## Configuring ETAS Simulations

ETAS simulations are defined with [JSON](https://beginnersbook.com/2015/04/json-tutorial/) configuration files. The simplest way to get started is to modify an example in the [json_examples directory](json_examples) and to read the [file format documentation](json_examples/README.md). These files describe the simulation parameters (start time, inclusion of spontaneous ruptures, etc), optional input 'trigger' ruptures (if you are simulating the aftermath of a scenario or real event), output directory, and path to various required UCERF3 inputs and cache files (located in the [inputs directory](inputs)).

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

`u3etas_plot_generator.sh </path/to/etas_configuration.json> </path/to/etas_output.bin or /path/to/results>`

For example, if config.json exists in the current directory and results are consoludated using a [binary output filter](json_examples/README.md#binary-output-filters) in results.bin:

`u3etas_plot_generator.sh config.json results.bin`

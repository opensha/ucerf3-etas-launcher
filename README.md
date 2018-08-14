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

Thend efine the following environmental variables in your login script (outside the scope of this documentation, for most users editing `~/.bash_profile` is a good place to do this)

  * `ETAS_LAUNCHER`: the path to the `ucerf3-etas-launcher` directory. Optional but recommended as it allows for the use of relative paths in ETAS configuration files
  * `ETAS_MEM_GB`: maximum amount of memory to assign to ETAS calculations. ETAS simulations require lots of memory (about 5 GB per calculation thread), set as high as possible with a small buffer for other OS software. I typically set it to system memory minus 2 Gb
  * `ETAS_THREADS`: the number of threads to spawn during ETAS calculations. Setting it globally here is optional, otherwise it can either be specified on the command line when running ETAS calculations via the `--threads <threads>` argument or it will be determined on-the-fly from the total amount of memory available
  
### .bash_profile example

Here is an example `~/.bash_profile` script defining these variables. This assumes a system with 16 GB of memory.

```
export ETAS_MEM_GB=14
export ETAS_LAUNCHER=/home/kevin/git/ucerf3-etas-launcher
export ETAS_THREADS=3
```

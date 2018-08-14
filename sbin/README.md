# UCERF3-ETAS Launcher & Processing Scripts

## General notes

* These scripts call Java code and all assume that that opensha-ucerf3-all.jar file is in the directory one level above, as is the case in this distribution. If you copy these scripts elsewhere, they will no longer work.
* ETAS simulations are memory intensive and Java requires that you set the maximum memory that you intend to use BEFORE runtime. These scripts will attempt to detect total system memory using the `free` command, and allocate 80% of that amount to java. You can override this setting by setting the `ETAS_MEM_GB` environmental variable before running (in your current shell, or globally in your ~/.bashrc file).

## Run ETAS simulations: u3etas_launcher.sh

USAGE: `u3etas_launcher.sh [--num-threads <threads>] </path/to/etas_config.json>`

This script is used to run UCERF3-ETAS simulations on a local machine. It takes an ETAS configuration JSON file as input, and optionally an argument specifying the number of threads to use (the number of simulations to run in parallel at a given time).

ETAS simulations require about 5 GB of memory per thread, so choose the number of threads carefully and see notes on how to set memory limits above. You can also control the number of threads by setting the `ETAS_THREADS` environmental variable. If you do not specify a thread count, the number of threads will be calculated as the total memory allocate to Java divided by 5 GB, so 15 GB of memory will result in 3 calculation threads.

## Plot ETAS results: u3etas_plot_generator.sh

USAGE: `u3etas_plot_generator.sh [--no-maps] </path/to/etas_config.json> </path/to/binary_catalogs_output.bin OR /path/to/results directory>`

This script is used to generate output plots/HTML for ETAS simulations. It requires an ETAS configuration JSON file and the path to either a binary ETAS catalogs file or the results directory. Binary catalog files are preferred for faster plot generation and will automatically be generated during ETAS simulations as long as the `binaryOutputFilters` section is populated in the JSON input file (see documentation in the json_examples directory), or can be generated after the fact with the `u3etas_binary_writer.sh` script in this directory. Alternatively, you can pass the path to the "results" directory.

If you don't have internet access, or the opensha.usc.edu map server is down, pass the optional "--no-maps" argument to disable plots which require the server.

Plots will be stored in the "plots" subdirectory, and both markdown (`README.md`) and HTML (`index.html`) will be written to the output directory specified in the JSON configuration file.

## Build binary catalog files: u3etas_binary_writer.sh

USAGE: `u3etas_binary_writer.sh </path/to/etas_config.json> [</path/to/results>]`

This script is used to [re]build binary catalog files from a directory containing all UCERF3-ETAS results. By default, it looks in the `results` subdirectory of the output directory specified in the JSON file, but this can be overridded by supplying an optional second argument.

The `binaryOutputFilters` section must be populated in the JSON input file (see documentation in the json_examples directory), and results will be written to the JSON output directory.

## Convert binary catalog files to ASCII: u3etas_ascii_writer.sh

USAGE: `u3etas_ascii_writer.sh </path/to/binary_catalogs_output.json> </path/to/output-dir or zip file> [<num-catalogs-to-write>]`

This script is used to convert binary catalog files to human readable ASCII files (which are inefficient and large, but easier to process externally in other codes). It takes a binary catalog file, and either the path to a directory in which ASCII files should be written, or a path to a zip file which should be created to contain these files. If you only want to write a subset of catalogs, you can supply a third argument with the total number of catalogs to write out.

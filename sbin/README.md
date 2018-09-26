# UCERF3-ETAS Launcher & Processing Scripts

## General notes

* These scripts call Java code and all assume that that opensha-ucerf3-all.jar file is in the directory one level above, as is the case in this distribution. If you copy these scripts elsewhere, they will no longer work.
* ETAS simulations are memory intensive and Java requires that you set the maximum memory that you intend to use BEFORE runtime. These scripts will attempt to detect total system memory using the `free` command, and allocate 80% of that amount to java. You can override this setting by setting the `ETAS_MEM_GB` environmental variable before running (in your current shell, or globally in your ~/.bashrc file).

## Run ETAS simulations: u3etas_launcher.sh

USAGE: `u3etas_launcher.sh [--threads <threads>] </path/to/etas_config.json>`

This script is used to run UCERF3-ETAS simulations on a local machine. It takes an ETAS configuration JSON file as input, and optionally an argument specifying the number of threads to use (the number of simulations to run in parallel at a given time).

ETAS simulations require about 5 GB of memory per thread, so choose the number of threads carefully and see notes on how to set memory limits above. You can also control the number of threads by setting the `ETAS_THREADS` environmental variable. If you do not specify a thread count, the number of threads will be calculated as the total memory allocate to Java divided by 5 GB, so 15 GB of memory will result in 3 calculation threads.

## Plot ETAS results: u3etas_plot_generator.sh

USAGE: `u3etas_plot_generator.sh [--no-maps] </path/to/etas_config.json> [</path/to/binary_catalogs_output.bin OR /path/to/results directory>]`

This script is used to generate output plots/HTML for ETAS simulations. It requires an ETAS configuration JSON file and optionally the path to either a binary ETAS catalogs file or the results directory. Binary catalog files are preferred for faster plot generation and will automatically be generated during ETAS simulations as long as the `binaryOutputFilters` section is populated in the JSON input file (see documentation in the json_examples directory), or can be generated after the fact with the `u3etas_binary_writer.sh` script in this directory. Alternatively, you can pass the path to the "results" directory, or omit the argument and the plotter will serach for suitable binary files (or the results subdirectory) in the output directory specified in the JSON configuration file.

If you don't have internet access, or the opensha.usc.edu map server is down, pass the optional "--no-maps" argument to disable plots which require the server.

Plots will be stored in the "plots" subdirectory, and both markdown (`README.md`) and HTML (`index.html`) will be written to the output directory specified in the JSON configuration file.

## Build binary catalog files: u3etas_binary_writer.sh

USAGE: `u3etas_binary_writer.sh </path/to/etas_config.json> [</path/to/results>]`

This script is used to [re]build binary catalog files from a directory containing all UCERF3-ETAS results. By default, it looks in the `results` subdirectory of the output directory specified in the JSON file, but this can be overridded by supplying an optional second argument.

The `binaryOutputFilters` section must be populated in the JSON input file (see documentation in the json_examples directory), and results will be written to the JSON output directory.

## Convert binary catalog files to ASCII: u3etas_ascii_writer.sh

USAGE: `u3etas_ascii_writer.sh </path/to/binary_catalogs_output.bin> </path/to/output-dir or zip file> [<num-catalogs-to-write>]`

This script is used to convert binary catalog files to human readable ASCII files (which are inefficient and large, but easier to process externally in other codes). It takes a binary catalog file, and either the path to a directory in which ASCII files should be written, or a path to a zip file which should be created to contain these files. If you only want to write a subset of catalogs, you can supply a third argument with the total number of catalogs to write out.

## Filter out spontaneous ruptures (descendants of triggers only): u3etas_filter_descendants.sh

USAGE: `u3etas_filter_descendants.sh </path/to/etas_config.json> </path/to/binary_catalogs_output.bin OR /path/to/results directory> </path/to/filtered_descendants_output.bin>`

This script is used to filter out any spontaneous ruptures from catalogs, leaving only descendants of trigger ruptures (note: if a trigger catalog is supplied but treatTriggerCatalogAsSpontaneous=true, its descendants will be removed). It takes an ETAS configuration JSON file, either an input binary file or path to the results directory, and the path where the filtered output binary catalogs file should be written.

## Combine binary catalog files from multiple simulations: u3etas_combine_binary.sh

USAGE: `u3etas_combine_binary.sh </path/to/binary_catalogs_1.bin> </path/to/binary_catalogs_2.bin> [... </path/to/binary_catalogs_N.bin>] </path/to/combined_binary_catalogs.bin>`

This script is used to combine the binary output files from multiple runs of UCERF3 ETAS. This is useful if, for example, first you ran 1000 simulations of a scenario and then you ran another 1000 later. You would use this script to combine the two simulations into a single binary file, which can be used to generate plots from all 2000 catalogs.

## Search for subsections by name or location: u3etas_section_search.sh

USAGE: `u3etas_section_search.sh [--latitude <lat> --longitude <lon> [--radius <radius>]] [--name <section-name>] </path/to/fault_sustem_solution.zip>`

This script allows you to search for UCERF3 subsections by location or by name. This can be useful to find subsection indexes which are near a recent earthquake, in order to build a trigger rupture.

For example, search for all sections within 20km of 34, -118:

`u3etas_section_search.sh --latitude 34 --longitude -118 --radius 20 $ETAS_LAUNCHER/inputs/2013_05_10-ucerf3p3-production-10runs_COMPOUND_SOL_FM3_1_SpatSeisU3_MEAN_BRANCH_AVG_SOL.zip`

## Search for ruptures by location and magnitude range: u3etas_rupture_search.sh

USAGE: `u3etas_rupture_search.sh --latitude <lat> --longitude <lon> --radius 50 --min-mag <min-mag> --max-mag <max-mag> </path/to/fault_sustem_solution.zip>`

This script allows you to search for UCERF3 supraseismogenic ruptures by location and magnitude range. It will print out the ID number (which can be used to define a trigger rupture in the ETAS JSON file), as well as other properties for all matching ruptures.

For example, search for all ruptures M7-7.1 within 20km of 34, -118:

`u3etas_rupture_search.sh --latitude 34 --longitude -118 --radius 20 --min-mag 7 --max-mag 7.1 $ETAS_LAUNCHER/inputs/2013_05_10-ucerf3p3-production-10runs_COMPOUND_SOL_FM3_1_SpatSeisU3_MEAN_BRANCH_AVG_SOL.zip`

## Compute comparison UCERF3-TD or UCERF3-TI catalogs: u3etas_td_comparison_launcher.sh

USAGE: `u3etas_td_comparison_launcher.sh --fss-file </path/to/fault_sustem_solution.zip> --duration <duration-years> [--start-year <year> --cov <COV option --time-independent> --gridded] </path/to/output_dir>`

This script allows you to compute UCERF3-TD or UCERF3-TI catalogs. Output will be in the UCERF3-ETAS ASCII format, with some ETAS specific fields populated with default values (generation fiexed to zero, etc). Hypocenter locations are randomly sampled from the rupture surface. If the optional `--time-independent` option is supplied, the UCERF3-TI model is used. The simulation starts on January 1 of the current year unless `--start-year` is supplied. The optional `--cov` option allows you to specify a different magnitude-dependent aperiodicity branch from the UCERF3-TD logic tree: LOW_VALUES, MID_VALUES, or HIGH_VALUES. By default, only supra-seismogenic, fault-based ruptures are included in output catalogs. You can enable gridded ruptures with the `--gridded` option, but this will dramatically slow down the calculation of time-dependent catalogs (TI will still be fast). As gridded ruptures in UCERF3-TD are by nature time-indepedent, you might consider calculating them in time-independent mode then stitching them into a fault-only TD catalog.

For example, for a 100 year UCERF3 simulation starting in 2014, written to /tmp/u3td_output:

`u3etas_td_comparison_launcher.sh --fss-file $ETAS_LAUNCHER/inputs/2013_05_10-ucerf3p3-production-10runs_COMPOUND_SOL_FM3_1_SpatSeisU3_MEAN_BRANCH_AVG_SOL.zip --duration 100 --start-year 2012 /tmp/u3td_output`

# Configuring UCERF3-ETAS Simulations

UCERF3-ETAS simulations are defined with [JSON](https://beginnersbook.com/2015/04/json-tutorial/) configuration files. These files describe the simulation parameters (start time, inclusion of spontaneous ruptures, etc), optional input 'trigger' ruptures (if you are simulating the aftermath of a scenario or real event), output directory, and path to various required UCERF3 inputs and cache files (located in the [inputs directory](inputs)).

While cumbersome, you can create configuration files from scratch or modify an example in the [json_examples directory](json_examples) after reading the [file format documentation](json_examples/README.md). A simpler approach is often to use the scripts defined below which generate JSON configuration files for either scenario ruptures, spontaneous simulations, or ComCat events.

## Configuring simulations for ComCat events

USAGE: `u3etas_comcat_event_config_builder.sh [options] --num-simulations <num> --event-id <event-id>`

This script is used to generate JSON configuration files which are specific to a ComCat event. The only required arguments are the number of simulations (`--num-simulations <num>`) and the ComCat event ID (`--event-id <event-id>`, e.g. `--event-id ci38457511`). If `--output-dir <path>` has not been supplied, it assumes the the `$ETAS_SIM_DIR` environmental variable has been set and creates a sub-directory of `$ETAS_SIM_DIR`. Commonly used options are summarized below, run the command without any arguments to see details on all options. Note that accessing ComCat occasionally failes, and retrying immediate usually works. Input plots of the spatial distribution of input ruptures, distances to UCERF3 fault sections and polygons will be written to the `config_input_plots` subdirectory of the output directory.

* Use `--days-before <days>`, `--hours-before <hours>`, `--days-after <days>`, `--hours-after <hours>`, and/or `--end-now` to include other ComCat events before and/or after the specified event. All events within a certain radius of the mainshock will be included. That radius is the Wells & Coppersmith (1994) radius by default, but can be overridden with `--radius <radius>` in kilometers. Also considers the optional `--min-mag <mag>`, `--min-depth <depth>`, and `--max-depth <depth>` arguments.
* Use `--finite-surf-shakemap` to attempt to pull a finite surface from ShakeMap for the primary event. Optionally also supply `finite-surf-shakemap-min-mag <min-mag>` to fetch ShakeMap surfaces for all other events above a given magnitude if available.
* Use `--finite-surf-inversion` to attempt to pull a finite surface from the slip inverson. Note that this surface may be very large and include areas with little or no inverted slip, use `--finite-surf-inversion-min-slip <min-slip>` in meters to specify a minimum amount of slip on each pach for it to be included. Optionally also supply `finite-surf-inversion-min-mag <min-mag>` to fetch inverted surfaces for all other events above a given magnitude if available.
* Specify your own custom, planar finite surface with `--finite-surf-dip <dip>`, `--finite-surf-strike <strike>`, `--finite-surf-length-along <length>`, `--finite-surf-length-before <length>`, `--finite-surf-upper-depth <depth>`, and `--finite-surf-lower-depth <depth>`. Length along is how far in the along-strike direction the surface extends from the hypocenter, and before is how far in the opposite-strike direction it extends.
* Specify any UCERF3 fault surfaces to reset (elastic rebound) with `--reset-sects <id1,id2,...,idN>`. You can also construct a finite-surface for the primary rupture from these sections with the `--finite-surf-from-sections` option.
* Specify the simulation duration with `--duration-years <duration>`
* Include spontaneous ruptures with `--include-spontaneous`
* If you wish to configure a SLURM job submission script using one of the preset sites, use the `--hpc-site <name>` argument with either `USC_HPC` or `TACC_STAMPEDE2`. Specify the number of nodes needed with `--nodes <num>` and the number of wall clock time hours with `--hours <hours>`

### Examples

Here's an example for ShakeMap surfaces of the 2019 M7.1 Ridgecrest earthquake, configured for submission at the USC HPC center, including 7 days of prior events and starting the moment after the mainshock:

`u3etas_comcat_event_config_builder.sh --event-id ci38457511 --num-simulations 100000 --days-before 7 --finite-surf-shakemap --finite-surf-shakemap-min-mag 5 --hpc-site USC_HPC --nodes 36 --hours 24 --queue scec`

Here's an example for a custom drawn surface of the 2019 M7.1 Ridecrest earthquake, including 7 days of prior events and starting 28 days after the mainshock:

`u3etas_comcat_event_config_builder.sh --event-id ci38457511 --num-simulations 100000 --days-before 7 --days-after 28 --finite-surf-dip 85 --finite-surf-strike 139 --finite-surf-length-along 29 --finite-surf-length-before 22 --finite-surf-upper-depth 0 --finite-surf-lower-depth 12`

## Common Options

Thse options are common to both configuration scripts:

| **Name** | **Default Value** | **Description** | **Example** |
|-------|-------|-------|-------|
| `--num-simulations <num>` | **REQUIRED** | Number of ETAS simulations to perform, must be >0 | `--num-simulations 10000` |
| `--output-dir <path>` | **REQUIRED** | Output dir to write results. If not supplied, directory name will be built automatically with the date, simulation name, and parameters, and placed in $ETAS_SIM_DIR | `--output-dir /path/to/simulation-dir` |
| `--random-seed <seed>` | (unique random seed) | Random seed for simulations | `--random-seed 12345` |
| `--fault-model <FM>` | `FM3_1` | Fault model, one of `FM3_1` or `FM3_2` | `--fault-model FM3_1` |
| `--include-spontaneous` | (disabled) | If supplied, spontaneous ruptures will be enabled | `--include-spontaneous` |
| `--historical-catalog` | (disabled) | If supplied, historical catalog will be included | `--include-spontaneous` |
| `--duration-years <duration>` | `10` | Simulation duration (years) | `--duration-years 10` |
| `--prob-model <name>` | `FULL_TD` | UCERF3-ETAS Probability Model, one of `FULL_TD`, `NO_ERT`, or `POISSON` | `--prob-model FULL_TD` |
| `--scale-factor <scale>` | (prob-model dependent) | Total rate scale factor. Default is determined from probability model | `--scale-factor 1.14` |
| `--gridded-only` | (disabled) | Flag for gridded only (no-faults) ETAS. Will also change the default probability model to POISSON | `--gridded-only` |
| `--etas-k` | `-2.367` | ETAS productivity parameter parameter, k, in Log10 units of (days)^(p-1) | `--etas-k -2.367` |
| `--etas-p` | `1.07` | ETAS temporal decay paramter, p | `--etas-p 1.07` |
| `--etas-c` | `0.0065` | ETAS minimum time paramter, c, in days | `--etas-c 0.0065` |
| `--impose-gr` | (disabled) | If supplied, imposeGR will be set to true | `--impose-gr` |

## HPC Options

These scripts can also automatically generate SLURM job submission files for use on clusters. Read the [documentation here](parallel/) for more information. SLURM scripts are modified from the [examples here](parallel/mpj_examples/).

| **Name** | **Default Value** | **Description** | **Example** |
|-------|-------|-------|-------|
| `--hpc-site` | (required if you want to generate SLURM scripts) | HPC site to configure for. Either `USC_HPC` or `TACC_STAMPEDE2` | `--hpc-site USC-HPC` |
| `--nodes` | (determined from example script) | Compute nodes to run on for HPC configuration | `--nodes 10` |
| `--hours` | (determined from example script) | Wall-clock hours for HPC configuration | `--hours 24` |
| `--threads` | (determined from example script) | Threads per node for HPC configuration | `--threads 8` |
| `--queue` | (determined from example script) | Queue name for HPC configuration | `--queue scec` |

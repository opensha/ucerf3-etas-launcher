# Configuring UCERF3-ETAS Simulations

UCERF3-ETAS simulations are defined with [JSON](https://beginnersbook.com/2015/04/json-tutorial/) configuration files. These files describe the simulation parameters (start time, inclusion of spontaneous ruptures, etc), optional input 'trigger' ruptures (if you are simulating the aftermath of a scenario or real event), output directory, and path to various required UCERF3 inputs and cache files (located in the [inputs directory](../inputs)).

While cumbersome, you can create configuration files from scratch or modify an example in the [json_examples directory](../json_examples) after reading the [file format documentation](json_configuration_format.md). A simpler approach is often to use the scripts defined below which generate JSON configuration files for either [specific ComCat events/sequences](#configuring-simulations-for-comcat-events), [all ComCat events in a region and time window](#configuring-simulations-for-comcat-regions-and-time-windows), or [scenario ruptures/spontaneous simulations](#configuring-simulations-for-scenarios-or-spontaneous-events).

## Configuring simulations for ComCat events

USAGE: `u3etas_comcat_event_config_builder.sh [options] --num-simulations <num> --event-id <event-id>`

This script is used to generate JSON configuration files which are specific to a ComCat event. The only required arguments are the number of simulations (`--num-simulations <num>`) and the ComCat event ID (`--event-id <event-id>`, e.g. `--event-id ci38457511`). If `--output-dir <path>` has not been supplied, it assumes the the `$ETAS_SIM_DIR` environmental variable has been set and creates a sub-directory of `$ETAS_SIM_DIR`. Commonly used options specific to ComCat events are summarized below, but all of the [common](#common-options) and [HPC](#hpc-options) also apply. You can also run the command without any arguments to see details on all options. The order of finite fault surfaces matters, and options given first have highest priority. So if, for example, you want to prefer ShakeMap over Inverted Surfaces, give the ShakeMap option first.

Note that accessing ComCat occasionally failes, and retrying immediate usually works. Input plots of the spatial distribution of input ruptures, distances to UCERF3 fault sections and polygons will be written to the `config_input_plots` subdirectory of the output directory.

### Including fore/aftershocks from ComCat

Use `--days-before <days>`, `--hours-before <hours>`, `--days-after <days>`, `--hours-after <hours>`, and/or `--end-now` to include other ComCat events before and/or after the specified event. See the section below for details on the region in which events will be included.

If you include aftershocks, the simulations will start immediately following the aftershock data period supplied, otherwise they will start immediately following the mainshock.

### Specifying ComCat regions for data fetching and post-simulation comparisons

The ComCat region is used for fetching fore/aftershocks (see above), and also for comparison plots after simulations complete which compare actual aftershock data from ComCat to simulation predictions. By default, the region is circular about the mainshock hypocenter. The circular radius is determined from Wells & Coppersmich (1994), but can be overridden with `--radius <radius>` in kilometers. If a finite surface reprsentation is used for the mainshock, a sausage region with that radius will be used instead.

You can also supply a custom region with the `--region lat1,lon1[,lat2,lon2]` argument. If only one location is supplied, then a circular region is built and you must also supply the --radius argument. Otherwise, if two locations and the --radius option is supplied, a sausage region is drawn around the line defined, otherwise a rectangular region is defined between the two points.

You can also specify the minimimum magnitude with `--min-mag <mag>`, and depth range with `--min-depth <depth>` and `--max-depth <depth>`. The default minimum depth is -10 km (that is, above the earth's surface), and the default maximum depth is the greater of 24 km (the maximum UCERF3-ETAS simulated depth) and twice the hypocentral depth.

### Including finite surfaces from ShakeMap

Use `--finite-surf-shakemap` to attempt to pull a finite surface from ShakeMap for the primary event. You can optionally also supply `finite-surf-shakemap-min-mag <min-mag>` to fetch ShakeMap surfaces for all other events above a given magnitude if available. If multiple ShakeMap versions are available in ComCat, the most preffered version will be used unless `--finite-surf-shakemap-version <version-number` is suppplied. You can also use simple planar fault drawn through the extents of the ShakeMap surface with the `--finite-surf-shakemap-planar-extents` flag.

### Including inverted finite surfaces from ComCat

Use `--finite-surf-inversion` to attempt to pull a finite surface from the slip inverson. Note that this surface may be very large and include areas with little or no inverted slip, which can be mitigated by also supplying `--finite-surf-inversion-min-slip <min-slip>` in meters to specify a minimum amount of slip on each patch for it to be included. Optionally also supply `finite-surf-inversion-min-mag <min-mag>` to fetch inverted surfaces for all other events above a given magnitude if available.

### Building your own custom surface

You can specify your own custom, planar finite surface for the primary rupture with `--finite-surf-dip <dip>`, `--finite-surf-strike <strike>`, `--finite-surf-length-along <length>`, `--finite-surf-length-before <length>`, `--finite-surf-upper-depth <depth>`, and `--finite-surf-lower-depth <depth>`. The surface is forced to intersect the hypocenter. Length along is how far in the along-strike direction the surface extends from the hypocenter, and before is how far in the opposite-strike direction it extends.

### Using a KML file to specify the fault surface

Scientists in the field often map surface rupture with KML/KMZ files. You can construct a primary (mainshock) surface from lines drawn in one of these files with the `--kml-surf <file>` option. If you do so, you must supply the lower seismogenic depth with `--kml-surf-lower-depth <depth>` in km, and can optionally (deafult is 0 km) supply the upper depth with `--kml-surf-upper-depth`. Surfaces are assumed to be vertical unless `--kml-surf-dip <dip>` is supplied (you can also supply the dip direction azimuth with `--kml-surf-dip-dir <direction>`).

By default, all lines in the KML file are used, but you can use only a specific feature by name with `--kml-surf-name <name>`. Repeat this argument multiple times to include multiple possible names (logical OR). If the `--kml-surf-name-contains` flag is supplied, then it need not be an exact match.

### Reset UCERF3 Fault Sections

Specify any UCERF3 fault surfaces to reset (in an elastic rebound sense) with `--reset-sects <id1,id2,...,idN>`. By default they will be reset at the origin time of the mainshock (the event that you defined with the `--event-id <event-id>` argument), but you can also specify different event IDs for sections with the format `--reset-sects <event-id>:<id1,id2,...,idN>`. You can also construct a finite-surface from these sections with the `--finite-surf-from-sections` option.

### Use custom mainshock ETAS parameters or magnitude

You can override the ETAS k, p, and c parameters for the mainshock only with the `--event-etas-k <value>` (Log10 units), `--event-etas-p <value>`, and `--event-etas-c <value>` options. You can also override the magnitude of the mainshock with `--mod-mag <mag>`. You can also override these values for any events with the format `--argument <event-id>:<value>`, e.g. `--mod-mag ci38443183:6.48` or `--etas-event-k ci38443183:-2.5`.  You can repeat these options multiple times to specify values for multiple ruptures.

### Other options

In addition to the [common](#common-options) and [HPC](#hpc-options) options, you can supply `--name "Simulation Name"` to override the otherwise automatically-generated simulation name. You can add custom text at the end of the automatically generated name with `--name-add "Text Here"`. You can also force the ComCat evaluation plots to use a specified magnitude-of-completeness value with `--mag-complete <mag>`.

### Examples

Here's an example for ShakeMap surfaces of the 2019 M7.1 Ridgecrest earthquake, configured for submission at the USC HPC center, including 7 days of prior events and starting the moment after the mainshock:

`u3etas_comcat_event_config_builder.sh --event-id ci38457511 --num-simulations 100000 --days-before 7 --finite-surf-shakemap --finite-surf-shakemap-min-mag 5 --hpc-site USC_HPC --nodes 36 --hours 24 --queue scec`

Here's an example for a custom drawn surface of the 2019 M7.1 Ridecrest earthquake, including 7 days of prior events and starting 28 days after the mainshock:

`u3etas_comcat_event_config_builder.sh --event-id ci38457511 --num-simulations 100000 --days-before 7 --days-after 28 --finite-surf-dip 85 --finite-surf-strike 139 --finite-surf-length-along 29 --finite-surf-length-before 22 --finite-surf-upper-depth 0 --finite-surf-lower-depth 12`

## Configuring simulations for ComCat regions and time windows

USAGE: `u3etas_comcat_config_builder.sh [options] --num-simulations <num> --event-id <event-id>`

You can also specify a region and time window to fetch ComCat events, instead of focusing on a single event (and its after/foreshocks). This could be useful for swarms, or other sequences which don't fit the mainshock/aftershock paradigm. It can also be used for spontaneous simulations with a historical catalog, where you want to add ComCat events between the end of the historical catalog and the simulation start time.

The script shares many options with the script for [ComCat events](#configuring-simulations-for-comcat-events), with some differences which are outlined below.

### Specifying ComCat data start time

You must always specify the start time used to fetch ComCat data. This can be done a number of different ways:

* `--start-time <time>`: Start fetching ComCat data at the given time in epoch milliseconds
* `--start-date <date>`: Start fetching ComCat data at the given date in the format 'yyyy-MM-dd' (e.g. 2019-01-01) or 'yyyy-MM-ddTHH:mm:ss' (e.g. 2019-01-01T01:23:45). All dates and times in UTC
* `--start-at <event-id>`: Start fetching ComCat data at the time of the given ComCat event
* `--start-days-before <days>`: Start fetching ComCat data this many days before the end time
* `--start-after-historical`: Flag to start fetching ComCat data immediately following the end of the UCERF3 historical catalog (at 2012-04-24T19:44:19)

### Specifying ComCat data end time

You must always also specify the end time used to fetch ComCat data. The simulation start time will be 1 second after the ComCat data end time. This can be done a number of different ways:

* `--end-time <time>`: End fetching ComCat data at the given time in epoch milliseconds
* `--end-year <year>`: End fetching ComCat data at the given year
* `--end-date <date>`: End fetching ComCat data at the given date in the format 'yyyy-MM-dd' (e.g. 2019-01-01) or 'yyyy-MM-ddTHH:mm:ss' (e.g. 2019-01-01T01:23:45). All dates and times in UTC
* `--end-after <event-id>`: End fetching ComCat data immediately after the time of the given ComCat event
* `--end-days-after <days>`: End fetching ComCat data this many days after the start time
* `--end-now`: Flag to end fetching ComCat data at the current time

### Specifying the ComCat region

You can use the optional `--region <lat1,lon1[,lat2,lon2]` to specify a ComCat data region, otherwise the entire California UCERF3 model region will be used. If only one location is supplied, then a circular region is built and you must also supply the `--radius <radius>` argument (in kilometers). Otherwise, a rectangular region is defined between the two points.

### Specifying finite fault surfaces

You can use the [ShakeMap](#including-finite-surfaces-from-shakemap) surfaces option, `--finite-surf-shakemap`, to look for ShakeMaps. By deafult, it will look for ShakeMaps for all ruptures with M>=5, but that can be overridden with `--finite-surf-shakemap-min-mag <mag>`. Same for [Inverted Surfaces](#including-inverted-finite-surfaces-from-comcat) with the `--finite-surf-inversion` and `--finite-surf-inversion-min-mag` options, and [surfaces from UCERF3 subsections](#reset-ucerf3-fault-sections) with the `--finite-surf-from-sections` flag and `--reset-sects <event-id>:<id1,id2,...,idN>` options.

As with the ComCat event builder, the order of finite fault surfaces matters, and options given first have highest priority. So if you want to prefer ShakeMap over Inverted Surfaces, give the ShakeMap option first.

### Examples

Here's an example to fetch events between 2 moderate magnitude Northern California events in October, 2019, for a custom region:

`u3etas_comcat_config_builder.sh --start-at nc73291880 --end-after nc73292360 --region 38.5,-122.75,36.25,-120.5 --num-simulations 100000 --hpc-site USC_HPC --nodes 36 --hours 24 --queue scec`

Here's an example for simulating spontaneous and historical events starting at the current moment, filling in events from ComCat (with ShakeMap surfaces for M>=6's) between the end of the UCERF3 historical catalog and the present moment:

`u3etas_comcat_config_builder.sh --start-after-historical --end-now --historical-catalog --include-spontaneous --num-simulations 10000 --finite-surf-shakemap --finite-surf-shakemap-min-mag 6 --hpc-site USC_HPC --nodes 36 --hours 24 --queue scec`

## Configuring simulations for scenarios or spontaneous events

USAGE: `u3etas_config_builder.sh [options] --num-simulations <num>`

This script is used to generate JSON configuration files for scenarios or spontaneous ruptures. The only required arguments are the number of simulations (`--num-simulations <num>`) and the the simulation start time (either `--start-time <epoch-millis>` or `--start-year <year>`), though you must either enable spontaneous ruptures (with the `--include-spontaneous` flag), the historical catalog (with `--historical-catalog`), or specify trigger ruptures.

### Trigger rupture options

You can specify a point source rupture with `--latitude <lat>`, `--longitude <lon>`, `--depth <depth>`, a UCERF3 Fault System Solution rupture index with `--fss-index`, or build a rupture from 1 or more fault subsection indices with `--fault-sections <ids>` (e.g. `--fault-sections 120,121,122`). You must also supply a magnitude with `--magnitude <mag>`, execpt for the UCERF3 rupture index option where magnitude is optional (will default to the UCERF3 magnitude for that rupture).

Trigger ruptures are assumed to start immediately before the simulation start time unless you supply another time with `--trigger-time <epoch-millis>`.

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
| `--historical-catalog-as-spontaneous` | (disabled) | If supplied, aftershocks which descend from the historical catalog (enabled with --historical-catalog) will be treated identically to spontaneous ruptures for the purposes of output plots and tables | `--historical-catalog-as-spontaneous` |
| `--duration-years <duration>` | `10` | Simulation duration (years) | `--duration-years 10` |
| `--prob-model <name>` | `FULL_TD` | UCERF3-ETAS Probability Model, one of `FULL_TD`, `NO_ERT`, or `POISSON` | `--prob-model FULL_TD` |
| `--scale-factor <scale>` | (prob-model dependent) | Total rate scale factor. Default is determined from probability model | `--scale-factor 1.14` |
| `--gridded-only` | (disabled) | Flag for gridded only (no-faults) ETAS. Will also change the default probability model to POISSON | `--gridded-only` |
| `--etas-k` | `-2.367` | ETAS productivity parameter parameter, k, in Log10 units of (days)^(p-1) | `--etas-k -2.367` |
| `--etas-k-cov` | `0` | COV of ETAS productivity parameter parameter, k | `--etas-k-cov 1.16` |
| `--etas-p` | `1.07` | ETAS temporal decay paramter, p | `--etas-p 1.07` |
| `--etas-c` | `0.0065` | ETAS minimum time paramter, c, in days | `--etas-c 0.0065` |
| `--impose-gr` | (disabled) | If supplied, imposeGR will be set to true | `--impose-gr` |

## HPC Options

These scripts can also automatically generate SLURM job submission files for use on clusters. Read the [documentation here](../parallel/) for more information. SLURM scripts are modified from the [examples here](../parallel/mpj_examples/).

| **Name** | **Default Value** | **Description** | **Example** |
|-------|-------|-------|-------|
| `--hpc-site` | (required if you want to generate SLURM scripts) | HPC site to configure for. Either `USC_HPC` or `TACC_STAMPEDE2` | `--hpc-site USC-HPC` |
| `--nodes` | (determined from example script) | Compute nodes to run on for HPC configuration | `--nodes 10` |
| `--hours` | (determined from example script) | Wall-clock hours for HPC configuration | `--hours 24` |
| `--threads` | (determined from example script) | Threads per node for HPC configuration | `--threads 8` |
| `--queue` | (determined from example script) | Queue name for HPC configuration | `--queue scec` |

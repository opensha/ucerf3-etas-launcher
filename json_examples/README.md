# ETAS Configuration File Documentation

## Calculation Paramters

This section describes calculation extents and some calculation parameters

| **Name** | **Required?** | **Description** | **Example** |
|-------|-------|-------|-------|
| numSimulations | yes | Number of etas simulations to perform for the given configuration, must be >0 | `"numSimulations": 10000` |
| duration | yes | Simulation duration in years | `"duration": 10.0` |
| startYear | no | Simulation start year (integer). Must supply this or startTimeMillis below (not both) | `"startYear": 2018` |
| startTimeMillis | no | Simulation start time in epoch milliseconds. Must supply this or startYear above (not both) | `"startTimeMillis": 1514764800000` |
| includeSpontaneous | yes | If 'true', spontaneous events will be computed, if 'false', only triggered (and either trigger ruptures or a trigger catalog must be supplied) | `"includeSpontaneous": true` |
| randomSeed | no | Can be used to reproduce a single run, only valid if numSimulations=1 | `"randomSeed": 1234567` |
| binaryOutput | yes | If yes, catalogs will be converted to binary format when each simulation completes to save space. Recommended for large simulation counts (>100) | `"binaryOutput": true` |
| binaryOutputFilters | no | If supplied, consolidated binary files will be written for each of the given configurations. This works even with binaryOutput=false, and can be used to automatically generated magnitude filtered files for analysis later | [see object format below](#binary-output-filters)  |
| forceRecalc | no | If true, all simulations will be recalculated even if they finished in an earlier run (with the same output directory). | `"forceRecalc": false` |
| simulationName | no | Simulation name. If omitted, one will be automatically generated (but won't be very descriptive). Will show up in output plots. | `"simulationName": "Mojave M7, no spontaneous"` |
| numRetries | no | Number of times to try a simulation before exiting if errors are encountered. Setting >1 will help to recover from things like filesystem issues during a large simulation. | `"numRetries": 3 |

## Binary Output Filters

TODO

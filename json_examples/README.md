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
| numRetries | no | Number of times to try a simulation before exiting if errors are encountered. Setting >1 will help to recover from things like filesystem issues during a large simulation. | `"numRetries": 3` |

## Input Ruptures ##

Input ruptures are all optional, though at least one must be supplied if includeSpontaneous=false above.

 **Name** | **Required?** | **Description** | **Example** |
|-------|-------|-------|-------|
| triggerCatalog | no | Path to trigger catalog file inb 10 column format. This can be a custom catalog, or can be the UCERF3 historical catalog | `"triggerCatalog": "/path/to/trigger_catalog.txt"` |
| triggerCatalogSurfaceMappings | no | Path to XML file with finite surface mappings for ruptures in triggerCatalog. Complicated format, and probably only useful for the UCERF3 historical catalog | `"triggerCatalogSurfaceMappings": "/path/to/u3_historical_catalog_finite_fault_mappings.xml"` |
| triggerRuptures | no | Speicification of individual trigger ruptures. Array format, and you can include as many as needed. | [see description below](#trigger-ruptures) |

### Trigger Ruptures

JSON array for specifying trigger ruptures (0 or more). There are 3 types of trigger ruptures, and can be mixed in the array.

#### Point Source Rupture

This represents a point source rupture, without any finite fault surface or fault sections to reset (for elastic rebound probabilities)

 **Name** | **Required?** | **Description** | **Example** |
|-------|-------|-------|-------|
| occurrenceTimeMillis | no | Rupture occurrence time in epoch milliseconds. If omitted, the rupture is assumed to occur at simulation start time | `"occurrenceTimeMillis": 1532665006760` |
| mag | yes | Rupture magnitude | `"mag": 5.3` |
| latitude | yes | Latitude for point source rupture in decimal degrees | `"latitude": 34.213` |
| longitude | yes | Longitude for point source rupture in decimal degrees | `"longitude": -118.537` |
| depth | yes | Depth for point source rupture in kilometers (positive) | `"depth": 18.2` |

#### UCERF3 Fault System Rupture Set Rupture

This represents a rupture from our UCERF3 fault system rupture set, and requires already knowing the index for that rupture. The surface of this rupture will be used for triggering distances, and elastic rebound time of last event will be reset for each rupture subsection.

 **Name** | **Required?** | **Description** | **Example** |
|-------|-------|-------|-------|
| occurrenceTimeMillis | no | Rupture occurrence time in epoch milliseconds. If omitted, the rupture is assumed to occur at simulation start time | `"occurrenceTimeMillis": 1532665006760` |
| mag | no | Rupture magnitude if you wish to override the UCERF3 magnitude for this rupture, otherwise omit | `"mag": 5.3` |
| fssIndex | yes | Rupture index in the UCERF3 fault system solution file | `"fssIndex": 187455` |

#### UCERF3 Section Based Rupture

This represents a rupture built from UCERF3 fault subsections, and requires already knowing the section index numbers. The surface of this rupture will be used for triggering distances, and elastic rebound time of last event will be reset for each rupture subsection.

 **Name** | **Required?** | **Description** | **Example** |
|-------|-------|-------|-------|
| occurrenceTimeMillis | no | Rupture occurrence time in epoch milliseconds. If omitted, the rupture is assumed to occur at simulation start time | `"occurrenceTimeMillis": 1532665006760` |
| mag | yes | Rupture magnitude | `"mag": 5.3` |
| subSectIndexes | yes | JSON array of integer UCERF3 subsection indexes that comprise the rupture | `"subSectIndexes": [ 1412,1413 ]` |

## Binary Output Filters

TODO

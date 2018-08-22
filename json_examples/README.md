# ETAS Configuration File Documentation

This directory contains example JSON UCERF3-ETAS configuration files. Users will probably want to start with one of the supplied examples, and update them as needed. Documentation for each field is below, with those fields most likely to require updating in highlighted in bold.

## Calculation Paramters

This section describes calculation extents and some calculation parameters.

| **Name** | **Required?** | **Description** | **Example** |
|-------|-------|-------|-------|
| **numSimulations** | yes | Number of etas simulations to perform for the given configuration, must be >0 | `"numSimulations": 10000` |
| **duration** | yes | Simulation duration in years | `"duration": 10.0` |
| **startYear** | no | Simulation start year (integer). Must supply this or startTimeMillis below (not both). If supplied, simulations will start at midnight, January 1, UTC | `"startYear": 2018` |
| **startTimeMillis** | no | Simulation start time in epoch milliseconds. Must supply this or startYear above (not both) | `"startTimeMillis": 1514764800000` |
| **includeSpontaneous** | yes | If 'true', spontaneous events will be computed, if 'false', only triggered (and either trigger ruptures or a trigger catalog must be supplied) | `"includeSpontaneous": true` |
| randomSeed | no | Can be used to reproduce a single run, only valid if numSimulations=1 | `"randomSeed": 1234567` |
| binaryOutput | yes | If yes, catalogs will be converted to binary format when each simulation completes to save space. Recommended for large simulation counts (>100) | `"binaryOutput": true` |
| binaryOutputFilters | no | If supplied, consolidated binary files will be written for each of the given configurations. This works even with binaryOutput=false, and can be used to automatically generated magnitude filtered files for analysis later | [see object format below](#binary-output-filters)  |
| forceRecalc | no | If true, all simulations will be recalculated even if they finished in an earlier run (with the same output directory). | `"forceRecalc": false` |
| **simulationName** | no | Simulation name. If omitted, one will be automatically generated (but won't be very descriptive). Will show up in output plots. | `"simulationName": "Mojave M7, no spontaneous"` |
| numRetries | no | Number of times to try a simulation before exiting if errors are encountered. Setting >1 will help to recover from things like filesystem issues during a large simulation. | `"numRetries": 3` |
| **outputDir** | yes | Path to output directory where all results will be written | `"outputDir": "/path/to/etas_output"` |

## Input Ruptures ##

Input ruptures are all optional, though at least one must be supplied if includeSpontaneous=false above.

 **Name** | **Required?** | **Description** | **Example** |
|-------|-------|-------|-------|
| **triggerCatalog** | no | Path to trigger catalog file inb 10 column format. This can be a custom catalog, or can be the UCERF3 historical catalog | `"triggerCatalog": "/path/to/trigger_catalog.txt"` |
| **triggerCatalogSurfaceMappings** | no | Path to XML file with finite surface mappings for ruptures in triggerCatalog. Complicated format, and probably only useful for the UCERF3 historical catalog | `"triggerCatalogSurfaceMappings": "/path/to/u3_historical_catalog_finite_fault_mappings.xml"` |
| **treatTriggerCatalogAsSpontaneous**| no | If true, ruptures in the triggerCatalog (and their descendants) will be treated as spontanous for purposes of output plots/tables. If false, their descendants will be included in analysis which filters out spontaneous ruptures | `"treatTriggerCatalogAsSpontaneous": true` |
| **triggerRuptures** | no | Speicification of individual trigger ruptures. Array format, and you can include as many as needed. | [see description below](#trigger-ruptures) |

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

#### Trigger Ruptures Example

Here is an example specifying 3 trigger ruptures, one of each type. The first one is a UCERF3 Fault System Rupture set rupture, followed by a Point Source Rupture, then finally a UCERF3 Section Based Rupture

```
"triggerRuptures": [
    {
      "occurrenceTimeMillis": 1532638606760,
      "fssIndex": 187455,
      "mag": 6.7
    },
    {
      "occurrenceTimeMillis": 1532665006760,
      "mag": 5.3,
      "latitude": 34.213,
      "longitude": -118.537,
      "depth": 18.2
    },
    {
      "occurrenceTimeMillis": 1532725006760,
      "mag": 6.2,
      "subSectIndexes": [
        1412
      ]
    }
  ]
```

### Input File Paths

These paths must be updated for each system, or if you want to use different fault system solution files

 **Name** | **Required?** | **Description** | **Example** |
|-------|-------|-------|-------|
| **cacheDir** | yes | Path to ETAS cache files. These are specific to each UCERF3 Fault System Solution | `"cacheDir": "/path/to/cache_fm3p1_ba"` |
| **fssFile** | yes | Path to UCERF3 Fault System Solution zip file | `"fssFile": "/path/to/2013_05_10-ucerf3p3-production-10runs_COMPOUND_SOL_FM3_1_SpatSeisU3_MEAN_BRANCH_AVG_SOL.zip"` |

### UCERF3 ETAS Parameters

 **Name** | **Required?** | **Description** | **Example** |
|-------|-------|-------|-------|
| **probModel** | yes | UCERF3 probability model, one of FULL_TD, NO_ERT, or POISSON | `"probModel": "FULL_TD"` |
| applySubSeisForSupraNucl | yes | This tells whether to correct gridded seismicity rates soas not to be less than the expected rate of aftershocks from supraseismogenic events | `"applySubSeisForSupraNucl": true` |
| totRateScaleFactor | yes | The amount by which the total region MFD is multiplied by. Should use 1.14 for UCERF3-TD fault based | `"totRateScaleFactor": 1.14` |
| gridSeisCorr | Apply the gridded seismicity correction file in cacheDir to rates of gridded seismicity nodes | `"gridSeisCorr": true` |
| timeIndependentERF | yes | If true, disables elastic rebound time-dependence in the ERF. Can lead to runaway sequences that never end | `"timeIndependentERF": false` |
| griddedOnly | yes | If true, gridded only (no faults) ETAS simulations will be preformed | `"griddedOnly": false` |
| imposeGR | yes | This tells whether to impose Gutenberg-Richter in sampling ETAS aftershocks | `"imposeGR": false` |
| includeIndirectTriggering | yes | Include secondary, tertiary, etc events | `"includeIndirectTriggering": true` |
| gridSeisDiscr | yes | lat lon discretization of gridded seismicity (degrees) | `"gridSeisDiscr": 0.1` |

## Binary Output Filters

These options tell the ETAS simulator to write consolidated binary files which contain all simulations in a single file. You can also filter catalogs for faster processing later. Filtering can be done by magnitude or to only include descendants of input events (filter out all spontaneous events).

They should be entered as a JSON array, with one array entry for each output filter.

 **Name** | **Required?** | **Description** | **Example** |
|-------|-------|-------|-------|
| prefix | yes | Output prefix. Will be written to outputDir/prefix.bin. During the simulation, they will be written to outputDir/prefix_partial.bin until the files are completed | `"prefix": "results_m5_preserve_chain"` |
| minMag | no | Minimum magnitude to include in the output file, or all magnitudes if omitted | `"minMag": 5.0` |
| preserveChainBelowMag | no | If minMag is supplied, then this controls whether full dependency chains of ruptures should be preserved. This keeps any foreshocks to a M>=minMag rupture, even if the foreshock (or a foreshock's foreshock, etc) has M<minMag. Recommended, as lineage for all ruptures will be fully maintained | "preserveChainBelowMag": true |
| descendantsOnly | no | If true, only descendants of triggered events (and each event triggered by those events, and so on) will be included. This will filter out all spontaneous events | "descendantsOnly": false |

### Binay Output Filters Example

```
  "binaryOutputFilters": [
    {
      "prefix": "results_complete",
      "descendantsOnly": false
    },
    {
      "prefix": "results_m5_preserve_chain",
      "minMag": 5.0,
      "preserveChainBelowMag": true,
      "descendantsOnly": false
    }
  ]
```

# ETAS Configuration File Documentation

This file documents the UCERF3-ETAS JSON file format. Most users won't want to generate these files from scratch, and will instead want to use a [configuration generator script](configuring_simulations.md) or modify one of the [example files](../json_examples). Documentation for each field is below, with those fields most likely to require updating in highlighted in bold.

## Calculation Paramters

This section describes calculation extents and some calculation parameters.

| **Name** | **Required?** | **Description** | **Example** |
|-------|-------|-------|-------|
| **numSimulations** | yes | Number of etas simulations to perform for the given configuration, must be >0 | `"numSimulations": 10000` |
| **duration** | yes | Simulation duration in years | `"duration": 10.0` |
| **startYear** | no | Simulation start year (integer). Must supply this or startTimeMillis below (not both). If supplied, simulations will start at midnight, January 1, UTC | `"startYear": 2018` |
| **startTimeMillis** | no | Simulation start time in epoch milliseconds. Must supply this or startYear above (not both). [Try this website](https://www.epochconverter.com/) to convert a date to its epoch representation (making sure to use the "Timestamp in milliseconds" field)  | `"startTimeMillis": 1514764800000` |
| **includeSpontaneous** | yes | If 'true', spontaneous events will be computed, if 'false', only triggered (and either trigger ruptures or a trigger catalog must be supplied) | `"includeSpontaneous": true` |
| randomSeed | no | Can be used to reproduce results. If numSimulations=1, this seed will be used for that simulation. If numSimulations>1, this seed will be used to generate a reproducible set of random seeds for each simulation. Note: reproducibility is not guarenteed across different computing architectures dues to variations in floating point math implementations, but should be reproducible on the same machine | `"randomSeed": 1234567` |
| binaryOutput | yes | If yes, catalogs will be converted to binary format when each simulation completes to save space. Recommended for large simulation counts (>100) | `"binaryOutput": true` |
| binaryOutputFilters | no | If supplied, consolidated binary files will be written for each of the given configurations. This works even with binaryOutput=false, and can be used to automatically generated magnitude filtered files for analysis later | [see object format below](#binary-output-filters)  |
| forceRecalc | no | If true, all simulations will be recalculated even if they finished in an earlier run (with the same output directory). | `"forceRecalc": false` |
| **simulationName** | no | Simulation name. If omitted, one will be automatically generated (but won't be very descriptive). Will show up in output plots. | `"simulationName": "Mojave M7, no spontaneous"` |
| numRetries | no | Number of times to try a simulation before exiting if errors are encountered. Setting >1 will help to recover from things like filesystem issues during a large simulation. | `"numRetries": 3` |
| **outputDir** | yes | Path to output directory where all results will be written. Path should be absolute and can contain system environmental variables | `"outputDir": "/path/to/etas_output"` or `"outputDir": "${ETAS_SIM_DIR}/my_simulation"` |

## Input Ruptures ##

Input ruptures are all optional, though at least one must be supplied if includeSpontaneous=false above.

 **Name** | **Required?** | **Description** | **Example** |
|-------|-------|-------|-------|
| **triggerCatalog** | no | Path to trigger catalog file inb 10 column format. This can be a custom catalog, or can be the UCERF3 historical catalog | `"triggerCatalog": "/path/to/trigger_catalog.txt"` |
| **triggerCatalogSurfaceMappings** | no | Path to XML file with finite surface mappings for ruptures in triggerCatalog. Complicated format, and probably only useful for the UCERF3 historical catalog | `"triggerCatalogSurfaceMappings": "/path/to/u3_historical_catalog_finite_fault_mappings.xml"` |
| **treatTriggerCatalogAsSpontaneous**| no | If true, ruptures in the triggerCatalog (and their descendants) will be treated as spontanous for purposes of output plots/tables. If false, their descendants will be included in analysis which filters out spontaneous ruptures | `"treatTriggerCatalogAsSpontaneous": true` |
| **triggerRuptures** | no | Speicification of individual trigger ruptures. Array format, and you can include as many as needed. | [see description below](#trigger-ruptures) |

### Trigger Ruptures

JSON array for specifying trigger ruptures (0 or more). There are 5 types of trigger ruptures, and can be mixed in the array.

#### Point Source Rupture

This represents a point source rupture, without any finite fault surface (though you can still list fault sections to reset for elastic rebound probabilities)

 **Name** | **Required?** | **Description** | **Example** |
|-------|-------|-------|-------|
| occurrenceTimeMillis | no | Rupture occurrence time in epoch milliseconds. If omitted, the rupture is assumed to occur at simulation start time | `"occurrenceTimeMillis": 1532665006760` |
| mag | yes | Rupture magnitude | `"mag": 5.3` |
| latitude | yes | Latitude for point source rupture in decimal degrees | `"latitude": 34.213` |
| longitude | yes | Longitude for point source rupture in decimal degrees | `"longitude": -118.537` |
| depth | yes | Depth for point source rupture in kilometers (positive) | `"depth": 18.2` |
| subSectResetIndexes | no | JSON array of integer UCERF3 subsection indexes to rest in an elastic rebound sense | `"subSectResetIndexes": [ 1412,1413 ]` |

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

#### Simple Fault Rupture

This represents a rupture constructed with [simple fault geometry](http://opensha.org/glossary-simpleFault): stike, dip, upper & lower depths, and fault trace. Multiple rupture planes are allowed, and you can optionally supply a list of UCERF3 subsection indices to reset (for elastic rebound properties)

 **Name** | **Required?** | **Description** | **Example** |
|-------|-------|-------|-------|
| occurrenceTimeMillis | no | Rupture occurrence time in epoch milliseconds. If omitted, the rupture is assumed to occur at simulation start time | `"occurrenceTimeMillis": 1532665006760` |
| mag | yes | Rupture magnitude | `"mag": 5.3` |
| latitude | no | Hypocenter latitude in decimal degrees (used only for metadata & plots) | `"latitude": 34.213` |
| longitude | no | Hypocenter longitude in decimal degrees (used only for metadata & plots) | `"longitude": -118.537` |
| depth | no | Hypocentral depth in kilometers (positive, used only for metadata & plots) | `"depth": 18.2` |
| ruptureSurfaces | yes | JSON array of Simple Fault Data rupture surfaces (see below) | see example below |
| subSectResetIndexes | no | JSON array of integer UCERF3 subsection indexes to rest in an elastic rebound sense | `"subSectResetIndexes": [ 1412,1413 ]` |

##### Simple Fault Data JSON Speicification

Simple fault geometry (in the `ruptureSurfaces` JSON object) is specified as an array of the following properties (one entry for each fault plane):

 **Name** | **Required?** | **Description** | **Example** |
|-------|-------|-------|-------|
| dip | yes | Fault dip (degrees) | `"dip": 90` |
| upperDepth | yes | Fault upper depth (kilometers) | `"upperDepth": 0` |
| lowerDepth | yes | Fault lower depth (kilometers) | `"lowerDepth": 12` |
| trace | yes | JSON array of objects containing `latitude`, `longitude`, and `depth` | see example below |

#### Edge Rupture

This represents a rupture consistent with the ShakeMap [Edge Rupture](https://usgs.github.io/shakemap/manual4_0/tg_input_formats.html#rupture-specification) definition. An edge rupture defines the outline of a rupture surface, with the following rules (copied from the ShakeMap V4 manual):

* Vertices must start on the top edge of the rupture.
* The top and bottom edges must contain the same number of vertices.
* The first and last points must be identical to close the polygon, and this means that there must always be an odd number of vertices.
* The top edge of the rupture must always be above the bottom edge.

In cross section, a single-segment multiple-quadrilateral rupture might look schematically like this:

```
   _.-P1-._
P0'        'P2---P3
|                  \
P7---P6----P5-------P4
```

 **Name** | **Required?** | **Description** | **Example** |
|-------|-------|-------|-------|
| occurrenceTimeMillis | no | Rupture occurrence time in epoch milliseconds. If omitted, the rupture is assumed to occur at simulation start time | `"occurrenceTimeMillis": 1532665006760` |
| mag | yes | Rupture magnitude | `"mag": 5.3` |
| latitude | no | Hypocenter latitude in decimal degrees (used only for metadata & plots) | `"latitude": 34.213` |
| longitude | no | Hypocenter longitude in decimal degrees (used only for metadata & plots) | `"longitude": -118.537` |
| depth | no | Hypocentral depth in kilometers (positive, used only for metadata & plots) | `"depth": 18.2` |
| ruptureSurfaces | yes | JSON array of surface outlines (see below) | see example below |
| subSectResetIndexes | no | JSON array of integer UCERF3 subsection indexes to rest in an elastic rebound sense | `"subSectResetIndexes": [ 1412,1413 ]` |

##### Edge Rupture Data JSON Speicification

Edge Rupture geometry (in the `ruptureSurfaces` JSON object) is specified as an array of the following properties (one entry for each fault plane):

 **Name** | **Required?** | **Description** | **Example** |
|-------|-------|-------|-------|
| outline | yes | JSON array of objects containing `latitude`, `longitude`, and `depth` | see example below |

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
    },
    {
      "occurrenceTimeMillis": 1562383193040,
      "mag": 7.1,
      "latitude": 35.7695,
      "longitude": -117.59933329999998,
      "depth": 8.0,
      "ruptureSurfaces": [
        {
          "dip": 85.0,
          "upperDepth": 0.0,
          "lowerDepth": 12.0,
          "trace": [
            {
              "latitude": 35.92284279864912,
              "longitude": -117.75376500872244,
              "depth": 0.0
            },
            {
              "latitude": 35.773629374775204,
              "longitude": -117.593478163178,
              "depth": 0.0
            },
            {
              "latitude": 35.576615540127804,
              "longitude": -117.38310820766546,
              "depth": 0.0
            }
          ]
        }
      ]
    },
    {
      "occurrenceTimeMillis": 1562261629000,
      "comcatEventID": "ci38443183",
      "mag": 6.4,
      "latitude": 35.7053333,
      "longitude": -117.5038333,
      "depth": 10.5,
      "ruptureSurfaces": [
        {
          "outline": [
            {
              "latitude": 35.6051534466,
              "longitude": -117.5905380735,
              "depth": 0.0
            },
            {
              "latitude": 35.6173144101,
              "longitude": -117.57249634649999,
              "depth": 0.0
            },
            {
              "latitude": 35.6173135736,
              "longitude": -117.5726723708,
              "depth": 0.0
            },
            {
              "latitude": 35.61731357360001,
              "longitude": -117.5726723708,
              "depth": 15.0
            },
            {
              "latitude": 35.6173144101,
              "longitude": -117.57249634649999,
              "depth": 15.0
            },
            {
              "latitude": 35.6051534466,
              "longitude": -117.5905380735,
              "depth": 15.0
            },
            {
              "latitude": 35.6051534466,
              "longitude": -117.5905380735,
              "depth": 0.0
            }
          ]
        }
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
| gridSeisCorr | yes | Apply the gridded seismicity correction file in cacheDir to rates of gridded seismicity nodes. Should be false when girddedOnly is true. | `"gridSeisCorr": true` |
| timeIndependentERF | yes | If true, disables elastic rebound time-dependence in the ERF. Can lead to runaway sequences that never end | `"timeIndependentERF": false` |
| griddedOnly | yes | If true, gridded only (no faults) ETAS simulations will be preformed | `"griddedOnly": false` |
| imposeGR | yes | This tells whether to impose Gutenberg-Richter in sampling ETAS aftershocks | `"imposeGR": false` |
| includeIndirectTriggering | yes | Include secondary, tertiary, etc events | `"includeIndirectTriggering": true` |
| gridSeisDiscr | yes | lat lon discretization of gridded seismicity (degrees), should always be 0.1 for now | `"gridSeisDiscr": 0.1` |
| catalogCompletenessModel | yes | Time-dependent catalog completness model which will be used to filter a historical catalog, and control the rate of spontaneous ruptures (children from missing events in that catalog). Acceptable values are "STRICT" (table L9 from UCERF3-TI Appendix L) or "RELAXED" (much less restrictive option in order to include more historical data in ETAS simulations but at the cost of under-estimating spontaneous rates in some regions) | `"catalogCompletenessModel": "RELAXED"` |
| etas_p | no | The ETAS p value in the temporal decay: `(t+c)^-p`. Default is 1.07, allowable range is `[1 1.4]` | `"etas_p": 1.07` |
| etas_c | no | The ETAS c value in the temporal decay, units of days: `(t+c)^-p`. Default is 0.00650145, allowable range is `[0.00036525 0.115419]` | `"etas_c": 0.00650145` |
| etas_log10_k | no | The ETAS productivity parameter k in Log10 units. Default is -2.54668, allowable range is `[-3.42136 -2.00261]` | `"etas_log10_k": -2.54668` |
| etas_k_cov | no | The COV of the ETAS productivity parameter k. Default is 0 which disables aleatory k variability, allowable range is `[0 2]` | `"etas_k_cov": 1.16` |

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

## Metadata (optional)

These JSON fields are metadata only and optional. They will be populated automatically by the command line configuration generation tools.

 **Name** | **Required?** | **Description** | **Example** |
|-------|-------|-------|-------|
| configCommand | no | If a command line tool was used to generate this configuration file, the command used will be included here | `"configCommand": "u3etas_comcat_event_config_builder.sh --event-id ci38457511 --num-simulations 100000 --days-before 7 --finite-surf-shakemap --finite-surf-shakemap-min-mag 5"` |
| configTime | no | Time that this configuration file was generated (in epoch milliseconds) | `"configTime": 1565117235077` |
| comcatMetadata | no | ComCat metadata, used to generate ComCat comparison plots which compare the simulated aftershock distribution with actual event data from ComCat | see below |

### ComCat Metadata

These fields will be used to generate comparison plots between simulated aftershock distributions and actual event data from ComCat. While this JSON object itself is optional, fields with "yes" in the "Required?" column are required if the object is supplied.

 **Name** | **Required?** | **Description** | **Example** |
|-------|-------|-------|-------|
| region | yes | ComCat region specification | see examples below |
| eventID | no | Primary ComCat event ID | `"eventID": "ci38457511"` |
| minDepth | yes | Minimum depth to fetch ComCat events in kilometers | `"minDepth": -10.0` |
| maxDepth | yes | Maximum depth to fetch ComCat events in kilometers | `"maxDepth": 24.0` |
| minMag | yes | Minimum magnitude event to fetch from ComCat | `"minMag": 2.5` |
| startTime | no | Start time (epoch milliseconds) for the ComCat query used to populate trigger events | `"startTime": 1562383193040` |
| endTime | no | End time (epoch milliseconds) for the ComCat query used to populate trigger events | `"endTime": 1562383193041` |
| magComplete | no | Magnitude of completeness to be used for comparison plots with real data. Default is modalMag+0.5 | `"magComplete": 4` |

### ComCat Metadata Examples

This example defines the ComCat region as a circle, with center latitude and longitude supplied, as well as the radius in kilometers:

```
  "comcatMetadata": {
    "region": {
      "centerLatitude": 35.7695,
      "centerLongitude": -117.59933329999998,
      "radius": 47.75292736576897
    },
    "eventID": "ci38457511",
    "minDepth": -10.0,
    "maxDepth": 24.0,
    "minMag": 2.5,
    "startTime": 1562383193040,
    "endTime": 1562383193041
  }
```

This example defines the ComCat region as a rectangle:

```
  "comcatMetadata": {
    "region": {
      "minLatitude": 35,
      "maxLatitude": 36,
      "minLongitude": -118,
      "maxLongitude": -117
    },
    "eventID": "ci38457511",
    "minDepth": -10.0,
    "maxDepth": 24.0,
    "minMag": 2.5,
    "startTime": 1562383193040,
    "endTime": 1562383193041
  }
```

This example defines the ComCat region as a polygon, in this case just supplying three points for a triangular region:

```
  "comcatMetadata": {
    "region": {
      "border": [
        {
          "latitude": 36,
          "longitude": -118
        },
        {
          "latitude": 36,
          "longitude": -116.7
        },
        {
          "latitude": 34,
          "longitude": -117.3
        }
      ]
    },
    "eventID": "ci38457511",
    "minDepth": -10.0,
    "maxDepth": 24.0,
    "minMag": 2.5,
    "startTime": 1562383193040,
    "endTime": 1562383193041
  }
```

# UCERF3-ETAS Output File Formats

UCERF3-ETAS stores synthetic earthquake catalogs in binary or ASCII file formats, which are described here.

## ASCII catalog format

The ASCII catalog format should only be used for small simulations, as resultant files can be very large. You can also convert binary catalogs to ASCII with the [u3etas_ascii_writer.sh script](scripts.md#convert-binary-catalog-files-to-ascii-u3etas_ascii_writersh).

The format is an extension to the typical 10-column earthquake catalog format (tab separated), with a header line that begins with a `%` and then a single line for each simulated event. All times are UTC. Here are the columns:
				
| **Name** | **Description** |
|-------|-------|
| Year | Occurence time year, e.g. `2019` |
| Month | Occurence time month, 1-based, e.g. `01` for January |
| Day | Occurence time day of month, 1-based, e.g. `01` for the first of the month |
| Hour | Occurence time hour, e.g. `00` |
| Minute | Occurence time minute, e.g. `00` |
| Sec | Occurence time seconds, rounded to the nearest millisecond, e.g. `01.234` |
| Lat | Hypocenter latitude, e.g. `34.1234` |
| Lon | Hypocenter longitude, e.g. `-118.1234` |
| Depth | Hypocenter depth in kilometers, e.g. `5.0` |
| Magnitude | Rupture magnitude, e.g. `6.7` |
| ID | Unique integer ID number, e.g. `1234` |
| parID | ID number of this rupture's parent, or -1 if it is a spontaneous rupture, e.g. `1234` |
| Gen | Generation of this rupture, e.g. `0` for a spontaneous rupture or `1` for a primary aftershock of an input event or spontaneous rupture |
| OrigTime | Origin time in epoch milliseconds, e.g. `1571174849123` |
| distToParent | Distance between this rupture and it's parent in kilometers, or NaN for spontaneous ruptures, e.g. `NaN` |
| nthERFIndex | Internal model integer index, e.g. `1234` |
| FSS_ID | Supra-seismogenic rupture ID in the UCERF3 Fault System Solution, or -1 if it is a point source rupture, e.g. `1234` |
| GridNodeIndex| Index in the UCERF3 California gridded region, or -1 if it is a supra-seismogenic fault-based rupture, e.g. `1234` |
| ETAS_k | ETAS `k` value for this rupture in linear units, useful is aleatory `k` variability is enabled, e.g. `0.00284` |

There may also be other metadata lines which start with a `%`, either at the beginning or end of the file. Be sure to filter those out if not needed.

Here is a snipped of the first few lines of one such catalog:

```
% Year	Month	Day	Hour	Minute	Sec	Lat	Lon	Depth	Magnitude	ID	parID	Gen	OrigTime	distToParent	nthERFIndex	FSS_ID	GridNodeIndex	ETAS_k
2012	01	01	00	46	57.287	31.965937	-116.31789	11.835893	2.65	110469	-1	0	1325378817287	NaN	288603	-1	133	NaN
2012	01	01	00	57	26.366	33.95457	-120.289474	8.48202	2.95	413467	-1	0	1325379446366	NaN	545472	-1	1277	NaN
2012	01	03	03	48	52.414	39.889828	-124.02973	8.570825	2.75	63786	128	1	1325562532414	0.17724292	1536415	-1	5705	NaN
2012	01	03	04	05	07.691	33.373974	-118.20255	4.783915	2.55	281764	-1	0	1325563507691	NaN	453580	-1	836	NaN
2012	01	03	04	51	56.847	37.70209	-118.7873	10.455201	3.25	239799	-1	0	1325566316847	NaN	1223581	-1	4335	NaN
2012	01	03	08	42	18.645	39.70379	-123.601425	8.855155	2.55	221913	-1	0	1325580138645	NaN	1510182	-1	5586	NaN
2012	01	03	19	07	14.908	36.702797	-116.26189	6.345098	3.05	249626	-1	0	1325617634908	NaN	1057620	-1	3603	NaN
2012	01	03	19	45	43.440	35.841515	-117.672874	4.850579	2.85	75132	57419	1	1325619943440	0.50766885	880434	-1	2848	NaN
2012	01	03	23	56	30.312	37.49854	-118.7729	3.4831977	3.45	308172	-1	0	1325634990312	NaN	1190792	-1	4189	NaN
```

## Binary catalog format

Most large UCERF3-ETAS simulations are stored in a binary format for storage and I/O efficiency. That binary format is described below, with **all values stored in the big-endian binary representations**.

If this format is too complicated for you, you may wish to convert to ASCII with the [u3etas_ascii_writer.sh script](scripts.md#convert-binary-catalog-files-to-ascii-u3etas_ascii_writersh).

### History of binary formats

Note that multiple file format versions exist. The 'Version' flag at the start of each catalog indicates the file format version. Fields that are version-dependent list the applicable version number(s) in the 'Versions' column below, and are omitted in other versions.

| **Version** | **Date** | **Description** |
|-------|-------|-------|
| 1 | circa 2016 | Initial binary file version |
| 2 | 10/15/2019 | Added new `ETAS 'k'` value for each rupture to track `k` in simulations with aleatory productivity variability enabled |
| 3 | 10/21/2019 | Added metadata at the start of each catalog |

### Single catalog binary format

Each catalog begins with the folowing values:

| **Name** | **Type** | **Versions** | **Description** |
|-------|-------|-------|-------|
| Version | 2-byte short integer | *ALL* | File format version number |
| Total (original) number of ruptures | 4-byte integer | **3+** | Total number of ruptures simulated, which may be greater than the number present in the catalog (due to filtering) |
| Random seed | 8-byte long integer | **3+** | Random seed used to generate the catalog |
| Catalog index | 4-byte integer | **3+** | Index of this catalog in the cast of a multi-catalog simulation, or -1 for a single catalog simulation |
| Historical rupture start ID | 4-byte integer | **3+** | First ID of historical ruptures, if included, else -1. Those ruptures are not listed in the file below, but could be the parent to ruptures below |
| Historical rupture end ID | 4-byte integer | **3+** | Last ID of historical ruptures, if included, else -1. Those ruptures are not listed in the file below, but could be the parent to ruptures below |
| Trigger rupture start ID | 4-byte integer | **3+** | First ID of trigger ruptures, if included, else -1. Those ruptures are not listed in the file below, but could be the parent to ruptures below |
| Trigger rupture end ID | 4-byte integer | **3+** | Last ID of trigger ruptures, if included, else -1. Those ruptures are not listed in the file below, but could be the parent to ruptures below |
| Simulation start time | 8-byte long integer | **3+** | Time that the simulation began in epoch milliseconds |
| Simulation end time | 8-byte long integer | **3+** | Time that the simulation completed in epoch milliseconds |
| Total number spontaneous ruptures | 4-byte integer | **3+** | Number of spontanous ruptures in this catalog. This quantity is updated to reflect the new value for filtered catalogs |
| Total number supraseismogenic ruptures | 4-byte integer | **3+** | Number of supraseismogenic ruptures in this catalog (fssIndex>=0). This quantity is updated to reflect the new value for filtered catalogs |
| Minimum magnitude | 8-byte double precision | **3+** | Minimum magnitude for this catalog. Note that for the case of filtered catalogs, this is the filter magnitude and there may be some ruptures below this level if preserveChain=true |
| Maximum magnitude | 8-byte double precision | **3+** | Maximum magnitude in this catalog. This quantity is updated to reflect the new value for filtered catalogs |
| Num Ruptures | 4-byte integer | *ALL* | Total number of ruptures in this catalog |

Then, the following fields are written for each rupture.

| **Name** | **Type** | **Versions** | **Description** |
|-------|-------|-------|-------|
| ID | 4-byte integer | *ALL* | Unique ID number for this rupture |
| Parent ID | 4-byte integer | *ALL* | ID number of this rupture's parent, or -1 if it is a spontaneous rupture  |
| Generation | 2-byte short integer | *ALL* | Generation of this rupture, e.g. `0` for a spontaneous rupture or `1` for a primary aftershock of an input event or spontaneous rupture |
| Origin time | 8-byte long integer | *ALL* | Origin time in epoch milliseconds, e.g. `1571174849123` |
| Latitude | 8-byte double precision | *ALL* | Hypocenter latitude |
| Longitude | 8-byte double precision | *ALL* | Hypocenter longitude |
| Depth | 8-byte double precision | *ALL* | Hypocenter depth in kilometers |
| Magnitude | 8-byte double precision | *ALL* | Rupture magnitude |
| Distance to parent | 8-byte double precision | *ALL* | Distance between this rupture and it's parent in kilometers, or NaN for spontaneous ruptures |
| Nth ERF index | 4-byte integer | *ALL* | Internal model index |
| FSS index | 4-byte integer | *ALL* | Supra-seismogenic rupture ID in the UCERF3 Fault System Solution, or -1 if it is a point source rupture, e.g. `1234` |
| Grod node index | 4-byte integer | *ALL* | Index in the UCERF3 California gridded region, or -1 if it is a supra-seismogenic fault-based rupture, e.g. `1234` |
| ETAS 'k' | 8-byte double precision | **2+** | ETAS `k` value for this rupture in linear units, useful is aleatory `k` variability is enabled, e.g. `0.00284` |

### Multiple catalogs binary format

Multiple catalogs can be stored in a single binary file (e.g. *results_complete.bin*). The first item in the binary file is:

| **Name** | **Type** | **Versions** | **Description** |
|-------|-------|-------|-------|
| Num catalogs | 4-byte integer | *ALL* | Total number of catalogs |

Then the [single catalog binary format](#single-catalog-binary-format) follows once for each of those catalogs.

# UCERF3-ETAS Output File Formats

UCERF3-ETAS stores synthetic earthquake catalogs in binary or ASCII file formats, which are described here.

## ASCII catalog format

The ASCII catalog format should only be used for small simulations, as resultant files can be very large. You can also convert binary catalogs to ASCII with the [u3etas_ascii_writer.sh script](scripts.md#convert-binary-catalog-files-to-ascii-u3etas_ascii_writersh).

The format is an extension to the typical 10-column earthquake catalog format (tab separated), with a header line that begins with a `%` and then a single line for each simulated event. All times are UTC. Here are the columns:

"Year\tMonth\tDay\tHour\tMinute\tSec\tLat\tLon\tDepth\tMagnitude\t"
				+ "ID\tparID\tGen\tOrigTime\tdistToParent\tnthERFIndex\tFSS_ID\tGridNodeIndex\tETAS_k";
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
| nthERFIndex | Internal integer index, e.g. `1234` |
| FSS_ID | Supra-seismogenic rupture ID in the UCERF3 Fault System Solution, or -1 if it is a point source rupture, e.g. `1234` |
| GridNodeIndex| Index in the UCERF3 California gridded region, or -1 if it is a supra-seismogenic fault-based rupture, e.g. `1234` |
| ETAS_k | ETAS `k` value for this rupture in linear units, useful is aleatory `k` variability is enabled, e.g. `0.00284` |

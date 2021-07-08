# UCERF3-ETAS Launcher & Processing Scripts

ETAS simulation and processing scripts. Documention of each script is [available here](../doc/scripts.md).

## General notes

* These scripts call Java code and all assume that that opensha-all.jar file exists or can be downloaded to/built in the `opensha` subdirectory, one level above this directory. If you copy these scripts elsewhere, they will no longer work.
* ETAS simulations are memory intensive and Java requires that you set the maximum memory that you intend to use BEFORE runtime. These scripts will attempt to detect total system memory using the `free` command, and allocate 80% of that amount to java. You can override this setting by setting the `ETAS_MEM_GB` environmental variable before running (in your current shell, or globally in your ~/.bashrc file).

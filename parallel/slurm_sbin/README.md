# Slurm Helper Scripts

The scripts in this directory can be used to help submit and monitor parallel jobs. Scripts in bold are most likely to be useful (some will only be called by other scripts and aren't very useful on their own).

Many of these scripts assume that the parallel job was submitted with `slurm_submit.sh`, and will not work otherwise.

| **Command** | **Arguments** | **Description** |
|---|---|---|
| detect_first_running.sh | *(none)* | Detects the ID number of the first running SLURM job and prints it to the console. Primarily used by other scripts |
| locate_job_stderr.sh | `[<job-id>]` | Locates the STDERR file of a job. Optionally takes a job ID number argument, otherwise uses `detect_first_running.sh` to find an ID |
| locate_job_stdout.sh | `[<job-id>]` | Same as above, but for STDOUT |
| **log_parse.sh** | `[<job-stdout-file>]` | Parses the STDOUT file for a parallel ETAS job with statistics on completed batches and runtime estimates |
| **log_parse_running.sh** | `[<job-id>]` | Parses the STDOUT file of a currently running ETAS job with statistics on completed batches and runtime estimates. Optionally takes a job ID, else uses `detect_first_running.sh` to find an ID |
| scancel_me.sh | *(none)* | Cancels all submitted (running or queued) SLURM jobs for the current user |
| **scec_queue_check.py** | `[<queue-name>]` | Prints out information on all running jobs in the given queue (defaults to "scec" queue) including counts of nodes in use across all users. Useful to quickly see if there are nodes available for a job |
| slurm_interactive.sh | `[<minutes> [<queue-name>]]` | Launches an interactive single node SLURM job. Defaults to 60 minutes and the main queue, but can be overriden with command line arguments |
| **slurm_submit.sh** | `<file-name>` | Submits the given SLURM batch script, and instructs SLURM to direct STDOUT to <file-name>.o<job-id> and STDOUT to <file-name>.e<job-id>. Other scripts assume this convention for STDOUT and STDERR files |
| stderr_job.sh | `[<job-id>]` | Cats the STDERR for the given job ID, or the first running job if no ID supplied |
| stdout_job.sh | `[<job-id>]` | Cats the STDOUT for the given job ID, or the first running job if no ID supplied |
| **stdout_job_tail.sh** | `[<job-id>]` | Tails the STDOUT file for the given job ID, or the first running job if no ID supplied |
| **watch_logparse.sh** | `[<job-id>]` | Watches the output of `log_parse_running.sh` every 60 seconds, useful for monitoring jobs |

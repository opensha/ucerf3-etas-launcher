# UCERF3-ETAS post-event response instructions

These instructions are intenteded to help those who have already configured and run UCERF3-ETAS to respond to a recent event.

## Step 1: pull latest UCERF3-ETAS launcher updates and define ETAS_SIM_DIR

Do this on your local machine, and also on the cluster if you're going to run simulations in parallel.

`cd $ETAS_LAUNCHER; git pull`

Then, if you haven't already, define the ETAS_SIM_DIR environmental variable on all machines that you will use. This should point to the directory where you want to store ETAS simulations, and allows you to use the same config.json file on multiple machines (e.g. to run simulations on a cluster, the copy back output and plot results on your local machine).

## Step 2: determine ComCat event ID

You'll need the ComCat event ID for the event, which you can determine from the URL on the USGS event page. For example, for the 2019 Ridgecrest M7.1, the full URL is `https://earthquake.usgs.gov/earthquakes/eventpage/ci38457511/executive` and the event ID is `ci38457511`.

## Step 3: configure simulations

Use the `u3etas_comcat_event_config_builder.sh` script to pull the event information directly from ComCat and configure a simulation. Full instructions are [here](CONFIGURING_SIMULATIONS.md#configuring-simulations-for-comcat-events), but here are the basics:

By default, only the given event will be included and the simulations will start immediately after the event. You can include foreshocks and aftershocks with `--days-before <days>`, `--hours-before <hours>`, `--days-after <days>`, `--hours-after <hours>`, and/or `--end-now` (the latter fetches all aftershocks up until the current moment and starts simulations at that time).

There are a few ways to describe finite fault surfaces. ShakeMap surfaces are currently supplied, use `--finite-surf-shakemap` if such a surface exists. You can also specify custom surfaces (e.g. drawn through seismicity) by following instructions [here](CONFIGURING_SIMULATIONS.md#building-your-own-custom-surface).

You'll probably want to run simulations on USC HPC, so include [those options](CONFIGURING_SIMULATIONS.md#hpc-options) as well.

Here's an example for 100,000 Ridgecrest simulations, starting immediately after the M7.1 (including seismicity 7 days before), using ShakeMap surfaces for all M>=5's, and configured to run on 36 nodes for up to 24 hours on the SCEC queue at USC HPC:

`u3etas_comcat_event_config_builder.sh --event-id ci38457511 --num-simulations 100000 --days-before 7 --finite-surf-shakemap --finite-surf-shakemap-min-mag 5 --hpc-site USC_HPC --nodes 36 --hours 24 --queue scec`

This command will generate the `config.json` and `etas_sim_mpj.slurm` files referenced below.

## Step 4: run the simulations

Run simulations on a single machine with `etas_launcher.sh config.json`, or [follow these instructions](parallel/README.md#submitting-the-slurm-parallel-etas-job) to submit them on a cluster.

If you're using a cluster, you'll then want to follow the instructions to [monitor job progress](parallel/README.md#monitoring-job-progress) and then copy output files back to your local machine.

## Step 5: plot results

When the job is complete, or at least some simulations have finished, you can plot the results with `u3etas_plot_generator.sh config.json`. This will generate many plots (in the 'plots' subdirectory) as well as an HTML index that can be opened in a web browser.

If you ran the simulations on a cluster, first copy the output back to your machine (either results_complete.bin or results_complete_partial.bin if the simulation is still in progress). Don't try to run the plot generator code on the head node of a HPC center (they won't like it, it'll be crazy slow, and will probably get killed).

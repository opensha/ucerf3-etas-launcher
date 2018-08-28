# UCERF3-ETAS Tutorials

This directory contains ETAS configuration JSON scripts which are configured to run quickly (only 10 simulations each) and output results in the "user_output" subdirectory.

## Mojave M7

This is an example running simulations of an aftershock sequence following a M7 on the SAF Mojave. First run the simulations (will take 5-10 minutes):

`u3etas_launcher.sh mojave_m7_example.json`

This will output results in the user_output/mojave_m7 directory, with individual catalogs in user_output/mojave_m7/results.

Then generate plots from the results:

`u3etas_plot_generator.sh mojave_m7_example.json`

That places plot files in user_output/mojave_m7/plots, with an index.html and README.md file in user_output/mojave_m7.

You can view example output of these commands [here](example_output/mojave_m7).

## Input Catalog With Spontaneous

This is an example running simulations with an input catalog (in this case the UCERF3 historical catalog). First run the simulations (will take 5-20 minutes):

`u3etas_launcher.sh input_catalog_with_spontaneous_example.json`

This will output results in the user_output/input_catalog_with_spontaneous directory, with individual catalogs in user_output/input_catalog_with_spontaneous/results.

Then generate plots from the results:

`u3etas_plot_generator.sh input_catalog_with_spontaneous_example.json`

That places plot files in user_output/input_catalog_with_spontaneous/plots, with an index.html and README.md file in user_output/spontaneous_only.

You can view example output of these commands [here](example_output/input_catalog_with_spontaneous).

## Spontaneous Only

This is an example running simulations with spontaneous ruptures only (no scenario/trigger ruptures). First run the simulations (will take 5-10 minutes):

`u3etas_launcher.sh spontaneous_only_example.json`

This will output results in the user_output/spontaneous_only directory, with individual catalogs in user_output/spontaneous_only/results.

Then generate plots from the results:

`u3etas_plot_generator.sh spontaneous_only_example.json`

That places plot files in user_output/spontaneous_only/plots, with an index.html and README.md file in user_output/spontaneous_only.

You can view example output of these commands [here](example_output/spontaneous_only).

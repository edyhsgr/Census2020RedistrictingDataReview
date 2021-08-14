# Census2020RedistrictingDataReview

This is a modified version of the R code that the US Census Bureau provided to download and review the 2020 Census Redistricting Files

Link to the US Census Bureau-provided code: https://www2.census.gov/programs-surveys/decennial/rdo/about/2020-census-program/Phase3/SupportMaterials/2020PL_R_import_scripts.zip 
(via https://www.census.gov/programs-surveys/decennial-census/about/rdo/summary-files.html)
	
It's set to tabulate county total population for each state, and compare that to the US Census Bureau's 2020 Evaluation Estimates by county

US Census Bureau's 2020 Evaluation Estimates are accessed via https://www.census.gov/programs-surveys/popest/technical-documentation/research/evaluation-estimates/2020-evaluation-estimates/2010s-cities-and-towns-total.html

To make the code work, you should be able to simply select-all, and copy and paste into an R command line 

It takes a *long* time to run though (a minute or two per state?), including to download and read-in the zip files, unfortunately

Users can change it to tabulate one or any selected states too though (see INPUTS)

Tabulations_County.csv, with the OUTPUT comparisons by county for each state, is provided too

August 2021

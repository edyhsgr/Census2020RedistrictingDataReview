# Census2020RedistrictingDataReview

This is a modified version of the R code that the US Census Bureau provided to download and review the 2020 Census Redistricting Files.

It's set to tabulate county total population for each state, and compare that to the US Census Bureau's 2020 Evaluation Estimates by county, 
as well as simple housing unit-ratio (no adjustment for changing household size or vacancy) based estimates by county

My parts of the code (and thus the results) have not been carefully reviewed.

Link to the US Census Bureau-provided code: 
https://www2.census.gov/programs-surveys/decennial/rdo/about/2020-census-program/Phase3/SupportMaterials/2020PL_R_import_scripts.zip 
(via https://www.census.gov/programs-surveys/decennial-census/about/rdo/summary-files.html).

The US Census Bureau's 2020 Evaluation Estimates are accessed via 
https://www.census.gov/programs-surveys/popest/technical-documentation/research/evaluation-estimates/2020-evaluation-estimates/2010s-cities-and-towns-total.html.
The US Census Bureau's 2020 Evaluation Estimates Housing Unit estimates are accessed via 
https://www.census.gov/programs-surveys/popest/technical-documentation/research/evaluation-estimates/2020-evaluation-estimates/2010s-totals-housing-units.html 
The US Census Bureau's 2010 Evaluation Estimates (Population and Housing Unit) estimates are accessed via 
https://www.census.gov/programs-surveys/popest/technical-documentation/research/evaluation-estimates.2010.html
	
Except for FILE DOWNLOAD (commented out - can simply remove the commenting to allow download), to make the code work, 
users should be able to simply select-all, and copy and paste into an R command line.

It takes a long time to run though (a minute per state?), unfortunately.

Users can change it to tabulate one or any selected states too though (see INPUTS).

Tabulations_County_2020.csv, with the OUTPUT comparisons by county for each state, and Tabulations_County_2010.csv with 2010 Census 
(accessed via IPUMS NHGIS, University of Minnesota, https://www.nhgis.org/), and 2010 Evaluation Estimates (via US Census Bureau) data, are provided too.

EvalEstToCensusReview.R is a Shiny for R application: https://edyhsgr.shinyapps.io/EvalEstToCensusReview/ 
to review US Census Bureau Evaluation Estimates county total population errors.

-Eddie Hunsinger, August 2021 (updated May 2022)


/*
	Program: _all.do
	Purpose: all stata processes for ACS ARD data
	By: MAS
	Last Updated: 04/22/25
*/

global workdir "/Users/schmidt/Desktop/Research/Analysis"
cd "$workdir"


***********************************
* CLEAN / computations for ACS FILES
* INPUT (./data/processed): All csv files prepended by ACS_
* OUTPUT (./data): all dta files prepended by ACS_
***********************************

do ./code/ACS_data_prep.do

***********************************
* CLEAN for RUCC FILES
* INPUT (./../raw/RUCC/): RUCC_2013.xls; RUCC_2023.xlsx
* OUTPUT (./data): RUCC_2013.dta; RUCC_2023.dta
***********************************

do ./code/RUCC_data_prep.do

***********************************
* CLEAN for Centroid FILES
* INPUT (./../raw/County centroid/): CenPop2020.txt; CenPop2010.txt
* OUTPUT (./data): Centroid_2010.dta; Centroid_2020.dta
***********************************

do ./code/Centroid_data_prep.do

***********************************
* Merge for Centroid and RUCC FILES
* INPUT (./data): Centroid_2010.dta; Centroid_2020.dta; RUCC_2013.dta; RUCC_2023.dta
* OUTPUT (./data): CenRUCC_2010.dta; CenRUCC_2020.dta
***********************************

do ./code/merge_cen_rucc.do

***********************************
* Summary stats for ACS FILES
* INPUT (./data): all ACS_<year>.dta files
* OUTPUT (./output): ACS_sum.xlsx
***********************************

do ./code/ACS_sum.do

***********************************
* merging for ACS FILES and CenRUCC files
* INPUT (./data): all ACS_<year>.dta files, CenRUCC.dta files, displacement.csv
* OUTPUT (./data): ACS_panel.dta
***********************************

do ./code/ACS_merge.do

***********************************
* codebook for ACS_panel.dta
* INPUT (./data): ACS_panel.dta
* OUTPUT (./codebooks): ACS_panel_codebook_generated.dta
***********************************

do ./code/ACS_codebook.do

***********************************
* Urban Displacement Project gentrification vulnerability classification / filtering
* INPUT (./data): ACS_panel.dta
* OUTPUT (./data): ACS_panel_urban.dta
***********************************

do ./code/udp_recreation.do

***********************************
* spline creation to derive incomplete gentrification 
* INPUT (./data): ACS_panel.dta, ACS_panel_urban.dta
* OUTPUT (./data): splines, model_data.dta
***********************************

do ./code/model_data.do

***********************************
* Mathematical Model to derive probabilities of incomplete gentrification 
* INPUT (./data): model_data.dta, <target metric>_spline.dta
* OUTPUT (./data): model_data.dta
***********************************

do ./code/model.do

***********************************
* LASSO for future rental prices to validate gentrification metric
* INPUT (./data): model_data.dta
* OUTPUT (./data): 
***********************************

do ./code/lasso.do




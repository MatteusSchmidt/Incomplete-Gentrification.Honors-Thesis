/*
	Program: Centroid_data_prep.do
	Purpose: all processes for Centroid ARD data
	By: MAS
	Last Updated: 03/11/25
*/

cd ..

log using ./Analysis/output/log_Centroid_cleaning.log, text replace

import delimited using "./raw/County centroid/CenPop2010.txt", clear stringcols(1 2)
gen FIPS = statefp + countyfp
drop couname stname statefp countyfp
save ./Analysis/data/Centroid_2010, replace

import delimited using "./raw/County centroid/CenPop2020.txt", clear stringcols(1 2)
gen FIPS = statefp + countyfp
drop couname stname statefp countyfp
save ./Analysis/data/Centroid_2020, replace

cd ./Analysis

log close

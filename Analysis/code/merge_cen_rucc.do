/*
	Program: merge_cen_rucc.do
	Purpose: merge RUCC and Centroid ARD data
	By: MAS
	Last Updated: 04/22/25
*/

log using ./output/log_merge_cen_rucc.log, text replace

use ./data/Centroid_2010, clear

// did this only for null values picked up from excel import, no real duplicates of any kind
merge m:m FIPS using ./data/RUCC_2013
duplicates list
duplicates drop FIPS, force 
gen RUCC_description = trim(Description)
drop _merge population Population_2010 Description
rename FIPS county
destring county, replace force 
save ./data/CenRUCC_2010, replace


use ./data/Centroid_2020, clear
merge m:m FIPS using ./data/RUCC_2023
duplicates list
duplicates drop FIPS, force 
gen RUCC_description = trim(Description)
drop _merge population Population_2020 Description
rename FIPS county
destring county, replace force 
save ./data/CenRUCC_2020, replace

log close

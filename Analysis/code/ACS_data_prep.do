/*
	Program: ACS_data_prep.do
	Purpose: all stata processes for ACS ARD data
	By: MAS
	Last Updated: 04/22/25
*/

log using ./output/log_ACS_data_prep.log, text replace

cd ..

import delimited using "./raw/ZCTA Crosswalks/tab20_zcta520_county20_natl.txt",  clear
keep geoid_zcta5_20 geoid_county_20
rename geoid_zcta5_20 zip
rename geoid_county_20 county
gen temp = county
destring temp, replace
drop if inrange(temp, 72000, 72999)   // Puerto Rico
drop if inrange(temp, 66000, 66999)   // Guam
drop if inrange(temp, 60000, 60999)   // American Samoa
drop if inrange(temp, 69000, 69999)   // Northern Mariana Islands
drop if inrange(temp, 78000, 78999)   // U.S. Virgin Islands
drop temp 

save "./Analysis/data/ZCTA_crosswalk_2020.dta", replace
gen temp = county
destring temp, replace
drop if inrange(temp, 9000, 9999) // special case for Connecticut
drop temp
save "./Analysis/data/ZCTA_crosswalk_2022.dta", replace

import delimited using "./raw/ZCTA Crosswalks/acs22_cousub22_zcta520_st09.txt",  clear
keep geoid_cousub_22 geoid_zcta5_20
tostring geoid_cousub_22, gen(geoid_str) format(%012.0f)
gen county = substr(geoid_str, 3, 5)
rename geoid_zcta5_20 zip
drop geoid_cousub_22 geoid_str
destring county, replace force
drop if zip == .
append using ./Analysis/data/ZCTA_crosswalk_2022.dta
save "./Analysis/data/ZCTA_crosswalk_2022.dta", replace

import delimited using "./raw/ZCTA Crosswalks/zcta_county_rel_10.txt", clear
keep zcta5 state geoid
destring state, replace force
drop if state == 72 | state == 66 | state == 60 | state == 69 | state == 78
drop state
rename zcta5 zip
rename geoid county

save "./Analysis/data/ZCTA_crosswalk_2010.dta", replace


forvalues i = 2015/2023 {
	import delimited "./Analysis/data/processed/ACS_`i'.csv", clear

	destring _all, replace force

	gen pop_under_18 = total_pop - eighteen_plus
	gen pop_18_to_65 = total_pop - sixty_five_plus - pop_under_18
// 	gen race_other = total_pop - black_only - two_plus_races - hisp - non_hisp_w
	drop eighteen_plus

	save "./Analysis/data/ACS_`i'.dta", replace
	
	// median income data by county
	import delimited using "./raw/ACS/county household income/ACSST5Y`i'.S1901-Data.csv", varnames(1) clear
	drop in 1
	keep geo_id s1901_c01_012e
	rename s1901_c01_012e county_med_y
	gen county = substr(geo_id, strlen(geo_id) - 4, 5)
	destring county_med_y county, replace force

	if `i' <= 2020 {
		merge 1:m county using ./Analysis/data/ZCTA_crosswalk_2010.dta
		drop if _merge ==1 | _merge == 2
		drop _merge
		save ./Analysis/data/ZCTA_crosswalk_2010.dta, replace
	}
	else {
		if `i' > 2021 {
			merge 1:m county using ./Analysis/data/ZCTA_crosswalk_2022.dta
			drop if _merge ==1 | _merge == 2
			drop _merge
			save ./Analysis/data/ZCTA_crosswalk_2022.dta, replace
		}
		else {
			merge 1:m county using ./Analysis/data/ZCTA_crosswalk_2020.dta
			drop if _merge ==1 | _merge == 2
			drop _merge
			save ./Analysis/data/ZCTA_crosswalk_2020.dta, replace
		}
	}		

	
	// pop data by county
	import delimited using "./raw/ACS/county pop/ACSST5Y`i'.S0101-Data.csv", varnames(1) clear
	drop in 1
	keep geo_id s0101_c01_001e
	rename s0101_c01_001e county_pop
	gen county = substr(geo_id, strlen(geo_id) - 4, 5)
	destring county_pop county, replace force

	if `i' <= 2020 {
		merge 1:m county using ./Analysis/data/ZCTA_crosswalk_2010.dta
	}
	else {
		if `i' > 2021 {
			merge 1:m county using ./Analysis/data/ZCTA_crosswalk_2022.dta
		}
		else {
			merge 1:m county using ./Analysis/data/ZCTA_crosswalk_2020.dta
		}
	}		
	drop if _merge ==1 | _merge == 2
	drop _merge
	
	// Step 1: Generate a random draw per observation, scaled by county_pop
	gen rand_weighted = runiform()^ (1 / county_pop)

	// Step 2: Tag the observation with the highest weighted draw per zip
	gen byte selected = 0
	bysort zip (rand_weighted): replace selected = 1 if _n == _N

	// Step 3: Keep only the selected observations
	keep if selected
	drop rand_weighted selected
	

	destring zip, replace force
	merge 1:1 zip using "./Analysis/data/ACS_`i'.dta"
	
	count if _merge == 1
	local unmatched = r(N)
	di "percent of unmatched crosswalk zip data: " 100 * (`unmatched' / _N)
		
	count if _merge == 2
	local unmatched = r(N)
	di "percent of unmatched ACS zip data: " 100 * (`unmatched' / _N)
	drop if _merge == 1 | _merge == 2
	
	drop _merge geo_id county_pop
	
	gen year = `i'
	
	save "./Analysis/data/ACS_`i'.dta", replace
}

cd ./Analysis
log close

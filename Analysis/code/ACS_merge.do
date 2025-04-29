/*
	Program: ACS_merge.do
	Purpose: create a panel dataset via acs demographic data 2015 - 2023
	By: MAS
	Last Updated: 04/22/25
*/

log using "./output/log_ACS_merge", text replace

forvalues i = 2015/2019 {
	use "./data/ACS_`i'.dta", clear
	merge m:1 county using "./data/CenRUCC_2010.dta"
	drop _merge
	save "./data/ACS_`i'.dta", replace
}

forvalues i = 2020/2023 {
	use "./data/ACS_`i'.dta", clear
	merge m:1 county using "./data/CenRUCC_2020.dta"
	drop _merge
	save "./data/ACS_`i'.dta", replace
}

use "./data/ACS_2015.dta", clear

forvalues i = 2016/2023 {
	append using "./data/ACS_`i'.dta"
}

save ./data/ACS_panel, replace

import delimited ./data/processed/displacement.csv, clear
merge 1:m zip year using ./data/ACS_panel
drop _merge

save ./data/ACS_panel, replace

log close

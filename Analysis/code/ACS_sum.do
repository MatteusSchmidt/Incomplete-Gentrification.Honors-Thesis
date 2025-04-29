/*
	Program: ACS_sum.do
	Purpose: To create the sum stat tables in excel for the codebook
	By: MAS
	Last Updated: 04/01/25
*/

log using "./output/log_ACS_sum", text replace

forvalues i = 2015/2023 {
	use "./data/ACS_`i'.dta", clear
	putexcel set "./output/ACS_summary_statistics.xlsx", modify sheet("ACS_`i'")
	putexcel A1 = "ACS_`i'"
	local place = 3
	foreach var of varlist _all {
		capture confirm numeric variable `var'
		if _rc != 0 | "`var'" == "zip" | "`var'" == "county" | "`var'" == "year"{
			continue
        }
		
		quietly summarize `var', detail
		local me : display %9.2f r(mean)
		local med : display %9.2f r(p50)
		local std_dev : display %9.2f r(sd)
		local min : display %9.2f r(min)
		local max : display %9.2f r(max)
		local obs = r(N)
		local missing = _N - r(N)
		
		putexcel A2 = "Variable" B2 = "Mean" C2 = "Median" D2 = "Standard Deviation" E2 = "Minimum"
		putexcel F2 = "Maximum" G2 = "Missing Values" H2 = "Observations"
		putexcel A`place' = "`var'" B`place' = `me' C`place' = `med' D`place' = `std_dev' 
		putexcel E`place' = `min' F`place' = `max' G`place' = `missing' H`place' = `obs'
		local place = `place' + 1
	}
}

log close

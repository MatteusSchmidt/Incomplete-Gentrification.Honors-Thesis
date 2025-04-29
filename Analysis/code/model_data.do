/*
	Program: model_data.do
	Purpose: To create the target variable splines by zip
	By: MAS
	Last Updated: 04/25/25
*/

log using "./output/log_model_data", text replace

use ./data/ACS_panel_urban.dta, clear
keep year zip vulnerability
gen vulnerable = 1

merge 1:m zip year using ./data/ACS_panel
drop _merge
replace vulnerable = 0 if displacement == .
drop if year == 2016 | year == 2015

gen displacement_scaled = displacement
replace displacement_scaled = 5 + 0.25*(displacement - 5) if displacement > 5
replace displacement_scaled = 10  if displacement_scaled > 10

gen pct_homeownership = homeowner_units_occ / housing_units_occ

bysort year: egen z_median_income = std(med_h_y)
bysort year: egen z_pct_bach_grad = std(perc_bach_grad_and_above)
bysort year: egen z_median_rent = std(med_rent)
bysort year: egen z_pct_homeownership = std(pct_homeownership)
bysort year: egen z_pct_poverty = std(perc_below_pov_line)

drop if z_median_income == .
drop if z_pct_bach_grad == .
drop if z_median_rent == .
drop if z_pct_homeownership == .
drop if z_pct_poverty == .


drop if (missing(RUCC_2013) & RUCC_2023 > 3) | (!missing(RUCC_2013) & RUCC_2013 > 3)

* quadratic term
gen year2 = year^2

save ./data/model_data, replace
//
// * Empty cumulative temp file to start
// tempfile temp cumulative
// clear
// save `cumulative', emptyok replace
//
// * spline creation
// forvalues i = 2019/2022 {
//     use ./data/model_data, clear
//     local start = `i' - 2
//     keep if inrange(year, `start', `i')
//	
// 	gen year_centered = year - `start'
//     gen year2_centered = year_centered^2
//
//     * Save subset
//     tempfile tempdata
//     save `tempdata', replace
//
//     * Run statsby cleanly
//     statsby slope=_b[year_centered] curvature=_b[year2_centered] eval_year=`i', by(zip): regress z_median_income year_centered year2_centered
//
//     * Save current spline results
//     tempfile partial
//     save `partial', replace
//
//     * Now accumulate into master file
//     use `cumulative', clear
//     append using `partial'
//     save `cumulative', replace
// }
// use `cumulative', clear
// save ./data/med_income_spline, replace
//
// tempfile temp cumulative
// clear
// save `cumulative', emptyok replace
//
// forvalues i = 2019/2022 {
//     use ./data/model_data, clear
//     local start = `i' - 2
//     keep if inrange(year, `start', `i')
//	
// 	gen year_centered = year - `start'
//     gen year2_centered = year_centered^2
//
//     * Save subset
//     tempfile tempdata
//     save `tempdata', replace
//
//     * Run statsby cleanly
//     statsby slope=_b[year_centered] curvature=_b[year2_centered] eval_year=`i', by(zip): regress z_pct_homeownership year_centered year2_centered
//
//     * Save current spline results
//     tempfile partial
//     save `partial', replace
//
//     * Now accumulate into master file
//     use `cumulative', clear
//     append using `partial'
//     save `cumulative', replace
// }
// use `cumulative', clear
// save ./data/pct_homeownership_spline, replace
//
// tempfile temp cumulative
// clear
// save `cumulative', emptyok replace
//
// * spline creation
// forvalues i = 2019/2022 {
//     use ./data/model_data, clear
//     local start = `i' - 2
//     keep if inrange(year, `start', `i')
//	
// 	gen year_centered = year - `start'
//     gen year2_centered = year_centered^2
//
//     * Save subset
//     tempfile tempdata
//     save `tempdata', replace
//
//     * Run statsby cleanly
//     statsby slope=_b[year_centered] curvature=_b[year2_centered] eval_year=`i', by(zip): regress z_median_rent year_centered year2_centered
//
//     * Save current spline results
//     tempfile partial
//     save `partial', replace
//
//     * Now accumulate into master file
//     use `cumulative', clear
//     append using `partial'
//     save `cumulative', replace
// }
// use `cumulative', clear
// save ./data/median_rent_spline, replace
//
// tempfile temp cumulative
// clear
// save `cumulative', emptyok replace
//
// * spline creation
// forvalues i = 2019/2022 {
//     use ./data/model_data, clear
//     local start = `i' - 2
//     keep if inrange(year, `start', `i')
//	
// 	gen year_centered = year - `start'
//     gen year2_centered = year_centered^2
//
//     * Save subset
//     tempfile tempdata
//     save `tempdata', replace
//
//     * Run statsby cleanly
//     statsby slope=_b[year_centered] curvature=_b[year2_centered] eval_year=`i', by(zip): regress z_pct_bach_grad year_centered year2_centered
//
//     * Save current spline results
//     tempfile partial
//     save `partial', replace
//
//     * Now accumulate into master file
//     use `cumulative', clear
//     append using `partial'
//     save `cumulative', replace
// }
// use `cumulative', clear
// save ./data/pct_bach_grad_spline, replace
//
// tempfile temp cumulative
// clear
// save `cumulative', emptyok replace
//
// * spline creation
// forvalues i = 2019/2022 {
//     use ./data/model_data, clear
//     local start = `i' - 2
//     keep if inrange(year, `start', `i')
//	
// 	gen year_centered = year - `start'
//     gen year2_centered = year_centered^2
//
//     * Save subset
//     tempfile tempdata
//     save `tempdata', replace
//
//     * Run statsby cleanly
//     statsby slope=_b[year_centered] curvature=_b[year2_centered] eval_year=`i', by(zip): regress z_pct_poverty year_centered year2_centered
//
//     * Save current spline results
//     tempfile partial
//     save `partial', replace
//
//     * Now accumulate into master file
//     use `cumulative', clear
//     append using `partial'
//     save `cumulative', replace
// }
// use `cumulative', clear
// save ./data/pct_poverty_spline, replace

log close

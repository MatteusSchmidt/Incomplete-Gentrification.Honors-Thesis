/*
	Program: model.do
	Purpose: To create the mathematical model establishing incomplete gentrification amongst Urban data
	By: MAS
	Last Updated: 04/25/25
*/

log using "./output/log_model", text replace

use ./data/med_income_spline, clear
drop if missing(eval_year, zip, curvature, slope)
rename slope slope_inc
rename curvature curvature_inc
rename eval_year year
merge 1:1 zip year using ./data/model_data
drop _merge
save ./data/model_data, replace

use ./data/pct_homeownership_spline, clear
drop if missing(eval_year, zip, curvature, slope)
rename slope slope_homeownership
rename curvature curvature_homeownership
rename eval_year year
merge 1:1 zip year using ./data/model_data
drop _merge
save ./data/model_data, replace

use ./data/median_rent_spline, clear
drop if missing(eval_year, zip, curvature, slope)
rename slope slope_rent_med
rename curvature curvature_rent_med
rename eval_year year
merge 1:1 zip year using ./data/model_data
drop _merge
save ./data/model_data, replace

use ./data/pct_bach_grad_spline, clear
drop if missing(eval_year, zip, curvature, slope)
rename slope slope_bach_grad
rename curvature curvature_bach_grad
rename eval_year year
merge 1:1 zip year using ./data/model_data
drop _merge
save ./data/model_data, replace

use ./data/pct_poverty_spline, clear
drop if missing(eval_year, zip, curvature, slope)
rename slope slope_poverty
rename curvature curvature_poverty
rename eval_year year
merge 1:1 zip year using ./data/model_data
drop _merge
drop if year < 2019
save ./data/model_data, replace

log close

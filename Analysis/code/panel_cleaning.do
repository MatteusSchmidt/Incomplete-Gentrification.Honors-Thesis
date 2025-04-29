/*
	Program: panel_cleaning.do
	Purpose: To clean the panel data so that vulnerable zips are flagged and the mathematical model may be implemented
	By: MAS
	Last Updated: 04/24/25
*/

log using "./output/log_panel_cleaning", text replace

use ./data/ACS_panel, clear

destring RUCC_2023, replace force
destring RUCC_2013, replace force

// save only metro areas
drop if (missing(RUCC_2013) & RUCC_2023 > 3) | (!missing(RUCC_2013) & RUCC_2013 > 3)

gen renters_perc = renters_units_occ / housing_units_occ
gen people_of_c_perc = 1 - nonhisp_white_perc
gen pct_nobachelors = 1 - perc_bach_grad_and_above
gen threshold = 0.8 * county_med_y
gen pct_below_80ami = 0

* Define locals manually
local bins hi_05k hi_510k hi_1015k hi_1520k hi_2025k hi_2535k hi_3550k hi_5075k hi_75100k hi_100150k hi_150k_plus
local lowers 0 5000 10000 15000 20000 25000 35000 50000 75000 100000 150000
local uppers 5000 10000 15000 20000 25000 35000 50000 75000 100000 150000 .

* Set up a counter
local nvars : word count `bins'

* Now loop through them
forvalues i = 1/`nvars' {
    local bin : word `i' of `bins'
    local lower : word `i' of `lowers'
    local upper : word `i' of `uppers'
  
    quietly {
        replace pct_below_80ami = pct_below_80ami + `bin' if threshold >= `upper' & !missing(`bin')
        replace pct_below_80ami = pct_below_80ami + (`bin' * ((threshold - `lower')/(`upper' - `lower'))) ///
            if threshold > `lower' & threshold < `upper' & !missing(`bin')
    }
}

bysort year (zip): egen z_pct_renters = std(renters_perc)
bysort year (zip): egen z_pct_poc = std(people_of_c_perc)
bysort year (zip): egen z_pct_low_income = std(pct_below_80ami)
bysort year (zip): egen z_pct_kids_poverty = std(hh_w_child_pov_perc)
bysort year (zip): egen z_pct_nobachelors = std(pct_nobachelors)

gen v_renters = (z_pct_renters > 0.5)
gen v_poc = (z_pct_poc > 0.5)
gen v_low_income = (z_pct_low_income > 0.5)
gen v_kids_poverty = (z_pct_kids_poverty > 0.5)
gen v_nobachelors = (z_pct_nobachelors > 0.5)

gen total_vulnerabilities = v_renters + v_poc + v_low_income + v_kids_poverty + v_nobachelors

drop if total_vulnerabilities < 3

gen vulnerability = (z_pct_nobachelors + z_pct_kids_poverty + z_pct_low_income + z_pct_poc + z_pct_renters) / 5

drop z_pct_renters z_pct_poc z_pct_low_income z_pct_kids_poverty z_pct_nobachelors v_renters v_poc v_low_income v_kids_poverty v_nobachelors total_vulnerabilities

drop if zip == .
drop if vulnerability == .

save ./data/ACS_panel_urban, replace

log close

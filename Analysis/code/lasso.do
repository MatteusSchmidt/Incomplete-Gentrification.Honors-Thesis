/*
	Program: lasso.do
	Purpose: To prove the significance of the created gentrification metric
	By: MAS
	Last Updated: 04/25/25
*/

log using "./output/log_model_data", text replace

use ./data/model_data, clear

xtset zip year
bysort zip (year): gen med_rent_future = F1.med_rent

gen gentrification_score = 1*slope_inc + 0.75*curvature_inc + 1.25*slope_rent_med + 1*curvature_rent_med + -1*slope_poverty + -0.75*curvature_poverty + -1*slope_homeownership + -0.75*curvature_homeownership + 1*slope_bach_grad + 0.75*curvature_bach_grad + 1*displacement

gen ln_med_rent_future = log(med_rent_future)
gen ln_med_rent = log(med_rent)

save ./data/model, replace

drop if year > 2021

lasso linear ln_med_rent_future gentrification_score ln_med_rent hs_incomp_25_plus nonhisp_white_perc hisp_perc nonhisp_black_perc perc_below_pov_line med_h_y mean_com_time_min hh_w_child_pov_perc pct_homeownership 

lassocoef

log close

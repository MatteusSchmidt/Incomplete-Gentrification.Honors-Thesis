/*
	Program: ACS_codebook.do
	Purpose: generate a codebook for ACS_panel dataset
	By: MAS
	Last Updated: 04/22/25
*/

//-------------------------------------------------------------------\\

/*
	Change dataset_name to the value of the dataset saved in the workdir/data (ommit .dta)
*/

local dataset_name = "ACS_panel"

//-------------------------------------------------------------------//


use "$workdir/data/`dataset_name'.dta", clear
log using "./output/log_`dataset_name'_codebook", text replace
putexcel set "./codebooks/`dataset_name'_codebook_generated.xlsx", replace sheet(`dataset_name')

tempname formatting
postfile `formatting' str32 var_name str10 var_type str15 var_format using "./data/`dataset_name'_codebook_format.dta", replace

foreach var of varlist _all {
    local vtype : type `var'
    local vformat : format `var'
    post `formatting' ("`var'") ("`vtype'") ("`vformat'")
}

postclose `formatting'

use "./data/`dataset_name'_codebook_format.dta", clear

putexcel A2 = "VARIABLE" B2 = "DESCRIPTION" C2 = "TYPE" D2 = "FORMAT" E2 = "LOOKUP"

local row = 3

//-------------------------------------------------------------------\\
/*
	Change the list of variables named lookups to contain those which you'd like 
		Frequencies and summary statistics of
		
	Column names separated by spaces contained within the quotes
*/

local lookups "RUCC_2023 RUCC_2013 RUCC_description"

//-------------------------------------------------------------------//

forvalues i = 1/`=_N' {
	local condition = 0
	local name = var_name[`i']
	
	foreach varname in `lookups' {
		if var_name[`i'] == "`varname'" {
			local condition = 1
		}
	}
	
	if `condition' == 1 {
        putexcel A`row' = "`name'" C`row' = "`vtype'" D`row' = "`vformat'" E`row' = `"=HYPERLINK("#`name'!A1", "See Tab")"'
    }
    else {
        putexcel A`row' = "`name'" C`row' = "`vtype'" D`row' = "`vformat'"
    }
	
    local ++row
}

use "$workdir/data/`dataset_name'.dta", clear

//-------------------------------------------------------------------\\
/*
	Change the list of variables named lookups to contain those which you'd like frequency 
		tables of (Summary statistics not computed) (can copy paste from previous lookups - no quotes)
		
	Column names separated by spaces following <lookups>
*/

local lookups RUCC_2023 RUCC_2013 RUCC_description

//-------------------------------------------------------------------//

putexcel set "./codebooks/`dataset_name'_codebook_generated.xlsx", modify sheet("Summary Statistics")
putexcel A1 = "`dataset_name'"
local place = 3
foreach var of varlist _all {
	capture confirm numeric variable `var'
	if _rc != 0 | strpos("`lookups'", "`var'") | "`var'" == "zip" | "`var'" == "county" {
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

foreach item in `lookups' {
	putexcel set "./codebooks/`dataset_name'_codebook_generated.xlsx", modify sheet("`item'")
	capture confirm numeric variable `item'
	if _rc == 0 {  
		tostring `item', replace force
		replace `item' = "MISSING" if `item' == "."
	}
	else {
		replace `item' = "EMPTY" if `item' == ""
	}
	tabulate `item', matcell(freq)
	levelsof `item', local(categories)

	scalar total_freq = 0
	matrix percent = freq / _N * 100	
	putexcel A7 = "`item'" B7 = "Description" C7 = "Freq." D7 = "Percentage"

	local index = 1
	local place = 8
	local has_missing = 0
	foreach category in `categories' {
		if `"`category'"' == "MISSING" | `"`category'"' == "EMPTY" {
			local num_categories: word count `categories'
			local missing_place = `num_categories' + 7
			putexcel A`missing_place' = `"`category'"' C`missing_place' = freq[`index',1] D`missing_place' = percent[`index',1]
			local has_missing = 1
		}
		else {
			putexcel A`place' = `"`category'"' C`place' = freq[`index',1] D`place' = percent[`index',1]
			local place = `place' + 1
		}
		scalar total_freq = total_freq + freq[`index',1]
		local index = `index' + 1
	}
	if `has_missing' == 1 {
		local place = `place' + 1
	}
	putexcel A`place' = "Total" C`place' = total_freq D`place' = 100, bold
	
	local place = `place' + 2
	putexcel D`place' = `"=HYPERLINK("#`dataset_name'!A1", "home <<")"'
}

log close

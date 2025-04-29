/*
	Program: ACS_data_prep.do
	Purpose: all processes for RUCC ARD data
	By: MAS
	Last Updated: 03/11/25
*/

cd ..

log using ./Analysis/output/log_RUCC_cleaning.log, text replace

import excel ./raw/RUCC/RUCC_2013.xls, sheet("RUCC 2013") firstrow clear
drop State County_Name
save ./Analysis/data/RUCC_2013, replace

import excel ./raw/RUCC/RUCC_2023.xlsx, sheet("RUCC 2023") firstrow clear
drop State County_Name
save ./Analysis/data/RUCC_2023, replace

cd ./Analysis

log close

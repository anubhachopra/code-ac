clear all
set more off
set matsize 10000
set maxvar 10000


global homepath "C:\Users\ac4296\OneDrive - Drexel University\Desktop\DLR replication files"
global datapath "${homepath}\Data"
global outputpath "${homepath}\Data\Output"
global dopath "${homepath}\Dofiles"
global estimatespath "${homepath}\Data\Output\Estimates"


***all counties***

use "$datapath\qwi_minwage_ALLcounties_database2011_rev.dta", clear

 /*cap log close
 log using "${outputpath}/Table1.log", replace*/

keep if year >= 2000

**Anubha's code begins here

* identify samples
foreach j in fempns earnend emp hira sep turnovra earns emps hiras seps turnovrs earnns empns hirans sepns turnovrns nemphira nempsep {
	if "`j'" == "emp" local catlist 0A00 722A00 /*722A01 722A02*/
	else local catlist 0A00 722A00
	foreach cat in `catlist' {
		if "`j'" == "emp" local genlist BS F M
		else local genlist BS F M
		foreach gender in `genlist' {
			
			if "`j'" == "fempns" rename `j'_`cat'_`gender' `j'`cat'_`gender'

			* identify sample used in regressions
			replace `j'`cat'_`gender' = . if flag_`j'`cat'_`gender'_50 == 1
		} // gen
	} // cat
} // j

* create vars
* recode to missing if not in regression samples

/*
gen fteen_722A00_BS = emp722A01_BS/emp722A00_BS
gen fteen_0A01_BS = 1 // make fraction teen for teens

gen fya_722A00_BS = emp722A02_BS/emp722A00_BS
gen fya_0A01_BS = 0

gen ffem_722A00_BS = emp722A00_F/emp722A00_BS
gen ffem_0A01_BS = emp0A01_F/emp0A01_BS
*/

foreach stat in hira sep hiras seps {
	gen `stat'rate_722A00_BS = `stat'722A00_BS/emp722A00_BS
	gen `stat'rate_722A00_M = `stat'722A00_M/emp722A00_M
	gen `stat'rate_722A00_F = `stat'722A00_F/emp722A00_F
	gen `stat'rate_0A00_BS = `stat'0A00_BS/emp0A00_BS
	gen `stat'rate_0A00_M = `stat'0A00_M/emp0A00_M
	gen `stat'rate_0A00_F = `stat'0A00_F/emp0A00_F
}

**ALL INDUSTRIES

*BOTH SEXES
tabstat earnend0A00_BS emp0A00_BS hirarate_0A00_BS seprate_0A00_BS turnovra0A00_BS fempns0A00_BS earns0A00_BS emps0A00_BS hirasrate_0A00_BS sepsrate_0A00_BS turnovrs0A00_BS earnseps0A00_BS earnsepc0A00_BS  nempsep0A00_BS earnhiras0A00_BS earnhirac0A00_BS  nemphira0A00_BS  /*ffem_0A00_BS fteen_0A00_BS fya_0A00_BS*/, statistics(mean sd N) columns(statistics) save varwidth(24)
matrix all_pop=r(StatTotal)'
matrix colnames all_pop = all_pop_mean all_pop_sd all_pop_N

*MALES
tabstat earnend0A00_M emp0A00_M hirarate_0A00_M seprate_0A00_M turnovra0A00_M fempns0A00_M earns0A00_M emps0A00_M hirasrate_0A00_M sepsrate_0A00_M turnovrs0A00_M earnseps0A00_M earnsepc0A00_M  nempsep0A00_M earnhiras0A00_M earnhirac0A00_M  nemphira0A00_M  /*ffem_0A00_M fteen_0A00_M fya_0A00_M*/, statistics(mean sd N) columns(statistics) save varwidth(24)
matrix all_pop_M=r(StatTotal)'
matrix colnames all_pop_M = all_pop_M_mean all_pop_M_sd all_pop_M_N

*FEMALES
tabstat earnend0A00_F emp0A00_F hirarate_0A00_F seprate_0A00_F turnovra0A00_F fempns0A00_F earns0A00_F emps0A00_F hirasrate_0A00_F sepsrate_0A00_F turnovrs0A00_F earnseps0A00_F earnsepc0A00_F  nempsep0A00_F earnhiras0A00_F earnhirac0A00_F  nemphira0A00_F  /*ffem_0A00_F fteen_0A00_F fya_0A00_F*/, statistics(mean sd N) columns(statistics) save varwidth(24)
matrix all_pop_F=r(StatTotal)'
matrix colnames all_pop_F = all_pop_F_Fean all_pop_F_sd all_pop_F_N

**RESTAURANT

*BOTH SEXES
tabstat earnend722A00_BS emp722A00_BS hirarate_722A00_BS seprate_722A00_BS turnovra722A00_BS fempns722A00_BS earns722A00_BS emps722A00_BS hirasrate_722A00_BS sepsrate_722A00_BS turnovrs722A00_BS earnseps722A00_BS earnsepc722A00_BS  nempsep722A00_BS earnhiras722A00_BS earnhirac722A00_BS  nemphira722A00_BS  /*ffem_722A00_BS fteen_722A00_BS fya_722A00_BS*/, statistics(mean sd N) columns(statistics) save varwidth(24) 
matrix all_rest=r(StatTotal)'
matrix colnames all_rest = all_rest_mean all_rest_sd all_rest_N

*MALES
tabstat earnend722A00_M emp722A00_M hirarate_722A00_M seprate_722A00_M turnovra722A00_M fempns722A00_M earns722A00_M emps722A00_M hirasrate_722A00_M sepsrate_722A00_M turnovrs722A00_M earnseps722A00_M earnsepc722A00_M  nempsep722A00_M earnhiras722A00_M earnhirac722A00_M  nemphira722A00_M  /*ffem_722A00_M fteen_722A00_M fya_722A00_M*/, statistics(mean sd N) columns(statistics) save varwidth(24) 
matrix all_rest_M=r(StatTotal)'
matrix colnames all_rest_M = all_rest_M_mean all_rest_M_sd all_rest_M_N

*FEMALES
tabstat earnend722A00_F emp722A00_F hirarate_722A00_F seprate_722A00_F turnovra722A00_F fempns722A00_F earns722A00_F emps722A00_F hirasrate_722A00_F sepsrate_722A00_F turnovrs722A00_F earnseps722A00_F earnsepc722A00_F  nempsep722A00_F earnhiras722A00_F earnhirac722A00_F  nemphira722A00_F  /*ffem_722A00_F fteen_722A00_F fya_722A00_F*/, statistics(mean sd N) columns(statistics) save varwidth(24) 
matrix all_rest_F=r(StatTotal)'
matrix colnames all_rest_F = all_rest_F_mean all_rest_F_sd all_rest_F_N

**Anubha's code ends here

***paired counties***

use "$datapath/qwi_minwage_countypair_database2011_rev.dta", clear

keep if year >= 2000
keep if pairdist <= 75
drop bothflag*

* identify samples
foreach j in fempns earnend emp hira sep turnovra earns emps hiras seps turnovrs earnns empns hirans sepns turnovrns nemphira nempsep {

	if "`j'" == "emp" local catlist 0A00 722A00
	else local catlist 0A00 722A00
	foreach cat in `catlist' {
		if "`j'" == "emp" local genlist BS F M
		else local genlist BS F M
		foreach gender in `genlist' {
	
			if "`j'" == "fempns" rename `j'_`cat'_`gender' `j'`cat'_`gender'

			* identify non-primary sample
			egen byte bothflag_`j'`cat'_`gender'_50 = max(flag_`j'`cat'_`gender'_50), by(pair_id)

			* identify pair beginning date requirement sample
			gen byte primarysample = bothflag_`j'`cat'_`gender'_50 == 0
			egen byte sumexist = total(primarysample), by(absorb_2)
			gen byte bothexist = sumexist == 2
			egen _pairentrydate = min(period) if bothexist == 1, by(pair_id)
			egen pairentrydate = max(_pairentrydate), by(pair_id)
			gen byte edsample_`j'_`cat'_`gender'_50 = period >= pairentrydate
		
			* identify sample used in regressions
			gen byte regsample_`j'_`cat'_`gender' = bothflag_`j'`cat'_`gender'_50 == 0 & edsample_`j'_`cat'_`gender'_50 == 1

			drop primarysample sumexist bothexist _pairentrydate pairentrydate bothflag* edsample*


			replace `j'`cat'_`gender' = . if regsample_`j'_`cat'_`gender' == 0
		} // gen
	} // cat
} // j




* create vars
* recode to missing if not in regression sample

/*
gen fteen_722A00_BS = emp722A01_BS/emp722A00_BS
gen fteen_0A01_BS = 1 // make fraction teen for teens

gen fya_722A00_BS = emp722A02_BS/emp722A00_BS
gen fya_0A01_BS = 0

gen ffem_722A00_BS = emp722A00_F/emp722A00_BS
gen ffem_0A01_BS = emp0A01_F/emp0A01_BS

foreach stat in hira sep hiras seps {
	gen `stat'rate_722A00_BS = `stat'722A00_BS/emp722A00_BS
	gen `stat'rate_0A01_BS = `stat'0A01_BS/emp0A01_BS
}
*/

foreach stat in hira sep hiras seps {
	gen `stat'rate_722A00_BS = `stat'722A00_BS/emp722A00_BS
	gen `stat'rate_722A00_M = `stat'722A00_M/emp722A00_M
	gen `stat'rate_722A00_F = `stat'722A00_F/emp722A00_F
	gen `stat'rate_0A00_BS = `stat'0A00_BS/emp0A00_BS
	gen `stat'rate_0A00_M = `stat'0A00_M/emp0A00_M
	gen `stat'rate_0A00_F = `stat'0A00_F/emp0A00_F
}

**ALL INDUSTRIES

*BOTH SEXES
tabstat earnend0A00_BS emp0A00_BS hirarate_0A00_BS seprate_0A00_BS turnovra0A00_BS fempns0A00_BS earns0A00_BS emps0A00_BS hirasrate_0A00_BS sepsrate_0A00_BS turnovrs0A00_BS earnseps0A00_BS earnsepc0A00_BS  nempsep0A00_BS earnhiras0A00_BS earnhirac0A00_BS  nemphira0A00_BS  /*ffem_0A00_BS fteen_0A00_BS fya_0A00_BS*/, statistics(mean sd N) columns(statistics) save varwidth(24)
matrix matched_pop=r(StatTotal)'
matrix colnames matched_pop = matched_pop_mean matched_pop_sd matched_pop_N

*MALES
tabstat earnend0A00_M emp0A00_M hirarate_0A00_M seprate_0A00_M turnovra0A00_M fempns0A00_M earns0A00_M emps0A00_M hirasrate_0A00_M sepsrate_0A00_M turnovrs0A00_M earnseps0A00_M earnsepc0A00_M  nempsep0A00_M earnhiras0A00_M earnhirac0A00_M  nemphira0A00_M  /*ffem_0A00_M fteen_0A00_M fya_0A00_M*/, statistics(mean sd N) columns(statistics) save varwidth(24)
matrix matched_pop_M=r(StatTotal)'
matrix colnames matched_pop_M = matched_pop_M_mean matched_pop_M_sd matched_pop_M_N

*FEMALES
tabstat earnend0A00_F emp0A00_F hirarate_0A00_F seprate_0A00_F turnovra0A00_F fempns0A00_F earns0A00_F emps0A00_F hirasrate_0A00_F sepsrate_0A00_F turnovrs0A00_F earnseps0A00_F earnsepc0A00_F  nempsep0A00_F earnhiras0A00_F earnhirac0A00_F  nemphira0A00_F  /*ffem_0A00_F fteen_0A00_F fya_0A00_F*/, statistics(mean sd N) columns(statistics) save varwidth(24)
matrix matched_pop_F=r(StatTotal)'
matrix colnames matched_pop_F = matched_pop_F_Fean matched_pop_F_sd matched_pop_F_N

**RESTAURANT

*BOTH SEXES
tabstat earnend722A00_BS emp722A00_BS hirarate_722A00_BS seprate_722A00_BS turnovra722A00_BS fempns722A00_BS earns722A00_BS emps722A00_BS hirasrate_722A00_BS sepsrate_722A00_BS turnovrs722A00_BS earnseps722A00_BS earnsepc722A00_BS  nempsep722A00_BS earnhiras722A00_BS earnhirac722A00_BS  nemphira722A00_BS  /*ffem_722A00_BS fteen_722A00_BS fya_722A00_BS*/, statistics(mean sd N) columns(statistics) save varwidth(24) 
matrix matched_rest=r(StatTotal)'
matrix colnames matched_rest = matched_rest_mean matched_rest_sd matched_rest_N

*MALES
tabstat earnend722A00_M emp722A00_M hirarate_722A00_M seprate_722A00_M turnovra722A00_M fempns722A00_M earns722A00_M emps722A00_M hirasrate_722A00_M sepsrate_722A00_M turnovrs722A00_M earnseps722A00_M earnsepc722A00_M  nempsep722A00_M earnhiras722A00_M earnhirac722A00_M  nemphira722A00_M  /*ffem_722A00_M fteen_722A00_M fya_722A00_M*/, statistics(mean sd N) columns(statistics) save varwidth(24) 
matrix matched_rest_M=r(StatTotal)'
matrix colnames matched_rest_M = matched_rest_M_mean matched_rest_M_sd matched_rest_M_N

*FEMALES
tabstat earnend722A00_F emp722A00_F hirarate_722A00_F seprate_722A00_F turnovra722A00_F fempns722A00_F earns722A00_F emps722A00_F hirasrate_722A00_F sepsrate_722A00_F turnovrs722A00_F earnseps722A00_F earnsepc722A00_F  nempsep722A00_F earnhiras722A00_F earnhirac722A00_F  nemphira722A00_F  /*ffem_722A00_F fteen_722A00_F fya_722A00_F*/, statistics(mean sd N) columns(statistics) save varwidth(24) 
matrix matched_rest_F=r(StatTotal)'
matrix colnames matched_rest_F = matched_rest_F_mean matched_rest_F_sd matched_rest_F_N

***combine matrices, make into dta file***

matrix Table1= all_pop, all_pop_M, all_pop_F, matched_pop, matched_pop_M, matched_pop_F
set linesize 200
matrix list Table1

matrix Table1_722= all_rest, all_rest_M, all_rest_F, matched_rest, matched_rest_M, matched_rest_F
set linesize 200
matrix list Table1_722

clear

svmat Table1, names(col)

save "${outputpath}/Table1", replace

clear

svmat Table1_722, names(col)

save "${outputpath}/Table1 722", replace

/*

qui foreach var of varlist all_teen_N all_rest_N matched_teen_N matched_rest_N {
	sum `var'
	local `var'_max = r(max)
	local `var'_min = r(min)
}
local N_all_max = max(`all_teen_N_max',`all_rest_N_max')
local N_all_min = min(`all_teen_N_min',`all_rest_N_min')
local N_matched_max = max(`matched_teen_N_max',`matched_rest_N_max')
local N_matched_min = min(`matched_teen_N_min',`matched_rest_N_min')


di "Sample sizes vary by demographic group, industry and tenure and range"
di "from `N_all_min' to `N_all_max' for the all county sample, and " 
di "from `N_matched_min' to `N_matched_max' for the contiguous county pair sample." 


log close

*/

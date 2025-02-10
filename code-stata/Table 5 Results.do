
clear all
set more off
set matsize 10000
set maxvar 10000


*global homepath "/Users/arindrajitdube/Documents/QWI Minimum Wage/Empirics/replication files/"
global homepath "C:\Users\ac4296\OneDrive - Drexel University\Desktop\DLR replication files"
global datapath "${homepath}/Data"
global outputpath "${homepath}/Data/Output"
global dopath "${homepath}/Dofiles"
global estimatespath "${homepath}/Data/Output/Estimates"


* SAMPLE DEFINITION & CONTROLS: BOTH SEXES
local BSl A00 /*AGE GROUP*/
local BSk 0 /*SEX*/
local BScontrols lnpop /*lnteenpop lnemp_0A00_BS*/

* SAMPLE DEFINITION & CONTROLS: MALE
local Ml A00 /*AGE GROUP*/
local Mk 1 /*SEX*/
local Mcontrols lnpop /*lnteenpop lnemp_0A00_M*/

* SAMPLE DEFINITION & CONTROLS: FEMALE
local Fl A00 /*AGE GROUP*/
local Fk 2 /*SEX*/
local Fcontrols lnpop /*lnteenpop lnemp_0A00_F*/

/*
* SAMPLE DEFINITION & CONTROLS: RESTAURANT WORKERS
local restl A00
local restk 722
local restcontrols lnpop lnemp_0A00_BS
*/



use year quarter period state_fips pairdist lnMW lnpop lnteenpop countyreal bordersegment pair_id absorb_* ln*_0A00_BS ln*_0A00_M ln*_0A00_F flag_*0A00_*_* s*0A00_* /* ln*_722A00_BS ln*_0A01_BS flag_*0A01_BS_* flag_*722A00_BS_* s*0A01_BS s*722A00_BS */ using "$datapath/qwi_minwage_countypair_database2011_rev.dta", clear 


*** generate sample indicators *****
gen byte sample2000 = year >= 2000
keep if sample2000 == 1
compress

* generate the estimates
foreach j in earnend emp hira sep turnovra  { // outcomes are earnings, employment, new hires, separations, turnover
	foreach cat in BS M F /*teen rest*/ {
		/*
		local l ``cat'l'
		local k ``cat'k'
		*/
	
		* identify non-primary sample
     		egen byte bothflag50 = max(flag_`j'0A00_`cat'_50), by(pair_id)
	
		* identify pair beginning date
		gen byte primarysample = bothflag50 == 0
		egen byte sumexist = total(primarysample), by(absorb_2)
		gen byte bothexist = sumexist == 2
		egen _pairentrydate = min(period) if bothexist == 1, by(pair_id)
		egen pairentrydate = max(_pairentrydate), by(pair_id)
		gen byte entrydatesample = period >= pairentrydate

		foreach spec in 1 2 {
			* primary sample regression
		 	twfe ln`j'_0A00_`cat' lnMW ``cat'controls' if bothflag50 == 0 & pairdist <= 75 & entrydatesample == 1, cluster(state_fips bordersegment) id(absorb_`spec' countyreal)
			if `spec' == 1 estadd local commontimeFE = "Y"
			if `spec' == 2 estadd local pairtimeFE = "Y"
	     		estimates save "${estimatespath}/table3`j'`cat'_spec`spec'", replace
		
		} // spec

		drop bothflag50 primarysample sumexist bothexist _pairentrydate pairentrydate entrydatesample
	} // cat
} // j


* generate the tables
* first load estimates
foreach j in earnend emp hira sep turnovra  { // outcomes are earnings, employment, new hires, separations, turnover
	foreach cat in BS M F /*teen rest*/ {
		/*
		local l ``cat'l'
		local k ``cat'k'
		*/

		foreach spec in 1 2 {
			estimates use "${estimatespath}/table3`j'`cat'_spec`spec'"
			eststo `j'`cat'_spec`spec'
		}
	} // cat
} // j

* now use esttab
local earnendlabel Earnings
local emplabel Employment
local hiralabel Hires
local seplabel Separations
local turnovralabel Turnover Rate

local counter = 0
foreach j in earnend emp hira sep turnovra  { 
	local counter = `counter' + 1
	if `counter' == 1 {
		local appendorreplace replace
		local mgroups mgroups("Both Sexes" "Males" "Females", pattern(1 0 1 0 1 0))
		local numbers numbers
		local title title("Minimum Wage Elasticities by Gender: Earnings, Employment Stocks and Flows")
	}
	else {
		local appendorreplace append
		local mgroups mgroups(, pattern(1 0 1 0 1 0))
		local numbers nonumbers
		local title ""
	}

	if `counter' == 5 local stats stats(N blankspace blankspace commontimeFE pairtimeFE, fmt(%9.0g) label(" " " " "Controls:" "Common time effects" "Pair-specific time effects"))
	else local stats stats(N blankspace, fmt(%9.0g) label(" " " "))
	
	* TABLE 3
	esttab /// 
	`j'BS_spec1 `j'BS_spec2 `j'M_spec1 `j'M_spec2 `j'F_spec1 `j'F_spec2 ///
	using "${outputpath}/QWIregression_Table3.csv", `appendorreplace' ///
	`title' ///
	style(tex) nodepvars nonotes nolines noeqlines nogap nomtitles collabels(none) `numbers' ///
	`mgroups' extracols(3) ///
	keep(lnMW) cells(b(star fmt(%9.3f)) se(par fmt(%9.3f)) ) ///
	varlabels(lnMW "``j'label'") ///
	starlevels(* 0.10 ** 0.05 *** 0.01) ///
	stats(N, fmt(%9.0g) label("Observations"))
}

  

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


use year quarter period state_fips pairdist lnMW lnMW_* lnpop lnteenpop countyreal bordersegment pair_id absorb_* ln*_0A00_* ln*_722A00_* ln*_0A00_* flag_*0A00_*_* flag_*722A00_*_* s*0A00_* s*722A00_* using "$datapath/qwi_minwage_countypair_database2011_rev.dta", clear 

keep if year>=2000
keep if pairdist<=75

* identify the samples
foreach j in nemphira nempsep earnhiras earnseps {
	foreach cat in 0A00 722A00 {
		foreach gender in BS M F {
		
		* identify non-primary sample
		egen byte bothflag_`j'`cat'_`gender'_50 = max(flag_`j'`cat'_`gender'_50), by(pair_id)

		* identify pair beginning date requirement sample
		gen byte primarysample = bothflag_`j'`cat'_`gender'_50 == 0
		egen byte sumexist = total(primarysample), by(absorb_2)
		gen byte bothexist = sumexist == 2
		egen _pairentrydate = min(period) if bothexist == 1, by(pair_id)
		egen pairentrydate = max(_pairentrydate), by(pair_id)
		gen byte edsample_`j'`cat'_`gender' = period >= pairentrydate

		drop primarysample sumexist bothexist _pairentrydate pairentrydate
		}
	}
}


* create the estimates
foreach j in nemphira nempsep earnhiras earnseps {
	foreach gender in BS M F {
	twfe ln`j'_0A00_`gender' lnMW lnpop lnteenpop lnemp_0A00_`gender' if bothflag_`j'0A00_`gender'_50==0 & edsample_`j'0A00_`gender' == 1, cluster(state_fips bordersegment) id(absorb_2 countyreal)
    	estimates save "${estimatespath}/table8ln`j'_0A00_`gender'", replace

	twfe ln`j'_722A00_`gender' lnMW lnpop lnemp_0A00_`gender' if bothflag_`j'722A00_`gender'_50==0 & edsample_`j'722A00_`gender' == 1, cluster(state_fips bordersegment) id(absorb_2 countyreal)
	estimates save "${estimatespath}/table8ln`j'_722A00_`gender'", replace
	}
}
*/



* create the tables

foreach j in nemphira nempsep earnhiras earnseps {
	foreach cat in 0A00 722A00 {
		foreach gender in BS M F {
			estimates use "${estimatespath}/table8ln`j'_`cat'_`gender'"
			estimates store ln`j'_`cat'_`gender'
		}
	}
}

local nempspeclist lnnemphira_0A00_BS lnnempsep_0A00_BS lnnemphira_0A00_M lnnempsep_0A00_M  lnnemphira_0A00_F lnnempsep_0A00_F lnnemphira_722A00_BS lnnempsep_722A00_BS lnnemphira_722A00_M lnnempsep_722A00_M lnnemphira_722A00_F lnnempsep_722A00_F
local earnspeclist lnearnhiras_0A00_BS lnearnseps_0A00_BS  lnearnhiras_0A00_M lnearnseps_0A00_M  lnearnhiras_0A00_F lnearnseps_0A00_F lnearnhiras_722A00_BS lnearnseps_722A00_BS lnearnhiras_722A00_M lnearnseps_722A00_M lnearnhiras_722A00_F lnearnseps_722A00_F
local nemplabel Non-employment duration
local earnlabel Full-quarter earnings

local counter = 0
foreach j in earn nemp  { 
	local counter = `counter' + 1
	if `counter' == 1 {
		local appendorreplace replace
		local mgroups mgroups("Both Sexes" "Males" "Females", pattern(1 0 1 0))
		local numbers numbers
		local title title("Minimum Wage Elasticities for Movers: Non-Employment Duration and Earnings Changes")
		local mlabels mlabels("Hires" "Separations" "Hires" "Separations")
	}
	else {
		local appendorreplace append
		local mgroups mgroups(, pattern(1 0 1 0))
		local numbers nonumbers
		local title ""
		local mlabels nomtitles
	}

	local stats stats(N blankspace, fmt(%9.0g) label(" " " "))
	
	* TABLE D1
	esttab /// 
	``j'speclist' ///
	using "${outputpath}/QWIregression_TableD1.csv", `appendorreplace' ///
	`title' ///
	style(tex) nodepvars nonotes nolines noeqlines nogap collabels(none) `numbers' ///
	 `mgroups'  `mlabels' extracols(3) ///
	keep(lnMW) cells(b(star fmt(%9.3f)) se(par fmt(%9.3f)) ) ///
	varlabels(lnMW "``j'label'") ///
	starlevels(* 0.10 ** 0.05 *** 0.01) ///
	`stats'
}

 
 
 

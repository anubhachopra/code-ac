clear all
set mem 30g
set more off
set matsize 10000
set maxvar 10000


global homepath "C:\Users\ac4296\OneDrive - Drexel University\Desktop\DLR replication files"
global datapath "${homepath}/Data"
global outputpath "${homepath}/Data/Output"
global dopath "${homepath}/Dofiles"
global estimatespath "${homepath}/Data/Output/Estimates"
adopath + "$dopath" //this is where ivreg2.ado is


// create a random sample from ALL county sample // 
use year period state_fips   state_name   *pop* countyreal  ln*   using "$datapath/qwi_minwage_ALLcounties_database2011_rev.dta", clear

keep if year>=2000


tsset countyreal period


// now create a random sample from BORDER county sample

* tsset county_pair_id period
use year period pair_id state_fips *dist* state_name all pairdist *flag* *pop* countyreal  ln*    using "$datapath/qwi_minwage_countypair_database2011_rev.dta", clear

keep if year>=2000
keep if pairdist<75
 
egen pairidcounty = group(pair_id countyreal)
tsset pairidcounty period

*ALL SEXES

g epop = exp(lnemp_0A00_BS - lnpop)
g emp = exp(lnemp_0A00_BS)
g turnrate = exp(lnturnovra_0A00_BS)
*g teenshare = exp( lnteenpop - lnpop)
g lnearn = lnearnend_0A00_BS
g lnemp = ln(emp)

g empgrow4 = S4.lnemp 
g earngrow4 = S4.lnearn
g popgrow4 = S4.lnpop
*g teensharegrow4 = S4.teenshare
g turnrategrow4 = S4.turnrate
g epopgrow4 = S4.epop

g empgrow12 = S12.lnemp 
g earngrow12 = S12.lnearn
g popgrow12 = S12.lnpop
*g teensharegrow12 = S12.teenshare
g turnrategrow12 = S12.turnrate
g epopgrow12 = S12.epop

*MALES

*g epop_M = exp(lnemp_0A00_M - lnpop_M)
g emp_M = exp(lnemp_0A00_M)
g turnrate_M = exp(lnturnovra_0A00_M)
*g teenshare = exp( lnteenpop - lnpop)
g lnearn_M = lnearnend_0A00_M
g lnemp_M = ln(emp_M)

g empgrow4_M = S4.lnemp_0A00_M 
g earngrow4_M = S4.lnearn_M
*g popgrow4 = S4.lnpop
*g teensharegrow4 = S4.teenshare
g turnrategrow4_M = S4.turnrate_M
*g epopgrow4_M = S4.epop_M

g empgrow12_M = S12.lnemp_0A00_M 
g earngrow12_M = S12.lnearn_M
*g popgrow12 = S12.lnpop
*g teensharegrow12 = S12.teenshare
g turnrategrow12_M = S12.turnrate_M
*g epopgrow12_M = S12.epop_M

*FEMALES
*g epop_F = exp(lnemp_0A00_F - lnpop_F)
g emp_F = exp(lnemp_0A00_F)
g turnrate_F = exp(lnturnovra_0A00_F)
*g teenshare = exp( lnteenpop - lnpop)
g lnearn_F = lnearnend_0A00_F
g lnemp_F = ln(emp_F)

g empgrow4_F = S4.lnemp_0A00_F 
g earngrow4_F = S4.lnearn_F
*g popgrow4 = S4.lnpop
*g teensharegrow4 = S4.teenshare
g turnrategrow4_F = S4.turnrate_F
*g epopgrow4_F = S4.epop_F

g empgrow12_F = S12.lnemp_0A00_F 
g earngrow12_F = S12.lnearn_F
*g popgrow12 = S12.lnpop
*g teensharegrow12 = S12.teenshare
g turnrategrow12_F = S12.turnrate_F
*g epopgrow12_F = S12.epop_F

keep lnpop epop emp turnrate lnearn lnemp empgrow4 earngrow4 popgrow4 turnrategrow4 epopgrow4 empgrow12 earngrow12 popgrow12 turnrategrow12 epopgrow12 emp_M turnrate_M lnearn_M lnemp_M empgrow4_M earngrow4_M turnrategrow4_M empgrow12_M earngrow12_M turnrategrow12_M emp_F turnrate_F lnearn_F lnemp_F empgrow4_F earngrow4_F turnrategrow4_F empgrow12_F earngrow12_F turnrategrow12_F lnMW countyreal  period state_fips

local  covariates lnpop epop emp turnrate lnearn lnemp empgrow4 earngrow4 popgrow4 turnrategrow4 epopgrow4 empgrow12 earngrow12 popgrow12 turnrategrow12 epopgrow12 emp_M turnrate_M lnearn_M lnemp_M empgrow4_M earngrow4_M turnrategrow4_M empgrow12_M earngrow12_M turnrategrow12_M emp_F turnrate_F lnearn_F lnemp_F empgrow4_F earngrow4_F turnrategrow4_F empgrow12_F earngrow12_F turnrategrow12_F

duplicates drop
sort countyreal
merge m:1 countyreal using "$datapath/countycentroids_area.dta"
keep if _merge==3

g quarter = mod(period,4)+1

  keep if quarter ==4 

 
foreach j in `covariates' countyreal  state_fips lat lon lnMW {
	rename `j' `j'2
}

sort period  
save "$datapath/randomALLcountysample.dta", replace 
 
 

/****  Create Border Pair Sample */


* tsset county_pair_id period
use year period state_fips *dist* state_name all      *pop* countyreal  ln* emp_sh* bordersegment pair_id absorb* using "$datapath/qwi_minwage_countypair_database2011_rev.dta", clear

keep if year>=2000

egen pairidcounty = group(pair_id countyreal)
tsset pairidcounty period

 
*ALL SEXES

g epop = exp(lnemp_0A00_BS - lnpop)
g emp = exp(lnemp_0A00_BS)
g turnrate = exp(lnturnovra_0A00_BS)
*g teenshare = exp( lnteenpop - lnpop)
g lnearn = lnearnend_0A00_BS
g lnemp = ln(emp)

g empgrow4 = S4.lnemp 
g earngrow4 = S4.lnearn
g popgrow4 = S4.lnpop
*g teensharegrow4 = S4.teenshare
g turnrategrow4 = S4.turnrate
g epopgrow4 = S4.epop

g empgrow12 = S12.lnemp 
g earngrow12 = S12.lnearn
g popgrow12 = S12.lnpop
*g teensharegrow12 = S12.teenshare
g turnrategrow12 = S12.turnrate
g epopgrow12 = S12.epop

*MALES

*g epop_M = exp(lnemp_0A00_M - lnpop_M)
g emp_M = exp(lnemp_0A00_M)
g turnrate_M = exp(lnturnovra_0A00_M)
*g teenshare = exp( lnteenpop - lnpop)
g lnearn_M = lnearnend_0A00_M
g lnemp_M = ln(emp_M)

g empgrow4_M = S4.lnemp_0A00_M 
g earngrow4_M = S4.lnearn_M
*g popgrow4 = S4.lnpop
*g teensharegrow4 = S4.teenshare
g turnrategrow4_M = S4.turnrate_M
*g epopgrow4_M = S4.epop_M

g empgrow12_M = S12.lnemp_0A00_M 
g earngrow12_M = S12.lnearn_M
*g popgrow12 = S12.lnpop
*g teensharegrow12 = S12.teenshare
g turnrategrow12_M = S12.turnrate_M
*g epopgrow12_M = S12.epop_M

*FEMALES
*g epop_F = exp(lnemp_0A00_F - lnpop_F)
g emp_F = exp(lnemp_0A00_F)
g turnrate_F = exp(lnturnovra_0A00_F)
*g teenshare = exp( lnteenpop - lnpop)
g lnearn_F = lnearnend_0A00_F
g lnemp_F = ln(emp_F)

g empgrow4_F = S4.lnemp_0A00_F 
g earngrow4_F = S4.lnearn_F
*g popgrow4 = S4.lnpop
*g teensharegrow4 = S4.teenshare
g turnrategrow4_F = S4.turnrate_F
*g epopgrow4_F = S4.epop_F

g empgrow12_F = S12.lnemp_0A00_F 
g earngrow12_F = S12.lnearn_F
*g popgrow12 = S12.lnpop
*g teensharegrow12 = S12.teenshare
g turnrategrow12_F = S12.turnrate_F
*g epopgrow12_F = S12.epop_F
  

sort pair_id period countyreal

by pair_id period: g firstcounty = _n==1

expand 2, gen(dupl)
egen pair_id2 = group(pair_id dupl)

replace firstcounty = 1- firstcounty if dupl==1

keep `covariates' lnMW countyreal  period state_fips pair_id pair_id2 firstcounty pairdist  ///
dupl firstcounty



reshape wide `covariates' lnMW countyreal  pairdist pair_id  state_fips  , i(pair_id2 period) j(firstcounty) 

g quarter = mod(period,4)+1

 keep if quarter ==4 



joinby period using "$datapath/randomALLcountysample.dta"

drop if countyreal0==countyreal2

drop if state_fips0 == state_fips2


g highMWA = lnMW0>lnMW2 if lnMW0!=lnMW2
g highMWB = lnMW0>lnMW1 if lnMW0!=lnMW1

  

* dif *
 
foreach j in    `covariates'  lnMW{
 
  	cap drop  difA_`j'
 	g difA_`j' =  (`j'0 -`j'2) if highMWA==1
 	replace difA_`j' = (`j'2 - `j'0 ) if highMWA==0

  	cap drop  difB_`j'
 	g difB_`j' =  (`j'0 -`j'1) if highMWB==1 
 	replace difB_`j' = (`j'1 - `j'0 ) if highMWB==0 	
 	
 	cap drop absdifA_`j'
 	g absdifA_`j' = abs(`j'0-`j'2)
 	
 	cap drop absdifB_`j'
 	g absdifB_`j' = abs(`j'0-`j'1)	
 	
 	cap drop difabsdifAB_`j'
 	g difabsdifAB_`j' =  absdifA_`j' - absdifB_`j'
 	
 	cap drop difdifAB_`j'
 	g difdifAB_`j' =  difA_`j' -  difB_`j'
}


g all = 1
  
save "$datapath/random_border_countypairsampleMW.dta", replace


  

 use  "$datapath/random_border_countypairsampleMW.dta", clear 



collapse (mean) absdif* dif* pairdist0 countyreal1, by(pair_id2 countyreal0 period) 

 save "$datapath/random_border_countypairsampleMW_collapsed.dta", replace
*/

 use "$datapath/random_border_countypairsampleMW_collapsed.dta", replace
 
foreach j in /*`covariates'*/ lnpop epop emp turnrate lnearn lnemp empgrow4 earngrow4 popgrow4 turnrategrow4 epopgrow4 empgrow12 earngrow12 popgrow12 turnrategrow12 epopgrow12 emp_M turnrate_M lnearn_M lnemp_M empgrow4_M earngrow4_M turnrategrow4_M empgrow12_M earngrow12_M turnrategrow12_M emp_F turnrate_F lnearn_F lnemp_F empgrow4_F earngrow4_F turnrategrow4_F empgrow12_F earngrow12_F turnrategrow12_F lnMW {



    ivreg2 absdifA_`j'   , cluster(countyreal0 countyreal1)
     est store absdifA`j'
    ivreg2 absdifB_`j' , cluster(countyreal0 countyreal1)
     est store absdifB`j'     
   
    ivreg2 difabsdifAB_`j'  , cluster(countyreal0 countyreal1)
     est store difabsdifAB`j'        
     
    ivreg2 difA_`j'  , cluster(countyreal0 countyreal1)
     est store difA`j'
    ivreg2 difB_`j'  , cluster(countyreal0 countyreal1)
     est store difB`j'     
   
    ivreg2 difdifAB_`j'  , cluster(countyreal0 countyreal1)
     est store difdifAB`j'        
    
          
 } 
 
 esttab absdifAlnMW absdifBlnMW difabsdifABlnMW  difAlnMW  difBlnMW  difdifABlnMW using "${outputpath}/MWSelectivity_RandomContig.csv" , replace ///
   	 keep(_cons) cells(b(star fmt(%9.4f)) se(par fmt(%9.4f)))  starlevels(* 0.10 ** 0.05 *** 0.01)   ///
  	  nodepvars nonumbers nonotes nolines noeqlines nomtitles nogap noobs

foreach j in   lnpop epop emp turnrate lnearn lnemp empgrow4 earngrow4 popgrow4 turnrategrow4 epopgrow4 empgrow12 earngrow12 popgrow12 turnrategrow12 epopgrow12 emp_M turnrate_M lnearn_M lnemp_M empgrow4_M earngrow4_M turnrategrow4_M empgrow12_M earngrow12_M turnrategrow12_M emp_F turnrate_F lnearn_F lnemp_F empgrow4_F earngrow4_F turnrategrow4_F empgrow12_F earngrow12_F turnrategrow12_F {

 esttab absdifA`j' absdifB`j' difabsdifAB`j'  difA`j'  difB`j'  difdifAB`j' using "${outputpath}/MWSelectivity_RandomContig.csv" , append ///
   	 keep(_cons) cells(b(star fmt(%9.4f)) se(par fmt(%9.4f)))  starlevels(* 0.10 ** 0.05 *** 0.01)   ///
  	  nomtitles nodepvars nonumbers nonotes nolines noeqlines nomtitles nogap noobs

} 


/****** UNDER 75 KM Pairs ******/


 
foreach j in lnMW lnpop epop emp turnrate lnearn lnemp empgrow4 earngrow4 popgrow4 turnrategrow4 epopgrow4 empgrow12 earngrow12 popgrow12 turnrategrow12 epopgrow12 emp_M turnrate_M lnearn_M lnemp_M empgrow4_M earngrow4_M turnrategrow4_M empgrow12_M earngrow12_M turnrategrow12_M emp_F turnrate_F lnearn_F lnemp_F empgrow4_F earngrow4_F turnrategrow4_F empgrow12_F earngrow12_F turnrategrow12_F {



    ivreg2 absdifA_`j' if pairdist0<75 , cluster(countyreal0 countyreal1)
     est store absdifA`j'
    ivreg2 absdifB_`j' if pairdist0<75, cluster(countyreal0 countyreal1)
     est store absdifB`j'     
   
    ivreg2 difabsdifAB_`j' if pairdist0<75, cluster(countyreal0 countyreal1)
     est store difabsdifAB`j'        
     
    ivreg2 difA_`j' if pairdist0<75, cluster(countyreal0 countyreal1)
     est store difA`j'
    ivreg2 difB_`j' if pairdist0<75, cluster(countyreal0 countyreal1)
     est store difB`j'     
   
    ivreg2 difdifAB_`j' if pairdist0<75 , cluster(countyreal0 countyreal1)
     est store difdifAB`j'        
    
          
 } 
 
 esttab absdifAlnMW absdifBlnMW difabsdifABlnMW  difAlnMW  difBlnMW  difdifABlnMW using "${outputpath}/MWSelectivity_RandomContig_75m.csv", replace ///
   	 keep(_cons) cells(b(star fmt(%9.4f)) se(par fmt(%9.4f)))  starlevels(* 0.10 ** 0.05 *** 0.01)   ///
  	  nodepvars nonumbers nonotes nolines noeqlines nomtitles nogaps noobs

foreach j in   lnpop epop emp turnrate lnearn lnemp empgrow4 earngrow4 popgrow4 turnrategrow4 epopgrow4 empgrow12 earngrow12 popgrow12 turnrategrow12 epopgrow12 emp_M turnrate_M lnearn_M lnemp_M empgrow4_M earngrow4_M turnrategrow4_M empgrow12_M earngrow12_M turnrategrow12_M emp_F turnrate_F lnearn_F lnemp_F empgrow4_F earngrow4_F turnrategrow4_F empgrow12_F earngrow12_F turnrategrow12_F {

 esttab absdifA`j' absdifB`j' difabsdifAB`j'  difA`j'  difB`j'  difdifAB`j' using "${outputpath}/MWSelectivity_RandomContig_75m.csv", append ///
   	 keep(_cons) cells(b(star fmt(%9.4f)) se(par fmt(%9.4f)))  starlevels(* 0.10 ** 0.05 *** 0.01)   ///
  	  nomtitles nodepvars nonumbers nonotes nolines noeqlines nomtitles nogaps noobs

} 

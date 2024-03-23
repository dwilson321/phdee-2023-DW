**Homework 8 for Environmental Economics**
 *David Wilson*
clear
version 18.0
set more off
		

*Home:
if "`c(username)'"== "Owner" { 
	global path "C:\Users\Owner\Dropbox\Personal\Enviro Econ II\phdee-2023-DW\homework8"
	}
	
*Work:
if "`c(username)'"== "dwilson321" {
	global path "C:\Users\dwilson321\Dropbox\Personal\Enviro Econ II\phdee-2023-DW\homework8"
	}


global datapath "$path\data"
global codepath "$path\code" 
global tablepath "$path\output\tables" 
global figurepath "$path\output\figures"

	
clear	 
use "$datapath\electric_matching.dta", clear 

*Q1
gen log_mw=log(mw)

format date %td
gen treatment=0
replace treatment=1 if date>mdy(3,1,2020)
	
*Save the treated data
save "$datapath\electric_matching_treated", replace

*Q1.a
ivreghdfe log_mw treatment temp pcp, absorb(zone month dow hour) robust

*Q1.b
encode zone, gen(zone_fac)
drop if inrange(month,1,2)
teffects nnmatch (log_mw temp pcp) (treatment), metric(maha) ematch(i.zone_fac i.month i.dow i.hour)


*Q2.a
use "$datapath\electric_matching_treated", clear
ivreghdfe log_mw treatment temp pcp, absorb(zone month dow hour year) robust


*Q3.a
gen year2020=0
replace year2020=1 if year==2020
drop if year<2019
encode zone, gen(zone_fac)
teffects nnmatch (log_mw temp pcp) (year2020), metric(maha) ematch(i.zone_fac i.month i.dow i.hour) generate(match)
predict log_mwhat, po tlevel(0)


gen dlog_mw=log_mw-log_mwhat
reg dlog_mw treatment if year2020, robust




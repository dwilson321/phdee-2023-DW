**Homework 9 for Environmental Economics**
 *David Wilson*
clear
version 18.0
	

*Set paths	

*Home:
if "`c(username)'"== "Owner" { 
	global path "C:\Users\Owner\Dropbox\Personal\Enviro Econ II\phdee-2023-DW\homework9"
	}
	
*Work:
if "`c(username)'"== "dwilson321" {
	global path "C:\Users\dwilson321\Dropbox\Personal\Enviro Econ II\phdee-2023-DW\homework9"
	}

global datapath "$path\data"
global codepath "$path\code" 
global tablepath "$path\output\tables" 
global figurepath "$path\output\figures"

clear	 
use "$datapath\recycling_hw.dta", clear 

*Q1 
collapse (mean) recyclingrate, by(nyc year)
twoway (line recyclingrate year if nyc == 1, lcolor(navy)) (line recyclingrate year if nyc == 0, lcolor(gold)), legend(label(1 "NYC") label(2 "Controls")) xline(2002 2004, lpattern(dash) lcolor(black)) title("Annual Recycling Rate for NYC and Controls") ytitle("Recycling Rate") xtitle("Year") note("Dashed line represents the start of the recycling pause")

graph export "$figurepath\nycrecyclingrate.pdf", replace

*Q2 TWFE
clear	 
use "$datapath\recycling_hw.dta", clear 
keep if year < 2005

gen treatment = 0
replace treatment=1 if nyc & year > 2001
ivreghdfe recyclingrate treatment, absorb(region year) vce(cluster region)

*Q3 SDID
sdid recyclingrate region year treatment, vce(bootstrap) seed(1) reps(100) graph 
		
graph export "$figurepath\sdid.pdf", replace

*Q4 Event study
clear	 
use "$datapath\recycling_hw.dta", clear

reghdfe recyclingrate b2001.year##1.nyc incomepercapita nonwhite munipop2000 collegedegree2000 democratvoteshare2000 democratvoteshare2004, absorb(region year) vce(cluster region)

coefplot, baselevels omitted xline(5) yline(0) title("Event Study Plot") ytitle("Coefficient") xtitle("Year") keep(*.year#1.nyc) coeflabels( 1997.year#1.nyc="1997" 1998.year#1.nyc="1998" 1999.year#1.nyc="1999" 2000.year#1.nyc="2000" 2001.year#1.nyc="2001" 2002.year#1.nyc="2002" 2003.year#1.nyc="2003" 2004.year#1.nyc="2004" 2005.year#1.nyc="2005" 2006.year#1.nyc="2006" 2007.year#1.nyc="2007" 2008.year#1.nyc="2008") vertical
	
graph export "$figurepath\eventstudyreg.pdf", replace

*Q5
clear	 
use "$datapath\recycling_hw.dta", clear
	
* Collapse the data for graphing
collapse (mean) recyclingrate incomepercapita collegedegree2000 democratvoteshare2000 democratvoteshare2004 nonwhite (first) nj ma munipop2000, by(id nyc year)
	
save "$datapath\recycling_hw_sc.dta", replace
collapse (mean) recyclingrate incomepercapita collegedegree2000 democratvoteshare2000 democratvoteshare2004 nonwhite (first) nj ma id munipop2000, by(nyc year)	
drop if !nyc
save "$datapath\recycling_hw_sc_nyc.dta", replace
	
use "$datapath\recycling_hw_sc.dta", clear
drop if nyc
append using "$datapath\recycling_hw_sc_nyc.dta"
save "$datapath\recycling_hw_sc.dta", replace
	
label var recyclingrate "Recycling Rate"
xtset id year
synth recyclingrate recyclingrate(1997) recyclingrate(1998) recyclingrate(1999) recyclingrate(2000) recyclingrate(2001) democratvoteshare2000(2000) collegedegree2000(2000) nonwhite incomepercapita, trunit(27) trperiod(2002) fig keep(scresult) replace
			
synth_runner recyclingrate recyclingrate(1997) recyclingrate(1998) recyclingrate(1999) recyclingrate(2000) recyclingrate(2001) democratvoteshare2000(2000) collegedegree2000(2000) nonwhite incomepercapita, trunit(27) trperiod(2002) mspeperiod(1998(1)2001) gen_vars

single_treatment_graphs, treated_name(NYC) trlinediff(-0.5) effects_ylabels(-.4(.1).5) do_color(gs13) raw_options(scale(1.4) xlabel(1997(2)2008, nogrid) xmtick(1997(1)2008) xtitle(Year) xline(2004.5) title("Synthetic Control Raw Outcomes")) effects_options(scale(1.6) xlabel(1997(2)2008, nogrid) xmtick(1997(1)2008) xtitle(Year) ytitle("") xline(2004.5) title(Synthetic Control Effects and Placebos))

effect_graphs, treated_name(NYC) trlinediff(-0.5) tc_options(scale(2) xlabel(1997(2)2008, nogrid) xmtick(1997(1)2008) ylabel(,nogrid) xtitle(Year) legend(pos(7) ring(0) region(style(none))) xline(2004.5) title(NYC and Synthetic Controls)) effect_options(xlabel(1997(2)2008, nogrid) xmtick(1997(1)2008) ylabel(, nogrid) xtitle(Year) legend(pos(7) ring(0) region(style(none))) xline(2004.5) title(Synthetic Control) yline(0) scale(2))
	
graph export "$figurepath\raw_outcomes.pdf", name(raw) replace
graph export "$figurepath\placeboeffects.pdf", name(effects) replace
graph export "$figurepath\effect.pdf", name(effect) replace
graph export "$figurepath\treatmentcontrol.pdf", name(tc) replace

	

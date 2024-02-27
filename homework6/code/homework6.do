**Homework 6 for Environmental Economics**
 *David Wilson*
clear
version 18.0
macro drop _all
set linesize 255
set more off, permanently
graph drop _all
matrix drop _all

*install twowayfeweights package
ssc install twowayfeweights
	

*Set paths	

*Home:
if "`c(username)'"== "Owner" { 
	global path "C:\Users\Owner\Dropbox\Personal\Enviro Econ II\phdee-2023-DW\homework6"
	}
	
*Work:
if "`c(username)'"== "dwilson321" {
	global path "C:\Users\dwilson321\Dropbox\Personal\Enviro Econ II\phdee-2023-DW\homework6"
	}


global data_path "$path\data"
global code_path "$path\code" 
global table_path "$path\output\tables" 
global figure_path "$path\output\figures"

	

clear	
 
use "$data_path\energy_staggered.dta" 

*1.1
gen double time =clock(datetime, "MDYhms")
format time %tc
order time id treatment

bysort id treatment: egen first_treated=min(time) if treatment==1
bysort id (first_treated): replace first_treated=first_treated[1] if missing(first_treated)
format first_treated %tc

egen cohort=csgvar(treatment), ivar(id) tvar(time)
format cohort %tc
count if cohort==first_treated
sort time
egen hour=seq(), by(id)

save "$data_path\staggered_by_hour", replace


*1.2
twowayfeweights energy cohort hour treatment, type(feTR)
est clear
eststo: reghdfe energy treatment temperature precipitation relativehumidity, absorb(time id) vce(cluster id)

esttab using "$table_path\hrly_twfe.tex", label replace b(4) se(4) collabels(none) nonum coeflabels(treatment "ATT" relativehumidity "Relative Humidity (\%)") ar2 sfmt(%8.2f)


use "$data_path\staggered_by_hour", clear

gen date=dofc(time)
format date %td
collapse (max) treatment=treatment (sum) energy=energy (mean) temperature relativehumidity precipitation zip size occupants devicegroup, by(id date)

sort date
egen day=seq(), by(id)

bysort id treatment: egen first_treated=min(day) if treatment==1
bysort id (first_treated): replace first_treated=first_treated[1] if missing(first_treated)

egen cohort=csgvar(treatment), ivar(id) tvar(day)
count if cohort==first_treated
save "$data_path\staggered_by_day", replace

est clear
eststo: reghdfe energy treatment temperature precipitation relativehumidity, absorb(date id) vce(cluster id)
	
esttab using "$table_path\daily_twfe.tex", label replace b(4) se(4)	mtitles("Energy usage (kWh)") collabel(none) star(* 0.10 ** 0.05 *** 0.01) nonum coeflabels(treatment "ATT" relativehumidity "Relative Humidity (\%)" temperature "Temperature (F)" precipitation "Precipitation (inches)" ) ar2 sfmt(%8.2f)

*2.2
gen event_time=day-first_treated

char event_time[omit] -1
xi i.event_time, pref(_T)
	
*Lining up positions
local pos_of_neg_2 = 28 
local pos_of_zero = `pos_of_neg_2' + 2
local pos_of_max = `pos_of_zero' + 29

*Event study
reghdfe energy  _T* temperature precipitation relativehumidity, absorb(id) vce(cluster id)
	forvalues i = 1(1)`pos_of_neg_2'{
		scalar b_`i' = _b[_Tevent_tim_`i']
		scalar se_v2_`i' = _se[_Tevent_tim_`i']
	}
		

forvalues i = `pos_of_zero'(1)`pos_of_max'{
		scalar b_`i' = _b[_Tevent_tim_`i']
		scalar se_v2_`i' = _se[_Tevent_tim_`i']
	}

capture drop order
capture drop b 
capture drop high 
capture drop low

gen order = .
gen b =. 
gen high =. 
gen low =.
local i = 1
local graph_start  = 1
forvalues day = 1(1)`pos_of_neg_2'{
		local event_time = `day' - 2 - `pos_of_neg_2'
		replace order = `event_time' in `i'
		
		replace b    = b_`day' in `i'
		replace high = b_`day' + 1.96*se_v2_`day' in `i'
		replace low  = b_`day' - 1.96*se_v2_`day' in `i'
			
		local i = `i' + 1
}

replace order = -1 in `i'

replace b    = 0  in `i'
replace high = 0  in `i'
replace low  = 0  in `i'

local i = `i' + 1
forvalues day = `pos_of_zero'(1)`pos_of_max'{
		local event_time = `day' - 2 - `pos_of_neg_2'

		replace order = `event_time' in `i'
		
		replace b    = b_`day' in `i'
		replace high = b_`day' + 1.96*se_v2_`day' in `i'
		replace low  = b_`day' - 1.96*se_v2_`day' in `i'
			
		local i = `i' + 1
}


return list

twoway rarea low high order if order<=29 & order >= -29 , fcol(gs14) lcol(white) msize(1) estimates	|| connected b order if order<=29 & order >= -29, lw(0.6) col(white) msize(1) msymbol(s) lp(solid) highlighting	|| connected b order if order<=29 & order >= -29, lw(0.2) col("71 71 179") msize(1) msymbol(s) lp(solid) || scatteri 0 -29 0 29, recast(line) lcol(gs8) lp(longdash) lwidth(0.5) xlab(-30(10)30, nogrid labsize(2) angle(0)) ylab(, nogrid labs(3)) legend(off) xtitle("Days since treatment", size(5)) ytitle("Daily energy usage (kWh)", size(5)) xline(-.5, lpattern(dash) lcolor(gs7) lwidth(0.6)) 
	
			
graph export "$figure_path\event_study.pdf", replace 
	
	
*2.3
eventdd energy temperature precipitation relativehumidity, hdfe absorb(id) timevar(event_time) cluster(id) graph_op(ytitle("Daily energy usage (kWh)", size(5)) xlabel(-30(10)30) xtitle("Days since treatment", size(5)))
	
graph export "$figure_path\eventdd_study.pdf", replace 
	
*2.4
csdid energy temperature precipitation relativehumidity, ivar(id) time(day) gvar(first_treated) wboot reps(50)
estat simple
estat event
csdid_plot, ytitle("Daily energy usage (kWh)", size(5)) xlabel(-30(10)30) xtitle("Days since treatment", size(5)) xline(-.5, lpattern(dash) lcolor(gs7) lwidth(0.3))
	
graph export "$figure_path\event_study_csdid.pdf", replace
	
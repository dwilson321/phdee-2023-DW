**Homework 7 for Environmental Economics**
 *David Wilson*
clear
version 18.0
macro drop _all
set linesize 255
set more off, permanently
graph drop _all
matrix drop _all

	

*Set paths	

*Home:
if "`c(username)'"== "Owner" { 
	global path "C:\Users\Owner\Dropbox\Personal\Enviro Econ II\phdee-2023-DW\homework7"
	}
	
*Work:
if "`c(username)'"== "dwilson321" {
	global path "C:\Users\dwilson321\Dropbox\Personal\Enviro Econ II\phdee-2023-DW\homework7"
	}


global datapath "$path\data"
global codepath "$path\code" 
global tablepath "$path\output\tables" 
global figurepath "$path\output\figures"

	

clear	 
import delimited "C:\Users\Owner\Dropbox\Personal\Enviro Econ II\phdee-2023-DW\homework7\data\instrumentalvehicles.csv", clear 

*Q2.1
rdrobust mpg length, c(225) p(1) covs(car)
local h_l = r(h_l)
local h_r = r(h_r)
rdplot mpg length if inrange(length,225-`h_l',225+`h_r'), c(225) kernel(triangular) covs(car) p(1) genvars graph_options(ytitle("Fuel efficiency (mpg)") xtitle("Vehicle length (in)") graphregion(color(white)) legend(off))

graph export "$figurepath\RD.pdf", replace
	
rename rdplot_hat_y mpg_hat
	
est clear
eststo: reg price mpg_hat car, robust
	
esttab using "$tablepath\estimatesstata.tex", label replace order(mpg_hat car) keep(mpg_hat car) star(* .1 ** .05 *** .01) b(2) se(2) ar2 obslast mtitles("Second-stage estimates") nonum coeflabels(mpg_hat "Miles per gallon" car "=1 if the vehicle is sedan")
		
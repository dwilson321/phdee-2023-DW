**Homework 4 for Environmental Economics**
 *David Wilson*
clear
version 18.0
macro drop _all
set linesize 255
set more off, permanently
capture log close
capture graph drop _all
matrix drop _all
	

*Set paths	

*Home:
if "`c(username)'"== "Owner" { 
	global path "C:\Users\Owner\Dropbox\Personal\Enviro Econ II\phdee-2023-DW\homework4"
	}
	
*Work:
if "`c(username)'"== "dwilson321" {
	global path "C:\Users\dwilson321\Dropbox\Personal\Enviro Econ II\phdee-2023-DW\homework4"
	}


global data_path "$path\data"
global code_path "$path\code" 
global table_path "$path\output\tables" 
global figure_path "$path\output\figures"

	

clear	
*Import .csv file and label variables
import delimited "$data_path\fishbycatch.csv"

*Use reshape to convert panel data from wide to long form
reshape long shrimp salmon bycatch, i(firm) j(month)
tsset firm month
gen treat_it=0
replace treat_it=1 if month>=13 & treated==1

foreach m of num 1/24 {
		gen t_`m'=0
		replace t_`m'=1 if month==`m'
	}
	foreach f of num 1/50 {
		gen f_`f'=0
		replace f_`f'=1 if firm==`f'
	}
*Demeaning process for within-transformation	
	foreach x of varlist bycatch treat_it shrimp salmon firmsize {
	egen mean_`x'=mean(`x'), by(firm)
	gen demean_`x'=`x' - mean_`x'
	drop mean*
	}
	
	
	est clear
	eststo: reg bycatch t_* f_* treat_it salmon shrimp firmsize, vce(cluster firm)
	estadd local method "firm indicators"
	eststo: reg demean_bycatch demean_treat_it demean_shrimp demean_salmon demean_firmsize, vce(cluster firm)
	estadd local method "within-transformation"
	
	
* Exporting to a .tex file
	esttab using "$table_path\stata.tex", rename(demean_treat_it treat_it) label replace 	keep(treat_it) b(2) se(2) mtitle("(a)" "(b)") collabels(none) nostar nonote nonum coeflabels(treat_it "DID estimates") scalars("method Method") obslast

**Homework 5 for Environmental Economics**
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
	global path "C:\Users\Owner\Dropbox\Personal\Enviro Econ II\phdee-2023-DW\homework5"
	}
	
*Work:
if "`c(username)'"== "dwilson321" {
	global path "C:\Users\dwilson321\Dropbox\Personal\Enviro Econ II\phdee-2023-DW\homework5"
	}


global data_path "$path\data"
global code_path "$path\code" 
global table_path "$path\output\tables" 
global figure_path "$path\output\figures"

	

clear	
*Import .csv file and label variables
import delimited "$data_path\instrumentalvehicles.csv"

*2.1
ivregress liml price car ( mpg = weight ), robust

outreg2 using "$table_path\outreg2.tex", replace
*2.2
weakivtest

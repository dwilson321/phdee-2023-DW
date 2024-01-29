
clear
version 18.0
macro drop _all
set linesize 255
set more off, permanently
capture log close
capture graph drop _all
matrix drop _all

*********************************************************************************
	
	global install_stata_packages 0 // Set to 1 for first time running, 0 o/w	
	global export_log 1 // Set to 1 if you want to export log, 0 o/w
	
	global path "C:\Users\Owner\Dropbox\Personal\Enviro Econ II\phdee-2023-DW\homework2"
	global data_path "$path\data"
	global temp_path "$path\temp"
	global code_path "$path\code" 
	global table_path "$path\output\table" 
	global figure_path "$path\output\figure"

	* ON IAC VLAB server, you will need to uncomment this line and run this:
	*sysdir set PERSONAL \\iac.nas.gatech.edu\mramadhani3

	* Set the location of Python and R executable
	
	global RSCRIPT_PATH "C:\Program Files\R\R-4.2.2\bin\x64\Rscript.exe"
	*python set exec C:\Users\mramadhani3\AppData\Local\anaconda3\python.exe
	*python set userpath "C:\Users\mramadhani3\AppData\Local\anaconda3\Lib\site-packages" "C:\Users\mramadhani3\OneDrive - Georgia Institute of Technology\Documents\Spring-24\environmental-econ-ii\phdee-24-MR\homework-2\code"

import delimited "$data_path\kwh.csv"
label variable electricity "kWh used by the household in the month"
label variable sqft "square feet of home"
label variable retrofit	"retrofitting dummy variable"
label variable temp " average monthly outdoor temperature in F"

eststo control: estpost summarize electricity sqft temp if retrofit == 0
eststo treatment: estpost summarize electricity sqft temp if retrofit == 1
eststo differences:  estpost ttest electricity sqft temp, by(retrofit) unequal



*********************************************************************************
* Q1 Run the given Python code from Shell (make sure dependency are all installed)
	
	!python 1_python_OLS.py

*********************************************************************************
* Q2 Run the given Stata code

	do "$code_path\2_stata_code.do"

*********************************************************************************
* End of code
if $export_log = 1{
	log close
	}

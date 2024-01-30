
clear
version 18.0
macro drop _all
set linesize 255
set more off, permanently
capture log close
capture graph drop _all
matrix drop _all
	

*Set paths	
global path "C:\Users\Owner\Dropbox\Personal\Enviro Econ II\phdee-2023-DW\homework2"
**Remember to delete if on school PC, idiot!!**
*global path "C:\Users\dwilson321\Dropbox\Personal\Enviro Econ II\phdee-2023-DW\homework2"
 
global data_path "$path\data"
global temp_path "$path\temp"
global code_path "$path\code" 
global table_path "$path\output\table" 
global figure_path "$path\output\figure"

	

clear	
*Import .csv file and label variables
import delimited "$data_path\kwh.csv"
label variable electricity "Monthly kWh used by the household"
label variable sqft "Square footage of home"
label variable retrofit	"Retrofitting dummy variable"
label variable temp "Average monthly outdoor temperature in F\textdegree"

*2.1 Build balance table with treatment and control means and standard deviations. Add third column that is difference in means test
eststo control: estpost summarize electricity sqft temp if retrofit == 0
eststo treatment: estpost summarize electricity sqft temp if retrofit == 1
eststo differences:  estpost ttest electricity sqft temp, by(retrofit) unequal

esttab control treatment differences using "$table_path\balance.tex", replace label cell( mean(pattern(1 1 0) fmt(2))     &  p(pattern(0 0 1) fmt(3)) sd(pattern(1 1 0) fmt(2) par) & t(pattern(0 0 1) fmt(3) par([ ]) ) ) mtitle("Control" "Treatment" "P-value")  collabels(none) nonum stats(N, fmt(%15.0fc) label("Observations"))
	
*2.2Two-way scatter plot with Georgia Tech colors
twoway  (scatter electricity sqft, mcolor(dknavy) msymbol(smcircle)), legend(off) title("{bf}Figure 2", size(2.75)) 

*Export graph
graph export "$figure_path\twoway.pdf", replace

eststo nonrobust: reg electricity retrofit sqft temp
eststo robust: reg electricity retrofit sqft temp, robust
	
*2.3 Regress with robust standard errors
esttab nonrobust robust using "$table_path\ols_stata.tex", label replace cell( 	b(pattern(1 1) fmt(3)) se(pattern(1 1) fmt(3) par) ) mtitle("OLS" "OLS with robust s.e.") collabels(none) nostar nonum stats(rmse, fmt(%15.3fc) label("MSE"))
	
	
	
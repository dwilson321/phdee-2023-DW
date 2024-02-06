
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
global path "C:\Users\Owner\Dropbox\Personal\Enviro Econ II\phdee-2023-DW\homework3"
*Work:
*global path "C:\Users\dwilson321\Dropbox\Personal\Enviro Econ II\phdee-2023-DW\homework3"
*Remember to switch if on school PC, idiot!!**

global data_path "$path\data"
global code_path "$path\code" 
global table_path "$path\output\table" 
global figure_path "$path\output\figures"

	

clear	
*Import .csv file and label variables
import delimited "$data_path\kwh.csv"
label variable electricity "Monthly kWh used by the household"
label variable sqft "Square footage of home"
label variable retrofit	"Retrofitting dummy variable"
label variable temp "Average monthly outdoor temperature in F\textdegree"


*Generating natural logarithms
gen ln_electricity=ln(electricity)
gen ln_sqft = ln(sqft)
gen ln_temp	= ln(temp)
lab var ln_electricity "natural log of monthly kWh used by the household"
lab var ln_sqft "natural log of square footage of home"
lab var ln_temp "natural log of average monthly outdoor temperature in F\textdegree"


*e. Bootstrapping attempt
eststo parameter: bootstrap delta=exp(_b[retrofit]) gamma_sqft=_b[ln_sqft] gamma_temp=_b[ln_temp], reps(1000): reg ln_elec retrofit ln_sqft ln_temp

	

	eststo parameter: bootstrap retrofit ln_sqft ln_temp, reps(1000) seed(1): reg ln_elec retrofit ln_sqft ln_temp, robust
	
eststo parameter: bootstrap cons=_b[_cons] delta=exp(_b[retrofit]) gamma_sqft=_b[ln_sqft] gamma_temp=_b[ln_temp], reps(1000) seed(1): reg ln_elec retrofit ln_sqft ln_temp, robust
	capture program drop ameboot
	program define ameboot, rclass
	 preserve 
	  bsample
		reg ln_elec retrofit ln_sqft ln_temp, robust
		scalar delta=exp(_b[retrofit])
		scalar gamma_sqft=(_b[ln_sqft])
		scalar gamma_temp=(_b[ln_temp])
		gen dydd=(delta-1)*electricity/(delta^retrofit)
		sum dydd
		scalar mean1 = r(mean)
		gen dyds=gamma_sqft*electricity/sqft
		sum dyds
		scalar mean2 = r(mean)
		gen dydt=gamma_temp*electricity/temp
		sum dydt
		scalar mean3 = r(mean)
		return scalar delta = mean1
		return scalar gamma_sqft = mean2
		return scalar gamma_temp = mean3
	 restore
	end
	
	eststo ame: bootstrap delta = r(delta) gamma_sqft = r(gamma_sqft) gamma_temp = r(gamma_temp), reps(1000) seed(1): ameboot
	
	
*Exporting the table into .tex
esttab parameter ame using "$table_path\bootstrappage.tex", label replace cell( 	b(pattern(1 1) fmt(3)) ci(pattern(1 1) fmt(3) par([ ,  ])) ) mtitle("Parameter Estimates" "Marginal Effect Estimates") collabels(none) nostar nonum coeflabels(cons "Constant" delta "Received retrofit" gamma_sqft "Size of home in ft$^2$" gamma_temp "Average outdoor temperature F\textdegree") stats(N, fmt(%15.0fc) label("Observations"))


*Plot the average margin
reg ln_electricity ln_sqft ln_temp, robust
margins, dydx( ln_temp ln_sqft)
marginsplot

*Export graph
graph export "$figure_path\AME.pdf" saved as PDF format



esttab parameter using "$table_path\bootstrappage.tex", label replace cell( b(pattern(1 1) fmt(3))  se(pattern(1 1) fmt(3) par) ) mtitle("Parameter Estimates" "Average Marginal Effects Estimates") collabels(none) nostar nonum coeflabels(cons "Constant" delta "=1 if home received retrofit" gamma_sqft "Square feet of home" gamma_temp "Outdoor average temperature (\textdegree F)") stats(N, fmt(%15.0fc) label("Observations"))

margins, dydx(temp sqft)
	
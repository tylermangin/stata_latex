/* LaTex snippets

1.) Summary Statistics Tables
2.) Regression Tables

by : Tyler Mangin

*/

				///* Preamble: Set working directory, load packages *///

/* Directory 

Files Required:
~none~

*/

// change this line to the directory/folder that the files above are saved in
cd  "directory here"

/* Packages

Packages required:
catplot
estout
spmap

*/

findit estout
findit catplot
findit spmap

set more off // allows for program to run through

				/* example data */
// creates example data so the prgram runs
set obs 1000
gen double x1 = rnormal(5,10) 
gen double x2 = rnormal(1,0.5)
gen double x3 = rnormal(0,4)
gen double e  = rnormal(0,20)
gen x3_sq = x3^2
gen x2x3 = x2*x3
gen indicator = x1>3
gen y = 0.25*x1 + 1.5*x2 - 0.5*x3 + 1*x3^2 - 2*x2*x3 + e
				

// variable lables help make tables pretty			
label variable y "Outcome"
label variable x2 "RHS Variable 2"
label variable x3 "RHS Variable 3"
label variable x3_sq "RHS Variable 3 squared"
label variable x2x3 "RHS interaction"
label define indicator 1 "Large" 0 "Small"

// variable formats help make tables pretty			
format y x1 x2 x3 x3_sq x2x3 %12.1f

				/* 1.) Summary Statistic Tables */
// Summary Statistics: Using summarize and esttab
estpost summarize y x1 x2 x3
esttab using table.tex,    replace  ///overwrite file
						   cells("mean sd") /// calls the desired statistics from summarize command
						   label    /// uses variable labels
						   nonumber /// takes away numbered columns
						   nostar   /// removes some LaTex ode from the output for formatting the star character commonly used in regression tables
						   booktabs /// uses the fancier booktabs package in LaTex
						   title(Summary Statistics\label{statstable}) 
						   
// Comparison Across Groups: Using summarize and tabstat
estpost tabstat y x1 x2 x3, by(indicator) statistics(mean sd) 
esttab using table.tex, replace  ///overwrite file
						   cells("y x1 x2 x3") /// calls the desired statistics from summarize command
						   nonumber /// takes away numbered columns
						   nostar   /// removes some LaTex ode from the output for formatting the star character commonly used in regression tables
						   booktabs /// uses the fancier booktabs package in LaTex
						   title(Summary Statistics by Indicator\label{compartable}) 
						   
				/* 2.) Regression Tables */
reg y x1
estimates store reg1
reg y x1 x2 x3
estimates store reg2
reg y x1 x2 x3 x3_sq x2x3
estimates store reg3
	   
esttab reg1 reg2 reg3 using regressions.tex,  replace  ///overwrite file
											  label    /// uses variable labels
											  mtitles("Regession 1" "Regession 2" "Regression 3") /// column titles booktabs
											  title(Regressions\label{regtable})

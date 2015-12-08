/* LaTex snippets

1.) Summary Statistics Tables
2.) Regression Tables

by : Tyler Mangin

*/

				///* Preamble: Set working directory, load packages *///

/* Directory 

Files Required:
US_States_LowRes_2015data.dta  //for map example
US_States_LowRes_2015coord.dta //for map example

*/

// change this line to the directory/folder that the files above are saved in
cd  "directory here"

/* Packages

Packages required:

catplot
    Nicholas J. Cox
    Durham University
    n.j.cox@durham.ac.uk
estout
    Ben Jann
    Institute of Sociology
    University of Bern
    jann@soz.unibe.ch
spmap
    Maurizio Pisati
    Department of Sociology and Social Research
    University of Milano Bicocca - Italy
    maurizio.pisati@unimib.it
graph2tex
     Statistical Consulting Group
     Institute for Digital Research and Education, UCLA
     idrestat@ucla.edu 


*/

findit estout
findit catplot
findit spmap
findit graph2tex

set more off // allows for program to run through


									///* Main Program *///

				/* example data */
// creates example data so the prgram runs
set obs 1000
gen double x1 = rnormal(5,10) 
gen double x2 = rnormal(1,0.5)
gen double x3 = rnormal(0,4)
gen double e  = rnormal(0,20)				
gen x3_sq = x3^2
gen x2x3 =  x2*x3
gen indicator =  x1>3
gen indicator2 = x3<5
gen statename =""
replace statename = "Colorado" if indicator==0&indicator2==0
replace statename = "New Mexico" if indicator==1&indicator2==0
replace statename = "Oklahoma" if indicator==0&indicator2==1
replace statename = "Texas" if indicator==1&indicator2==1
gen y = 0.25*x1 + 1.5*x2 - 0.5*x3 + 1*x3^2 - 2*x2*x3 + e
				

// variable lables help make tables pretty			
label variable y "Outcome"
label variable x1 "RHS Variable 1"
label variable x2 "RHS Variable 2"
label variable x3 "RHS Variable 3"
label variable x3_sq "RHS Variable 3 squared"
label variable x2x3 "RHS interaction"
label define indicator 1 "Large" 0 "Small"
label variable e "error"
label variable statename "State"
label variable indicator "Indicator"

// variable formats help make tables pretty			
format y x1 x2 x3 x3_sq x2x3 %12.1f

										///* Tables *///

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

											  
										///* Graphs *///											  
											  
					/* 1.) Scatter Plots */

scatter y x1, 			mlwidth(vvvthin)   /// thinnest outline
						mlcolor(gs5)       /// the sj scheme default fill is gs6, so thisoutline is just slightly darker to highlight
						msize(medlarge)    ///  makes the markers slightly larger
						graphregion(color(white)) // makes the region outside the graph white. sj's default is....something gross...salmon?

graph2tex , 			epsfile(graphname) /// saves an graphname.eps picture file to directory
						number 			   /// seqentially numbers graphname#.eps
						caption(caption)   /// includes a caption
						label(fig1)
						
///* LaTex Code printed in result window *///
						
					/* 2.) Categorical Variables */						
catplot state,	percent			   ///displays percents instead of frequencies
						var1opts(sort(1)descending) ///displays bars decending from highest frequency
						label			   ///uses variable labels
						graphregion(color(white)) // makes the region outside the graph white. sj's default is....something gross...salmon?

						
graph2tex , 			epsfile(graphname) /// saves an graphname.eps picture file to directory
						number 			   /// seqentially numbers graphname#.eps
						caption(caption)   /// includes a caption
					        label(fig2)
						
						
///* LaTex Code printed in result window *///

					/* 3.) Maps */	
//prepare data for merge with state-level map data
collapse y x1 x2 x3, by(statename)
//merge with state-level map data (on variable statename)
merge m:1 statename using US_States_LowRes_2015data.dta
	drop if _merge==2 //only graph states for which data exists

spmap y using US_States_LowRes_2015coord.dta, id(_ID) /// _ID is the matching field for the coordinate data set to draw the map
											  fcolor(Blues2) /// the least ugly of the default map color settings...
											  osize(vvthin vvthin vvthin vvthin) /// have to specifiy for each unit on the map!
											/*ocolor(none none none none) */     /// alternative no borders if the color breaks are clean enough between map units
											  legend(label(2 "0 to X") label(3 "X to X" )label(4 "X to X") label(5 "X to X" ) size(vsmall)) /// have to specifiy for each unit on the map!
						
graph2tex , 			epsfile(graphname) /// saves an graphname.eps picture file to directory
						number 			   /// seqentially numbers graphname#.eps
						caption(caption)   /// includes a caption
						label(fig3)

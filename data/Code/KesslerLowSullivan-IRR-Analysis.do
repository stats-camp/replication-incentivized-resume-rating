	/******************************************************/
	/*** Replication Code for Kessler/Low/Sullivan 2019 ***/
	/***                                                ***/
	/*** See README for implementation details.         ***/
	/*** Contact: colins@wharton.upenn.edu              ***/
	/******************************************************/


	/**********************/
	/*** Initialization ***/
	/**********************/
	
	// Edit filepath here: Change working directory to Supplements on local file system
	// cd "filepath-to-Supplements" 
	clear all
	set matsize 800
	
	global output 			"./Tables and Figures"
	global data				"./Data"
	global allwhite 		"plotregion(fcolor(white)) graphregion(color(white) lwidth(large)) bgcolor(white)"
	
	// starglob and starending will dictate whether the tables are made with stars. 
	// Must be changed together: when starglob = nostar, set starending = ""
	global starglob 		"nostar" //"star(* 0.10 ** 0.05 *** 0.01)" //
	global starending		"" // "}" // 

	
	// Set color scheme
	global col1 "51 30 87" 
	global col2 "192 75 101" 
	global col3 "0 187 202" 
	global col4 "0 91 60"	
	

	/*************************************************/
	/***     Load Data and Generate Variables      ***/
	/*************************************************/
{	
	/*** Penn Data ***/
	use "$data/Raw/IRRData_Penn.dta", clear
	
	// Demographic indicators
	gen rand_female 	= (randfirstname_gender=="female")
	label variable rand_female "Resume name indicative of female candidate"

	gen white 			= (rand_eth=="White":randethtype)
	label variable white "Resume name indicative of white candidate"

	gen whitefemale		= rand_female==1 & white==1
	label variable whitefemale "Female, White"
	
	gen nonwhite_female = rand_eth!="White":randethtype & rand_female==1
	label variable nonwhite_female "Female, Non-White"
	
	gen nonwhite_male = rand_eth!="White":randethtype & rand_female==0
	label variable nonwhite_male "Male, Non-White"

	gen whitemale = (rand_eth=="White":randethtype & rand_female==0)
	label variable whitemale "Male, White"
	
	gen not_a_whitemale = 1-whitemale
	label variable not_a_whitemale "Not a White Male"

	// Human Capital indicators
	tab randmajor, gen(imajor) 
	
	gen noNarrative = (NarrativeScore==1)
	label variable noNarrative "Work experiences have no relationship"
	
	gen hassecondjob = !mi(randworkexptwo)
	label variable hassecondjob "Resume has two work experiences"
	
	gen wharton = (randschool == "The Wharton School")
	label variable wharton "Wharton" 
	
	gen majorHumSS = (major_type==2)
	label variable majorHumSS "Major is Humanities/Social Sciences"

	
	// Generate numeric variables for work and leadership for use in regressions
	encode randworkexp, gen(work1)
	label variable work1 "First work experience"

	encode randworkexptwo, gen(work2)
	label variable work2 "Second work experience"
	
	encode randleadexp, gen(lead1)
	label variable work1 "First leadership experience"
	
	encode randleadexptwo, gen(lead2)	
	label variable work1 "Second work experience"
	
	save "$data/Clean/IRRAnalysisFile_Penn.dta", replace

	
	/*** Pitt Data ***/
	use "$data/Raw/IRRData_Pitt.dta", clear
	
	// Demographic indicators
	gen rand_female 	= (randfirstname_gender=="female")
	label variable rand_female "Resume name indicative of female candidate"

	gen white 			= (rand_eth=="White":randethtype)
	label variable white "Resume name indicative of white candidate"

	gen whitefemale		= rand_female==1 & white==1
	label variable whitefemale "Female, White"
	
	gen nonwhite_female = rand_eth!="White":randethtype & rand_female==1
	label variable nonwhite_female "Female, Non-White"
	
	gen nonwhite_male = rand_eth!="White":randethtype & rand_female==0
	label variable nonwhite_male "Male, Non-White"

	gen whitemale = (rand_eth=="White":randethtype & rand_female==0)
	label variable whitemale "Male, White"

	gen not_a_whitemale = 1-whitemale
	label variable not_a_whitemale "Not a White Male"

	
	// Human Capital indicators
	tab randmajor, gen(imajor) 
	
	gen hassecondjob = !mi(randworkexptwo)
	label variable hassecondjob "Resume has two work experiences"
	
	gen majorHumSS = (major_type==2)
	label variable majorHumSS "Major is Humanities/Social Sciences"
	
	// Generate numeric variables for work and leadership for use in regressions
	encode randworkexp, gen(work1)
	label variable work1 "First work experience"
	encode randworkexptwo, gen(work2)
	label variable work2 "Second work experience"
		
	encode randleadexp, gen(lead1)
	label variable lead1 "First leadership experience"
	encode randleadexptwo, gen(lead2)	
	label variable lead2 "Second leadership experience"
	
	save "$data/Clean/IRRAnalysisFile_Pitt.dta", replace
	
}

	
	/***********************/
	/***     Tables      ***/
	/***********************/

	
	/*** Table 2: Human Capital Results ***/	
{
	use "$data/Clean/IRRAnalysisFile_Penn.dta", clear

	// 1 - No controls
	xi: reg rating_hire randgpa topemp secondint wfm techskills whitefemale nonwhite_male nonwhite_female imajor*, robust 
	est sto dum4_noctrls
	estadd local majorfe "Yes"
	estadd local orderfe "No"
	estadd local leadfe "No"
	estadd local subjfe "No"
	unab imaj: imajor*
	test `imaj'		
	local pval: di %4.3f r(p)
	if (`pval' < 0.001) estadd local Ftest = "$<0.001$"
	else estadd local Ftest = "`pval'"	

	
	// 2 - Some Controls
	xi: reg rating_hire randgpa topemp secondint wfm techskills whitefemale nonwhite_male nonwhite_female i.resumenumber imajor* i.lead1 i.lead2, robust 
	est sto dum4_somectrls
	estadd local majorfe "Yes"
	estadd local orderfe "Yes"
	estadd local leadfe "Yes"
	estadd local subjfe "No"
	unab imaj: imajor*
	test `imaj'		
	local pval: di %4.3f r(p)
	if (`pval' < 0.001) estadd local Ftest = "$<0.001$"
	else estadd local Ftest = "`pval'"	
	
	
	// 3 - All Controls
	xi: reg rating_hire randgpa topemp secondint wfm techskills whitefemale nonwhite_male nonwhite_female i.resumenumber imajor* i.lead1 i.lead2, absorb(subjroundid) robust 
	est sto dum4_allctrls
	estadd local majorfe "Yes"
	estadd local orderfe "Yes"
	estadd local leadfe "Yes"
	estadd local subjfe "Yes"
	unab imaj: imajor*
	test `imaj'		
	local pval: di %4.3f r(p)
	if (`pval' < 0.001) estadd local Ftest = "$<0.001$"
	else estadd local Ftest = "`pval'"	
	
	// 4 - Rescaled
	eststo dum4_rescaled: nlcom (randgpa: _b[randgpa]/_b[randgpa]) ///
		(topemp: _b[topemp]/_b[randgpa]) ///
		(secondint: _b[secondint]/_b[randgpa]) ///
		(wfm: _b[wfm]/_b[randgpa]) ///
		(techskills: _b[techskills]/_b[randgpa]) ///
		(whitefemale: _b[whitefemale]/_b[randgpa]) ///
		(nonwhite_male: _b[nonwhite_male]/_b[randgpa]) ///
		(nonwhite_female: _b[nonwhite_female]/_b[randgpa]) ///
		, post	
	if (`pval' < 0.001) estadd local Ftest = "$<0.001$"
		else estadd local Ftest = "`pval'"	
	estadd local majorfe "Yes"
	estadd local orderfe "Yes"
	estadd local leadfe "Yes"
	estadd local subjfe "Yes"
	
	// 5 - Probit
	oprobit rating_hire randgpa topemp secondint wfm techskills whitefemale nonwhite_male nonwhite_female imajor*, robust 
	est sto dum4_oprob
	estadd local majorfe "Yes"
	estadd local orderfe "No"
	estadd local leadfe "No"
	estadd local subjfe "No"
	local cut1 = string(_b[/cut1], "%3.2f")
	local cut2 = string(_b[/cut2], "%3.2f")
	local cut3 = string(_b[/cut3], "%3.2f")
	local cut4 = string(_b[/cut4], "%3.2f")
	local cut5 = string(_b[/cut5], "%3.2f")
	local cut6 = string(_b[/cut6], "%3.2f")
	local cut7 = string(_b[/cut7], "%3.2f")
	local cut8 = string(_b[/cut8], "%3.2f")
	local cut9 = string(_b[/cut9], "%3.2f")
	unab imaj: imajor*
	test `imaj'		
	local pval: di %4.3f r(p)
	if (`pval' < 0.001) estadd local Ftest = "$<0.001$"
	else estadd local Ftest = "`pval'"
	

	// Write to file
	esttab dum4_noctrls dum4_somectrls dum4_allctrls dum4_rescaled dum4_oprob using "$output/Table2.tex", ///
		b(3) se(3) replace compress nofloat r2 ///
		mgroups("\shortstack{Dependent Variable: Hiring Interest}", pattern(1 0 0 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
		mtitles("OLS" "OLS" "OLS"  "\shortstack{GPA-Scaled\\OLS}" "\shortstack{Ordered\\Probit}") ///
		nonum label depvar nogaps noomitted $starglob ///
		keep(randgpa whitefemale nonwhite_male nonwhite_female topemp secondint wfm techskills) eqlabels(none) ///
		postfoot("\hline\hline \addlinespace \multicolumn{5}{l}{\footnotesize Ordered probit cutpoints: `cut1', `cut2', `cut3', `cut4', `cut5', `cut6', `cut7', `cut8', and `cut9'.} \end{tabular} $starending") ///
		scalars("Ftest \shortstack[l]{\emph{p-value for test of joint}\\\emph{\quad significance of Majors}}" ///
			"majorfe Major FEs" "leadfe Leadership FEs" "orderfe Order FEs" "subjfe Subject FEs") sfmt(%5.4fc)
}
			
			
	/*** Table 3: Hiring Interest by Major ***/
{
	use "$data/Clean/IRRAnalysisFile_Penn.dta", clear

	// Humanities & Social Sciences
	// 1) No Controls - Hum/SS
	reg rating_hire randgpa topemp secondint wfm techskills whitefemale nonwhite_male nonwhite_female imajor* if majorHumSS==1, robust 
	est sto ols_penn_noctrl_hum

	estadd local subjfe "No"
	estadd local majorfe "Yes"
	estadd local orderfe "No"
	estadd local leadfe "No"
	
	unab imaj: imajor*
	test `imaj'		
	local pval: di %4.3f r(p)*2
	if (`pval' < 0.001) estadd local Ftest = "$<0.001$"
	else estadd local Ftest = "`pval'"	
	
	// 2) Leadership, Order, Major FEs - Hum/SS
	xi: reg  rating_hire randgpa topemp secondint wfm techskills whitefemale nonwhite_male nonwhite_female i.resumenumber imajor* i.lead1 i.lead2 if majorHumSS==1, robust 
	est sto ols_penn_somectrls_hum
	
	estadd local subjfe "No"
	estadd local majorfe "Yes"
	estadd local orderfe "Yes"
	estadd local leadfe "Yes"

	unab imaj: imajor*
	test `imaj'		
	local pval: di %4.3f r(p)*2
	if (`pval' < 0.001) estadd local Ftest = "$<0.001$"
	else estadd local Ftest = "`pval'"	
	
	// 3) All controls - Hum/SS
	xi: reg rating_hire randgpa topemp secondint wfm techskills whitefemale nonwhite_male nonwhite_female i.resumenumber imajor* i.lead1 i.lead2 if majorHumSS==1, absorb(subjroundid) robust 
	est sto ols_penn_allctrls_hum
	estadd local subjfe "Yes"
	estadd local majorfe "Yes"
	estadd local orderfe "Yes"
	estadd local leadfe "Yes"
	
	unab imaj: imajor*
	test `imaj'
	local pval: di %4.3f r(p)*2
	if (`pval' < 0.001) estadd local Ftest = "$<0.001$"
	else estadd local Ftest = "`pval'"	
	
	// 4) Rescaled wrt GPA
	eststo ols_penn_rescaled_hum: nlcom (randgpa: _b[randgpa]/_b[randgpa]) ///
		(topemp: _b[topemp]/_b[randgpa]) ///
		(secondint: _b[secondint]/_b[randgpa]) ///
		(wfm: _b[wfm]/_b[randgpa]) ///
		(techskills: _b[techskills]/_b[randgpa]) ///
		(whitefemale: _b[whitefemale]/_b[randgpa]) ///
		(nonwhite_male: _b[nonwhite_male]/_b[randgpa]) ///
		(nonwhite_female: _b[nonwhite_female]/_b[randgpa]) ///
		, post	
	if (`pval' < 0.001) estadd local Ftest = "$<0.001$"
		else estadd local Ftest = "`pval'"	
	estadd local subjfe "Yes"
	estadd local majorfe "Yes"
	estadd local orderfe "Yes"
	estadd local leadfe "Yes"

	// 5) Ordered Probit - Hum/SS
	oprobit rating_hire randgpa topemp secondint wfm techskills whitefemale nonwhite_male nonwhite_female imajor* if majorHumSS==1
	est sto oprob_penn_hum
	estadd local subjfe "No"
	estadd local majorfe "Yes"
	estadd local orderfe "No"
	estadd local leadfe "No"
	
	local cut1hum = string(_b[/cut1], "%3.2f")
	local cut2hum = string(_b[/cut2], "%3.2f")
	local cut3hum = string(_b[/cut3], "%3.2f")
	local cut4hum = string(_b[/cut4], "%3.2f")
	local cut5hum = string(_b[/cut5], "%3.2f")
	local cut6hum = string(_b[/cut6], "%3.2f")
	local cut7hum = string(_b[/cut7], "%3.2f")
	local cut8hum = string(_b[/cut8], "%3.2f")
	local cut9hum = string(_b[/cut9], "%3.2f")
	
	unab imaj: imajor*
	test `imaj'
	local pval: di %4.3f r(p)*2
	if (`pval' < 0.001) estadd local Ftest = "$<0.001$"
	else estadd local Ftest = "`pval'"	


	/*** Science  ***/
	use "$data/Clean/IRRAnalysisFile_Penn.dta", clear
	// 6) No Controls - Science
	reg rating_hire randgpa topemp secondint wfm techskills whitefemale nonwhite_male nonwhite_female imajor* if majorHumSS==0, robust 
	est sto ols_penn_noctrl_sci

	estadd local subjfe "No"
	estadd local majorfe "Yes"
	estadd local orderfe "No"
	estadd local leadfe "No"
	
	unab imaj: imajor*
	test `imaj'		
	local pval: di %4.3f r(p)*2
	if (`pval' < 0.001) estadd local Ftest = "$<0.001$"
	else estadd local Ftest = "`pval'"	
	
	// 7) Leadership, Order, Major FEs - Science
	xi: reg rating_hire randgpa topemp secondint wfm techskills whitefemale nonwhite_male nonwhite_female i.resumenumber imajor* i.lead1 i.lead2 if majorHumSS==0, robust 
	est sto ols_penn_somectrls_sci

	estadd local subjfe "No"
	estadd local majorfe "Yes"
	estadd local orderfe "Yes"
	estadd local leadfe "Yes"

	unab imaj: imajor*
	test `imaj'		
	local pval: di %4.3f r(p)*2
	if (`pval' < 0.001) estadd local Ftest = "$<0.001$"
	else estadd local Ftest = "`pval'"	
	
	// 8) All controls - Science
	xi: reg rating_hire randgpa topemp secondint wfm techskills whitefemale nonwhite_male nonwhite_female i.resumenumber imajor* i.lead1 i.lead2 if majorHumSS==0, absorb(subjroundid) robust 
	est sto ols_penn_allctrls_sci
	estadd local subjfe "Yes"
	estadd local majorfe "Yes"
	estadd local orderfe "Yes"
	estadd local leadfe "Yes"
	
	unab imaj: imajor*
	test `imaj'
	local pval: di %4.3f r(p)*2
	if (`pval' < 0.001) estadd local Ftest = "$<0.001$"
	else estadd local Ftest = "`pval'"	
	
	
	// 9) Rescaled wrt GPA
	eststo ols_penn_rescaled_sci: nlcom (randgpa: _b[randgpa]/_b[randgpa]) ///
		(topemp: _b[topemp]/_b[randgpa]) ///
		(secondint: _b[secondint]/_b[randgpa]) ///
		(wfm: _b[wfm]/_b[randgpa]) ///
		(techskills: _b[techskills]/_b[randgpa]) ///
		(whitefemale: _b[whitefemale]/_b[randgpa]) ///
		(nonwhite_male: _b[nonwhite_male]/_b[randgpa]) ///
		(nonwhite_female: _b[nonwhite_female]/_b[randgpa]) ///
		, post	
	if (`pval' < 0.001) estadd local Ftest = "$<0.001$"
		else estadd local Ftest = "`pval'"	
	estadd local subjfe "Yes"
	estadd local majorfe "Yes"
	estadd local orderfe "Yes"
	estadd local leadfe "Yes"
		
	
	// 10) Ordered Probit - Science
	oprobit rating_hire randgpa topemp secondint wfm techskills whitefemale nonwhite_male nonwhite_female imajor* if majorHumSS==0
	est sto oprob_penn_sci
	estadd local subjfe "No"
	estadd local majorfe "Yes"
	estadd local orderfe "No"
	estadd local leadfe "No"
	local cut1sci = string(_b[/cut1], "%3.2f")
	local cut2sci = string(_b[/cut2], "%3.2f")
	local cut3sci = string(_b[/cut3], "%3.2f")
	local cut4sci = string(_b[/cut4], "%3.2f")
	local cut5sci = string(_b[/cut5], "%3.2f")
	local cut6sci = string(_b[/cut6], "%3.2f")
	local cut7sci = string(_b[/cut7], "%3.2f")
	local cut8sci = string(_b[/cut8], "%3.2f")
	local cut9sci = string(_b[/cut9], "%3.2f")
	
	unab imaj: imajor*
	test `imaj'
	local pval: di %4.3f r(p)*2
	if (`pval' < 0.001) estadd local Ftest = "$<0.001$"
	else estadd local Ftest = "`pval'"	
		
	// Write to file
	esttab ols_penn_noctrl_hum ols_penn_somectrls_hum ols_penn_allctrls_hum ols_penn_rescaled_hum oprob_penn_hum ///
		ols_penn_noctrl_sci ols_penn_somectrls_sci ols_penn_allctrls_sci ols_penn_rescaled_sci oprob_penn_sci using "$output/Table3.tex", ///
		b(3) se(3) replace compress nofloat r2 ///
		nomtitles varwidth(15) ///
		nonum label depvar nogaps noomitted $starglob ///
		keep(randgpa topemp secondint wfm techskills whitefemale nonwhite_male nonwhite_female) eqlabels(none) ///
		prehead("{\def\sym#1{\ifmmode^{#1}\else\(^{#1}\)\fi} \begin{tabular}{l*{10}{c}} \hline\hline & \multicolumn{10}{c}{Dependent Variable: Hiring Interest} \\ & \multicolumn{5}{c}{Humanities \& Social Sciences} & \multicolumn{5}{c}{STEM} \\ \cmidrule(lr){2-6}  \cmidrule(lr){7-11} & OLS & OLS & OLS & \shortstack{GPA-Scaled\\OLS} & \shortstack{Ordered\\Probit} & OLS & OLS & OLS & \shortstack{GPA-Scaled\\OLS} & \shortstack{Ordered\\Probit} \\") ///
		prefoot("\hline") ///
		postfoot("\hline\hline \addlinespace \multicolumn{9}{l}{\footnotesize Ordered probit cutpoints (Column 5): `cut1hum', `cut2hum', `cut3hum', `cut4hum', `cut5hum', `cut6hum', `cut7hum', `cut8hum', `cut9hum'.} \\ \multicolumn{9}{l}{\footnotesize Ordered probit cutpoints (Column 10): `cut1sci', `cut2sci', `cut3sci', `cut4sci', `cut5sci', `cut6sci', `cut7sci', `cut8sci', `cut9sci'.} \end{tabular} }") ///
		scalars("Ftest \shortstack{\emph{p-value for test of joint}\\\emph{\quad significance of Majors}}" ///
			"line \hline%" "majorfe Major FEs" "leadfe Leadership FEs" "orderfe Order FEs" "subjfe Subject FEs") sfmt(%5.4fc)	
}			
	
		
	/*** Table 4: Likelihood of Acceptance ***/
{
	use "$data/Clean/IRRAnalysisFile_Penn.dta", clear

	xi: reg rating_accept randgpa topemp secondint wfm techskills whitefemale nonwhite_male nonwhite_female imajor*, robust 
	est sto dum4_acc_noctrls
	estadd local majorfe "Yes"
	estadd local orderfe "No"
	estadd local leadfe "No"
	estadd local subjfe "No"
	unab imaj: imajor*
	test `imaj'		
	local pval: di %4.3f r(p)
	if (`pval' < 0.001) estadd local Ftest = "$<0.001$"
	else estadd local Ftest = "`pval'"	
	
	test whitefemale nonwhite_male nonwhite_female
	local p_discrim: di %4.3f r(p)
	if (`p_discrim' < 0.001) estadd local pdemog = "$<0.001$"
	else estadd local pdemog = "`p_discrim'"	
	
		
	xi: reg rating_accept randgpa topemp secondint wfm techskills whitefemale nonwhite_male nonwhite_female i.resumenumber imajor* i.lead1 i.lead2, robust 
	est sto dum4_acc_somectrls
	estadd local majorfe "Yes"
	estadd local orderfe "Yes"
	estadd local leadfe "Yes"
	estadd local subjfe "No"
	unab imaj: imajor*
	test `imaj'		
	local pval: di %4.3f r(p)
	if (`pval' < 0.001) estadd local Ftest = "$<0.001$"
	else estadd local Ftest = "`pval'"	
	
	test whitefemale nonwhite_male nonwhite_female
	local p_discrim: di %4.3f r(p)
	if (`p_discrim' < 0.001) estadd local pdemog = "$<0.001$"
	else estadd local pdemog = "`p_discrim'"	
	
	
	
	xi: reg rating_accept randgpa topemp secondint wfm techskills whitefemale nonwhite_male nonwhite_female i.resumenumber imajor* i.lead1 i.lead2, absorb(subjroundid) robust 
	est sto dum4_acc_allctrls
	estadd local majorfe "Yes"
	estadd local orderfe "Yes"
	estadd local leadfe "Yes"
	estadd local subjfe "Yes"
	unab imaj: imajor*
	test `imaj'		
	local pval: di %4.3f r(p)
	if (`pval' < 0.001) estadd local Ftest = "$<0.001$"
	else estadd local Ftest = "`pval'"	
	
	test whitefemale nonwhite_male nonwhite_female
	local p_discrim: di %4.3f r(p)
	if (`p_discrim' < 0.001) estadd local pdemog = "$<0.001$"
	else estadd local pdemog = "`p_discrim'"	
	
	local gpascaler = _b[randgpa]
	display `gpascaler'
	
	
	oprobit rating_accept randgpa topemp secondint wfm techskills whitefemale nonwhite_male nonwhite_female imajor*, robust 
	est sto dum4_acc_oprob
	estadd local majorfe "Yes"
	estadd local orderfe "No"
	estadd local leadfe "No"
	estadd local subjfe "No"
	local cut1 = string(_b[/cut1], "%3.2f")
	local cut2 = string(_b[/cut2], "%3.2f")
	local cut3 = string(_b[/cut3], "%3.2f")
	local cut4 = string(_b[/cut4], "%3.2f")
	local cut5 = string(_b[/cut5], "%3.2f")
	local cut6 = string(_b[/cut6], "%3.2f")
	local cut7 = string(_b[/cut7], "%3.2f")
	local cut8 = string(_b[/cut8], "%3.2f")
	local cut9 = string(_b[/cut9], "%3.2f")
	unab imaj: imajor*
	test `imaj'		
	local pval: di %4.3f r(p)
	if (`pval' < 0.001) estadd local Ftest = "$<0.001$"
	else estadd local Ftest = "`pval'"
	
	test whitefemale nonwhite_male nonwhite_female
	local p_discrim: di %4.3f r(p)
	if (`p_discrim' < 0.001) estadd local pdemog = "$<0.001$"
	else estadd local pdemog = "`p_discrim'"	
	
	
	esttab dum4_acc_noctrls dum4_acc_somectrls dum4_acc_allctrls dum4_acc_oprob  using "$output/Table4.tex", ///
		b(3) se(3) replace compress nofloat r2 ///
		mgroups("\shortstack{Dependent Variable: Likelihood of Acceptance}", pattern(1 0 0 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
		mtitles("OLS" "OLS" "OLS" "\shortstack{Ordered\\Probit}") ///
		nonum label depvar nogaps noomitted $starglob ///
		transform(@/`gpascaler', pattern(0 0 0 0 1)) ///
		keep(randgpa whitefemale nonwhite_male nonwhite_female topemp secondint wfm techskills) eqlabels(none) ///
		postfoot("\hline\hline \addlinespace \multicolumn{5}{l}{\footnotesize Ordered probit cutpoints: `cut1', `cut2', `cut3', `cut4', `cut5', `cut6', `cut7', `cut8', and `cut9'.} \end{tabular} $starending") ///
		scalars("Ftest \shortstack[l]{\emph{p-value for test of joint}\\\emph{\quad significance of Majors}}" ///
			"majorfe Major FEs" "leadfe Leadership FEs" "orderfe Order FEs" "subjfe Subject FEs") sfmt(%5.4fc)
}
				

	/*** Table 5: Likelihood of Acceptance by Major ***/
{
	use "$data/Clean/IRRAnalysisFile_Penn.dta", clear

	// Humanities & Social Sciences
	// 1) No Controls - Hum/SS
	reg rating_accept randgpa topemp secondint wfm techskills whitefemale nonwhite_male nonwhite_female imajor* if majorHumSS==1, robust 
	est sto ols_acc_penn_noctrl_hum

	estadd local subjfe "No"
	estadd local majorfe "Yes"
	estadd local orderfe "No"
	estadd local leadfe "No"
	
	unab imaj: imajor*
	test `imaj'		
	local pval: di %4.3f r(p)*2
	if (`pval' < 0.001) estadd local Ftest = "$<0.001$"
	else estadd local Ftest = "`pval'"	
	
	// 2) Leadership, Order, Major FEs - Hum/SS
	xi: reg rating_accept randgpa topemp secondint wfm techskills whitefemale nonwhite_male nonwhite_female i.resumenumber imajor* i.lead1 i.lead2 if majorHumSS==1, robust 
	est sto ols_acc_penn_somectrls_hum
	
	estadd local subjfe "No"
	estadd local majorfe "Yes"
	estadd local orderfe "Yes"
	estadd local leadfe "Yes"

	unab imaj: imajor*
	test `imaj'		
	local pval: di %4.3f r(p)*2
	if (`pval' < 0.001) estadd local Ftest = "$<0.001$"
	else estadd local Ftest = "`pval'"	
	
	
	// 3) All controls - Hum/SS
	xi: reg rating_accept randgpa topemp secondint wfm techskills whitefemale nonwhite_male nonwhite_female i.resumenumber imajor* i.lead1 i.lead2 if majorHumSS==1, absorb(subjroundid) robust 
	est sto ols_acc_penn_allctrls_hum
	estadd local subjfe "Yes"
	estadd local majorfe "Yes"
	estadd local orderfe "Yes"
	estadd local leadfe "Yes"
	
	unab imaj: imajor*
	test `imaj'
	local pval: di %4.3f r(p)*2
	if (`pval' < 0.001) estadd local Ftest = "$<0.001$"
	else estadd local Ftest = "`pval'"	
	
	
	// 4) Ordered Probit - Hum/SS
	oprobit rating_acc randgpa topemp secondint wfm techskills whitefemale nonwhite_male nonwhite_female imajor* if majorHumSS==1
	est sto oprob_acc_penn_hum
	estadd local subjfe "No"
	estadd local majorfe "Yes"
	estadd local orderfe "No"
	estadd local leadfe "No"
	
	local cut1hum = string(_b[/cut1], "%3.2f")
	local cut2hum = string(_b[/cut2], "%3.2f")
	local cut3hum = string(_b[/cut3], "%3.2f")
	local cut4hum = string(_b[/cut4], "%3.2f")
	local cut5hum = string(_b[/cut5], "%3.2f")
	local cut6hum = string(_b[/cut6], "%3.2f")
	local cut7hum = string(_b[/cut7], "%3.2f")
	local cut8hum = string(_b[/cut8], "%3.2f")
	local cut9hum = string(_b[/cut9], "%3.2f")
	
	unab imaj: imajor*
	test `imaj'
	local pval: di %4.3f r(p)*2
	if (`pval' < 0.001) estadd local Ftest = "$<0.001$"
	else estadd local Ftest = "`pval'"	


	/*** Science  ***/
	use "$data/Clean/IRRAnalysisFile_Penn.dta", clear
	// 5) No Controls - Science
	reg rating_acc randgpa topemp secondint wfm techskills whitefemale nonwhite_male nonwhite_female imajor* if majorHumSS==0, robust 
	est sto ols_acc_penn_noctrl_sci

	estadd local subjfe "No"
	estadd local majorfe "Yes"
	estadd local orderfe "No"
	estadd local leadfe "No"
	
	unab imaj: imajor*
	test `imaj'		
	local pval: di %4.3f r(p)*2
	if (`pval' < 0.001) estadd local Ftest = "$<0.001$"
	else estadd local Ftest = "`pval'"	

	
	
	// 6) Leadership, Order, Major FEs - Science
	xi: reg rating_acc randgpa topemp secondint wfm techskills whitefemale nonwhite_male nonwhite_female i.resumenumber imajor* i.lead1 i.lead2 if majorHumSS==0, robust 
	est sto ols_acc_penn_somectrls_sci

	estadd local subjfe "No"
	estadd local majorfe "Yes"
	estadd local orderfe "Yes"
	estadd local leadfe "Yes"

	unab imaj: imajor*
	test `imaj'		
	local pval: di %4.3f r(p)*2
	if (`pval' < 0.001) estadd local Ftest = "$<0.001$"
	else estadd local Ftest = "`pval'"	

	
	
	// 7) All controls - Science
	xi: reg rating_acc randgpa topemp secondint wfm techskills whitefemale nonwhite_male nonwhite_female i.resumenumber imajor* i.lead1 i.lead2 if majorHumSS==0, absorb(subjroundid) robust 
	est sto ols_acc_penn_allctrls_sci
	estadd local subjfe "Yes"
	estadd local majorfe "Yes"
	estadd local orderfe "Yes"
	estadd local leadfe "Yes"
	
	unab imaj: imajor*
	test `imaj'
	local pval: di %4.3f r(p)*2
	if (`pval' < 0.001) estadd local Ftest = "$<0.001$"
	else estadd local Ftest = "`pval'"	

		
	// 8) Ordered Probit - Science
	oprobit rating_acc randgpa topemp secondint wfm techskills whitefemale nonwhite_male nonwhite_female imajor* if majorHumSS==0
	est sto oprob_acc_penn_sci
	estadd local subjfe "No"
	estadd local majorfe "Yes"
	estadd local orderfe "No"
	estadd local leadfe "No"
	local cut1sci = string(_b[/cut1], "%3.2f")
	local cut2sci = string(_b[/cut2], "%3.2f")
	local cut3sci = string(_b[/cut3], "%3.2f")
	local cut4sci = string(_b[/cut4], "%3.2f")
	local cut5sci = string(_b[/cut5], "%3.2f")
	local cut6sci = string(_b[/cut6], "%3.2f")
	local cut7sci = string(_b[/cut7], "%3.2f")
	local cut8sci = string(_b[/cut8], "%3.2f")
	local cut9sci = string(_b[/cut9], "%3.2f")
	
	unab imaj: imajor*
	test `imaj'
	local pval: di %4.3f r(p)*2
	if (`pval' < 0.001) estadd local Ftest = "$<0.001$"
	else estadd local Ftest = "`pval'"	

		
	esttab ols_acc_penn_noctrl_hum ols_acc_penn_somectrls_hum ols_acc_penn_allctrls_hum oprob_acc_penn_hum ///
		ols_acc_penn_noctrl_sci ols_acc_penn_somectrls_sci ols_acc_penn_allctrls_sci oprob_acc_penn_sci using "$output/Table5.tex", ///
		b(3) se(3) replace compress nofloat r2 ///
		nomtitles varwidth(15) ///
		nonum label depvar nogaps noomitted $starglob ///
		keep(randgpa topemp secondint wfm techskills whitefemale nonwhite_male nonwhite_female) eqlabels(none) ///
		prehead("{\def\sym#1{\ifmmode^{#1}\else\(^{#1}\)\fi} \begin{tabular}{l*{8}{c}} \hline\hline & \multicolumn{8}{c}{Dependent Variable: Likelihood of Acceptance} \\ & \multicolumn{4}{c}{Humanities \& Social Sciences} & \multicolumn{4}{c}{STEM} \\ \cmidrule(lr){2-5}  \cmidrule(lr){6-9} & OLS & OLS & OLS & \shortstack{Ordered\\Probit} & OLS & OLS & OLS & \shortstack{Ordered\\Probit} \\") ///
		prefoot("\hline") ///
		postfoot("\hline\hline \addlinespace \multicolumn{9}{l}{\footnotesize Ordered probit cutpoints (Column 4): `cut1hum', `cut2hum', `cut3hum', `cut4hum', `cut5hum', `cut6hum', `cut7hum', `cut8hum', `cut9hum'.} \\ \multicolumn{9}{l}{\footnotesize Ordered probit cutpoints (Column 8): `cut1sci', `cut2sci', `cut3sci', `cut4sci', `cut5sci', `cut6sci', `cut7sci', `cut8sci', `cut9sci'.} \end{tabular} }") ///
		scalars("Ftest \shortstack{\emph{p-value for test of joint}\\\emph{\quad significance of Majors}}" ///
			 "line \hline%" "majorfe Major FEs" "leadfe Leadership FEs" "orderfe Order FEs" "subjfe Subject FEs") sfmt(%5.4fc)	
}


	/*** Table 6: Pitt Target Major ***/
{
	use "$data/Clean/IRRAnalysisFile_Pitt.dta", clear

	xi: reg rating_hire randgpa topemp secondint wfm techskills whitefemale nonwhite_male nonwhite_female i.resumenumber imajor* i.lead1 i.lead2, absorb(subjroundid) robust 
	est sto ols_hire_penn
	estadd local subjfe "Yes"
	estadd local majorfe "Yes"
	estadd local orderfe "Yes"
	estadd local leadfe "Yes"
	
	unab imaj: imajor*
	test `imaj'		
	local pval: di %4.3f r(p)
	if (`pval' < 0.001) estadd local Ftest = "$<0.001$"
	else estadd local Ftest = "`pval'"
	
	xi: reg rating_hire randgpa topemp secondint wfm techskills whitefemale nonwhite_male nonwhite_female i.resumenumber imajor* i.lead1 i.lead2, absorb(subjroundid) robust 
	est sto ols_hire_pitt
	estadd local subjfe "Yes"
	estadd local majorfe "Yes"
	estadd local orderfe "Yes"
	estadd local leadfe "Yes"
	
	unab imaj: imajor*
	test `imaj'		
	local pval: di %4.3f r(p)
	if (`pval' < 0.001) estadd local Ftest = "$<0.001$"
	else estadd local Ftest = "`pval'"
	
	xi: reg rating_hire randgpa topemp secondint wfm techskills whitefemale nonwhite_male nonwhite_female i.resumenumber imajor* i.lead1 i.lead2 if round==4 & acceptmajor==0, absorb(subjroundid) robust 
	est sto ols_hire_pitt_unacc
	estadd local subjfe "Yes"
	estadd local majorfe "Yes"
	estadd local orderfe "Yes"
	estadd local leadfe "Yes"
	
	unab imaj: imajor*
	test `imaj'		
	local pval: di %4.3f r(p)
	if (`pval' < 0.001) estadd local Ftest = "$<0.001$"
	else estadd local Ftest = "`pval'"

	xi: reg rating_hire randgpa topemp secondint wfm techskills whitefemale nonwhite_male nonwhite_female i.resumenumber imajor* i.lead1 i.lead2 if round==4 & acceptmajor==1, absorb(subjroundid) robust 
	est sto ols_hire_pitt_accmaj
	estadd local subjfe "Yes"
	estadd local majorfe "Yes"
	estadd local orderfe "Yes"
	estadd local leadfe "Yes"
	
	unab imaj: imajor*
	test `imaj'		
	local pval: di %4.3f r(p)
	if (`pval' < 0.001) estadd local Ftest = "$<0.001$"
	else estadd local Ftest = "`pval'"
	
	esttab ols_hire_penn ols_hire_pitt ols_hire_pitt_unacc ols_hire_pitt_accmaj using "$output/Table6.tex", ///
		b(3) se(3) replace compress nofloat r2 ///
		mtitles("Penn" "Pitt" "\shortstack{Pitt, Wave 2\\Non-Target Major}" "\shortstack{Pitt, Wave 2\\Target Major}") ///
		mgroups("Dependent Variable: Hiring Interest", pattern(1 0 0 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
		nonum label depvar nogaps noomitted $starglob ///
		keep(randgpa topemp secondint wfm techskills whitefemale nonwhite_male nonwhite_female) ///
		postfoot("\hline\hline \end{tabular} $starending") ///
		scalars("Ftest \shortstack{\emph{p-value for test of joint}\\\emph{significance of Majors}}" "majorfe Major FEs" "leadfe Leadership FEs" "orderfe Order FEs" "subjfe Subject FEs")
		//note("Standard errors clustered at the subject level in parentheses.""Includes FEs for subject, major, resume order.")
}
	
		
	/***********************/
	/***     Figures     ***/
	/***********************/
	
	
	/*** Figure 1: Value of Quality of Experience Over Selectivity Distribution ***/
{
	// a) Empirical CDF for Top Internship
	use "$data/Clean/IRRAnalysisFile_Penn.dta", clear
	sort rating_hire topemp
	cumul rating_hire if topemp==1, gen(cdf_topemp1)
	cumul rating_hire if topemp==0, gen(cdf_topemp0)
	line cdf_topemp0 rating_hire, c(J) col("$col1") || ///
	  line cdf_topemp1 rating_hire, c(J) col("$col2") lp(dash) ///
	  $allwhite ///
	  legend(label(1 "No Top Internship") label(2 "Top Internship") region(style(none)) size(medlarge)) ///
	  title() xtitle(Hiring Interest Rating, size(large)) yscale(titlegap(medium)) ///
	  ytitle(Pr(Hiring Interest {&le} x), size(large) ) ylab(, nogrid labsize(medlarge)) xlab(, labsize(medlarge))
	graph export "$output/fig1_a.png", replace
	
	// b) Linear Probability Model for Top Internship
	use "$data/Clean/IRRAnalysisFile_Penn.dta", clear
	
	gen threshold=_n if _n<11
	
	gen beta = .
	gen se = .
	
	forvalues i=1(1)10 {
		gen callback = (rating_hire>=`i')
		qui reg callback topemp, robust
		replace beta = _b[topemp] if _n==`i'
		replace se = _se[topemp] if _n==`i'
				
		drop callback
	}
	gen seplot_lo = beta - 1.96*se
	gen seplot_hi = beta + 1.96*se
	
	twoway rspike seplot_lo seplot_hi threshold if !mi(beta), col(gray) || ///
		scatter beta threshold if !mi(beta), $allwhite msym(S) col("$col2") ///
		title() ///
		legend(order(2 "Top Internship") region(style(none)) size(medlarge)) ///
		xtitle(Callback Threshold, size(large)) ytitle(Coefficient Estimate, size(large)) ///
		ylab(,nogrid labsize(medlarge)) xlab(, labsize(medlarge)) yscale(titlegap(medium)) yline(0, lcolor(gs10))
	graph export "$output/fig1_b.png", replace
	
	// c) Empirical CDF for Second Job Type
	use "$data/Clean/IRRAnalysisFile_Penn.dta", clear
	sort rating_hire wfm hassecondjob secondint
	cumul rating_hire if wfm==1, gen(cdf_wfm1)	
	cumul rating_hire if hassecondjob==0, gen(cdf_hassecondjob1)
	cumul rating_hire if secondint==1, gen(cdf_secondint1)

	line cdf_hassecondjob1 rating_hire, c(J) col("$col1") || ///
	  line cdf_wfm1 rating_hire, c(J) col("$col2") lp(dash) || ///
	  line cdf_secondint1 rating_hire, c(J) col("$col3") lp(".__") ///
	  $allwhite ///
	  legend(label(1 "No Second Job") label(2 "Work for Money")  label(3 "Second Internship") ///
		region(style(none)) size(medlarge) symxsize(8)) ///
	  title() xtitle(Hiring Interest Rating, size(large)) yscale(titlegap(medium)) ///
	  ytitle(Pr(Hiring Interest {&le} x), size(large)) legend(row(1)) ylab(,nogrid labsize(medlarge)) xlab(, labsize(medlarge)) 
	graph export "$output/fig1_c.png", replace
	
	// d) Linear Probability Model for Second Job Type
	use "$data/Clean/IRRAnalysisFile_Penn.dta", clear

	gen threshold=_n if _n<11
	
	gen beta_wfm = .
	gen se_wfm = .
	
	gen beta_nj2 = .
	gen se_nj2 = .
		
	forvalues i=1(1)10 {
		gen callback = (rating_hire>=`i')
		qui reg callback wfm secondint, robust
		replace beta_wfm = _b[wfm] if _n==`i'
		replace se_wfm = _se[wfm] if _n==`i'
		
		replace beta_nj2 = _b[secondint] if _n==`i'
		replace se_nj2 = _se[secondint] if _n==`i'
		
		drop callback
	}
	gen seplot_lo_wfm = beta_wfm - 1.96*se_wfm
	gen seplot_hi_wfm = beta_wfm + 1.96*se_wfm
	
	gen seplot_lo_nj2 = beta_nj2 - 1.96*se_nj2
	gen seplot_hi_nj2 = beta_nj2 + 1.96*se_nj2
	
	gen threshlow = threshold - 0.05
	gen threshhi = threshold + 0.05

	twoway rspike seplot_lo_wfm seplot_hi_wfm threshlow if !mi(beta_wfm), col(gray) || scatter beta_wfm threshlow if !mi(beta_wfm), msym(S) col("$col2") || ///
		rspike seplot_lo_nj2 seplot_hi_nj2 threshhi if !mi(beta_nj2), col(gray) || scatter beta_nj2 threshhi if !mi(beta_nj2), msym(O) col("$col3") $allwhite ///
		title() ///
		legend(order(2 "Work for Money" 4 "Second Internship") row(1) region(style(none)) size(medlarge)) ///
		xtitle(Callback Threshold, size(large)) ytitle(Coefficient Estimate, size(large)) yscale(titlegap(medium)) ///
		yline(0, lcolor(gs10)) ylab(,nogrid labsize(medlarge)) xlab(, labsize(medlarge)) 
	graph export "$output/fig1_d.png", replace
}
	
	
	/*** Figure 2: Demographics by Major Type Over Selectivity Distribution ***/
{			
	// a) Empirical CDF: Not a White Male, Humanities & Social Sciences
	use "$data/Clean/IRRAnalysisFile_Penn.dta", clear
	sort rating_hire not_a_whitemale
	cumul rating_hire if not_a_whitemale==1 & majorHumSS==1, gen(cdf_1)
	cumul rating_hire if not_a_whitemale==0 & majorHumSS==1, gen(cdf_0)
	line cdf_0 rating_hire, c(J) col("$col1") || ///
	  line cdf_1 rating_hire, c(J) col("$col2") lp("-") ///
	  $allwhite ///
	  legend(label(1 "White Male") label(2 "Not a White Male") region(style(none)) size(medlarge)) ///
	  title() xtitle(Hiring Interest Rating, size(large)) yscale(titlegap(medium)) ///
	  ytitle(Pr(Hiring Interest {&le} x), size(large)) ylab(,nogrid labsize(medlarge)) xlab(, labsize(medlarge))
	graph export "$output/fig2_a.png", replace
		
	
	// b) Linear Probability Model: Not a White Male, Humanities & Social Sciences	
	use "$data/Clean/IRRAnalysisFile_Penn.dta", clear
	
	gen threshold=_n if _n<11
	
	gen beta = .
	gen se = .
	
	forvalues i=1(1)10 {
		gen callback = (rating_hire>=`i')
		qui reg callback not_a_whitemale if majorHumSS == 1, robust
		replace beta = _b[not_a_whitemale] if _n==`i'
		replace se = _se[not_a_whitemale] if _n==`i'
				
		drop callback
	}
	gen seplot_lo = beta - 1.96*se
	gen seplot_hi = beta + 1.96*se
	
	twoway rspike seplot_lo seplot_hi threshold if !mi(beta), col(gray) || ///
		scatter beta threshold if !mi(beta), $allwhite msym(S) col("$col2") ///
		title() ///
		legend(order(2 "Not a White Male") region(style(none)) size(medlarge)) ///
		xtitle(Callback Threshold, size(large)) ytitle(Coefficient Estimate, size(large)) ///
		ylab(,nogrid labsize(medlarge)) xlab(, labsize(medlarge)) yscale(titlegap(medium)) yline(0, lcolor(gs10))
	graph export "$output/fig2_b.png", replace
	
	
	// c) Empirical CDF: Not a White Male, STEM
	use "$data/Clean/IRRAnalysisFile_Penn.dta", clear
	sort rating_hire not_a_whitemale
	cumul rating_hire if not_a_whitemale==1 & majorHumSS==0, gen(cdf_1)
	cumul rating_hire if not_a_whitemale==0 & majorHumSS==0, gen(cdf_0)
	line cdf_0 rating_hire, c(J) col("$col1") || ///
	  line cdf_1 rating_hire, c(J) col("$col2") lp("-") ///
	  $allwhite ///
	  legend(label(1 "White Male") label(2 "Not a White Male") region(style(none)) size(medlarge)) ///
	  title() xtitle(Hiring Interest Rating, size(large)) yscale(titlegap(medium)) ///
	  ytitle(Pr(Hiring Interest {&le} x), size(large)) ylab(,nogrid labsize(medlarge)) xlab(, labsize(medlarge))
	graph export "$output/fig2_c.png", replace
	
	// d) Linear Probability Model: Not a White Male, STEM
	use "$data/Clean/IRRAnalysisFile_Penn.dta", clear
	
	gen threshold=_n if _n<11
	
	gen beta = .
	gen se = .
	
	forvalues i=1(1)10 {
		gen callback = (rating_hire>=`i')
		qui reg callback not_a_whitemale if majorHumSS ==0, robust
		replace beta = _b[not_a_whitemale] if _n==`i'
		replace se = _se[not_a_whitemale] if _n==`i'
				
		drop callback
	}
	gen seplot_lo = beta - 1.96*se
	gen seplot_hi = beta + 1.96*se
	
	twoway rspike seplot_lo seplot_hi threshold if !mi(beta), col(gray) || ///
		scatter beta threshold if !mi(beta), $allwhite msym(S) col("$col2") ///
		title() ///
		legend(order(2 "Not a White Male") region(style(none)) size(medlarge)) ///
		xtitle(Callback Threshold, size(large)) ytitle(Coefficient Estimate, size(large)) ///
		ylab(,nogrid labsize(medlarge)) xlab(, labsize(medlarge)) yscale(titlegap(medium)) yline(0, lcolor(gs10))
	graph export "$output/fig2_d.png", replace	
	
}		

	/***********************************/
	/*** Appendix B Tables & Figures ***/
	/***********************************/
	
	// Table B.1: Work Experience Narrative
{	
	use "$data/Clean/IRRAnalysisFile_Penn.dta", clear
	
	gen resumenarrative = (noNarrative==0 & hassecondjob==1)
	label variable resumenarrative "Narrative"
	
	// 1
	xi: reg rating_hire randgpa topemp secondint wfm techskills whitefemale nonwhite_male nonwhite_female resumenarrative imajor*, robust 
	est sto narr1
	estadd local subjfe "No"
	estadd local majorfe "Yes"
	estadd local orderfe "No"
	estadd local leadfe "No"

	unab imaj: imajor*
	test `imaj'		
	local pval: di %4.3f r(p)
	if (`pval' < 0.001) estadd local Ftest = "$<0.001$"
	else estadd local Ftest = "`pval'"	

	// 2
	xi: reg rating_hire randgpa topemp secondint wfm techskills whitefemale nonwhite_male nonwhite_female resumenarrative i.resumenumber imajor* i.lead1 i.lead2, robust 
	est sto narr2
	estadd local subjfe "No"
	estadd local majorfe "Yes"
	estadd local orderfe "Yes"
	estadd local leadfe "Yes"
	
	unab imaj: imajor*
	test `imaj'		
	local pval: di %4.3f r(p)
	if (`pval' < 0.001) estadd local Ftest = "$<0.001$"
	else estadd local Ftest = "`pval'"	
	
	// 3
	xi: reg rating_hire randgpa topemp secondint wfm techskills whitefemale nonwhite_male nonwhite_female resumenarrative i.resumenumber imajor* i.lead1 i.lead2, absorb(subjroundid) robust 
	est sto narr3
	estadd local subjfe "Yes"
	estadd local majorfe "Yes"
	estadd local orderfe "Yes"
	estadd local leadfe "Yes"
		
	unab imaj: imajor*
	test `imaj'		
	local pval: di %4.3f r(p)
	if (`pval' < 0.001) estadd local Ftest = "$<0.001$"
	else estadd local Ftest = "`pval'"	
	
	// 4 - Rescaled
	eststo narrative_rescaled: nlcom (randgpa: _b[randgpa]/_b[randgpa]) ///
		(topemp: _b[topemp]/_b[randgpa]) ///
		(secondint: _b[secondint]/_b[randgpa]) ///
		(wfm: _b[wfm]/_b[randgpa]) ///
		(techskills: _b[techskills]/_b[randgpa]) ///
		(whitefemale: _b[whitefemale]/_b[randgpa]) ///
		(nonwhite_male: _b[nonwhite_male]/_b[randgpa]) ///
		(nonwhite_female: _b[nonwhite_female]/_b[randgpa]) ///
		(resumenarrative: _b[resumenarrative]/_b[randgpa]) ///
		, post	
	if (`pval' < 0.001) estadd local Ftest = "$<0.001$"
		else estadd local Ftest = "`pval'"	
	estadd local majorfe "Yes"
	estadd local orderfe "Yes"
	estadd local leadfe "Yes"
	estadd local subjfe "Yes"
	
	// 5) Ordered Probit
	oprobit rating_hire randgpa topemp secondint wfm techskills whitefemale nonwhite_male nonwhite_female resumenarrative imajor*
	est sto narr4
	estadd local subjfe "No"
	estadd local majorfe "Yes"
	estadd local orderfe "No"
	estadd local leadfe "No"
	local cut1 = round(_b[/cut1], 0.01)
	local cut2 = round(_b[/cut2], 0.01)
	local cut3 = round(_b[/cut3], 0.01)
	local cut4 = round(_b[/cut4], 0.01)
	local cut5 = round(_b[/cut5], 0.01)
	local cut6 = round(_b[/cut6], 0.01)
	local cut7 = round(_b[/cut7], 0.01)
	local cut8 = round(_b[/cut8], 0.01)
	local cut9 = round(_b[/cut9], 0.01)
	
	oprobit rating_hire randgpa topemp secondint wfm techskills whitefemale nonwhite_male nonwhite_female resumenarrative  
	lrtest narr4
	local pval: di %4.3f r(p)
	if (`pval' < 0.001) estadd local Ftest = "$<0.001$" : narr4
	else estadd local Ftest = "`pval'" : narr4

	esttab narr1 narr2 narr3 narrative_rescaled narr4 using "$output/TableB1.tex", ///
		b(3) se(3) replace compress nofloat r2 ///
		mgroups("Dependent Variable: Hiring Interest", pattern(1 0 0 0 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
		mtitles("OLS" "OLS" "OLS" "\shortstack{GPA-Scaled\\OLS}" "\shortstack{Ordered\\Probit}") ///
		nonum label depvar nogaps noomitted $starglob ///
		keep(randgpa topemp secondint wfm techskills whitefemale nonwhite_male nonwhite_female resumenarrative) eqlabels(none) ///
		postfoot("\hline\hline \addlinespace \multicolumn{5}{l}{\footnotesize Ordered probit cutpoints: `cut1', `cut2', `cut3', `cut4', `cut5', `cut6', `cut7', `cut8', and `cut9'.} \end{tabular} $starending") ///
		scalars("Ftest \shortstack{\emph{p-value for test of joint}\\\emph{significance of Majors}}" "majorfe Major FEs" "leadfe Leadership FEs" "orderfe Order FEs" "subjfe Subject FEs") sfmt(%5.4fc)
}


	// Table B.2: Prestigious Schools (Engineering & Wharton)
{
	use "$data/Clean/IRRAnalysisFile_Penn.dta", clear
	gen eng = randschool == "School of Engineering and Applied Science" 
	replace wharton = 0 if mi(wharton) 
	label variable eng "School of Engineering"
	label variable wharton "Wharton" 
	
	// No controls
	xi: reg rating_hire randgpa topemp secondint wfm techskills whitefemale nonwhite_male nonwhite_female eng wharton majorHumSS  , robust 	
	est sto majoreng1
	estadd local majorfe "No"
	estadd local orderfe "No"
	estadd local leadfe "No"
	estadd local subjfe "No"
	
	// Leadership and order controls
	xi: reg rating_hire randgpa topemp secondint wfm techskills whitefemale nonwhite_male nonwhite_female eng wharton majorHumSS i.resumenumber i.lead1 i.lead2, robust 	
	est sto majoreng2
	estadd local majorfe "No"
	estadd local orderfe "Yes"
	estadd local leadfe "Yes"
	estadd local subjfe "No"
	
	// Add subject FEs
	xi: reg rating_hire randgpa topemp secondint wfm techskills whitefemale nonwhite_male nonwhite_female eng wharton majorHumSS i.resumenumber i.lead1 i.lead2, absorb(subjroundid) robust 	
	est sto majoreng3
	estadd local majorfe "No"
	estadd local orderfe "Yes"
	estadd local leadfe "Yes"
	estadd local subjfe "Yes"
	
	
	// 4) Rescaled wrt GPA
	eststo majoreng_rescale: nlcom (randgpa: _b[randgpa]/_b[randgpa]) ///
		(topemp: _b[topemp]/_b[randgpa]) ///
		(secondint: _b[secondint]/_b[randgpa]) ///
		(wfm: _b[wfm]/_b[randgpa]) ///
		(techskills: _b[techskills]/_b[randgpa]) ///
		(whitefemale: _b[whitefemale]/_b[randgpa]) ///
		(nonwhite_male: _b[nonwhite_male]/_b[randgpa]) ///
		(nonwhite_female: _b[nonwhite_female]/_b[randgpa]) ///
		(eng: _b[eng]/_b[randgpa]) ///
		(wharton: _b[wharton]/_b[randgpa]) ///
		, post	
	estadd local subjfe "Yes"
	estadd local majorfe "Yes"
	estadd local orderfe "Yes"
	estadd local leadfe "Yes"
	
	// Ordered Probit
	oprobit rating_hire randgpa topemp secondint wfm techskills whitefemale nonwhite_male nonwhite_female eng wharton majorHumSS, robust 	
	est sto majoreng4
	estadd local majorfe "No"
	estadd local orderfe "No"
	estadd local leadfe "No"
	estadd local subjfe "No"
	
	local cut1 = string(_b[/cut1], "%3.2f")
	local cut2 = string(_b[/cut2], "%3.2f")
	local cut3 = string(_b[/cut3], "%3.2f")
	local cut4 = string(_b[/cut4], "%3.2f")
	local cut5 = string(_b[/cut5], "%3.2f")
	local cut6 = string(_b[/cut6], "%3.2f")
	local cut7 = string(_b[/cut7], "%3.2f")
	local cut8 = string(_b[/cut8], "%3.2f")
	local cut9 = string(_b[/cut9], "%3.2f")
	
	esttab majoreng1 majoreng2 majoreng3 majoreng_rescale majoreng4 using "$output/TableB2.tex", ///
		b(3) se(3) replace compress nofloat r2 ///
		mgroups("\shortstack{Dependent Variable: Hiring Interest}", pattern(1 0 0 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
		mtitles("OLS" "OLS" "OLS" "\shortstack{GPA-Scaled\\OLS}" "\shortstack{Ordered\\Probit}") ///
		nonum label depvar nogaps noomitted $starglob ///
		postfoot("\hline\hline \addlinespace \multicolumn{6}{l}{\footnotesize Ordered probit cutpoints: `cut1', `cut2', `cut3', `cut4', `cut5', `cut6', `cut7', `cut8', and `cut9'.} \end{tabular} $starending") ///
		keep(randgpa whitefemale nonwhite_male nonwhite_female topemp secondint wfm techskills eng wharton) eqlabels(none) ///
		scalars("majorfe Major FEs" "leadfe Leadership FEs" "orderfe Order FEs" "subjfe Subject FEs") sfmt(%5.4fc)

}


	// Table B.3: Hiring Interest, Weighted by GPA
{
	use "$data/Clean/IRRAnalysisFile_Penn.dta", clear
		
	// Adding controls - WEIGHTED
	// 1) No Controls
	reg rating_hire randgpa topemp secondint wfm techskills whitefemale nonwhite_male nonwhite_female imajor* [pweight=gpaprob], robust 
	est sto ols_hire_penn_noctrlw

	estadd local subjfe "No"
	estadd local majorfe "Yes"
	estadd local orderfe "No"
	estadd local leadfe "No"
	
	unab imaj: imajor*
	test `imaj'		
	local pval: di %4.3f r(p)
	if (`pval' < 0.001) estadd local Ftest = "$<0.001$"
	else estadd local Ftest = "`pval'"
	
	// 2) Leadership, Order, Major FEs
	xi: reg rating_hire randgpa topemp secondint wfm techskills whitefemale nonwhite_male nonwhite_female i.resumenumber imajor* i.lead1 i.lead2 [pweight=gpaprob], robust 
	est sto ols_hire_penn_somectrlsw

	estadd local subjfe "No"
	estadd local majorfe "Yes"
	estadd local orderfe "Yes"
	estadd local leadfe "Yes"

	unab imaj: imajor*
	test `imaj'		
	local pval: di %4.3f r(p)
	if (`pval' < 0.001) estadd local Ftest = "$<0.001$"
	else estadd local Ftest = "`pval'"	
	
	// 3) All controls
	xi: reg rating_hire randgpa topemp secondint wfm techskills whitefemale nonwhite_male nonwhite_female i.resumenumber imajor* i.lead1 i.lead2 [pweight=gpaprob], absorb(subjroundid) robust 
	est sto ols_hire_penn_allctrlsw
	estadd local subjfe "Yes"
	estadd local majorfe "Yes"
	estadd local orderfe "Yes"
	estadd local leadfe "Yes"
	
	unab imaj: imajor*
	test `imaj'		
	local pval: di %4.3f r(p)
	if (`pval' < 0.001) estadd local Ftest = "$<0.001$"
	else estadd local Ftest = "`pval'"	
	
	
	// 4 - Rescaled
	eststo rescaled_w: nlcom (randgpa: _b[randgpa]/_b[randgpa]) ///
		(topemp: _b[topemp]/_b[randgpa]) ///
		(secondint: _b[secondint]/_b[randgpa]) ///
		(wfm: _b[wfm]/_b[randgpa]) ///
		(techskills: _b[techskills]/_b[randgpa]) ///
		(whitefemale: _b[whitefemale]/_b[randgpa]) ///
		(nonwhite_male: _b[nonwhite_male]/_b[randgpa]) ///
		(nonwhite_female: _b[nonwhite_female]/_b[randgpa]) ///
		, post	
	if (`pval' < 0.001) estadd local Ftest = "$<0.001$"
		else estadd local Ftest = "`pval'"	
	estadd local majorfe "Yes"
	estadd local orderfe "Yes"
	estadd local leadfe "Yes"
	estadd local subjfe "Yes"
	
	// 4) Ordered Probit
	oprobit rating_hire randgpa topemp secondint wfm techskills whitefemale nonwhite_male nonwhite_female imajor* [pweight=gpaprob]  
	est sto oprob_desir_pennw
	estadd local subjfe "No"
	estadd local majorfe "Yes"
	estadd local orderfe "No"
	estadd local leadfe "No"
	local cut1 = string(_b[/cut1], "%3.2f")
	local cut2 = string(_b[/cut2], "%3.2f")
	local cut3 = string(_b[/cut3], "%3.2f")
	local cut4 = string(_b[/cut4], "%3.2f")
	local cut5 = string(_b[/cut5], "%3.2f")
	local cut6 = string(_b[/cut6], "%3.2f")
	local cut7 = string(_b[/cut7], "%3.2f")
	local cut8 = string(_b[/cut8], "%3.2f")
	local cut9 = string(_b[/cut9], "%3.2f")
	
	unab imaj: imajor*
	test `imaj'		
	local pval: di %4.3f r(p)
	if (`pval' < 0.001) estadd local Ftest = "$<0.001$"
	else estadd local Ftest = "`pval'"	


	esttab ols_hire_penn_noctrlw ols_hire_penn_somectrlsw ols_hire_penn_allctrlsw rescaled_w oprob_desir_pennw using "$output/TableB3.tex", ///
		b(3) se(3) replace compress nofloat r2 ///
		mgroups("Dependent Variable: Hiring Interest", pattern(1 0 0 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
		mtitles("OLS" "OLS" "OLS" "\shortstack{GPA-Scaled\\OLS}" "\shortstack{Ordered\\Probit}") ///
		nonum label depvar nogaps noomitted $starglob ///
		keep(randgpa topemp secondint wfm techskills whitefemale nonwhite_male nonwhite_female) eqlabels(none) ///
		postfoot("\hline\hline \addlinespace \multicolumn{5}{l}{\footnotesize Ordered probit cutpoints: `cut1', `cut2', `cut3', `cut4', `cut5', `cut6', `cut7', `cut8', and `cut9'.} \end{tabular} $starending") ///
		scalars("Ftest \shortstack{\emph{p-value for test of joint}\\\emph{significance of Majors}}" "majorfe Major FEs" "leadfe Leadership FEs" "orderfe Order FEs" "subjfe Subject FEs") sfmt(%5.4fc)
	
}


	// Table B.4: Hiring Interest by Major Type, Weighted by GPA
{
	use "$data/Clean/IRRAnalysisFile_Penn.dta", clear

	/*** Hum/SS only ***/
	
	// 1) No Controls
	reg rating_hire randgpa topemp secondint wfm techskills whitefemale nonwhite_male nonwhite_female imajor* [pweight=gpaprob]if majorHumSS==1, robust 
	est sto hire_penn_noctrl_humw

	estadd local subjfe "No"
	estadd local majorfe "Yes"
	estadd local orderfe "No"
	estadd local leadfe "No"
	
	unab imaj: imajor*
	test `imaj'		
	local pval: di %4.3f r(p)*2
	if (`pval' < 0.001) estadd local Ftest = "$<0.001$"
	else estadd local Ftest = "`pval'"	
	
	// 2) Leadership, Order, Major FEs
	xi: reg rating_hire randgpa topemp secondint wfm techskills whitefemale nonwhite_male nonwhite_female i.resumenumber imajor* i.lead1 i.lead2 [pweight=gpaprob]if majorHumSS==1, robust 
	est sto hire_penn_somectrls_humw
	
	estadd local subjfe "No"
	estadd local majorfe "Yes"
	estadd local orderfe "Yes"
	estadd local leadfe "Yes"

	unab imaj: imajor*
	test `imaj'		
	local pval: di %4.3f r(p)*2
	if (`pval' < 0.001) estadd local Ftest = "$<0.001$"
	else estadd local Ftest = "`pval'"	
	
	// 3) All controls
	xi: reg rating_hire randgpa topemp secondint wfm techskills whitefemale nonwhite_male nonwhite_female i.resumenumber imajor* i.lead1 i.lead2 [pweight=gpaprob]if majorHumSS==1, absorb(subjroundid) robust 
	est sto hire_penn_allctrls_humw
	estadd local subjfe "Yes"
	estadd local majorfe "Yes"
	estadd local orderfe "Yes"
	estadd local leadfe "Yes"
	
	unab imaj: imajor*
	test `imaj'		
	local pval: di %4.3f r(p)*2
	if (`pval' < 0.001) estadd local Ftest = "$<0.001$"
	else estadd local Ftest = "`pval'"	
	
	// 4) Rescaled wrt GPA
	eststo ols_penn_rescaled_humw: nlcom (randgpa: _b[randgpa]/_b[randgpa]) ///
		(topemp: _b[topemp]/_b[randgpa]) ///
		(secondint: _b[secondint]/_b[randgpa]) ///
		(wfm: _b[wfm]/_b[randgpa]) ///
		(techskills: _b[techskills]/_b[randgpa]) ///
		(whitefemale: _b[whitefemale]/_b[randgpa]) ///
		(nonwhite_male: _b[nonwhite_male]/_b[randgpa]) ///
		(nonwhite_female: _b[nonwhite_female]/_b[randgpa]) ///
		, post	
	if (`pval' < 0.001) estadd local Ftest = "$<0.001$"
		else estadd local Ftest = "`pval'"	
	estadd local subjfe "Yes"
	estadd local majorfe "Yes"
	estadd local orderfe "Yes"
	estadd local leadfe "Yes"
	
	// 5) Ordered Probit
	oprobit rating_hire randgpa topemp secondint wfm techskills whitefemale nonwhite_male nonwhite_female imajor* [pweight=gpaprob]if majorHumSS==1
	est sto oprob_desir_penn_humw
	estadd local subjfe "No"
	estadd local majorfe "Yes"
	estadd local orderfe "No"
	estadd local leadfe "No"
	local cut1humw = string(_b[/cut1], "%3.2f")
	local cut2humw = string(_b[/cut2], "%3.2f")
	local cut3humw = string(_b[/cut3], "%3.2f")
	local cut4humw = string(_b[/cut4], "%3.2f")
	local cut5humw = string(_b[/cut5], "%3.2f")
	local cut6humw = string(_b[/cut6], "%3.2f")
	local cut7humw = string(_b[/cut7], "%3.2f")
	local cut8humw = string(_b[/cut8], "%3.2f")
	local cut9humw = string(_b[/cut9], "%3.2f")
	unab imaj: imajor*
	test `imaj'		
	local pval: di %4.3f r(p)*2
	if (`pval' < 0.001) estadd local Ftest = "$<0.001$"
	else estadd local Ftest = "`pval'"	
		
		
	/*** Science only ***/

	// 6) No Controls
	reg rating_hire randgpa topemp secondint wfm techskills whitefemale nonwhite_male nonwhite_female imajor* [pweight=gpaprob]if majorHumSS==0, robust 
	est sto hire_penn_noctrl_sciw

	estadd local subjfe "No"
	estadd local majorfe "Yes"
	estadd local orderfe "No"
	estadd local leadfe "No"
	
	unab imaj: imajor*
	test `imaj'		
	local pval: di %4.3f r(p)*2
	if (`pval' < 0.001) estadd local Ftest = "$<0.001$"
	else estadd local Ftest = "`pval'"	
	
	// 7) Leadership, Order, Major FEs
	xi: reg rating_hire randgpa topemp secondint wfm techskills whitefemale nonwhite_male nonwhite_female i.resumenumber imajor* i.lead1 i.lead2 [pweight=gpaprob]if majorHumSS==0, robust 
	est sto hire_penn_somectrls_sciw

	estadd local subjfe "No"
	estadd local majorfe "Yes"
	estadd local orderfe "Yes"
	estadd local leadfe "Yes"

	unab imaj: imajor*
	test `imaj'		
	local pval: di %4.3f r(p)*2
	if (`pval' < 0.001) estadd local Ftest = "$<0.001$"
	else estadd local Ftest = "`pval'"	
	
	// 8) All controls
	xi: reg rating_hire randgpa topemp secondint wfm techskills whitefemale nonwhite_male nonwhite_female i.resumenumber imajor* i.lead1 i.lead2 [pweight=gpaprob]if majorHumSS==0, absorb(subjroundid) robust 
	est sto hire_penn_allctrls_sciw
	estadd local subjfe "Yes"
	estadd local majorfe "Yes"
	estadd local orderfe "Yes"
	estadd local leadfe "Yes"
	
	unab imaj: imajor*
	test `imaj'		
	local pval: di %4.3f r(p)*2
	if (`pval' < 0.001) estadd local Ftest = "$<0.001$"
	else estadd local Ftest = "`pval'"	
	
	// 9) Rescaled wrt GPA
	eststo ols_penn_rescaled_sciw: nlcom (randgpa: _b[randgpa]/_b[randgpa]) ///
		(topemp: _b[topemp]/_b[randgpa]) ///
		(secondint: _b[secondint]/_b[randgpa]) ///
		(wfm: _b[wfm]/_b[randgpa]) ///
		(techskills: _b[techskills]/_b[randgpa]) ///
		(whitefemale: _b[whitefemale]/_b[randgpa]) ///
		(nonwhite_male: _b[nonwhite_male]/_b[randgpa]) ///
		(nonwhite_female: _b[nonwhite_female]/_b[randgpa]) ///
		, post	
	if (`pval' < 0.001) estadd local Ftest = "$<0.001$"
		else estadd local Ftest = "`pval'"	
	estadd local subjfe "Yes"
	estadd local majorfe "Yes"
	estadd local orderfe "Yes"
	estadd local leadfe "Yes"
	
	// 10) Ordered Probit
	oprobit rating_hire randgpa topemp secondint wfm techskills whitefemale nonwhite_male nonwhite_female imajor* [pweight=gpaprob]if majorHumSS==0
	est sto oprob_desir_penn_sciw
	estadd local subjfe "No"
	estadd local majorfe "Yes"
	estadd local orderfe "No"
	estadd local leadfe "No"
	local cut1sciw = string(_b[/cut1], "%3.2f")
	local cut2sciw = string(_b[/cut2], "%3.2f")
	local cut3sciw = string(_b[/cut3], "%3.2f")
	local cut4sciw = string(_b[/cut4], "%3.2f")
	local cut5sciw = string(_b[/cut5], "%3.2f")
	local cut6sciw = string(_b[/cut6], "%3.2f")
	local cut7sciw = string(_b[/cut7], "%3.2f")
	local cut8sciw = string(_b[/cut8], "%3.2f")
	local cut9sciw = string(_b[/cut9], "%3.2f")
	unab imaj: imajor*
	test `imaj'		
	local pval: di %4.3f r(p)*2
	if (`pval' < 0.001) estadd local Ftest = "$<0.001$"
	else estadd local Ftest = "`pval'"	

	esttab hire_penn_noctrl_humw hire_penn_somectrls_humw hire_penn_allctrls_humw ols_penn_rescaled_humw oprob_desir_penn_humw ///
			hire_penn_noctrl_sciw hire_penn_somectrls_sciw hire_penn_allctrls_sciw ols_penn_rescaled_sciw oprob_desir_penn_sciw using "$output/TableB4.tex", ///
		b(3) se(3) replace compress nofloat r2 ///
		nomtitles varwidth(15) ///
		nonum label depvar nogaps noomitted $starglob ///
		keep(randgpa topemp secondint wfm techskills whitefemale nonwhite_male nonwhite_female) eqlabels(none) ///
		prehead("{\def\sym#1{\ifmmode^{#1}\else\(^{#1}\)\fi} \begin{tabular}{l*{10}{c}} \hline\hline & \multicolumn{10}{c}{Dependent Variable: Hiring Interest} \\ & \multicolumn{5}{c}{Humanities \& Social Sciences} & \multicolumn{5}{c}{STEM} \\ \cmidrule(lr){2-6}  \cmidrule(lr){7-11} & OLS & OLS & OLS & \shortstack{GPA-Scaled\\OLS} & \shortstack{Ordered\\Probit} & OLS & OLS & OLS & \shortstack{GPA-Scaled\\OLS} & \shortstack{Ordered\\Probit} \\") ///
		prefoot("\hline") ///
		postfoot("\hline\hline \addlinespace \multicolumn{9}{l}{\footnotesize Ordered probit cutpoints (Column 5): `cut1humw', `cut2humw', `cut3humw', `cut4humw', `cut5humw', `cut6humw', `cut7humw', `cut8humw', `cut9humw'.} \\ \multicolumn{9}{l}{\footnotesize Ordered probit cutpoints (Column 10): `cut1sciw', `cut2sciw', `cut3sciw', `cut4sciw', `cut5sciw', `cut6sciw', `cut7sciw', `cut8sciw', `cut9sciw'.} \end{tabular} }") ///
		scalars("Ftest \shortstack{\emph{p-value for test of joint}\\\emph{\quad significance of Majors}}" ///
			"line \hline%" "majorfe Major FEs" "leadfe Leadership FEs" "orderfe Order FEs" "subjfe Subject FEs") sfmt(%5.4fc)		
			
}


	// Table B.5: Likelihood of Acceptance, Weighted by GPA
{
	use "$data/Clean/IRRAnalysisFile_Penn.dta", clear
		
	// 1) No Controls
	reg rating_accept randgpa topemp secondint wfm techskills whitefemale nonwhite_male nonwhite_female imajor* [pweight=gpaprob], robust 
	est sto ols_acc_penn_noctrlw

	estadd local subjfe "No"
	estadd local majorfe "Yes"
	estadd local orderfe "No"
	estadd local leadfe "No"
		
	unab imaj: imajor*
	test `imaj'		
	local pval: di %4.3f r(p)
	if (`pval' < 0.001) estadd local Ftest = "$<0.001$"
	else estadd local Ftest = "`pval'"	
	
	
	// 2) Leadership, Order, Major FEs
	xi: reg rating_accept randgpa topemp secondint wfm techskills whitefemale nonwhite_male nonwhite_female i.resumenumber imajor* i.lead1 i.lead2 [pweight=gpaprob], robust 
	est sto ols_acc_penn_somectrlsw

	estadd local subjfe "No"
	estadd local majorfe "Yes"
	estadd local orderfe "Yes"
	estadd local leadfe "Yes"

	unab imaj: imajor*
	test `imaj'		
	estadd local Ftest = "$<0.001$"
	
	// 4) All controls
	xi: reg rating_accept randgpa topemp secondint wfm techskills whitefemale nonwhite_male nonwhite_female i.resumenumber imajor* i.lead1 i.lead2 [pweight=gpaprob], absorb(subjroundid) robust 
	est sto ols_acc_penn_allctrlsw
	estadd local subjfe "Yes"
	estadd local majorfe "Yes"
	estadd local orderfe "Yes"
	estadd local leadfe "Yes"
	
	unab imaj: imajor*
	test `imaj'
	estadd local Ftest = "$<0.001$"
	
	// Ordered Probit - Acceptance
	oprobit rating_accept randgpa topemp secondint wfm techskills whitefemale nonwhite_male nonwhite_female imajor* [pweight=gpaprob] 
	est sto oprob_acc_pennw
	estadd local subjfe "No"
	estadd local majorfe "Yes"
	estadd local orderfe "No"
	estadd local leadfe "No"
	estadd local Ftest = ""
	local cut1 = string(_b[/cut1], "%3.2f")
	local cut2 = string(_b[/cut2], "%3.2f")
	local cut3 = string(_b[/cut3], "%3.2f")
	local cut4 = string(_b[/cut4], "%3.2f")
	local cut5 = string(_b[/cut5], "%3.2f")
	local cut6 = string(_b[/cut6], "%3.2f")
	local cut7 = string(_b[/cut7], "%3.2f")
	local cut8 = string(_b[/cut8], "%3.2f")
	local cut9 = string(_b[/cut9], "%3.2f")
	
	unab imaj: imajor*
	test `imaj'		
	local pval: di %4.3f r(p)
	if (`pval' < 0.001) estadd local Ftest = "$<0.001$"
	else estadd local Ftest = "`pval'"	
	
	esttab ols_acc_penn_noctrlw ols_acc_penn_somectrlsw ols_acc_penn_allctrlsw oprob_acc_pennw using "$output/TableB5.tex", ///
		b(3) se(3) replace compress nofloat r2 ///
		mgroups("\shortstack{Dependent Variable:\\Likelihood of Acceptance}", pattern(1 0 0 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
		mtitles("OLS" "OLS" "OLS" "\shortstack{Ordered\\Probit}") ///
		nonum label depvar nogaps noomitted $starglob ///
		keep(randgpa topemp secondint wfm techskills whitefemale nonwhite_male nonwhite_female) eqlabels(none) ///
		postfoot("\hline\hline \addlinespace \multicolumn{5}{l}{\footnotesize Ordered probit cutpoints: `cut1', `cut2', `cut3', `cut4', `cut5', `cut6', `cut7', `cut8', and `cut9'.} \end{tabular} $starending") ///
		scalars("Ftest \shortstack{\emph{p-value for test of joint}\\\emph{significance of Majors}}" "majorfe Major FEs" "leadfe Leadership FEs" "orderfe Order FEs" "subjfe Subject FEs") sfmt(%5.4fc)
		
}

	
	// Table B.6: Hiring Interest by Rater Demographics
{
	use "$data/Clean/IRRAnalysisFile_Penn.dta", clear

	// Column 1: All Raters
	xi: reg rating_hire randgpa topemp secondint wfm techskills whitefemale nonwhite_male nonwhite_female i.resumenumber imajor* i.lead1 i.lead2, absorb(subjroundid) robust 
	est sto hire_all
	estadd local subjfe "Yes"
	estadd local majorfe "Yes"
	estadd local orderfe "Yes"
	estadd local leadfe "Yes"
	
	// Column 2: Female Raters
	xi: reg rating_hire randgpa topemp secondint wfm techskills whitefemale nonwhite_male nonwhite_female i.resumenumber imajor* i.lead1 i.lead2 if rater_female==1, absorb(subjroundid) robust 
	est sto hire_fem
	estadd local subjfe "Yes"
	estadd local majorfe "Yes"
	estadd local orderfe "Yes"
	estadd local leadfe "Yes"

	// Column 3: Male Raters
	xi: reg rating_hire randgpa topemp secondint wfm techskills whitefemale nonwhite_male nonwhite_female i.resumenumber imajor* i.lead1 i.lead2 if rater_female==0, absorb(subjroundid) robust 
	est sto hire_male
	estadd local subjfe "Yes"
	estadd local majorfe "Yes"
	estadd local orderfe "Yes"
	estadd local leadfe "Yes" 

	// Column 4: Non-White Raters
	xi: reg rating_hire randgpa topemp secondint wfm techskills whitefemale nonwhite_male nonwhite_female i.resumenumber imajor* i.lead1 i.lead2 if rater_ethnicity!=2, absorb(subjroundid) robust 
	est sto hire_nw
	estadd local subjfe "Yes"
	estadd local majorfe "Yes"
	estadd local orderfe "Yes"
	estadd local leadfe "Yes"

	// Column 5: White Raters
	xi: reg rating_hire randgpa topemp secondint wfm techskills whitefemale nonwhite_male nonwhite_female i.resumenumber imajor* i.lead1 i.lead2 if rater_ethnicity==2, absorb(subjroundid) robust 
	est sto hire_white
	estadd local subjfe "Yes"
	estadd local majorfe "Yes"
	estadd local orderfe "Yes"
	estadd local leadfe "Yes"

	esttab hire_all hire_fem hire_male hire_nw hire_white using "$output/TableB6.tex", ///
		b(3) se(3) replace compress nofloat r2 ///
		prehead("{\def\sym#1{\ifmmode^{#1}\else\(^{#1}\)\fi} \begin{tabular}{l*{5}{c}} \hline\hline & \multicolumn{4}{c}{Dependent Variable: Hire Rating} \\ & & \multicolumn{2}{c}{Rater Gender} & \multicolumn{2}{c}{Rater Race} \\ \cmidrule(lr){3-4}  \cmidrule(lr){5-6} \\") ///
		mtitles("All" "\shortstack{Female\\Raters}" "\shortstack{Male\\Raters}" "\shortstack{Non-White\\Raters}" "\shortstack{White\\Raters}") ///
		nonum label depvar nogaps noomitted $starglob ///
		keep(randgpa topemp secondint wfm techskills whitefemale nonwhite_male nonwhite_female) eqlabels(none) ///
		postfoot("\hline\hline \addlinespace \end{tabular} }") ///
		scalars("line \hline%""majorfe Major FEs" "leadfe Leadership FEs" "orderfe Order FEs" "subjfe Subject FEs" ) sfmt(%5.4fc)

}


	// Table B.7: Implicit Bias 
{
	use "$data/Clean/IRRAnalysisFile_Penn.dta", clear
	gen withinblock = mod(resumenumber, 10)
	replace withinblock = 10 if withinblock == 0
	gen last5inblock = withinblock > 5
	gen last20 = resumenumber > 20
	label variable last5inblock "Latter Half of Block"
	label variable last20 "Second Half of Study"
	
	gen rt_submit_wins95 = timing_pagesubmit
	qui sum timing_pagesubmit, d
	replace rt_submit_wins95 = r(p95) if timing_pagesubmit> r(p95)
	
	qui sum rt_submit_wins95
	local rtw95_mean = string(r(mean), "%3.2f")
	di "`rtw95_mean'"
	
	reg rt_submit_wins95 last5inblock randgpa topemp secondint wfm techskills not_a_whitemale imajor* i.lead1 i.lead2, absorb(subjroundid) robust 
	est sto rt95_inblock
	estadd local subjfe "Yes"
	estadd local majorfe "Yes"
	estadd local orderfe "No"
	estadd local leadfe "Yes"
	estadd local meanrt "`rtw95_mean'"
	unab imaj: imajor*
	test `imaj'		
	local pval: di %4.3f r(p)
	if (`pval' < 0.001) estadd local Ftest = "$<0.001$"
	else estadd local Ftest = "`pval'"	

	
	reg rt_submit_wins95 last20 randgpa topemp secondint wfm techskills not_a_whitemale imajor* i.lead1 i.lead2, absorb(subjroundid) robust 
	est sto rt95_last20
	estadd local subjfe "Yes"
	estadd local majorfe "Yes"
	estadd local orderfe "No"
	estadd local leadfe "Yes"
	estadd local meanrt "`rtw95_mean'"
	unab imaj: imajor*
	test `imaj'		
	local pval: di %4.3f r(p)
	if (`pval' < 0.001) estadd local Ftest = "$<0.001$"
	else estadd local Ftest = "`pval'"	

	
	
	reg rating_hire c.last5inblock##c.not_a_whitemale randgpa topemp secondint wfm techskills imajor* i.lead1 i.lead2, absorb(subjroundid) robust 
	est sto rating_inblock
	estadd local subjfe "Yes"
	estadd local majorfe "Yes"
	estadd local orderfe "No"
	estadd local leadfe "Yes"
	unab imaj: imajor*
	test `imaj'		
	local pval: di %4.3f r(p)
	if (`pval' < 0.001) estadd local Ftest = "$<0.001$"
	else estadd local Ftest = "`pval'"	
	

	reg rating_hire c.last20##c.not_a_whitemale randgpa topemp secondint wfm techskills not_a_whitemale imajor* i.lead1 i.lead2, absorb(subjroundid) robust 
	est sto rating_last20
	estadd local subjfe "Yes"
	estadd local majorfe "Yes"
	estadd local orderfe "No"
	estadd local leadfe "Yes"
	unab imaj: imajor*
	test `imaj'		
	local pval: di %4.3f r(p)
	if (`pval' < 0.001) estadd local Ftest = "$<0.001$"
	else estadd local Ftest = "`pval'"	
	
	
	esttab rt95_inblock rt95_last20 rating_inblock rating_last20 using "$output/TableB7.tex", ///
		b(3) se(3) replace compress nofloat r2 ///
		mgroups("\shortstack{Dependent Variable:\\Response Time}" "\shortstack{Dependent Variable:\\Hiring Interest}", pattern(1 0 1 0) prefix(\multicolumn{@span}{c}{) suffix(}) span ) ///
		nomtitles ///
		nonum label depvar nogaps noomitted $starglob ///
		postfoot("\hline\hline \end{tabular} $starending") ///
		keep(*last5inblock* *last20* randgpa topemp secondint wfm techskills *not_a_whitemale*) eqlabels(none) ///
		order(last5inblock last20 *not_a_whitemale*) interaction(" $\times$\\\hspace{3mm}") ///
		scalars("Ftest \shortstack{\emph{p-value for test of joint}\\\emph{significance of Majors}}" "majorfe Major FEs" "leadfe Leadership FEs" "orderfe Order FEs" "subjfe Subject FEs") sfmt(%5.4fc)
   
}   


	// Table B.8: Top Internship x Demographics 
{
	use "$data/Clean/IRRAnalysisFile_Penn.dta", clear
	gen topxwf = topemp*whitefemale
	gen topxnwm = topemp*nonwhite_male
	gen topxnwf = topemp*nonwhite_female
	label variable topxwf "\shortstack[l]{Top Internship $\times$\\ \quad Female, White}"
	label variable topxnwm "\shortstack[l]{Top Internship $\times$\\ \quad Male, Non-White}"
	label variable topxnwf "\shortstack[l]{Top Internship $\times$\\ \quad Female, Non-White}"

	// 1) No Controls
	xi: reg rating_hire randgpa topemp whitefemale nonwhite_male nonwhite_female topxwf topxnwm topxnwf secondint wfm techskills imajor*, robust 
	est sto ols_topxnwm_noctrls
	estadd local subjfe "No"
	estadd local majorfe "Yes"
	estadd local orderfe "No"
	estadd local leadfe "No"
	
	unab imaj: imajor*
	test `imaj'		
	local pval: di %4.3f r(p)
	if (`pval' < 0.001) estadd local Ftest = "$<0.001$"
	else estadd local Ftest = "`pval'"
	
	
	// 2) Some controls
	xi: reg rating_hire randgpa topemp whitefemale nonwhite_male nonwhite_female topxwf topxnwm topxnwf secondint wfm techskills i.resumenumber imajor* i.lead1 i.lead2, robust 
	est sto ols_topxnwm_somectrls
	estadd local subjfe "No"
	estadd local majorfe "Yes"
	estadd local orderfe "Yes"
	estadd local leadfe "Yes"
	
	unab imaj: imajor*
	test `imaj'		
	local pval: di %4.3f r(p)
	if (`pval' < 0.001) estadd local Ftest = "$<0.001$"
	else estadd local Ftest = "`pval'"
	
	// 3) All controls
	xi: reg rating_hire randgpa topemp whitefemale nonwhite_male nonwhite_female topxwf topxnwm topxnwf secondint wfm techskills i.resumenumber imajor* i.lead1 i.lead2, absorb(subjroundid) robust 
	est sto ols_topxnwm_allctrls
	estadd local subjfe "Yes"
	estadd local majorfe "Yes"
	estadd local orderfe "Yes"
	estadd local leadfe "Yes"
	
	unab imaj: imajor*
	test `imaj'		
	local pval: di %4.3f r(p)
	if (`pval' < 0.001) estadd local Ftest = "$<0.001$"
	else estadd local Ftest = "`pval'"
	
	// 4 - Rescaled
	eststo topxnwm_rescaled: nlcom (randgpa: _b[randgpa]/_b[randgpa]) ///
		(topemp: _b[topemp]/_b[randgpa]) ///
		(secondint: _b[secondint]/_b[randgpa]) ///
		(wfm: _b[wfm]/_b[randgpa]) ///
		(techskills: _b[techskills]/_b[randgpa]) ///
		(whitefemale: _b[whitefemale]/_b[randgpa]) ///
		(nonwhite_male: _b[nonwhite_male]/_b[randgpa]) ///
		(nonwhite_female: _b[nonwhite_female]/_b[randgpa]) ///
		(topxwf: _b[topxwf]/_b[randgpa]) ///
		(topxnwm: _b[topxnwm]/_b[randgpa]) ///
		(topxnwf: _b[topxnwf]/_b[randgpa]) ///
		, post	
	if (`pval' < 0.001) estadd local Ftest = "$<0.001$"
		else estadd local Ftest = "`pval'"	
	estadd local majorfe "Yes"
	estadd local orderfe "Yes"
	estadd local leadfe "Yes"
	estadd local subjfe "Yes"
	
	// 5) Ordered probit
	oprobit rating_hire randgpa topemp whitefemale nonwhite_male nonwhite_female topxwf topxnwm topxnwf secondint wfm imajor* techskills 
	est sto oprobit_topxnwm
	estadd local subjfe "No"
	estadd local majorfe "Yes"
	estadd local orderfe "No"
	estadd local leadfe "No"
	local cut1 = round(_b[/cut1], 0.01)
	local cut2 = round(_b[/cut2], 0.01)
	local cut3 = round(_b[/cut3], 0.01)
	local cut4 = round(_b[/cut4], 0.01)
	local cut5 = round(_b[/cut5], 0.01)
	local cut6 = round(_b[/cut6], 0.01)
	local cut7 = round(_b[/cut7], 0.01)
	local cut8 = round(_b[/cut8], 0.01)
	local cut9 = round(_b[/cut9], 0.01)
	
	oprobit rating_hire randgpa c.topemp##c.whitefemale c.topemp#c.nonwhite_male c.topemp#c.nonwhite_female secondint wfm techskills 
	lrtest oprobit_topxnwm
	local pval: di %4.3f r(p)
	if (`pval' < 0.001) estadd local Ftest = "$<0.001$" : oprobit_topxnwm
	else estadd local Ftest = "`pval'" : oprobit_topxnwm
	
	esttab ols_topxnwm_noctrls ols_topxnwm_somectrls ols_topxnwm_allctrls topxnwm_rescaled oprobit_topxnwm using "$output/TableB8.tex", ///
		b(3) se(3) replace compress nofloat r2 ///
		mgroups("Dependent Variable: Hiring Interest", pattern(1 0 0 0 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
		mtitles("OLS" "OLS" "OLS" "\shortstack{GPA-Scaled\\OLS}" "\shortstack{Ordered\\Probit}") ///
		postfoot("\hline\hline \addlinespace \multicolumn{6}{l}{\footnotesize Ordered probit cutpoints: `cut1', `cut2', `cut3', `cut4', `cut5', `cut6', `cut7', `cut8', and `cut9'.} \end{tabular} $starending") ///
		nonum label depvar nogaps noomitted $starglob ///
		eqlabels(none) ///
		keep(randgpa topemp secondint wfm techskills whitefemale nonwhite_male nonwhite_female topemp topxwf topxnwm topxnwf) ///
		order(randgpa topemp secondint wfm techskills whitefemale nonwhite_male nonwhite_female topemp topxwf topxnwm topxnwf) ///
		scalars("Ftest \shortstack{\emph{p-value for test of joint}\\\emph{significance of Majors}}" "majorfe Major FEs" "leadfe Leadership FEs" "orderfe Order FEs" "subjfe Subject FEs") sfmt(%5.4fc)
	
	
}


	// Table B9: Likelihood of Acceptance, controlling for Hire Rating 
{	
	use "$data/Clean/IRRAnalysisFile_Penn.dta", clear
	label variable rating_hire "Hiring Interest"
	
	// 1) All controls - linear rating_hire
	xi: reg rating_accept randgpa topemp secondint wfm techskills whitefemale nonwhite_male nonwhite_female rating_hire i.resumenumber imajor* i.lead1 i.lead2, absorb(subjroundid) robust 
	est sto ols_acc_linctrl
	estadd local hirefe "No"
	estadd local subjfe "Yes"
	estadd local majorfe "Yes"
	estadd local orderfe "Yes"
	estadd local leadfe "Yes"
	
	unab imaj: imajor*
	test `imaj'		
	local pval: di %4.3f r(p)
	if (`pval' < 0.001) estadd local Ftest = "$<0.001$"
	else estadd local Ftest = "`pval'"	
	
	// 2) Ordered Probit - Acceptance - linear rating_hire
	oprobit rating_accept randgpa topemp secondint wfm techskills whitefemale nonwhite_male nonwhite_female rating_hire imajor*  
	est sto oprob_acc_linctrl
	estadd local hirefe "No"
	estadd local subjfe "No"
	estadd local majorfe "Yes"
	estadd local orderfe "No"
	estadd local leadfe "No"
	
	local cut1_lin : di %3.2f _b[/cut1]
	local cut2_lin = string(_b[/cut2], "%3.2f")
	local cut3_lin = string(_b[/cut3], "%3.2f")
	local cut4_lin = string(_b[/cut4], "%3.2f")
	local cut5_lin = string(_b[/cut5], "%3.2f")
	local cut6_lin = string(_b[/cut6], "%3.2f")
	local cut7_lin = string(_b[/cut7], "%3.2f")
	local cut8_lin = string(_b[/cut8], "%3.2f")
	local cut9_lin = string(_b[/cut9], "%3.2f")
	
	unab imaj: imajor*
	test `imaj'		
	local pval: di %4.3f r(p)
	if (`pval' < 0.001) estadd local Ftest = "$<0.001$"
	else estadd local Ftest = "`pval'"	
	
	// 3) All controls - rating_hire FE
	xi: reg rating_accept randgpa topemp secondint wfm techskills whitefemale nonwhite_male nonwhite_female i.rating_hire i.resumenumber imajor* i.lead1 i.lead2, absorb(subjroundid) robust 
	est sto ols_acc_hirefe
	estadd local hirefe "Yes"
	estadd local subjfe "Yes"
	estadd local majorfe "Yes"
	estadd local orderfe "Yes"
	estadd local leadfe "Yes"
	
	unab imaj: imajor*
	test `imaj'		
	local pval: di %4.3f r(p)
	if (`pval' < 0.001) estadd local Ftest = "$<0.001$"
	else estadd local Ftest = "`pval'"	
	
	// 4) Ordered Probit - Acceptance - rating_hire FE
	oprobit rating_accept randgpa topemp secondint wfm techskills whitefemale nonwhite_male nonwhite_female imajor* i.rating_hire  
	est sto oprob_acc_hirefe
	estadd local hirefe "Yes"
	estadd local subjfe "No"
	estadd local majorfe "Yes"
	estadd local orderfe "No"
	estadd local leadfe "No"
	local cut1_fe = string(_b[/cut1], "%3.2f")
	local cut2_fe = string(_b[/cut2], "%3.2f")
	local cut3_fe = string(_b[/cut3], "%3.2f")
	local cut4_fe = string(_b[/cut4], "%3.2f")
	local cut5_fe = string(_b[/cut5], "%3.2f")
	local cut6_fe = string(_b[/cut6], "%3.2f")
	local cut7_fe = string(_b[/cut7], "%3.2f")
	local cut8_fe = string(_b[/cut8], "%3.2f")
	local cut9_fe = string(_b[/cut9], "%3.2f")
	
	unab imaj: imajor*
	test `imaj'		
	local pval: di %4.3f r(p)
	if (`pval' < 0.001) estadd local Ftest = "$<0.001$"
	else estadd local Ftest = "`pval'"	

	esttab ols_acc_linctrl oprob_acc_linctrl ols_acc_hirefe oprob_acc_hirefe using "$output/TableB9.tex", ///
		b(3) se(3) replace compress nofloat r2 ///
		mgroups("\shortstack{Dependent Variable:\\Likelihood of Acceptance}", pattern(1 0 0 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
		mtitles("OLS" "\shortstack{Ordered\\Probit}" "OLS" "\shortstack{Ordered\\Probit}") ///
		nonum label depvar nogaps noomitted $starglob ///
		keep(randgpa topemp secondint wfm techskills whitefemale nonwhite_male nonwhite_female rating_hire) eqlabels(none) ///
		order(randgpa topemp secondint wfm techskills whitefemale nonwhite_male nonwhite_female rating_hire) ///
		postfoot("\hline\hline \addlinespace \multicolumn{5}{l}{\footnotesize \shortstack{Cutpoints (Col 2): `cut1_lin', `cut2_lin', `cut3_lin', `cut4_lin', `cut5_lin', `cut6_lin', `cut7_lin', `cut8_lin', `cut9_lin'.\\Cutpoints (Col 4): `cut1_fe', `cut2_fe', `cut3_fe', `cut4_fe', `cut5_fe', `cut6_fe', `cut7_fe', `cut8_fe', `cut9_fe'.}} \end{tabular} $starending") ///
		scalars("Ftest \shortstack{\emph{p-value for test of joint}\\\emph{significance of Majors}}" "majorfe Major FEs" "leadfe Leadership FEs" "orderfe Order FEs" "subjfe Subject FEs") sfmt(%5.4fc)
		// indicate("Hiring Interest FEs = _Irating_hi*" "Hiring Interest Linear Control = rating_hire")  
}


	// Figure B.1: Wharton
{
	// a) Empirical CDF
	use "$data/Clean/IRRAnalysisFile_Penn.dta", clear
	sort rating_hire wharton
	cumul rating_hire if wharton==1, gen(cdf_wharton1)
	cumul rating_hire if wharton==0, gen(cdf_wharton0)
	line cdf_wharton0 rating_hire, c(J) col("$col1") || ///
	  line cdf_wharton1 rating_hire, c(J) col("$col2") lp("-") ///
	  $allwhite ///
	  legend(label(1 "Other Humanities/Social Sciences") label(2 "Wharton") region(style(none)) size(medlarge)) ///
	  title() xtitle(Hiring Interest Rating, size(large)) yscale(titlegap(medium)) ///
	  ytitle(Pr(Hiring Interest {&le} x), size(large)) ylab(,nogrid labsize(medlarge)) xlab(, labsize(medlarge)) 
	graph export "$output/figb1_a.png", replace
	
	// b) Linear Probability Model
	use "$data/Clean/IRRAnalysisFile_Penn.dta", clear
	
	gen threshold=_n if _n<11
	
	gen beta = .
	gen se = .
	
	forvalues i=1(1)10 {
		gen callback = (rating_hire>=`i')
		qui reg callback wharton, robust
		replace beta = _b[wharton] if _n==`i'
		replace se = _se[wharton] if _n==`i'
				
		drop callback
	}
	gen seplot_lo = beta - 1.96*se
	gen seplot_hi = beta + 1.96*se
	
	twoway rspike seplot_lo seplot_hi threshold if !mi(beta), col(gray) || ///
		scatter beta threshold if !mi(beta), $allwhite msym(S) col("$col2") ///
		title() ///
		legend(order(2 "Wharton") region(style(none)) size(medlarge)) ///
		xtitle(Callback Threshold, size(large)) ytitle(Coefficient Estimate, size(large)) ylab(,nogrid labsize(medlarge)) ///
		xlab(, labsize(medlarge)) yline(0, lcolor(gs10)) yscale(titlegap(medium)) yscale(titlegap(medium))
	graph export "$output/figb1_b.png", replace
}
	
	
	// Figure B.4: Alternative Specifications: Top Internship
{
	// a) Callback Ratio
	use "$data/Clean/IRRAnalysisFile_Penn.dta", clear
	gen threshold=_n if _n<11
				
	gen beta_scaled = .
	gen se_ratio = .
			
	forvalues i=1(1)10 {
		gen callback = (rating_hire>=`i')
		reg callback topemp 
		replace beta_scaled = (_b[topemp]+_b[_cons])/_b[_cons] if _n==`i'
		nlcom ratio: (_b[topemp]+_b[_cons])/_b[_cons], post
		
		replace se_ratio = _se[ratio] if _n==`i'
		drop callback
	}
	gen seplot_lo = beta_scaled - 1.96*se_ratio
	gen seplot_hi = beta_scaled + 1.96*se_ratio
	
	
	twoway rspike seplot_lo seplot_hi threshold if !mi(beta_scaled), col(gray) || ///
		scatter beta_scaled threshold if !mi(beta), $allwhite  col("$col2") ///
		title("") ///
		legend(off) xtitle(Callback Threshold, size(medlarge)) ytitle(Callback Ratio, size(medlarge)) ///
		ylab(, nogrid labsize(medlarge)) xlab(, labsize(medlarge))
	graph export "$output/figb4_a.png", replace
	
	
	// b) Logit
	use "$data/Clean/IRRAnalysisFile_Penn.dta", clear
	gen threshold=_n if _n<11
				
	gen beta_logit = .
	gen se_logit = . 
	
	replace beta_logit = 0 if _n==1
	
	forvalues i=2(1)10 {
		gen callback = (rating_hire>=`i')
		logit callback topemp 
		replace beta_logit = _b[topemp] if _n==`i'
		replace se_logit = _se[topemp] if _n==`i'
		drop callback
	}
	gen seplot_lo = beta_logit - 1.96*se_logit
	gen seplot_hi = beta_logit + 1.96*se_logit
	
	twoway rspike seplot_lo seplot_hi threshold if !mi(beta_logit), color(gray) || ///
		scatter beta_logit threshold if !mi(beta_logit) , color("$col2") ///
		$allwhite ///
		title() ///
		legend(off) xtitle(Callback Threshold, size(medlarge)) ytitle(Logit Coefficient, size(medlarge)) ///
		ylab(, nogrid labsize(medlarge)) xlab(, labsize(medlarge))
	graph export "$output/figb4_b.png", replace

}
	
	
	// Figure B.5: Alternative Specifications: Second Job Type
{
	// a) Callback Ratio 
	use "$data/Clean/IRRAnalysisFile_Penn.dta", clear
	gen threshold=_n if _n<11
	
	gen betarat_secondint = .
	gen serat_secondint = .
	
	gen betarat_wfm = .
	gen serat_wfm = .
	
	
	forvalues i=1(1)10 {
		gen callback = (rating_hire>=`i')
		reg callback secondint wfm 
		replace betarat_secondint = (_b[secondint]+_b[_cons])/_b[_cons] if _n==`i'
				
		nlcom ratio: (_b[secondint]+_b[_cons])/_b[_cons], post
		replace serat_secondint = _se[ratio] if _n==`i'
		
		reg callback secondint wfm 
		replace betarat_wfm = (_b[wfm]+_b[_cons])/_b[_cons] if _n==`i'
		nlcom ratio2: (_b[wfm]+_b[_cons])/_b[_cons], post
		replace serat_wfm = _se[ratio2] if _n==`i'
		
		drop callback
	}
	gen seplot_lo_secondint = betarat_secondint - 1.96*serat_secondint
	gen seplot_hi_secondint = betarat_secondint + 1.96*serat_secondint
	
	gen seplot_lo_wfm = betarat_wfm - 1.96*serat_wfm
	gen seplot_hi_wfm = betarat_wfm + 1.96*serat_wfm
	
	gen threshlow = threshold - 0.05
	gen threshhi = threshold + 0.05
	
	twoway rspike seplot_lo_secondint seplot_hi_secondint threshlow if !mi(betarat_secondint), col(gray) || ///
		rspike seplot_lo_wfm seplot_hi_wfm threshhi if !mi(betarat_wfm), col(gray) || ///
		scatter betarat_secondint threshlow if !mi(betarat_secondint), col("$col3") || ///
		scatter betarat_wfm threshhi if !mi(betarat_wfm), msym(S) col("$col2") $allwhite ///
		title("") ///
		legend(order(4 "Work for Money" 3 "Second Internship") row(1) region(style(none)) size(medlarge)) ///
		xtitle(Callback Threshold, size(medlarge)) ytitle(Callback Ratio, size(medlarge)) ///
		ylab(, nogrid labsize(medlarge)) xlab(, labsize(medlarge))
	graph export "$output/figb5_a.png", replace
	

	// b) Logit
	use "$data/Clean/IRRAnalysisFile_Penn.dta", clear
	gen threshold=_n if _n<11
	
	gen betarat_secondint = .
	gen serat_secondint = .
	
	gen betarat_wfm = .
	gen serat_wfm = .
	
	replace betarat_secondint = 0 if _n
	replace betarat_wfm = 0 if _n
	
	
	forvalues i=2(1)10 {
		gen callback = (rating_hire>=`i')
		logit callback secondint wfm 
		replace betarat_secondint = _b[secondint] if _n==`i'
		replace serat_secondint = _se[secondint] if _n==`i'

		replace betarat_wfm = _b[wfm] if _n==`i'
		replace serat_wfm = _se[wfm] if _n==`i'
		
		drop callback
	}
	gen seplot_lo_secondint = betarat_secondint - 1.96*serat_secondint
	gen seplot_hi_secondint = betarat_secondint + 1.96*serat_secondint
	
	gen seplot_lo_wfm = betarat_wfm - 1.96*serat_wfm
	gen seplot_hi_wfm = betarat_wfm + 1.96*serat_wfm
	
	gen threshlow = threshold - 0.05
	gen threshhi = threshold + 0.05
	
	twoway rspike seplot_lo_secondint seplot_hi_secondint threshlow if !mi(betarat_secondint), col(gray) || ///
		rspike seplot_lo_wfm seplot_hi_wfm threshhi if !mi(betarat_wfm), col(gray) || ///
		scatter betarat_secondint threshlow if !mi(betarat_secondint), col("$col3") || ///
		scatter betarat_wfm threshhi if !mi(betarat_wfm), msym(S) col("$col2") $allwhite ///
		title("") ///
		legend(order(4 "Work for Money" 3 "Second Internship") row(1) region(style(none)) size(medlarge)) ///
		xtitle(Callback Threshold, size(medlarge)) ytitle(Logit Coefficient, size(medlarge)) ///
		ylab(, nogrid labsize(medlarge)) xlab(, labsize(medlarge))
	graph export "$output/figb5_b.png", replace
}	
	
	
	// Figure B.6: Top Internship x Not a White Male
{
	// a) Empirical CDF 
	use "$data/Clean/IRRAnalysisFile_Penn.dta", clear
	sort rating_hire not_a_whitemale
	cumul rating_hire if topemp==1 & not_a_whitemale==1, gen(cdf_11)
	cumul rating_hire if topemp==1 & not_a_whitemale==0, gen(cdf_10)
	cumul rating_hire if topemp==0 & not_a_whitemale==1, gen(cdf_01)
	cumul rating_hire if topemp==0 & not_a_whitemale==0, gen(cdf_00)
	line cdf_00 rating_hire, c(J) col("$col1") || ///
	  line cdf_10 rating_hire, c(J) col("$col2") lp("-") || ///
	  line cdf_01 rating_hire, c(J) col("$col3") lp("__.") || ///
	  line cdf_11 rating_hire, c(J) col("$col4") lp("-..-") ///
	  $allwhite ///
	  legend(label(1 "No Top Internship, White Male") label(2 "Top Internship, White Male") ///
	    label(3 "No Top Internship, Not a White Male") label(4 "Top Internship, Not a White Male") ///
		region(style(none)) size(medium) symxsize(8)) ///
	  title() xtitle(Hiring Interest Rating, size(large)) yscale(titlegap(medium)) ///
	  ytitle(Pr(Hiring Interest {&le} x), size(large)) ylab(,nogrid labsize(medlarge)) xlab(, labsize(medlarge))
	graph export "$output/figb6_a.png", replace
	
	// b) Linear Probability Model
	use "$data/Clean/IRRAnalysisFile_Penn.dta", clear
	gen threshold=_n if _n<11
	
	gen topxnwm = topemp*not_a_whitemale
	label variable topxnwm "Top Internship x Not White Male"

	gen beta_nwm = .
	gen se_nwm = .
	gen beta_top = .
	gen se_top = .
	gen beta_x = .
	gen se_x = .
	
	forvalues i=1(1)10 {
		gen callback = (rating_hire>=`i')
		qui reg callback topemp not_a_whitemale topxnwm, robust
		replace beta_nwm = _b[not_a_whitemale] if _n==`i'
		replace se_nwm = _se[not_a_whitemale] if _n==`i'
		
		replace beta_top = _b[topemp] if _n==`i'
		replace se_top = _se[topemp] if _n==`i'
		
		replace beta_x = _b[topxnwm] if _n==`i'
		replace se_x = _se[topxnwm] if _n==`i'
		
		drop callback
	}
	gen seplot_lo_nwm = beta_nwm - 1.96*se_nwm
	gen seplot_hi_nwm = beta_nwm + 1.96*se_nwm
	
	gen seplot_lo_top = beta_top - 1.96*se_top
	gen seplot_hi_top = beta_top + 1.96*se_top
	
	gen seplot_lo_x = beta_x - 1.96*se_x
	gen seplot_hi_x = beta_x + 1.96*se_x
	
	gen threshlow = threshold-0.1
	gen threshhi = threshold+0.1

	twoway rspike seplot_lo_nwm seplot_hi_nwm threshlow if !mi(beta_nwm), col(gray) || scatter beta_nwm threshlow if !mi(beta_nwm), msym(S) col("$col3") || ///
	rspike seplot_lo_top seplot_hi_top threshold if !mi(beta_top), col(gray) || scatter beta_top threshold if !mi(beta_top), msym(T) col("$col2") ||  ///
	rspike seplot_lo_x seplot_hi_x threshhi if !mi(beta_x), col(gray) || scatter beta_x threshhi if !mi(beta_x), msym(O) col("$col4") $allwhite ///
		title() ///
		legend(order(2 "Not a White Male" 4 "Top Internship" 6 "Top Int x NWM") row(1) region(style(none)) size(medlarge)) yscale(titlegap(medium)) ///
		xtitle(Callback Threshold, size(large)) ytitle(Coefficient Estimate, size(large)) ylab(,nogrid labsize(medlarge)) xlab(, labsize(medlarge)) yline(0, lcolor(gs10))
	graph export "$output/figb6_b.png", replace
	
}
	

	/************************************/
	/***     Pitt Appendix Tables     ***/
	/************************************/
	
	/*** Table C.2: Hiring Interest by Major Type at Pitt ***/
{
	use "$data/Clean/IRRAnalysisFile_Pitt.dta", clear

	// Humanities & Social Sciences
	// 1) No Controls - Hum/SS
	reg rating_hire randgpa topemp secondint wfm techskills whitefemale nonwhite_male nonwhite_female imajor* if majorHumSS==1, robust 
	est sto pitt_noctrl_hum

	estadd local subjfe "No"
	estadd local majorfe "Yes"
	estadd local orderfe "No"
	estadd local leadfe "No"
	
	unab imaj: imajor*
	test `imaj'		
	local pval: di %4.3f r(p)*2
	if (`pval' < 0.001) estadd local Ftest = "$<0.001$"
	else estadd local Ftest = "`pval'"	
	
	// 2) Leadership, Order, Major FEs - Hum/SS
	xi: reg  rating_hire randgpa topemp secondint wfm techskills whitefemale nonwhite_male nonwhite_female i.resumenumber imajor* i.lead1 i.lead2 if majorHumSS==1, robust 
	est sto pitt_somectrls_hum
	
	estadd local subjfe "No"
	estadd local majorfe "Yes"
	estadd local orderfe "Yes"
	estadd local leadfe "Yes"

	unab imaj: imajor*
	test `imaj'		
	local pval: di %4.3f r(p)*2
	if (`pval' < 0.001) estadd local Ftest = "$<0.001$"
	else estadd local Ftest = "`pval'"	
	
	// 3) All controls - Hum/SS
	xi: reg rating_hire randgpa topemp secondint wfm techskills whitefemale nonwhite_male nonwhite_female i.resumenumber imajor* i.lead1 i.lead2 if majorHumSS==1, absorb(subjroundid) robust 
	est sto pitt_allctrls_hum
	estadd local subjfe "Yes"
	estadd local majorfe "Yes"
	estadd local orderfe "Yes"
	estadd local leadfe "Yes"
	
	unab imaj: imajor*
	test `imaj'
	local pval: di %4.3f r(p)*2
	if (`pval' < 0.001) estadd local Ftest = "$<0.001$"
	else estadd local Ftest = "`pval'"	
	
	// 4) Rescaled wrt GPA
	eststo pitt_rescaled_hum: nlcom (randgpa: _b[randgpa]/_b[randgpa]) ///
		(topemp: _b[topemp]/_b[randgpa]) ///
		(secondint: _b[secondint]/_b[randgpa]) ///
		(wfm: _b[wfm]/_b[randgpa]) ///
		(techskills: _b[techskills]/_b[randgpa]) ///
		(whitefemale: _b[whitefemale]/_b[randgpa]) ///
		(nonwhite_male: _b[nonwhite_male]/_b[randgpa]) ///
		(nonwhite_female: _b[nonwhite_female]/_b[randgpa]) ///
		, post	
	if (`pval' < 0.001) estadd local Ftest = "$<0.001$"
		else estadd local Ftest = "`pval'"	
	estadd local subjfe "Yes"
	estadd local majorfe "Yes"
	estadd local orderfe "Yes"
	estadd local leadfe "Yes"

	// 5) Ordered Probit - Hum/SS
	oprobit rating_hire randgpa topemp secondint wfm techskills whitefemale nonwhite_male nonwhite_female imajor* if majorHumSS==1
	est sto oprob_pitt_hum
	estadd local subjfe "No"
	estadd local majorfe "Yes"
	estadd local orderfe "No"
	estadd local leadfe "No"
	
	local cut1hum = string(_b[/cut1], "%3.2f")
	local cut2hum = string(_b[/cut2], "%3.2f")
	local cut3hum = string(_b[/cut3], "%3.2f")
	local cut4hum = string(_b[/cut4], "%3.2f")
	local cut5hum = string(_b[/cut5], "%3.2f")
	local cut6hum = string(_b[/cut6], "%3.2f")
	local cut7hum = string(_b[/cut7], "%3.2f")
	local cut8hum = string(_b[/cut8], "%3.2f")
	local cut9hum = string(_b[/cut9], "%3.2f")
	
	unab imaj: imajor*
	test `imaj'
	local pval: di %4.3f r(p)*2
	if (`pval' < 0.001) estadd local Ftest = "$<0.001$"
	else estadd local Ftest = "`pval'"	


	/*** Science  ***/
	use "$data/Clean/IRRAnalysisFile_Pitt.dta", clear
	// 6) No Controls - Science
	reg rating_hire randgpa topemp secondint wfm techskills whitefemale nonwhite_male nonwhite_female imajor* if majorHumSS==0, robust 
	est sto pitt_noctrl_sci

	estadd local subjfe "No"
	estadd local majorfe "Yes"
	estadd local orderfe "No"
	estadd local leadfe "No"
	
	unab imaj: imajor*
	test `imaj'		
	local pval: di %4.3f r(p)*2
	if (`pval' < 0.001) estadd local Ftest = "$<0.001$"
	else estadd local Ftest = "`pval'"	
	
	// 7) Leadership, Order, Major FEs - Science
	xi: reg rating_hire randgpa topemp secondint wfm techskills whitefemale nonwhite_male nonwhite_female i.resumenumber imajor* i.lead1 i.lead2 if majorHumSS==0, robust 
	est sto pitt_somectrls_sci

	estadd local subjfe "No"
	estadd local majorfe "Yes"
	estadd local orderfe "Yes"
	estadd local leadfe "Yes"

	unab imaj: imajor*
	test `imaj'		
	local pval: di %4.3f r(p)*2
	if (`pval' < 0.001) estadd local Ftest = "$<0.001$"
	else estadd local Ftest = "`pval'"	
	
	// 8) All controls - Science
	xi: reg rating_hire randgpa topemp secondint wfm techskills whitefemale nonwhite_male nonwhite_female i.resumenumber imajor* i.lead1 i.lead2 if majorHumSS==0, absorb(subjroundid) robust 
	est sto pitt_allctrls_sci
	estadd local subjfe "Yes"
	estadd local majorfe "Yes"
	estadd local orderfe "Yes"
	estadd local leadfe "Yes"
	
	unab imaj: imajor*
	test `imaj'
	local pval: di %4.3f r(p)*2
	if (`pval' < 0.001) estadd local Ftest = "$<0.001$"
	else estadd local Ftest = "`pval'"	
	
	
	// 9) Rescaled wrt GPA
	eststo pitt_rescaled_sci: nlcom (randgpa: _b[randgpa]/_b[randgpa]) ///
		(topemp: _b[topemp]/_b[randgpa]) ///
		(secondint: _b[secondint]/_b[randgpa]) ///
		(wfm: _b[wfm]/_b[randgpa]) ///
		(techskills: _b[techskills]/_b[randgpa]) ///
		(whitefemale: _b[whitefemale]/_b[randgpa]) ///
		(nonwhite_male: _b[nonwhite_male]/_b[randgpa]) ///
		(nonwhite_female: _b[nonwhite_female]/_b[randgpa]) ///
		, post	
	if (`pval' < 0.001) estadd local Ftest = "$<0.001$"
		else estadd local Ftest = "`pval'"	
	estadd local subjfe "Yes"
	estadd local majorfe "Yes"
	estadd local orderfe "Yes"
	estadd local leadfe "Yes"
		
	
	// 10) Ordered Probit - Science
	oprobit rating_hire randgpa topemp secondint wfm techskills whitefemale nonwhite_male nonwhite_female imajor* if majorHumSS==0
	est sto oprob_pitt_sci
	estadd local subjfe "No"
	estadd local majorfe "Yes"
	estadd local orderfe "No"
	estadd local leadfe "No"
	local cut1sci = string(_b[/cut1], "%3.2f")
	local cut2sci = string(_b[/cut2], "%3.2f")
	local cut3sci = string(_b[/cut3], "%3.2f")
	local cut4sci = string(_b[/cut4], "%3.2f")
	local cut5sci = string(_b[/cut5], "%3.2f")
	local cut6sci = string(_b[/cut6], "%3.2f")
	local cut7sci = string(_b[/cut7], "%3.2f")
	local cut8sci = string(_b[/cut8], "%3.2f")
	local cut9sci = string(_b[/cut9], "%3.2f")
	
	unab imaj: imajor*
	test `imaj'
	local pval: di %4.3f r(p)*2
	if (`pval' < 0.001) estadd local Ftest = "$<0.001$"
	else estadd local Ftest = "`pval'"	
		
	// Write to file
	esttab pitt_noctrl_hum pitt_somectrls_hum pitt_allctrls_hum pitt_rescaled_hum oprob_pitt_hum ///
		pitt_noctrl_sci pitt_somectrls_sci pitt_allctrls_sci pitt_rescaled_sci oprob_pitt_sci using "$output/TableC2.tex", ///
		b se replace compress nofloat r2 ///
		nomtitles varwidth(15) ///
		nonum label depvar nogaps noomitted $starglob ///
		keep(randgpa topemp secondint wfm techskills whitefemale nonwhite_male nonwhite_female) eqlabels(none) ///
		prehead("{\def\sym#1{\ifmmode^{#1}\else\(^{#1}\)\fi} \begin{tabular}{l*{10}{c}} \hline\hline & \multicolumn{10}{c}{Dependent Variable: Hiring Interest} \\ & \multicolumn{5}{c}{Humanities \& Social Sciences} & \multicolumn{5}{c}{STEM} \\ \cmidrule(lr){2-6}  \cmidrule(lr){7-11} & OLS & OLS & OLS & \shortstack{GPA-Scaled\\OLS} & \shortstack{Ordered\\Probit} & OLS & OLS & OLS & \shortstack{GPA-Scaled\\OLS} & \shortstack{Ordered\\Probit} \\") ///
		prefoot("\hline") ///
		postfoot("\hline\hline \addlinespace \multicolumn{9}{l}{\footnotesize Ordered probit cutpoints (Column 5): `cut1hum', `cut2hum', `cut3hum', `cut4hum', `cut5hum', `cut6hum', `cut7hum', `cut8hum', `cut9hum'.} \\ \multicolumn{9}{l}{\footnotesize Ordered probit cutpoints (Column 10): `cut1sci', `cut2sci', `cut3sci', `cut4sci', `cut5sci', `cut6sci', `cut7sci', `cut8sci', `cut9sci'.} \end{tabular} }") ///
		scalars("Ftest \shortstack{\emph{p-value for test of joint}\\\emph{\quad significance of Majors}}" ///
			"line \hline%" "majorfe Major FEs" "leadfe Leadership FEs" "orderfe Order FEs" "subjfe Subject FEs") sfmt(%5.4fc)	
}			
	
	
	/*** Table C.3: Likelihood of Acceptance at Pitt ***/
{
	use "$data/Clean/IRRAnalysisFile_Pitt.dta", clear

	xi: reg rating_accept randgpa topemp secondint wfm techskills whitefemale nonwhite_male nonwhite_female imajor*, robust 
	est sto pitt_acc_noctrls
	estadd local majorfe "Yes"
	estadd local orderfe "No"
	estadd local leadfe "No"
	estadd local subjfe "No"
	unab imaj: imajor*
	test `imaj'		
	local pval: di %4.3f r(p)
	if (`pval' < 0.001) estadd local Ftest = "$<0.001$"
	else estadd local Ftest = "`pval'"	
	
	test whitefemale nonwhite_male nonwhite_female
	local p_discrim: di %4.3f r(p)
	if (`p_discrim' < 0.001) estadd local pdemog = "$<0.001$"
	else estadd local pdemog = "`p_discrim'"	
	
		
	xi: reg rating_accept randgpa topemp secondint wfm techskills whitefemale nonwhite_male nonwhite_female i.resumenumber imajor* i.lead1 i.lead2, robust 
	est sto pitt_acc_somectrls
	estadd local majorfe "Yes"
	estadd local orderfe "Yes"
	estadd local leadfe "Yes"
	estadd local subjfe "No"
	unab imaj: imajor*
	test `imaj'		
	local pval: di %4.3f r(p)
	if (`pval' < 0.001) estadd local Ftest = "$<0.001$"
	else estadd local Ftest = "`pval'"	
	
	test whitefemale nonwhite_male nonwhite_female
	local p_discrim: di %4.3f r(p)
	if (`p_discrim' < 0.001) estadd local pdemog = "$<0.001$"
	else estadd local pdemog = "`p_discrim'"	
	
	
	
	xi: reg rating_accept randgpa topemp secondint wfm techskills whitefemale nonwhite_male nonwhite_female i.resumenumber imajor* i.lead1 i.lead2, absorb(subjroundid) robust 
	est sto pitt_acc_allctrls
	estadd local majorfe "Yes"
	estadd local orderfe "Yes"
	estadd local leadfe "Yes"
	estadd local subjfe "Yes"
	unab imaj: imajor*
	test `imaj'		
	local pval: di %4.3f r(p)
	if (`pval' < 0.001) estadd local Ftest = "$<0.001$"
	else estadd local Ftest = "`pval'"	
	
	test whitefemale nonwhite_male nonwhite_female
	local p_discrim: di %4.3f r(p)
	if (`p_discrim' < 0.001) estadd local pdemog = "$<0.001$"
	else estadd local pdemog = "`p_discrim'"	
	
	local gpascaler = _b[randgpa]
	display `gpascaler'
	
	
	oprobit rating_accept randgpa topemp secondint wfm techskills whitefemale nonwhite_male nonwhite_female imajor*, robust 
	est sto pitt_acc_oprob
	estadd local majorfe "Yes"
	estadd local orderfe "No"
	estadd local leadfe "No"
	estadd local subjfe "No"
	local cut1 = string(_b[/cut1], "%3.2f")
	local cut2 = string(_b[/cut2], "%3.2f")
	local cut3 = string(_b[/cut3], "%3.2f")
	local cut4 = string(_b[/cut4], "%3.2f")
	local cut5 = string(_b[/cut5], "%3.2f")
	local cut6 = string(_b[/cut6], "%3.2f")
	local cut7 = string(_b[/cut7], "%3.2f")
	local cut8 = string(_b[/cut8], "%3.2f")
	local cut9 = string(_b[/cut9], "%3.2f")
	unab imaj: imajor*
	test `imaj'		
	local pval: di %4.3f r(p)
	if (`pval' < 0.001) estadd local Ftest = "$<0.001$"
	else estadd local Ftest = "`pval'"
	
	test whitefemale nonwhite_male nonwhite_female
	local p_discrim: di %4.3f r(p)
	if (`p_discrim' < 0.001) estadd local pdemog = "$<0.001$"
	else estadd local pdemog = "`p_discrim'"	
	
	
	
	esttab pitt_acc_noctrls pitt_acc_somectrls pitt_acc_allctrls pitt_acc_oprob  using "$output/TableC3.tex", ///
		b se replace compress nofloat r2 ///
		mgroups("\shortstack{Dependent Variable: Likelihood of Acceptance}", pattern(1 0 0 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
		mtitles("OLS" "OLS" "OLS" "\shortstack{Ordered\\Probit}") ///
		nonum label depvar nogaps noomitted $starglob ///
		transform(@/`gpascaler', pattern(0 0 0 0 1)) ///
		keep(randgpa whitefemale nonwhite_male nonwhite_female topemp secondint wfm techskills) eqlabels(none) ///
		postfoot("\hline\hline \addlinespace \multicolumn{5}{l}{\footnotesize Ordered probit cutpoints: `cut1', `cut2', `cut3', `cut4', `cut5', `cut6', `cut7', `cut8', and `cut9'.} \end{tabular} $starending") ///
		scalars("Ftest \shortstack[l]{\emph{p-value for test of joint}\\\emph{\quad significance of Majors}}" ///
			"majorfe Major FEs" "leadfe Leadership FEs" "orderfe Order FEs" "subjfe Subject FEs") sfmt(%5.4fc)
}
		
		
	/*** Table C.4: Likelihood of Acceptance by Major Type at Pitt ***/
{
	use "$data/Clean/IRRAnalysisFile_Pitt.dta", clear

	// Humanities & Social Sciences
	// 1) No Controls - Hum/SS
	reg rating_accept randgpa topemp secondint wfm techskills whitefemale nonwhite_male nonwhite_female imajor* if majorHumSS==1, robust 
	est sto acc_pitt_noctrl_hum

	estadd local subjfe "No"
	estadd local majorfe "Yes"
	estadd local orderfe "No"
	estadd local leadfe "No"
	
	unab imaj: imajor*
	test `imaj'		
	local pval: di %4.3f r(p)*2
	if (`pval' < 0.001) estadd local Ftest = "$<0.001$"
	else estadd local Ftest = "`pval'"	
	
	// 2) Leadership, Order, Major FEs - Hum/SS
	xi: reg rating_accept randgpa topemp secondint wfm techskills whitefemale nonwhite_male nonwhite_female i.resumenumber imajor* i.lead1 i.lead2 if majorHumSS==1, robust 
	est sto acc_pitt_somectrls_hum
	
	estadd local subjfe "No"
	estadd local majorfe "Yes"
	estadd local orderfe "Yes"
	estadd local leadfe "Yes"

	unab imaj: imajor*
	test `imaj'		
	local pval: di %4.3f r(p)*2
	if (`pval' < 0.001) estadd local Ftest = "$<0.001$"
	else estadd local Ftest = "`pval'"	
	
	
	// 3) All controls - Hum/SS
	xi: reg rating_accept randgpa topemp secondint wfm techskills whitefemale nonwhite_male nonwhite_female i.resumenumber imajor* i.lead1 i.lead2 if majorHumSS==1, absorb(subjroundid) robust 
	est sto acc_pitt_allctrls_hum
	estadd local subjfe "Yes"
	estadd local majorfe "Yes"
	estadd local orderfe "Yes"
	estadd local leadfe "Yes"
	
	unab imaj: imajor*
	test `imaj'
	local pval: di %4.3f r(p)*2
	if (`pval' < 0.001) estadd local Ftest = "$<0.001$"
	else estadd local Ftest = "`pval'"	
	
	
	// 4) Ordered Probit - Hum/SS
	oprobit rating_acc randgpa topemp secondint wfm techskills whitefemale nonwhite_male nonwhite_female imajor* if majorHumSS==1
	est sto oprob_acc_pitt_hum
	estadd local subjfe "No"
	estadd local majorfe "Yes"
	estadd local orderfe "No"
	estadd local leadfe "No"
	
	local cut1hum = string(_b[/cut1], "%3.2f")
	local cut2hum = string(_b[/cut2], "%3.2f")
	local cut3hum = string(_b[/cut3], "%3.2f")
	local cut4hum = string(_b[/cut4], "%3.2f")
	local cut5hum = string(_b[/cut5], "%3.2f")
	local cut6hum = string(_b[/cut6], "%3.2f")
	local cut7hum = string(_b[/cut7], "%3.2f")
	local cut8hum = string(_b[/cut8], "%3.2f")
	local cut9hum = string(_b[/cut9], "%3.2f")
	
	unab imaj: imajor*
	test `imaj'
	local pval: di %4.3f r(p)*2
	if (`pval' < 0.001) estadd local Ftest = "$<0.001$"
	else estadd local Ftest = "`pval'"	


	/*** Science  ***/
	use "$data/Clean/IRRAnalysisFile_Pitt.dta", clear
	// 5) No Controls - Science
	reg rating_acc randgpa topemp secondint wfm techskills whitefemale nonwhite_male nonwhite_female imajor* if majorHumSS==0, robust 
	est sto acc_pitt_noctrl_sci

	estadd local subjfe "No"
	estadd local majorfe "Yes"
	estadd local orderfe "No"
	estadd local leadfe "No"
	
	unab imaj: imajor*
	test `imaj'		
	local pval: di %4.3f r(p)*2
	if (`pval' < 0.001) estadd local Ftest = "$<0.001$"
	else estadd local Ftest = "`pval'"	

	
	
	// 6) Leadership, Order, Major FEs - Science
	xi: reg rating_acc randgpa topemp secondint wfm techskills whitefemale nonwhite_male nonwhite_female i.resumenumber imajor* i.lead1 i.lead2 if majorHumSS==0, robust 
	est sto acc_pitt_somectrls_sci

	estadd local subjfe "No"
	estadd local majorfe "Yes"
	estadd local orderfe "Yes"
	estadd local leadfe "Yes"

	unab imaj: imajor*
	test `imaj'		
	local pval: di %4.3f r(p)*2
	if (`pval' < 0.001) estadd local Ftest = "$<0.001$"
	else estadd local Ftest = "`pval'"	

	
	
	// 7) All controls - Science
	xi: reg rating_acc randgpa topemp secondint wfm techskills whitefemale nonwhite_male nonwhite_female i.resumenumber imajor* i.lead1 i.lead2 if majorHumSS==0, absorb(subjroundid) robust 
	est sto acc_pitt_allctrls_sci
	estadd local subjfe "Yes"
	estadd local majorfe "Yes"
	estadd local orderfe "Yes"
	estadd local leadfe "Yes"
	
	unab imaj: imajor*
	test `imaj'
	local pval: di %4.3f r(p)*2
	if (`pval' < 0.001) estadd local Ftest = "$<0.001$"
	else estadd local Ftest = "`pval'"	

		
	// 8) Ordered Probit - Science
	oprobit rating_acc randgpa topemp secondint wfm techskills whitefemale nonwhite_male nonwhite_female imajor* if majorHumSS==0
	est sto oprob_acc_pitt_sci
	estadd local subjfe "No"
	estadd local majorfe "Yes"
	estadd local orderfe "No"
	estadd local leadfe "No"
	local cut1sci = string(_b[/cut1], "%3.2f")
	local cut2sci = string(_b[/cut2], "%3.2f")
	local cut3sci = string(_b[/cut3], "%3.2f")
	local cut4sci = string(_b[/cut4], "%3.2f")
	local cut5sci = string(_b[/cut5], "%3.2f")
	local cut6sci = string(_b[/cut6], "%3.2f")
	local cut7sci = string(_b[/cut7], "%3.2f")
	local cut8sci = string(_b[/cut8], "%3.2f")
	local cut9sci = string(_b[/cut9], "%3.2f")
	
	unab imaj: imajor*
	test `imaj'
	local pval: di %4.3f r(p)*2
	if (`pval' < 0.001) estadd local Ftest = "$<0.001$"
	else estadd local Ftest = "`pval'"	

		
	esttab acc_pitt_noctrl_hum acc_pitt_somectrls_hum acc_pitt_allctrls_hum oprob_acc_pitt_hum ///
		acc_pitt_noctrl_sci acc_pitt_somectrls_sci acc_pitt_allctrls_sci oprob_acc_pitt_sci using "$output/TableC4.tex", ///
		b se replace compress nofloat r2 ///
		nomtitles varwidth(15) ///
		nonum label depvar nogaps noomitted $starglob ///
		keep(randgpa topemp secondint wfm techskills whitefemale nonwhite_male nonwhite_female) eqlabels(none) ///
		prehead("{\def\sym#1{\ifmmode^{#1}\else\(^{#1}\)\fi} \begin{tabular}{l*{8}{c}} \hline\hline & \multicolumn{8}{c}{Dependent Variable: Likelihood of Acceptance} \\ & \multicolumn{4}{c}{Humanities \& Social Sciences} & \multicolumn{4}{c}{STEM} \\ \cmidrule(lr){2-5}  \cmidrule(lr){6-9} & OLS & OLS & OLS & \shortstack{Ordered\\Probit} & OLS & OLS & OLS & \shortstack{Ordered\\Probit} \\") ///
		prefoot("\hline") ///
		postfoot("\hline\hline \addlinespace \multicolumn{9}{l}{\footnotesize Ordered probit cutpoints (Column 4): `cut1hum', `cut2hum', `cut3hum', `cut4hum', `cut5hum', `cut6hum', `cut7hum', `cut8hum', `cut9hum'.} \\ \multicolumn{9}{l}{\footnotesize Ordered probit cutpoints (Column 8): `cut1sci', `cut2sci', `cut3sci', `cut4sci', `cut5sci', `cut6sci', `cut7sci', `cut8sci', `cut9sci'.} \end{tabular} }") ///
		scalars("Ftest \shortstack{\emph{p-value for test of joint}\\\emph{\quad significance of Majors}}" ///
			 "line \hline%" "majorfe Major FEs" "leadfe Leadership FEs" "orderfe Order FEs" "subjfe Subject FEs") sfmt(%5.4fc)	
}



	/****************************
	***      STATS CITED      ***
	*****************************/

	// Callback magnitude comparison (GPA and counterfactual callback rate, B&M 2004 Comparison)
{
	use "$data/Clean/IRRAnalysisFile_Penn.dta", clear

	gen callback = (rating_hire>=9)
	
	reg callback randgpa whitefemale nonwhite_male nonwhite_female if major_type==1
	
}


	// Recruiter Characteristics
{
	use "$data/Clean/IRRAnalysisFile_Penn.dta", clear
	bys subjid: keep if _n==1

	tab rater_ethnicity
	tab rater_female 
	tab rater_yearshiring 
	tab rater_college

}
	
	

*! mp_error_estimates v0.0.1 11october2016
* 
* This script calculates error estimates for the Manifesto Project Dataset 
* as suggested in the following article:

* Michael D. McDonald, Ian Budge
* "Getting it (approximately) right (and center and left!): Reliability and uncertainty estimates for the comparative manifesto data"
* Electoral Studies, Volume 35, September 2014, Pages 67-77
* http://dx.doi.org/10.1016/j.electstud.2014.04.017

* The script was provided by Michael D. McDonald
* and slightly adjusted to the current dataset versions by Nicolas Merz
* If you spot any errors in this script, please inform nicolas.merz@wzb.eu
* If you have questions on the error estimates in general, please contact the authors of the article


program define mp_error_estimates 
	

	syntax varlist(max=1)
		
	* define version *
	version 13.0
	
	dis "The loaded dataset needs to be a Manifesto Project Dataset or at least contain the following variables:"
	dis "country party date `varlist'"
	
	confirm variable date party `varlist'
	/*if !_rc {
                       di "variable date exists."
               }
               else {
                       di in red "Input data has wrong format. variable date is required."
					   break
               }
			   
	capture confirm variable party
	if !_rc {
                       di "variable party exists."
               }
               else {
                       di in red "Input data has wrong format. variable party is required."
					   break
               }
	
	capture confirm variable `varlist'
	if !_rc {
                       di "variable `varlist' exists."
               }
               else {
                       di in red "Input data has wrong format. variable `varlist' is required. "
					   break
               }
	*/		
	dis "Calculating error estimates for `varlist'. Please be patient, this may take a while."
	
	
	
	quietly {		
	
	* tempfile Lag1Results // Lag1Results.dta
	* tempfile Lag2Results // Lag2Results.dta
	* tempfile Lag3Results // Lag3Results.dta
	* tempfile FirstLagID // FirstLagID.dta
	* tempfile Lag2Results_esample3 // Lag2Results_esample3.dta
	* tempfile Lag1Results_esample3.dta // Lag1Results_esample3.dta
	* tempfile Lag1Results_esample2 // Lag1Results_esample2.dta
	* tempfule lagresults // lagresults.dta
	* tempfile cmpvar // CMP`varname'.dta
	* tempfile correlations // corr.dta
	* tempfile partyvar_sds // partyvar_sds.dta
	* tempfile outliersout_reliability // outliersout_reliability.dta 
	
	* tempfile orig_data // orig_data
	* tempfile subset_data // tempdata
	
	save orig_data, replace
	
	sort party date

	keep country party date `varlist'
	save tempdata, replace
	
	local varname "`varlist'"
	dis "test"
	dis `varname'

	set more off
	set seed 667
	sum `varname'
	foreach var of varlist `varname' {

	by party (date), sort: generate election = _n

	xtset party election

	by party, sort: egen `var'mean = total(`var')
	by party, sort: replace `var'mean = `var'mean / _N
	generate sample1 =0
	generate sample2 =0
	generate sample3 =0

	tempname sim
	postfile `sim' F dfm dfr r2a N party using "Lag1Results.dta", every(1) replace
	levelsof party, local(levels)
	foreach l of local levels {
	 capture { 
		 regress `var' L.`var' if `l' ==party
		 replace sample1 =1 if e(sample)==1
		 post `sim' (e(F)) (e(df_m)) (e(df_r)) (e(r2_a)) (e(N)) (`l') 
	 }
	}
	postclose `sim'

	tempname sim
	postfile `sim' F dfm dfr r2a N party using "Lag2Results.dta", every(1) replace
	levelsof party, local(levels)
		foreach l of local levels {
			 capture { 
			 regress `var' L.`var' LL.`var' if `l' ==party
			 replace sample2 =1 if e(sample)==1
			 post `sim' (e(F)) (e(df_m)) (e(df_r)) (e(r2_a)) (e(N)) (`l') 
	 }
	}
	postclose `sim'

	tempname sim
	postfile `sim' F dfm dfr r2a N party using "Lag3Results.dta", every(1) replace
	levelsof party, local(levels)
		foreach l of local levels {
		 capture { 
			 regress `var' L.`var' LL.`var' LLL.`var' if `l' ==party
			 replace sample3 =1 if e(sample)==1
			 post `sim' (e(F)) (e(df_m)) (e(df_r)) (e(r2_a)) (e(N)) (`l') 
		}
	}
	postclose `sim'

	clear all

	use "Lag1Results.dta"
	rename (F r2a N dfm dfr) (F_1 r2a_1 N_1 dfm_1 dfr_1)
	save "Lag1Results.dta", replace

	use "Lag2Results.dta"
	rename (F r2a N dfm dfr) (F_2 r2a_2 N_2 dfm_2 dfr_2)
	save "Lag2Results.dta", replace

	use "Lag3Results.dta"
	rename (F r2a N dfm dfr) (F_3 r2a_3 N_3 dfm_3 dfr_3)
	save "Lag3Results.dta", replace

	use "Lag1Results.dta", clear
	merge 1:1 party using "Lag2Results.dta"
	drop _merge
	merge 1:1 party using "Lag3Results.dta"

	drop _merge
	order party

	generate lag1sig = 0
	generate lag2sig = 0
	generate lag3sig = 0

	generate Fp1 = 1 - (F(dfm_1,dfr_1,F_1))
	generate Fp2 = 1 - (F(dfm_2,dfr_2,F_2))
	generate Fp3 = 1 - (F(dfm_3,dfr_3,F_3))

	replace lag1sig = 1 if Fp1 <.1
	replace lag2sig = 1 if Fp2 <.1
	replace lag3sig = 1 if Fp3 <.1

	generate l1b2 = 0
	generate l1b3 = 0
	replace l1b2 =1 if r2a_1 > r2a_2 & r2a_1 !=.
	replace l1b3 =1 if r2a_1 > r2a_3 & r2a_1 !=.

	generate l2b1 = 0
	generate l2b3 = 0
	replace l2b1 =1 if r2a_2 > r2a_1 & r2a_2 !=.
	replace l2b3 =1 if r2a_2 > r2a_3 & r2a_2 !=.

	generate l3b1 = 0
	generate l3b2 = 0
	replace l3b1 =1 if r2a_3 > r2a_1 & r2a_3 !=.
	replace l3b2 =1 if r2a_3 > r2a_2 & r2a_3 !=.

	generate toplag = 1 if l1b2 ==1 & l1b3 ==1 & lag1sig ==1
	replace toplag = 2 if l2b1 ==1 & l2b3 ==1 & lag2sig ==1
	replace toplag = 3 if l3b1 ==1 & l3b2 ==1 & lag3sig ==1

	keep party lag1sig lag2sig lag3sig toplag

	save "FirstLagID.dta", replace

	clear all
	use "tempdata"

	merge m:1 party using "FirstLagID.dta"

	drop _merge

	by party, sort: generate election = _n
	xtset party election

	by party, sort: egen `var'mean = total(`var')
	by party, sort: replace `var'mean = `var'mean / _N
	generate sample1 =0
	generate sample2 =0
	generate sample3 =0

	levelsof party, local(levels)
	foreach l of local levels {
	 capture { 
	 regress `var' L.`var' if `l' ==party
	 replace sample1 =1 if e(sample)==1
	 }
	}

	levelsof party, local(levels)
	foreach l of local levels {
	 capture { 
	 regress `var' L.`var' LL.`var' if `l' ==party
	 replace sample2 =1 if e(sample)==1
	 }
	}

	levelsof party, local(levels)
	foreach l of local levels {
	 capture { 
	 regress `var' L.`var' LL.`var' LLL.`var' if `l' ==party
	 replace sample3 =1 if e(sample)==1
	 }
	}

	tempname sim
	postfile `sim' F dfm dfr r2a N party using "Lag2Results_esample3.dta", every(1) replace
	levelsof party, local(levels)
	foreach l of local levels {
	 capture { 
	 regress `var' L.`var' LL.`var' if `l' ==party & sample3==1
	 replace sample2 =1 if e(sample)==1
	 post `sim' (e(F)) (e(df_m)) (e(df_r)) (e(r2_a)) (e(N)) (`l') 
	 }
	}
	postclose `sim'

	tempname sim
	postfile `sim' F dfm dfr r2a N party using "Lag1Results_esample3.dta", every(1) replace
	levelsof party, local(levels)
	foreach l of local levels {
	 capture { 
	 regress `var' L.`var' if `l' ==party & sample3==1
	 post `sim' (e(F)) (e(df_m)) (e(df_r)) (e(r2_a)) (e(N)) (`l') 
	 }
	}
	postclose `sim'

	tempname sim
	postfile `sim' F dfm dfr r2a N party using "Lag1Results_esample2.dta", every(1) replace
	levelsof party, local(levels)
	foreach l of local levels {
	 capture { 
	 regress `var' L.`var' if `l' ==party & sample2==1
	 replace sample2 =1 if e(sample)==1
	 post `sim' (e(F)) (e(df_m)) (e(df_r)) (e(r2_a)) (e(N)) (`l') 
	 }
	}
	postclose `sim'

	clear all

	use "Lag1Results_esample3.dta"
	rename (F dfm dfr r2a N) (F_l1_3 dfm_l1_3 dfr_l1_3 r2a_l1_3 N_l1_3)
	save "Lag1Results_esample3.dta", replace

	use "Lag2Results_esample3.dta", clear
	rename (F dfm dfr r2a N) (F_l2_3 dfm_l2_3 dfr_l2_3 r2a_l2_3 N_l2_3)
	save "Lag2Results_esample3.dta", replace

	use "Lag1Results_esample2.dta", clear
	rename (F dfm dfr r2a N) (F_l1_2 dfm_l1_2 dfr_l1_2 r2a_l1_2 N_l1_2)
	save "Lag1Results_esample2.dta", replace

	clear all
	use "tempdata.dta"

	merge m:1 party using "FirstLagID.dta"
	drop _merge
	merge m:1 party using "Lag1Results_esample3.dta"
	drop _merge
	merge m:1 party using "Lag2Results_esample3.dta"
	drop _merge
	merge m:1 party using "Lag1Results_esample2.dta"
	drop _merge


	merge m:1 party using "Lag1Results.dta"
	drop _merge
	merge m:1 party using "Lag2Results.dta"
	drop _merge
	merge m:1 party using "Lag3Results.dta"

	duplicates drop party, force


	generate lag1sig_b1 = 0

	generate lag1sig_b = 0
	generate lag2sig_b = 0

	generate Fp1_b1 = 1 - (F(dfm_l1_2,dfr_l1_2,F_l1_2))

	  
	generate Fp1_b = 1 - (F(dfm_l1_3,dfr_l1_3,F_l1_3))
	generate Fp2_b = 1 - (F(dfm_l2_3,dfr_l2_3,F_l2_3))

	replace lag1sig_b1 = 1 if Fp1_b1 <.1

	replace lag1sig_b = 1 if Fp1_b <.1
	replace lag2sig_b = 1 if Fp2_b <.1



	generate toplag2 =.
	replace toplag2 = 1 if r2a_2 < r2a_l1_2 & toplag ==2 & lag1sig_b1 ==1

	replace toplag2 = 2 if r2a_3 < r2a_l2_3 & toplag ==3 & lag2sig_b ==1
	replace toplag2 = 1 if r2a_3 < r2a_l1_3 & toplag ==3 & lag1sig_b ==1

	replace toplag = toplag2 if toplag2 != toplag & toplag2 !=.

	keep party toplag

	rename toplag `var'toplag

	save "`var'.dta", replace

	}

	save "lagresults.dta", replace



	clear all
	use "tempdata.dta"
	merge m:1 party using "lagresults.dta"
	drop _merge

	by party, sort: generate election = _n
	xtset party election
	generate enn = _n


	foreach var of varlist `varname' {
	generate `var'point =.
	gen `var'lag1N = .
	gen `var'lag2N = .
	gen `var'lag3N = .
	levelsof party, local(levels)
	foreach l of local levels {
	 capture {
	 regress `var' L.`var' if `l' == party
	 predict testpredict if `l' == party, xb
	 replace `var'point = _b[_cons] + _b[L.`var']*`var'[_n-1] if e(sample)==1 & `var'toplag ==1
	 replace `var'point =. if testpredict==. & `l' ==party & `var'toplag ==1
	 drop testpredict
	 replace `var'lag1N = e(N) if `l'== party
	 regress `var' L.`var' LL.`var' if `l' == party
	  predict testpredict if `l' == party, xb
	 replace `var'point = _b[_cons] + _b[L.`var']*`var'[_n-1] + _b[LL.`var']*`var'[_n-2] if e(sample)==1 & `var'toplag ==2
	  replace `var'point =. if testpredict==. & `l' ==party & `var'toplag ==2
	 drop testpredict
	 replace `var'lag2N = e(N) if `l'== party
	 regress `var' L.`var' LL.`var' LLL.`var' if `l' == party
	  predict testpredict if `l' == party, xb
	 replace `var'point = _b[_cons] + _b[L.`var']*`var'[_n-1] + _b[LL.`var']*`var'[_n-2] + _b[LLL.`var']*`var'[_n-3] if e(sample)==1 & `var'toplag ==3
	  replace `var'point =. if testpredict==. & `l' ==party & `var'toplag ==3
	  drop testpredict
	  replace `var'lag3N = e(N) if `l'== party

	 di `l'
	}
	}
	}

	foreach var of varlist `varname' {
	by party, sort: egen `var'mean = total(`var')
	by party, sort: replace `var'mean = `var'mean / _N
	replace `var'point = `var'mean if `var'point==. & `var'toplag ==.
	}



	save "CMP`varname'.dta", replace

	tempname sim
	postfile `sim' country v N rho cov12 c1 c2  using "corr.dta", every(1) replace
	levelsof country, local(countries)
	foreach country in `countries' {
		foreach v in "`varname'" {
		corr `v' `v'point if country ==`country'
		post `sim' (`country') (`v') (r(N)) (r(rho)) (r(cov_12)) (r(Var_1)) (r(Var_2))	
		}
	}
	postclose `sim'

	use "CMP`varname'.dta", clear


	foreach var of varlist `varname'  {
		by party, sort: egen `var'resid = total(`var'point)
		by party, sort: replace `var'resid = `var'resid / _N
		by party, sort: replace `var'resid = `var' - `var'point
	}

	tempname sim
	postfile `sim' party v sd using "partyvar_sds.dta", every(1) replace
	levelsof party, local(levels)
	foreach party of local levels {
		foreach v in "`varname'" {
		sum `v'resid if party == `party'
		post `sim' (`party') (`v') (r(sd))
		}
	}
	postclose `sim'


	use "partyvar_sds.dta", clear
	tostring v, replace force
	local varnamename "`varname'"
	replace v = "`varname'"
	reshape wide sd, i(party) j(v) string
	save "partyvar_sds.dta", replace

	use "corr.dta", clear
	rename rho rho`varname'
	save "corr.dta", replace
	
	use "CMP`varname'.dta", clear
	*merge m:1 country using "pwcorr_results.dta"
	merge m:1 country using "corr.dta"
	drop _merge

	merge m:1 party using "partyvar_sds.dta"
	rename sd* sd*
	drop _merge

	compress

	foreach var of varlist `varname' {
		gen outlierlag`var' = .
		by country, sort: replace outlierlag`var' = _N if `var'toplag==.
	}

	foreach var of varlist `varname' {
		dis "test"
		by party, sort: gen SEM`var' = sd`var' * (sqrt(1 - rho`var'))
		replace outlierlag`var' = . if `var'toplag ==0
		replace outlierlag`var' = `var'lag1N if `var'toplag ==1
		replace outlierlag`var' = `var'lag2N if `var'toplag ==2
		replace outlierlag`var' = `var'lag3N if `var'toplag ==3
	}





	foreach var of varlist `varname' {
		gen res`var' = `var' - `var'point
		replace `var'toplag = 0 if `var'toplag ==.
		gen t`var' = invttail(((outlierlag`var' - 1) - `var'toplag), .025)
		gen upper`var' = `var'point + (rho`var' * res`var') + (t`var' * SEM`var' * sqrt(rho`var'))
		gen lower`var' = `var'point + (rho`var' * res`var') + (-1 * t`var' * SEM`var' * sqrt(rho`var'))
		gen outlier`var'=0
		replace outlier`var' = 1 if `var'point > upper`var' & upper`var' !=.
		replace outlier`var' = 1 if `var'point < lower`var' & lower`var' !=.
	}

	tempname sim
	postfile `sim' country v N rho1 rho2 using "outliersout_reliability.dta", every(1) replace
	levelsof country, local(countries)
	foreach country in `countries' {
	
		foreach v in `varname' {
				corr `v' `v'point if country==`country'
				post `sim' (`country') (`v') (r(N)) (r(rho)) (.)
				capture: corr `v' `v'point if country==`country' & outlier`v' !=1
				post `sim' (`country') (`v') (r(N)) (.) (r(rho))
		}
	}
	postclose `sim'


	preserve
	use "outliersout_reliability.dta", clear
	gen N2 = N[_n+1] if rho2 ==.
	replace rho2=rho2[_n+1] if rho2==. & rho2[_n+1] !=.
	order country v N N2 rho1 rho2
	*tostring v, gen(varstr)
	drop v
	gen varstring = "`varname'"
	drop if rho1==. & rho2 !=.
	duplicates drop country varstr, force
	reshape wide rho1 rho2 N N2, i(country) j(varstr) string
	save "outliersout_reliability.dta", replace

	restore

	merge m:1 country using "outliersout_reliability.dta"
	drop _merge


	compress


	foreach var of varlist `varname' {
		by country, sort: egen outlier`var'num = total(outlier`var')
		by country, sort: egen x`var' = total(res`var'^2) if outlier`var' ==1
		by country, sort: gen outlierSEM`var' = x`var' - (x`var' * sqrt(rho2`var'))
		by country, sort: replace outlierSEM`var' = sqrt(outlierSEM`var' / outlier`var'num)* sqrt(rho2`var')
		by country, sort: replace outlierSEM`var' = SEM`var' * (sqrt(rho2`var') / sqrt(rho1`var')) if outlierSEM`var' ==.
		rename (SEM`var' outlierSEM`var' rho1`var' rho2`var' outlier`var') (`var'_firststageSEM `var'_secondstageSEM `var'_rho1 `var'_rho2 `var'_outlier)
	}

	
	compress

	keep party date  `varname'_firststageSEM `varname'_secondstageSEM `varname'_rho1 `varname'_rho2 `varname'_outlier
	
	merge 1:1 party date using orig_data, nogenerate
	
	order `varname'_firststageSEM `varname'_secondstageSEM `varname'_rho1 `varname'_rho2 `varname'_outlier, last
	
	label variable `varname'_firststageSEM "`varname': 1st stage standard error of measurement"
	label variable `varname'_secondstageSEM "`varname': 2nd stage standard error of measurement"
	label variable `varname'_outlier "`varname': outlier"
	label variable `varname'_rho1 "`varname': correlated with y-hat `varname', all data points"
	label variable `varname'_rho2 "`varname': correlated with y-hat `varname', outliers removed"
	
	*** this produces slight differences to michaels original script as it deletes error estimates for cases where the original estimate is missing
	foreach x of varlist `varname'_firststageSEM  `varname'_secondstageSEM `varname'_outlier `varname'_rho1 `varname'_rho2 {
		replace `x' = . if `varname' == .
	}
	
	} 
	dis "Generated the following variables: `varname'_firststageSEM, `varname'_secondstageSEM, `varname'_outlier, `varname'_rho1, `varname'_rho2."

end

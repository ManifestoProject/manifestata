clear all
use "C:\data\BJS_CMP_May4_2012.dta"


foreach var of varlist PER104-PER705 rile planeco markeco welfare intpeace {
clear all
use "C:\data\BJS_CMP_May4_2012.dta"

by party, sort: generate election = _n
xtset party election

by party, sort: egen `var'mean = total(`var')
by party, sort: replace `var'mean = `var'mean / _N
generate sample1 =0
generate sample2 =0
generate sample3 =0

tempname sim
postfile `sim' F dfm dfr r2a N party using "C:\data\Lag1Results.dta", every(1) replace
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
postfile `sim' F dfm dfr r2a N party using "C:\data\Lag2Results.dta", every(1) replace
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
postfile `sim' F dfm dfr r2a N party using "C:\data\Lag3Results.dta", every(1) replace
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

use "C:\data\Lag1Results.dta"
rename (F r2a N dfm dfr) (F_1 r2a_1 N_1 dfm_1 dfr_1)
save "C:\data\Lag1Results.dta", replace

use "C:\data\Lag2Results.dta"
rename (F r2a N dfm dfr) (F_2 r2a_2 N_2 dfm_2 dfr_2)
save "C:\data\Lag2Results.dta", replace

use "C:\data\Lag3Results.dta"
rename (F r2a N dfm dfr) (F_3 r2a_3 N_3 dfm_3 dfr_3)
save "C:\data\Lag3Results.dta", replace

use "C:\data\Lag1Results.dta", clear
merge 1:1 party using "C:\data\Lag2Results.dta"
drop _merge
merge 1:1 party using "C:\data\Lag3Results.dta"

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

save "C:\data\FirstLagID.dta", replace

clear all
use "C:\data\BJS_CMP_May4_2012.dta"

merge m:1 party using "C:\data\FirstLagID.dta"

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
postfile `sim' F dfm dfr r2a N party using "C:\data\Lag2Results_esample3.dta", every(1) replace
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
postfile `sim' F dfm dfr r2a N party using "C:\data\Lag1Results_esample3.dta", every(1) replace
levelsof party, local(levels)
foreach l of local levels {
 capture { 
 regress `var' L.`var' if `l' ==party & sample3==1
 post `sim' (e(F)) (e(df_m)) (e(df_r)) (e(r2_a)) (e(N)) (`l') 
 }
}
postclose `sim'

tempname sim
postfile `sim' F dfm dfr r2a N party using "C:\data\Lag1Results_esample2.dta", every(1) replace
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

use "C:\data\Lag1Results_esample3.dta"
rename (F dfm dfr r2a N) (F_l1_3 dfm_l1_3 dfr_l1_3 r2a_l1_3 N_l1_3)
save "C:\data\Lag1Results_esample3.dta", replace

use "C:\data\Lag2Results_esample3.dta", clear
rename (F dfm dfr r2a N) (F_l2_3 dfm_l2_3 dfr_l2_3 r2a_l2_3 N_l2_3)
save "C:\data\Lag2Results_esample3.dta", replace

use "C:\data\Lag1Results_esample2.dta", clear
rename (F dfm dfr r2a N) (F_l1_2 dfm_l1_2 dfr_l1_2 r2a_l1_2 N_l1_2)
save "C:\data\Lag1Results_esample2.dta", replace

clear all
use "C:\data\BJS_CMP_May4_2012.dta"

merge m:1 party using "C:\data\FirstLagID.dta"
drop _merge
merge m:1 party using "C:\data\Lag1Results_esample3.dta"
drop _merge
merge m:1 party using "C:\data\Lag2Results_esample3.dta"
drop _merge
merge m:1 party using "C:\data\Lag1Results_esample2.dta"
drop _merge


merge m:1 party using "C:\data\Lag1Results.dta"
drop _merge
merge m:1 party using "C:\data\Lag2Results.dta"
drop _merge
merge m:1 party using "C:\data\Lag3Results.dta"

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

save "C:\data\/`var'.dta", replace

}


use "C:\data\PER104.dta", clear
foreach file in PER105 PER106 PER107 PER108 PER110 PER201 PER202 PER203 PER204 PER301 PER303 PER304 PER305 PER401 PER402 PER403 PER404 PER406 PER407 PER410 PER411 PER412 PER413 PER414 PER501 PER502 PER503 PER504 PER505 PER506 PER601 PER602 PER603 PER604 PER605 PER606 PER701 PER703 PER705 rile planeco markeco welfare intpeace {
  merge 1:1 party using "C:\data\/`file'.dta"
  drop _merge
  compress
    }
save "C:\data\lagresults.dta", replace



clear all
use "C:\data\BJS_CMP_May4_2012.dta"
merge m:1 party using "C:\data\lagresults.dta"
drop _merge

by party, sort: generate election = _n
xtset party election
generate enn = _n


foreach var of varlist PER104-PER705 rile planeco markeco welfare intpeace {
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

foreach var of varlist PER104-PER705 rile planeco markeco welfare intpeace {
by party, sort: egen `var'mean = total(`var')
by party, sort: replace `var'mean = `var'mean / _N
replace `var'point = `var'mean if `var'point==. & `var'toplag ==.
}



save "C:\data\CMP_872012.dta", replace

tempname sim
postfile `sim' country v N rho cov12 c1 c2  using "C:\data\corr.dta", every(1) replace
foreach country in 11	12	13	14	15	21	22	23	31	32	33	34	35	41	42	43	51	52	53	61	62	63	64	71	72	73	74	75	80	81	82	83	84	86	87	88	89	90	91	92	93	94	95	96	97	98 {
foreach v in PER104 PER105 PER106 PER107 PER108 PER110 PER201 PER202 PER203 PER204 PER301 PER303 PER304 PER305 PER401 PER402 PER403 PER404 PER406 PER407 PER410 PER411 PER412 PER413 PER414 PER501 PER502 PER503 PER504 PER505 PER506 PER601 PER602 PER603 PER604 PER605 PER606 PER701 PER703 PER705 rile planeco markeco welfare intpeace {
corr `v' `v'point if country ==`country'
post `sim' (`country') (`v') (r(N)) (r(rho)) (r(cov_12)) (r(Var_1)) (r(Var_2))	
}
}
postclose `sim'


log using "C:\data\pwcorr_log.log", replace
foreach country in 11	12	13	14	15	21	22	23	31	32	33	34	35	41	42	43	51	52	53	61	62	63	64	71	72	73	74	75	80	81	82	83	84	86	87	88	89	90	91	92	93	94	95	96	97	98 {
foreach v in PER104 PER105 PER106 PER107 PER108 PER110 PER201 PER202 PER203 PER204 PER301 PER303 PER304 PER305 PER401 PER402 PER403 PER404 PER406 PER407 PER410 PER411 PER412 PER413 PER414 PER501 PER502 PER503 PER504 PER505 PER506 PER601 PER602 PER603 PER604 PER605 PER606 PER701 PER703 PER705 rile planeco markeco welfare intpeace {
pwcorr `v' `v'point if country ==`country'
display "N: "r(N)
display "Var: "`v'
display "Country: "`country'
}
}
log close


clear all
insheet using "C:\data\pwcorr_log.log"

drop in 1/16
drop in 14494/14499
compress

generate coef=.
replace coef= 1 if !mod(_n,7) 


split v1, parse(":") generate(descr)
drop in 1/3
destring descr2, replace

generate country =.
generate v = .
generate N = .


replace country = descr2 if descr1 =="Country"
replace v = descr2 if descr1 =="N"
replace N = descr2 if descr1 =="Var"

split descr1, parse(" ")
keep descr11 descr15 country v N coef

replace country = country[_n+3]
replace v = v[_n+1]
replace N = N[_n+2]
replace descr11 = descr11[_n-1] if coef==1

replace descr11="intpeace" if descr11=="intpeacepo~t"


keep if coef==1
drop coef

rename (v N descr11 descr15) (N v varstr rho)

destring rho, replace
compress

reshape wide rho N v, i(country) j(varstr) string

save "C:\data\pwcorr_results.dta", replace


use "C:\data\CMP_872012.dta", clear


foreach var of varlist PER104-PER705 rile planeco markeco welfare intpeace {
by party, sort: egen `var'resid = total(`var'point)
by party, sort: replace `var'resid = `var'resid / _N
by party, sort: replace `var'resid = `var' - `var'point
}




rename (rile planeco markeco welfare intpeace rileresid planecoresid markecoresid welfareresid intpeaceresid)  (PER801 PER802 PER803 PER804 PER805 PER801resid PER802resid PER803resid PER804resid PER805resid)

tempname sim
postfile `sim' party v sd using "C:\data\partyvar_sds.dta", every(1) replace
levelsof party, local(levels)
foreach party of local levels {
foreach v in 104	105	106	107	108	110	201	202	203	204	301	303	304	305	401	402	403	404	406	407	410	411	412	413	414	501	502	503	504	505	506	601	602	603	604	605	606	701	703	705 801 802 803 804 805 {
sum PER`v'resid if party == `party'
post `sim' (`party') (`v') (r(sd))
}
}
postclose `sim'



use "C:\data\partyvar_sds.dta", clear
tostring v, replace
replace v = "rile" if v=="801"
replace v = "planeco" if v=="802"
replace v = "markeco" if v=="803"
replace v = "welfare" if v=="804"
replace v = "intpeace" if v=="805"
reshape wide sd, i(party) j(v) string
save "C:\data\partyvar_sds.dta", replace


use "C:\data\CMP_872012.dta", clear
merge m:1 country using "C:\data\pwcorr_results.dta"
drop _merge

merge m:1 party using "C:\data\partyvar_sds.dta"
rename sd* sdPER*
drop _merge

compress

rename (sdPERrile sdPERplaneco sdPERmarkeco sdPERwelfare sdPERintpeace) (sdrile sdplaneco sdmarkeco sdwelfare sdintpeace)

foreach var of varlist PER104-PER705 rile planeco markeco welfare intpeace {
gen outlierlag`var' = .
by country, sort: replace outlierlag`var' = _N if `var'toplag==.
}

foreach var of varlist PER104-PER705 rile planeco markeco welfare intpeace {
by party, sort: gen SEM`var' = sd`var' * (sqrt(1 - rho`var'))
replace outlierlag`var' = . if `var'toplag ==0
replace outlierlag`var' = `var'lag1N if `var'toplag ==1
replace outlierlag`var' = `var'lag2N if `var'toplag ==2
replace outlierlag`var' = `var'lag3N if `var'toplag ==3
}





foreach var of varlist PER104-PER705 rile planeco markeco welfare intpeace {
gen res`var' = `var' - `var'point
replace `var'toplag = 0 if `var'toplag ==.
gen t`var' = invttail(((outlierlag`var' - 1) - `var'toplag), .025)
gen upper`var' = `var'point + (rho`var' * res`var') + (t`var' * SEM`var' * sqrt(rho`var'))
gen lower`var' = `var'point + (rho`var' * res`var') + (-1 * t`var' * SEM`var' * sqrt(rho`var'))
gen outlier`var'=0
replace outlier`var' = 1 if `var'point > upper`var' & upper`var' !=.
replace outlier`var' = 1 if `var'point < lower`var' & lower`var' !=.
}

rename (*rile* *planeco* *markeco* *welfare* *intpeace*) (*PER801* *PER802* *PER803* *PER804* *PER805*)

tempname sim
postfile `sim' country v N rho1 rho2 using "C:\data\outliersout_reliability.dta", every(1) replace
foreach country in 11 12 13 14 15 21 22 23 31 32 33 34 35 41 42 43 51 52 53 61 62 63 64 71 72 73 74 75 80 81 82 83 84 86 87 88 89 90 91 92 93 94 95 96 97 98 {
foreach v in 104 105 106 107 108 110 201 202 203 204 301 303 304 305 401 402 403 404 406 407 410 411 412 413 414 501 502 503 504 505 506 601 602 603 604 605 606 701 703 705 801 802 803 804 805 {
corr PER`v' PER`v'point if country==`country'
post `sim' (`country') (`v') (r(N)) (r(rho)) (.)
capture: corr PER`v' PER`v'point if country==`country' & outlierPER`v' !=1
post `sim' (`country') (`v') (r(N)) (.) (r(rho))
}
}
postclose `sim'

rename (*PER801* *PER802* *PER803* *PER804* *PER805*) (*rile* *planeco* *markeco* *welfare* *intpeace*)


preserve
use "C:\data\outliersout_reliability.dta", clear
gen N2 = N[_n+1] if rho2 ==.
replace rho2=rho2[_n+1] if rho2==. & rho2[_n+1] !=.
order country v N N2 rho1 rho2
tostring v, gen(varstr)
drop v
drop if rho1==. & rho2 !=.
duplicates drop country varstr, force
reshape wide rho1 rho2 N N2, i(country) j(varstr) string
save "C:\data\outliersout_reliability.dta", replace

restore

merge m:1 country using "C:\data\outliersout_reliability.dta"
drop _merge


compress

order rho*801

label variable rho1801 "Rile correlated with y-hat Rile, all data points"
label variable rho2801 "Rile correlated with y-hat Rile, outliers removed"

save "C:\data\9_19_2012.dta", replace

rename (rho1801 rho2801) (rho1rile rho2rile)
rename (rho1802 rho2802) (rho1planeco rho2planeco)
rename (rho1803 rho2803) (rho1markeco rho2markeco)
rename (rho1804 rho2804) (rho1welfare rho2welfare)
rename (rho1805 rho2805) (rho1intpeace rho2intpeace)

rename (rho1*) (rho1PER*)
rename (rho2*) (rho2PER*)

rename (rho1PERrile rho2PERrile) (rho1rile rho2rile)
rename (rho1PERplaneco rho2PERplaneco) (rho1planeco rho2planeco)
rename (rho1PERmarkeco rho2PERmarkeco) (rho1markeco rho2markeco)
rename (rho1PERwelfare rho2PERwelfare) (rho1welfare rho2welfare)
rename (rho1PERintpeace rho2PERintpeace) (rho1intpeace rho2intpeace)

foreach var of varlist PER104-PER705 rile planeco markeco welfare intpeace {
by country, sort: egen outlier`var'num = total(outlier`var')
by country, sort: egen x`var' = total(res`var'^2) if outlier`var' ==1
by country, sort: gen outlierSEM`var' = x`var' - (x`var' * sqrt(rho2`var'))
by country, sort: replace outlierSEM`var' = sqrt(outlierSEM`var' / outlier`var'num)* sqrt(rho2`var')
by country, sort: replace outlierSEM`var' = SEM`var' * (sqrt(rho2`var') / sqrt(rho1`var')) if outlierSEM`var' ==.
rename (SEM`var' outlierSEM`var') (firststageSEM`var' secondstageSEM`var')
}
//

//keep if country==51

//rename (N_CASES testresu totseats total) (enn_cases c_testresu c_totseats c_total)
//drop v* x* sd* N* upper* lower* t* *mean* *lag* *mean* outlier*num

compress
//rename (enn_cases c_testresu c_totseats c_total) (N_CASES testresu totseats total) 
order rho1rile rho2rile firststageSEMrile secondstageSEMrile party edate outlierrile

saveold "C:\data\9_22_2012.dta", replace

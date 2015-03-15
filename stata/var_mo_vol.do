cd /Users/research/GDrive/Dissertation/thesis/stata
import delim using language_mo3.csv, clear
merge 1:m year month using panel_mo_basic
drop _merge

collapse (mean) aret srisk=irisk turnover volume nyse_volume words vocab vent klent50 klent100 klent250 klent500 klent1000 klent2000, by(year month) 
keep if year > 1992 & year < 2004
//keep if year < 2004

gen date = ym(year, month)
format date %tm
tsset date
gen LVOL = log(volume)
gen lnyse_volume = log(nyse_volume)
gen lturnover = log(turnover)
gen lwords = log(words)
gen LCON  = (1 - klent1000)*100
 
 
egen svol = std(LVOL)
egen scon = std(LCON)

tsline svol scon, graphregion(color(white)) xtitle("") legend(lab(1 "log(VOLUME)") lab(2 "LCON")) name(m1, replace)
graph export "../figures/vol1.png", replace

tssmooth ma msvol = svol, w(3)
tssmooth ma mscon = scon, w(3)

tsline msvol mscon, graphregion(color(white)) xtitle("") legend(lab(1 "Smoothed log(VOLUME)") lab(2 "Smoothed LCON")) name(m2, replace)
graph export "../figures/vol2.png", replace

//check for optimal lags 
varsoc LCON LVOL, m(7)
//looks like 1 (SBIC HQIC), but 3 for others
vecrank LVOL LCON, lags(3)

set more off
vec LVOL LCON, r(1) lags(3) 
esttab using "../tex/vec1.tex", z nogaps wide compress replace
vecstable
veclmar, ml(9)

predict ce1 if e(sample), ce equ(#1)
tsline ce1 if e(sample)
//obvious from cointegration graph that problematic unless drop pre-1993

//test for short-run granger causality
test ([D_LVOL]: L2D.LVOL L2D.LCON) ([D_LCON]: L2D.LCON L2D.LVOL)
test ([D_LVOL]: LD.LCON L2D.LCON)
test ([D_LCON]: LD.LVOL L2D.LVOL) 

irf set vec_eg, replace
irf create vec_eg, step(12) replace
irf graph oirf, impulse(LCON) response(LVOL) yline(0) name(irf1, replace) graphregion(color(white))
irf graph oirf, impulse(LVOL) response(LCON) yline(0) name(irf2, replace) graphregion(color(white))



//robustness to nyse
vecrank LVOL lnyse_volume LCON, lags(3)
set more off
vec LVOL lnyse_volume LCON, r(1) lags(3) 
esttab using "../tex/vec2.tex", z nogaps wide compress replace


//robustness to diff top x
set more off
replace LCON = (1-klent50)*100
vec LVOL LCON, r(1) lags(3) 
est sto v1
replace LCON = (1-klent100)*100
vec LVOL LCON, r(1) lags(3) 
est sto v2
replace LCON = (1-klent250)*100
vec LVOL LCON, r(1) lags(3) 
est sto v3
replace LCON = (1-klent500)*100
vec LVOL LCON, r(1) lags(3) 
est sto v4
replace LCON = (1-klent1000)*100
vec LVOL LCON, r(1) lags(3) 
est sto v5
replace LCON = (1-klent2000)*100
vec LVOL LCON, r(1) lags(3) 
est sto v6
esttab v1 v2 v3 v4 v5 v6 using "../tex/vec3.tex", sca(r2_1 r2_2 aic sbic) star(+ 0.1 * 0.05 ** 0.01 *** 0.001) mtitle("Top 50" "Top 100" "Top 250" "Top 500" "Top 1k" "Top 2k") se nogaps compress replace

//robust to diff moving average

set more off
forvalues i=1(1)6 {
	import delim using language_mo`i'.csv, clear
	merge 1:m year month using panel_mo_basic
	drop _merge
	collapse (mean) volume klent2000, by(year month) 
	keep if year > 1992 & year < 2004
	gen date = ym(year, month)
	format date %tm
	tsset date
	gen LVOL = log(volume)
	gen LCON = (1-klent2000)*100
	vec LVOL LCON, r(1) lags(3) 
	est sto v`i'
}
esttab v1 v2 v3 v4 v5 v6 using "../tex/vec4.tex", sca(r2_1 r2_2 aic sbic) star(+ 0.1 * 0.05 ** 0.01 *** 0.001) mtitle("1 mos." "2 mos." "3 mos." "4 mos." "5 mos." "6 mos") se nogaps compress replace
//keep if year < 2004


//robustness of lcon with srisk

varsoc SRISK LCON, m(7)
vecrank ARET SRISK LCON, lags(3)
set more off

var SRISK D.LCON, lags(1/2) //ex(mfe1-mfe12 lnyse_volume)
vargranger
varstable
varlmar, ml(6)


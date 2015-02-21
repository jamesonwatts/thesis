cd /Users/research/GDrive/Dissertation/thesis/stata
import delim using language_mo.csv, clear
merge 1:m year month using panel_mo_basic
drop _merge

gen firms = 0
forvalues i=1993(1)2005 {
	count if year == `i' & month == 1
	replace firms = r(N) if year == `i'
}

collapse (mean) firms aret srisk=irisk turnover volume nyse_volume words vocab vent entropy=klent1000, by(year month) 
keep if year > 1992 & year < 2004

gen date = ym(year, month)
format date %tm
tsset date
gen lvolume = log(volume)
gen lnyse_volume = log(nyse_volume)
gen lturnover = log(turnover)
gen lwords = log(words)

gen lcon  = 1 - entropy

//rename and rescale variables
rename lvolume LVOL
rename lcon LCON
rename aret ARET
rename srisk SRISK
replace LCON = 100*LCON //note this in text


egen svol = std(lvolume)
egen scon = std(rlcon)

tsline svol scon, graphregion(color(white)) xtitle("") legend(lab(1 "log(VOLUME)") lab(2 "LCON")) name(m1, replace)
graph export "../figures/vol1.png", replace

tssmooth ma msvol = svol, w(3)
tssmooth ma mscon = scon, w(4)

tsline msvol mscon, graphregion(color(white)) xtitle("") legend(lab(1 "Smoothed log(VOLUME)") lab(2 "Smoothed LCON")) name(m2, replace)
graph export "../figures/vol2.png", replace



//check for optimal lags 
varsoc LCON LVOL, m(7)
//looks like 1 (SBIC HQIC), but 3 for others
vecrank LVOL LCON, lags(3)

set more off
vec LVOL LCON, r(1) lags(3) 
//est sto v1
esttab using "../tex/vec.tex", z nogaps wide compress replace
vecstable
veclmar, ml(9)

//test for short-run granger causality
test ([D_LVOL]: L2D.LVOL L2D.LCON) ([D_LCON]: L2D.LCON L2D.LVOL)
test ([D_LVOL]: LD.LCON L2D.LCON)
test ([D_LCON]: LD.LVOL L2D.LVOL) 

predict ce1 if e(sample), ce equ(#1)
tsline ce1 if e(sample)

//obvious from cointegration graph that problematic unless drop pre-1993
//also remember to talk about deseasonalization of lcon

irf set vec_eg, replace
irf create vec_eg, step(12) replace
irf graph oirf, impulse(LCON) response(LVOL) yline(0) name(irf1, replace) graphregion(color(white))
irf graph oirf, impulse(LVOL) response(LCON) yline(0) name(irf2, replace) graphregion(color(white))

irf graph oirf //

//robustness to nyse
vecrank LVOL lnyse_volume LCON, lags(3)
set more off
vec LVOL lnyse_volume LCON, r(1) lags(3) 

//robustness with srisk and aret
varsoc LVOL SRISK ARET LCON, m(7)
vecrank LVOL SRISK ARET LCON, lags(3)
set more off
vec LVOL SRISK ARET LCON, r(2) lags(3) 
vecstable
veclmar, ml(9)

irf set vec_eg, replace
irf create vec_eg, step(12) replace
irf graph oirf, impulse(LCON) response(LVOL) yline(0) name(irf1, replace) graphregion(color(white))
irf graph oirf, impulse(LCON) response(ARET) yline(0) name(irf2, replace) graphregion(color(white))
irf graph oirf, impulse(ARET) response(LCON) yline(0) name(irf2, replace) graphregion(color(white))
irf graph oirf, impulse(ARET) response(LVOL) yline(0) name(irf2, replace) graphregion(color(white))
irf graph oirf, impulse(LVOL) response(ARET) yline(0) name(irf2, replace) graphregion(color(white))


//robustness turnover
keep if year > 1997
varsoc turnover SRISK ARET LCON, m(7)
vecrank turnover SRISK ARET LCON, lags(3)
set more off
vec turnover SRISK ARET LCON, r(1) lags(3) 
vargranger
varstable
varlmar



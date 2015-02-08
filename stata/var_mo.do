cd /Users/research/GDrive/Dissertation/thesis/stata
//import delim using language_mo.csv, clear
//merge 1:m year month using panel_mo_basic
//drop _merge
use panel_mo_basic, clear
sort FID year month
by FID: gen t= _n
by FID: egen obs=max(t)
//keep if obs > 60 //5 years of trading data
//drop if date < date("1993/01/01","YMD")
drop if year < 1993
set matsize 800
collapse (mean) caret aret irisk turnover volume nyse_volume vent, by(year month) 
//collapse (mean) aret irisk turnover volume nyse_volume vent words klent1000 rank1000 churn1000, by(year month) 

gen t = _n
tsset t

tabulate year, gen(yfe)
tabulate month, gen(mfe)

gen lvolume = log(volume)
gen lnyse_volume  = log(nyse_volume)

forvalues p = 1/12 {
 qui reg L(0/`p').D.vent L.vent
 di "Lags =" `p'
 estat bgodfrey, lags(1 2 3)
} 
dfuller D.vent, l(3)
dfuller aret, l(0)
dfuller D.lvolume, l(0)
dfuller D.turnover, l(0)
dfuller irisk, l(0)

//choose lag level  
varsoc D.vent irisk D.lvolume aret, m(11) ex(D.lnyse_volume mfe1-mfe12)
//looks like lag of 3 based on majority of criteria
vecrank D.vent irisk D.lvolume caret, lags(3)
//no cointegration

//1998-2004
set more off
var D.vent irisk D.turnover caret, lags(1/3) 
vargranger
varstable //, graph
varlmar, ml(12)
varnorm
//1993-2004
set more off
var D.vent irisk D.lvolume caret, lags(1/12) ex(D.lnyse_volume mfe1-mfe12)
vargranger
varstable //, graph
varlmar, ml(12)
varnorm

irf create var1, set(varintro, replace) step(7)
irf graph irf, impulse(vent) response(turnover) yline(0)
irf graph irf, impulse(vent) response(wirisk) yline(0)


//portfolio graphs
use panel_mo_basic, clear
sort FID year month
by FID: gen t = _n
xtset FID t

replace emps = . if emps == -9
by FID: egen size = mean(emps)
gen lsize = log(size)
su lsize
gen big = lsize > r(mean) + r(sd)
gen small  = lsize < r(mean) - r(sd)
keep if small
drop if irisk == .

by FID: egen obs = count(t)
drop if obs < 48

gen lvolume = log(volume)

egen id=group(FID)
su id
global last = r(max)

set more off
//var D.vent irisk D.lvolume aret if id==1, lags(1/3) small
forvalues i=1(1)$last {
	display `i'
 	qui var D.vent irisk D.lvolume aret if id==`i', lags(1/3) small
	matrix b = e(b)
	qui vargranger
	matrix f = r(gstats)
	//for lag 3
	matrix s = (`i',f[5,1],(b[1,14]+b[1,15]+b[1,16]),f[9,1],(b[1,27]+b[1,28]+b[1,29]),f[13,1],(b[1,40]+b[1,41]+b[1,42]))
	//for lag 9
	//matrix s = (`i',f[5,1],(b[1,38]+b[1,39]+b[1,40]+b[1,41]+b[1,42]+b[1,43]+b[1,44]+b[1,45]+b[1,46]),f[9,1],(b[1,75]+b[1,76]+b[1,77]+b[1,78]+b[1,79]+b[1,80]+b[1,81]+b[1,82]+b[1,83]),f[13,1],(b[1,112]+b[1,113]+b[1,114]+b[1,115]+b[1,116]+b[1,117]+b[1,118]+b[1,119]+b[1,120]))
    if `i'==1 matrix stats=s
    else matrix stats=(stats \ s)
}
matrix colnames stats = id f_irisk b_irisk f_lvolume b_lvolume f_aret b_aret
matrix list stats
clear
svmat stats, names(col)

qui twoway scatter f_aret id, yline(1.5, lstyle(foreground)) name(f_aret, replace)
qui twoway scatter b_aret id, yline(0, lstyle(foreground)) name(b_aret, replace)
 gr combine f_aret b_aret, col(1) iscale(1)

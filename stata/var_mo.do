cd /Users/research/GDrive/Dissertation/thesis/stata
import delim using language_mo.csv, clear
merge 1:m year month using panel_mo_basic
drop _merge
sort FID year month
by FID: gen t= _n
by FID: egen obs=max(t)
//keep if obs > 60 //5 years of trading data
//drop if date < date("2000/12/31","YMD")
set matsize 800

collapse (mean) aret irisk turnover volume nyse_volume vent vrnk vchn words klent1000 rank1000 churn1000, by(year month) 

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
dfuller D.vent, l(9)
dfuller aret, l(0)
dfuller D.lvolume, l(0)
dfuller D.turnover, l(0)
dfuller irisk, l(0)

//choose lag level  
varsoc D.vent irisk D.lvolume aret, m(13) //ex(D.lnyse_volume yfe1-yfe13 mfe1-mfe12)
//looks like lag of 3 based on majority of criteria

//1998-2004
set more off
var D.vent irisk D.turnover aret, lags(1/9) 
vargranger
varstable //, graph
varlmar, ml(12)
varnorm
//1998-2004
set more off
var D.vent irisk D.lvolume aret, lags(1/9) 
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
su dc
gen hcent = dc > r(mean) + r(sd)
keep if hcent
drop if irisk == .
by FID: gen t = _n
xtset FID t

by FID: egen obs = count(t)
drop if obs < 60

gen lvolume = log(volume)

egen id=group(FID)
su id
global last = r(max)

set more off
forvalues i=1(1)$last {
	display `i'
 	qui var D.vent irisk D.lvolume aret if id==`i', lags(1/9) small
	matrix b = e(b)
	qui vargranger
	matrix f = r(gstats)
	//matrix s = (`i',f[5,1],(b[1,38]+b[1,39]+b[1,40]),f[9,1],(b[1,75]+b[1,76]+b[1,77]),f[13,1],(b[1,112]+b[1,113]+b[1,114]))
	matrix s = (`i',f[5,1],(b[1,38]+b[1,39]+b[1,40]+b[1,41]+b[1,42]+b[1,43]+b[1,44]+b[1,45]+b[1,46]),f[9,1],(b[1,75]+b[1,76]+b[1,77]+b[1,78]+b[1,79]+b[1,80]+b[1,81]+b[1,82]+b[1,83]),f[13,1],(b[1,112]+b[1,113]+b[1,114]+b[1,115]+b[1,116]+b[1,117]+b[1,118]+b[1,119]+b[1,120]))
    if `i'==1 matrix stats=s
    else matrix stats=(stats \ s)
}
matrix colnames stats = id f_irisk b_irisk f_lvolume b_lvolume f_aret b_aret
matrix list stats
clear
svmat stats, names(col)

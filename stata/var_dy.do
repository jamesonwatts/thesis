cd /Users/research/GDrive/Dissertation/thesis/stata
set matsize 800
use panel_dy_basic, clear
xtset FID t
//drop if date < date("1994/12/31","YMD")

gen fvalue = cshoc*prccd
egen sfvalue = total(fvalue), by(t)
egen fcount = count(FID), by(t)
gen vweight = fvalue/sfvalue
gen waret = aret*vweight 
collapse (mean) waret aret turnover volume=cshtrd nyse_volume words vocab entropy=klent1000, by(t) 
tsset t

//drop if t < 250

gen lvolume = log(volume)
gen lnyse_volume = log(nyse_volume)
gen lturnover = log(turnover)
gen lwords = log(words)

gen consensus  = 1 - entropy

tssmooth ma smvol=lvolume, w(60) replace
tssmooth ma smcon=consensus, w(60) replace
egen svol = std(smvol)
egen scon = std(smcon)

tsline svol scon, legend(lab(1 "volume") lab(2 "consensus")) ///
 name(m1, replace)


//check for stationarity
forvalues p = 1/24 {
 qui reg L(0/`p').D.lvolume L.lvolume
 di "Lags =" `p'
 estat bgodfrey, lags(1 2 3)
} 
//looks like 15 lags
dfuller turnover, lags(15)
//all good

forvalues p = 1/24 {
 qui reg L(0/`p').D.entropy L.entropy
 di "Lags =" `p'
 estat bgodfrey, lags(1 2 3)
} 
//looks like 23 or 24
dfuller entropy, lags(24)
//it's close. Probably want to do var in differences.
dfuller D.entropy, lags(24)


//check for optimal lags 
varsoc entropy lvolume, m(60) 
//looks like 19 (SBIC), 21 (HQIC), and 42 (FPE AIC)
vecrank lvolume consensus, lags(42)

set more off
var turnover D.consensus, la(1/24) ex(t lnyse_volume)
vargranger

set more off
vec lvolume entropy, r(1) lags(25)



//irf set vec_eg, replace
//irf create vec_eg, step(7) replace
//irf graph irf 




 

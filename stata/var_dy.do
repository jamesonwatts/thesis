cd /Users/research/GDrive/Dissertation/thesis/stata
use panel_dy_basic, clear
xtset FID t
//drop if date < date("2000/12/31","YMD")
set matsize 800
gen fvalue = cshoc*prccd
egen sfvalue = total(fvalue), by(t)
egen fcount = count(FID), by(t)
gen vweight = fvalue/sfvalue
gen waret = aret*vweight 
collapse (mean) waret aret turnover volume=cshtrd nyse_volume words vocab klent50 klent100 klent500 klent1000 klent2000, by(t) 
tsset t

gen lvolume = log(volume)
gen lnyse_volume = log(nyse_volume)
gen lturnover = log(turnover)
gen lwords = log(words)
reg klent100 lwords t //holidays yfe1-yfe13 mfe1-mfe12 wd1-wd5
predict entropy, r
reg lvolume lnyse_volume
predict rvolume, r

//check for stationarity
//dfgls turnover
dfuller turnover
kpss turnover
dfuller entropy
kpss entropy
dfuller aret
dfgls waret
kpss aret if 
//all stationarity diagnostics are cool


//check for optimal lags 
varsoc entropy aret turnover, m(30) 
//looks like 3, 11, and 23
set more off
var entropy rvolume, la(1/23) //ex(t lnyse_volume holidays yfe1-yfe13 mfe1-mfe12 wd1-wd5)
vargranger
varstable
varlmar, ml(10)

irf set vec_eg, replace
irf create vec_eg, step(7) replace
irf graph irf 


//check if it's just changes at all
gen adrank = abs(D.rrank)
var D.rvolume adrank, la(1/23) ex(price)

egen srank = std(rrank)
egen svolume = std(rvolume)
egen sklent = std(rklent)
tssmooth ma smrank=srank, w(60) replace
tssmooth ma smvolume=svolume, w(60) replace
tssmooth ma smklent=sklent, w(60) replace


tssmooth ma mklent=klent, w(60) replace
tsline mklent


tsline smvolume smrank, legend(lab(1 "volume") lab(2 "rank")) ///
 name(m1, replace)
tsline smvolume smklent, legend(lab(1 "volume") lab(2 "klent")) ///
 name(m2, replace)



 

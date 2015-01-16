cd /Users/research/GDrive/Dissertation/thesis/stata
use series_dy, clear
set matsize 800
set more off

//fix end of sample issue
//drop if datadate > date("2003/10/01","YMD")
drop if datadate > date("1998/01/01","YMD") | datadate < date("1995/01/01","YMD")
//drop if datadate < date("2000/01/01","YMD") | datadate > date("2003/10/01","YMD")

gen t = _n
tsset t

gen lvolume = log(volume)
gen lnyse_volume = log(nyse_volume)
gen lwords = log(words)

reg lvolume lnyse_volume 
predict rvolume, r

reg rank3 lwords wd1-wd5 holidays t
predict consensus, r

//check for stationarity
dfuller lvolume, //trend regress
dfgls lvolume
kpss lvolume
//null of unit root is rejected in favor of trend stationarity
dfgls consensus
kpss consensus
//all stationarity diagnostics are cool

//controls for causal structure
dfgls price
kpss price
dfgls volatility
kpss volatility

//check for optimal lags 
varsoc rvolume rklent price volatility, m(40) 
//looks like 21, 23 and 44
set more off
var D.rvolume D.consensus D.price, la(1/24)
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



 

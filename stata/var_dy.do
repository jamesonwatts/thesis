cd /Users/research/GDrive/Dissertation/thesis/stata
use series_dy, clear
set matsize 800
set more off

//fix end of sample issue
//drop if datadate > date("2003/10/01","YMD")
drop if datadate > date("1998/12/31","YMD") | datadate < date("1997/01/01","YMD")

gen t = _n
tsset t

gen efret = fret-rf

rolling, window(100) clear: arch efret mktrf smb hml umd, ar(1) //ma(1 4) earch(1) egarch(1)	


	
	//gen ht_1 = _b[_cons]+_b[L1.arch]*(L.r-_b[r:_cons])^2 


gen lwords = log(words)
reg rank2000 words
predict consensus, r

//check for stationarity
dfuller turnover //trend regress
dfgls turnover
kpss turnover
//null of unit root is rejected in favor of trend stationarity
dfgls consensus
kpss consensus
//all stationarity diagnostics are cool


//check for optimal lags 
varsoc turnover consensus, m(40) 
//looks like 21, 23 and 44
set more off
var turnover consensus fret, la(1/23) ex(t holidays yfe1-yfe13 mfe1-mfe12 wd1-wd5)
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



 

cd /Users/research/GDrive/Dissertation/thesis/stata
use series_mo,clear
gen t = _n
gen tt = t*t
tsset t

//seasonal indicators
tabulate month, gen(mfe)
tabulate year, gen(yfe)

drop if datadate > date("2003/10/01","YMD")
//drop if datadate > date("1998/01/01","YMD") | datadate < date("1992/01/01","YMD")
//drop if datadate < date("2000/01/01","YMD") | datadate > date("2003/10/01","YMD")

//logs fo volume
gen lnyse_volume = log(nyse_volume)
gen lvolume = log(volume)
gen lwords = log(words)

//sanitized volume measure
reg lvolume lnyse_volume volatility firms yfe1-yfe13
predict rvolume, r

reg rank lwords firms yfe1-yfe13
predict rrank, r

pwcorr rvolume rrank words firms

//regular regressions
reg lvolume L.lvolume L(0/1).rank lwords lnyse_volume volatility firms mfe1-mfe12 yfe1-yfe13
rvfplot
reg rvolume L.rvolume rrank
rvfplot
reg rrank L.rrank rvolume

//check stationarity
dfuller rvolume
dfgls rvolume
kpss rvolume

dfgls rrank
kpss rrank 
//looks like variables on nonstationary

//choose lag level  
varsoc rvolume rrank, m(6)
//looks like lag of 3 based on majority of criteria

//check cointigration 
vecrank rvolume rrank, la(5) si(t tt)
//there is at most 1 cointegrating equation, thus we can use vec not var)


set more off
vec rvolume rrank, r(1) lags(3) t(rt)
vecstable, graph
veclmar
vecnorm


irf create vec1, set(vecintro, replace) step(6)
irf graph oirf, impulse(rank) response(rvolume) yline(0)
irf graph oirf, impulse(words) response(rvolume) yline(0)




egen svolume = std(lvolume)
egen srank = std(rank)
tsline svolume srank, legend(lab (1 "volume") lab(2 "rank")) ///
 name(l1, replace)
tsline D.svolume D.srank, legend(lab (1 "volume") lab(2 "rank")) ///
 name(d1, replace)
egen srvolume = std(rvolume)
egen srrank = std(rrank)
tsline srvolume srrank, legend(lab (1 "volume") lab(2 "rank")) ///
 name(l1, replace)




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
reg lvolume lnyse_volume volatility mfe1-mfe12 firms
predict rvolume, r

reg rank lwords volatility mfe1-mfe12 firms
predict rrank, r

reg avg_clstr nodes edges mfe1-mfe12 t
predict rclstr, r

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

dfuller rrank
dfgls rrank
kpss rrank 

dfgls rclstr
kpss rclstr
dfuller rclstr
//looks like variables are stationary at lag < 1

//choose lag level  
varsoc rvolume rrank, m(6)
//looks like lag of 3 based on majority of criteria

//check cointigration 
vecrank rvolume rrank, la(1) t(rt) si(t tt)
//there is no cointegrating equation, thus we can use vec not var)


set more off
var D.rvolume D.rrank, lags(1/3)
varstable //, graph
varlmar
varnorm


irf create vec1, set(vecintro, replace) step(6)
irf graph oirf, impulse(rank) response(rvolume) yline(0)
irf graph oirf, impulse(words) response(rvolume) yline(0)

//on clustering

varsoc rclstr rrank, m(6)
vecrank rclstr rrank, la(1)

var D.avg_clstr D.rrank, la(1)

egen svolume = std(rvolume)
egen srank = std(rrank)
egen sclstr  = std(rclstr)
tsline svolume srank, legend(lab (1 "volume") lab(2 "rank")) ///
 name(l1, replace)
tsline D.svolume D.srank, legend(lab (1 "volume") lab(2 "rank")) ///
 name(d1, replace)
egen srvolume = std(rvolume)
egen srrank = std(rrank)
tsline srvolume srrank, legend(lab (1 "volume") lab(2 "rank")) ///
 name(l1, replace)




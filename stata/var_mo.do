cd /Users/research/GDrive/Dissertation/thesis/stata
use series_mo,clear
gen t = _n
tsset t

//seasonal indicators
tabulate month, gen(mfe)

//logs fo volume
gen lnyse_volume = log(nyse_volume)
gen lvolume = log(volume)

//sanitized volume measure
reg lvolume lnyse_volume
predict rvolume, r
//sanitized uncertainty measure
reg unc nyse_volatility
predict runc, r

//drop if t < 21 | t > 103 //first two years are messy and crash of 2000

egen svolume = std(lvolume)
egen sunc = std(runc)
egen srank = std(rank)

pwcorr rvolume runc firms rank churn words

//check stationarity
dfgls rvolume
kpss rvolume

dfgls rank
kpss rank 

//looks like variables on nonstationary

tsline svolume srank, legend(lab (1 "unc") lab(2 "rank")) ///
 name(l1, replace)
tsline D.svolume D.srank, legend(lab (1 "unc") lab(2 "rank")) ///
 name(d1, replace) 

//choose lag level  
varsoc rvolume rank words, m(6)
//looks like lag of 1 based on all criteria


//check cointigration 
vecrank runc rank, la(1)
//there is at most 1 cointegrating equation, thus we can use vec not var)


set more off
vec unc rank, lags(1) si(mfe1-mfe12 ) trend(c)

predict ce1 if e(sample), ce equ(#1)
tsline ce1 if e(sample)

vecstable, graph
vecnorm
veclmar

irf create vec1, set(vecintro, replace) step(12)
irf graph oirf, impulse(rank) response(unc) yline(0)
irf graph oirf, impulse(unc) response(rank) yline(0)





set more off
var D.runc D.rank, la(1/3) ex(mfe1-mfe12 firms)
varstable
varnorm



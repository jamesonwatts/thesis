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

drop if t < 21 | t > 105 //first two years are messy and crach of 2000

egen svolume = std(rvolume)
egen sunc = std(unc)
egen srank = std(rank)


pwcorr rvolume unc firms rank churn words

tsline sunc srank, legend(lab (1 "volume") lab(2 "rank")) ///
 name(l1, replace)
tsline D.svolume D.srank, legend(lab (1 "volume") lab(2 "rank")) ///
 name(d1, replace) 

//choose lag level  
varsoc rvolume rank unc, m(6)
//looks like lag of 3 based on all criteria

//check cointigration 
vecrank rvolume rank unc, la(3)
//there is at most 0 cointegrating equation, thus we can use var not vec)

set more off
var D.rvolume D.rank D.unc, la(1/3) ex(mfe1-mfe12 firms)
varstable
varnorm


set more off
vec rvolume rank, lags(3) si(mfe1-mfe12) trend(c)

predict ce1 if e(sample), ce equ(#1)
tsline ce1 if e(sample)


vecstable, graph
vecnorm
veclmar

irf create vec1, set(vecintro, replace) step(12)
irf graph oirf, impulse(rank) response(lvolume) yline(0)
irf graph oirf, impulse(lvolume) response(rank) yline(0)



//how many lags?
varsoc dlvolume drank, m(4)
//it suggests 2
var D.lvolume D.rank, lags(1/2)

varstable, graph
varlmar

//with covariates
var D.lvolume D.rank, ex(firms words) lags(1/2)

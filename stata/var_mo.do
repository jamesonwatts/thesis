cd /Users/research/GDrive/Dissertation/thesis/stata
use series_mo,clear

gen lvolume = ln(volume)
gen rank = 1-rank2000
egen slvolume = std(lvolume)
egen srank = std(rank)
egen schurn = std(churn)

gen t = _n

tsset t
drop if t > 79

tsline slvolume srank, legend(lab (1 "ln(volume)") lab(2 "rank")) ///
 name(l1, replace)
tsline D.slvolume D.srank, legend(lab (1 "ln(volume)") lab(2 "rank")) ///
 name(d1, replace) 

//choose lag level (looks like lag of one based on all criteria)
varsoc lvolume rank words

//check cointigration (there is at most 1 cointegrating equation, thus must use vec not var)
vecrank lvolume rank

set more off
vec lvolume rank , lags(3)
veclmar 

predict ce1, ce equ(#1)
twoway line ce1 t
 
vecnorm

irf create vec1, set(vecintro, replace) step(24)
irf graph oirf, impulse(rank) response(lvolume) yline(0)
irf graph oirf, impulse(lvolume) response(rank) yline(0)


//now a regular var model
gen dlvolume = D.lvolume
gen drank = D.rank

set more off
var dlvolume drank
//how many lags?
varsoc dlvolume drank, m(4)
//it suggests 2
var D.lvolume D.rank, lags(1/2)

varstable, graph
varlmar

//with covariates
var D.lvolume D.rank, ex(firms words) lags(1/2)

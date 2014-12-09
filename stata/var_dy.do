cd /Users/research/GDrive/Dissertation/thesis/stata

use series_dy, clear

gen lvolume = ln(volume)
gen rank = 1-rank1500

gen t = _n
tsset t

set more off
var D.volume D.churn, lags(1/10)
varstable
vargranger
varnorm


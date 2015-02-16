cd /Users/research/GDrive/Dissertation/thesis/stata
import delim using language_mo.csv, clear
merge 1:m year month using panel_mo_basic
drop _merge

collapse (mean) aret srisk=irisk turnover volume nyse_volume words vocab vent entropy=klent1000, by(year month) 
keep if year > 1992

gen date = ym(year, month)
format date %tm
tsset date
gen lvolume = log(volume)
gen lnyse_volume = log(nyse_volume)
gen lturnover = log(turnover)
gen lwords = log(words)

gen lcon  = 1 - entropy

tabulate year, gen(yfe)
tabulate month, gen(mfe)
gen tt = year - 1990

//deseasonalized variables
reg lcon mfe1-mfe12
predict rlcon, r
reg lvolume lnyse_volume
predict rlvolume, r

egen svol = std(lvolume)
egen scon = std(rlcon)

tsline svol scon, legend(lab(1 "volume") lab(2 "rlcon")) ///
 name(m1, replace)

//also show moving average and then argue for cointegration.

//check for stationarity
forvalues p = 1/12 {
 qui reg L(0/`p').D.lvolume L.lvolume
 di "Lags =" `p'
 estat bgodfrey, lags(1 2 3)
} 
//looks like no autocorrelation
dfuller lvolume //but not stationary
kpss lvolume //check for stationary in level seems ok
dfuller D.lvolume // looks like stationary in difference

forvalues p = 1/12 {
 qui reg L(0/`p').D.lcon L.lcon
 di "Lags =" `p'
 estat bgodfrey, lags(1 2 3)
} 
//looks like 2
dfuller lcon, lags(2)
//It's close at 1% level. Probably want to do var in differences.
dfuller D.lcon, lags(2) //ok


//check for optimal lags 
varsoc rlcon lvolume, m(7)
//looks like 1 (SBIC HQIC FPE AID), but 4 for (LR)
vecrank lvolume rlcon, lags(4)

set more off
vec lvolume lcon, r(1) lags(4) 
vecstable
veclmar, ml(9)

predict ce1 if e(sample), ce equ(#1)
tsline ce1 if e(sample)

//obvious from cointegration graph that problematic unless drop pre-1993
//also remember to talk about deseasonalization of lcon

irf set vec_eg, replace
irf create vec_eg, step(12) replace
irf graph irf, impulse(lcon) response(lvolume) yline(0) name(irf1, replace)
irf graph irf, impulse(lvolume) response(lcon) yline(0) name(irf2, replace)

//robustness in vec
vecrank lvolume srisk aret rlcon, lags(4)
set more off
vec lvolume srisk rlcon, r(1) lags(4) 
vecstable
veclmar, ml(9)



//robustness
dfuller rvolume
kpss rvolume
forvalues p = 1/12 {
 qui reg L(0/`p').D.srisk L.srisk
 di "Lags =" `p'
 estat bgodfrey, lags(1 2 3)
} 
dfuller srisk
kpss srisk

forvalues p = 1/12 {
 qui reg L(0/`p').D.aret L.aret
 di "Lags =" `p'
 estat bgodfrey, lags(1 2 3)
 } 
dfuller aret, lags(2) //lag 2
varsoc D.rlcon aret srisk rvolume, m(13)
vecrank rlcon aret srisk rlvolume, lags(2) //no cointegration


//structurated
set more off
var rlcon aret srisk rlvolume, la(1/2) ex(words) small
vargranger
varstable
varlmar, ml(9)
varnorm

//with turnover
forvalues p = 1/12 {
 qui reg L(0/`p').D.turnover L.turnover
 di "Lags =" `p'
 estat bgodfrey, lags(1 2 3)
 } 
dfuller turnover //no lag but need diff

varsoc D.rlcon aret srisk D.turnover, m(7) //two lags
set more off
var D.rlcon aret srisk D.turnover, la(1/2) small
vargranger
varstable
varlmar, ml(9)
varnorm


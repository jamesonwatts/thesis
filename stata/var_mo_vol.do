cd /Users/research/GDrive/Dissertation/thesis/stata
import delim using language_mo.csv, clear
merge 1:m year month using panel_mo_basic
drop _merge

collapse (mean) aret irisk turnover volume nyse_volume words vocab vent entropy=klent1000, by(year month) 
drop if year < 1993

gen date = ym(year, month)
format date %tm
tsset date
gen lvolume = log(volume)
gen lnyse_volume = log(nyse_volume)
gen lturnover = log(turnover)
gen lwords = log(words)

gen consensus  = 1 - entropy

tabulate year, gen(yfe)
tabulate month, gen(mfe)
gen tt = year - 1990
egen snvol = std(lnyse_volume)
egen svol = std(lvolume)
egen scon = std(consensus)

tsline svol scon, legend(lab(1 "volume") lab(2 "consensus")) ///
 name(m1, replace)


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
 qui reg L(0/`p').D.consensus L.consensus
 di "Lags =" `p'
 estat bgodfrey, lags(1 2 3)
} 
//looks like 4
dfuller consensus, lags(4)
//It's close at 1% level. Probably want to do var in differences.
dfuller D.consensus, lags(4) //ok


//check for optimal lags 
varsoc consensus lvolume, m(13)
//looks like 1 (SBIC HQIC), 3 (FPE AIC)
vecrank lvolume consensus, lags(4)

set more off
vec consensus lvolume, r(1) lags(4) 
vecstable
veclmar, ml(9)

predict ce1 if e(sample), ce equ(#1)
tsline ce1 if e(sample)


irf set vec_eg, replace
irf create vec_eg, step(7) replace
irf graph irf, impulse(consensus) response(lvolume) yline(0) name(irf1, replace)
irf graph irf, impulse(lvolume) response(consensus) yline(0) name(irf2, replace)


//robustness
reg lvolume lnyse_volume
predict rvolume, r
dfuller rvolume
kpss rvolume

varsoc consensus rvolume, m(13)
vecrank rvolume consensus, lags(4)
set more off
var D.consensus rvolume, la(1/3)
vargranger
varstable
varlmar, ml(9)


//risk
//check for stationarity
forvalues p = 1/12 {
 qui reg L(0/`p').D.irisk L.irisk
 di "Lags =" `p'
 estat bgodfrey, lags(1 2 3)
} 

dfuller irisk
kpss irisk
varsoc consensus irisk, m(13)
vecrank consensus irisk
set more off
var consensus irisk, la(1/4)
vargranger
varstable
varlmar, ml(9)

//abnormal returns
//check for stationarity
forvalues p = 1/12 {
 qui reg L(0/`p').D.aret L.aret
 di "Lags =" `p'
 estat bgodfrey, lags(1 2 3)
} 
//lag 2
dfuller aret, lags(2)
varsoc consensus aret, m(13)
vecrank consensus aret, lags(3)
set more off
var consensus aret, la(1/4)
vargranger
varstable
varlmar, ml(9)


//structurated
set more off
var consensus aret irisk rvolume, la(1/4)
vargranger
varstable
varlmar, ml(9)

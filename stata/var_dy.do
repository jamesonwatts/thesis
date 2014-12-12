cd /Users/research/GDrive/Dissertation/thesis/stata
use series_dy, clear
set matsize 800
set more off
//seasonal indicators
gen month = month(datadate)
gen day = day(datadate)
tabulate month, gen(mfe)
gen holidays = (month == 12 & day >= 20 & day <= 31) 
gen dow = dow(datadate)
tabulate dow, gen(wd)
gen monday = (dow==1)
//fix end of sample issue
drop if datadate > date("2004/10/01","YMD")
//drop if datadate > date("1999/01/01","YMD")

gen t = _n
gen tt = t*t
tsset t

gen lvolume = log(volume)
gen lnyse_volume = log(nyse_volume)


reg lvolume lnyse_volume
predict rvolume, r

reg rank words
predict rrank, r


pwcorr lvolume words vocab churn rank

//check for stationarity
dfuller rvolume, lags(15) trend regress
pperron rvolume, lags(15) trend regress
kpss rvolume //, maxlag(15) 
//null of unit root is rejected in favor of trend stationarity
dfuller rank, lags(45) trend regress
pperron rank, lags(45) trend regress
kpss rank, maxlag(45)
//null of unit root is also rejected in favor of trend stationarity


//check for optimal lags (23/45/64)
varsoc rvolume rank words, m(50) ex(wd1-wd5 holidays) 

varbasic D.rvolume D.rank D.words, la(1/23)

set more off
var D.lvolume D.rank D.words, la(1/5) ex(wd1-wd5 holidays D.lnyse_volume) 
varlmar, ml(5)
varnorm
vargranger
varstable, graph

irf create order1, set(varintro, replace) step(5) 
irf graph oirf, impulse(D.rank) response(D.rvolume)
irf graph oirf, impulse(D.words) response(D.rvolume)


egen swords = std(words)
egen srank = std(rank)
egen svolume = std(volume)
egen srrank = std(rrank)
egen srvolume = std(rvolume)
//tsline svolume srank, legend(lab (1 "volume") lab(2 "rank")) ///
// name(l1, replace)
//tsline D.sunc D.srank, legend(lab (1 "volume") lab(2 "rank")) ///
// name(d1, replace) 

tssmooth ma smrank=srank, w(60) replace
tssmooth ma smvolume=svolume, w(60) replace
tssmooth ma smwords=swords, w(60) replace

tsline smvolume smrank smwords, legend(lab(1 "volume") lab(2 "rank") lab(3 "words")) ///
 name(m1, replace)


 
 
 
 
 
 
 //check for cointegration rank (1)
vecrank lvolume rank, la(45) si(wd1-wd5 holidays nyse_volume) 


set more off
vec lnyse_volume lvolume rank, r(1) la(45) si(wd1-wd5 holidays) 
vecstable, graph
veclmar 
vecnorm

predict ce1, ce equ(#1)
twoway line ce1 t



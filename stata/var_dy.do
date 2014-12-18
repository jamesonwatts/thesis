cd /Users/research/GDrive/Dissertation/thesis/stata
use series_dy, clear
set matsize 800
set more off
//seasonal indicators
gen year = year(datadate)
tabulate year, gen(yfe)
gen month = month(datadate)
tabulate month, gen(mfe)
gen day = day(datadate)
tabulate day, gen(dfe)
gen holidays = (month == 12 & day >= 20 & day <= 31) 
gen dow = dow(datadate)
tabulate dow, gen(wd)
//week of month
gen week = week(datadate) 
//The first trading day of each month is given by 
gen first = mdy(month(datadate), 1, year(datadate)) 
//except that we must adjust Saturdays and Sundays: 
replace first = cond(dofw(first) == 0, first + 1, cond(dow(first) == 6, first + 2, first))
//So week in month would be 
replace week = week - week(first) + 1 
tabulate week, gen(wom)


//fix end of sample issue
drop if datadate > date("2003/10/01","YMD")
//drop if datadate > date("1998/01/01","YMD") | datadate < date("1992/01/01","YMD")
//drop if datadate < date("2000/01/01","YMD") | datadate > date("2003/10/01","YMD")

gen t = _n
gen tt = t*t
tsset t

gen lvolume = log(volume)
gen lnyse_volume = log(nyse_volume)
gen lwords = log(words)

reg lvolume lnyse_volume mfe1-mfe12 wd1-wd5 holidays
predict rvolume, r

reg rank words mfe1-mfe12 wd1-wd5 holidays
predict rrank, r

pwcorr rvolume words vocab churn rrank

//check regular regressions
reg lvolume L(1/3).lvolume L(1/2).rank L(1/2).lwords t tt lnyse_volume
reg rvolume L(1/3).rvolume L(1/2).rrank

rvfplot


//check for stationarity
dfuller rvolume, //trend regress
dfgls rvolume
dfgls rvolume, notrend
kpss rvolume
//null of unit root is rejected in favor of trend stationarity
dfgls rrank
dfgls rrank, notrend
kpss rrank

//xcorr rrank rvolume, lags(30) table
//check for optimal lags 
varsoc rvolume rrank, m(60) //ex(t tt)
//looks like 43
set more off
var D.rvolume D.rrank, la(1/43) //ex(t tt)
varstable
varlmar, ml(23)
vargranger

irf set vec_eg, replace
irf create vec_eg, step(7) replace
irf graph irf 


//cointegrated version
vecrank rvolume rrank, la(23) //t(rt) 
set more off
vec rvolume rrank, r(1) la(23) //t(rt)
vecstable
veclmar, ml(10)

irf set vec_eg, replace
irf create vec_eg, step(50) replace
irf graph irf 


egen srank = std(rrank)
egen svolume = std(rvolume)

tssmooth ma smrank=srank, w(60) replace
tssmooth ma smvolume=svolume, w(60) replace

tsline smvolume smrank, legend(lab(1 "volume") lab(2 "rank")) ///
 name(m1, replace)


 

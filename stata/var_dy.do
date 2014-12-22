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


reg lvolume lnyse_volume L(0/2).volatility firms mfe1-mfe12 wd1-wd5 holidays
predict rvolume, r

reg rank words volatility firms mfe1-mfe12 wd1-wd5 holidays t tt
predict rrank, r

reg klent words volatility firms mfe1-mfe12 wd1-wd5 holidays t tt
predict rklent, r

pwcorr rvolume words vocab churn klent rrank


//check regular regressions
reg lvolume L(1/10).lvolume L(0/3).rank L(0/3).lwords L(0/5).volatility firms t tt mfe1-mfe12 wd1-wd5 holidays lnyse_volume
reg lvolume L(1/10).lvolume L(0/3).klent L(0/3).lwords L(0/5).volatility firms t tt mfe1-mfe12 wd1-wd5 holidays lnyse_volume
reg rvolume L(1/10).rvolume L(0/3).rrank

rvfplot


//check for stationarity
dfuller rvolume, //trend regress
dfgls rvolume
kpss rvolume
//null of unit root is rejected in favor of trend stationarity
dfgls rrank
kpss rrank
//rklent
dfgls rklent
kpss rklent
//volatility
dfgls volatility
kpss volatility
//all stationarity diagnostics are cool

//check for optimal lags 
varsoc rvolume rklent, m(60) 
//looks like 21, 23 and 44
set more off
var D.rvolume D.rklent, la(1/23) ex(D.price)
varstable
vargranger
varlmar, ml(15)

irf set vec_eg, replace
irf create vec_eg, step(7) replace
irf graph irf 


//check if it's just changes at all
gen adrank = abs(D.rrank)
var D.rvolume adrank, la(1/23) ex(price)

egen srank = std(rrank)
egen svolume = std(rvolume)
egen sklent = std(rklent)
tssmooth ma smrank=srank, w(60) replace
tssmooth ma smvolume=svolume, w(60) replace
tssmooth ma smklent=sklent, w(60) replace


tssmooth ma mklent=klent, w(60) replace
tsline mklent


tsline smvolume smrank, legend(lab(1 "volume") lab(2 "rank")) ///
 name(m1, replace)
tsline smvolume smklent, legend(lab(1 "volume") lab(2 "klent")) ///
 name(m2, replace)



 

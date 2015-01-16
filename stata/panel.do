cd /Users/research/GDrive/Dissertation/thesis/stata
use panel_dy, clear

drop if datadate > date("1999/12/31","YMD") | datadate < date("1995/01/01","YMD")
drop if !public

//gen dm = mofd(datadate)
//format dm %tm
//xtset FID dm, monthly
xtset FID datadate

//gen t = year - 1990

gen lvolume = log(1+cshtrd)
gen lnyse_volume = log(nyse_volume)
gen lwords = log(words)
gen size = log(emps)
gen lprice = log(prccd)

gen act_div = 1-(((d_r/d)^2)+((d_f/d)^2)+((d_l/d)^2)+((d_c/d)^2)+((d_o/d)^2))
gen frm_div = 1-(((n_bio/d)^2)+((n_npr/d)^2)+((n_gov/d)^2)+((n_fin/d)^2)+((n_pha/d)^2)+((n_oth/d)^2))


//basic regression
global controls "lprice nyse_volume mfe1-mfe12"
su size
gen big = size > r(mean)+r(sd)
pvar2 lvolume rank1000 lprice, lags(5)
xtregar lvolume big#c.L.rank50 $controls, fe 

xtregar lvolume c.act_div##c.rank2000 $controls, fe 



//detrend the data
reg lvolume lnyse_volume 
predict rvolume, r

reg rank1 lwords
predict rrank, r

margins, dydx(L.rrank) at(ec=(0.1(0.02)0.3))
marginsplot


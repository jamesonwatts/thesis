cd /Users/research/GDrive/Dissertation/thesis/stata

//drop if datadate > date("1999/12/31","YMD")

use panel_dy_sample, clear
sort FID datadate
egen id=group(FID)
save tmp, replace

forvalues i=1(1)50 {
	use tmp, clear
	rolling, window(250) clear: arch efret mktrf smb hml umd if id==`i', ar(1) //arch(1) egarch(1)
	rename end t
	save four_factor_`i', replace
}  



gen act_div = 1-(((d_r/d)^2)+((d_f/d)^2)+((d_l/d)^2)+((d_c/d)^2)+((d_o/d)^2))
gen frm_div = 1-(((n_bio/d)^2)+((n_npr/d)^2)+((n_gov/d)^2)+((n_fin/d)^2)+((n_pha/d)^2)+((n_oth/d)^2))

reg rank2000 lwords t
predict rrank, r

//pvarsoc turnover rank2000

pvar2 turnover rrank, lags(4)
pvargranger
pvarstable

//regular regressions
global controls "lprice nyse_volume yfe1-yfe13 mfe1-mfe12"

xtregar lturnover big L.rrank $controls, fe 

xtregar lvolume c.act_div##c.rank2000 $controls, fe 

su size
gen big = size > r(mean)
su act_div
gen div = act_div > r(mean)

margins, dydx(L.rrank) at(ec=(0.1(0.02)0.3))
marginsplot


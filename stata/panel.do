cd /Users/research/GDrive/Dissertation/thesis/stata
use panel_dy_sample, clear

//drop if datadate > date("1998/12/31","YMD") | datadate < date("1998/01/01","YMD")
drop if !public
drop if turnover == .

sort FID datadate
by FID: generate t=_n
tsset FID t

by FID: gen fret = (price-price[_n-1])/price[_n-1]
by FID: gen efret = efret-rf 

reg efret mktrf smb hml umd if FID==30 & t < 30
arch efret mktrf smb hml umd if FID==30 & t < 250, earch(1) egarch(1)

gen pret=.
egen id=group(FID)
su id
forvalues i=1(1)r(max) { /*note: replace N with the highest value of id */ 
	l id FID if id==`i'
	arch , ar(1) ma(1 4) earch(1) egarch(1) if id==`i' & estimation_window==1 
	predict p if id==`i'
	replace predicted_return = p if id==`i' & event_window==1 
	drop p
}  

arch D.ln_wpi, ar(1) ma(1 4) earch(1) egarch(1)


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


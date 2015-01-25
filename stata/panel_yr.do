cd /Users/research/GDrive/Dissertation/thesis/stata

use panel_yr, clear
//drop if turnover == .
xtset FID year

gen tt = year-1990
gen lvolume = log(volume)
gen lnyse_volume = log(nyse_volume)
gen size = log(emps)
gen act_div = 1-(((d_r/d)^2)+((d_f/d)^2)+((d_l/d)^2)+((d_c/d)^2)+((d_o/d)^2))
gen frm_div = 1-(((n_bio/d)^2)+((n_npr/d)^2)+((n_gov/d)^2)+((n_fin/d)^2)+((n_pha/d)^2)+((n_oth/d)^2))

//regular regressions
global controls "size yfe1-yfe14"
xtregar aret irisk lvolume dc L.klent500 tt $controls, fe 

gen size_klent = size*klent50

xtabond2 lvolume L.lvolume aret irisk klent50 size_klent $controls, gmm (aret irisk lvolume klent50 $controls, lag(4 4)) iv(international) robust


margins, dydx(L.klent500) at(dc=(0(0.01)0.1))
marginsplot


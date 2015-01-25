cd /Users/research/GDrive/Dissertation/thesis/stata
set more off
use panel_mo, clear
xtset FID t

gen lvolume = log(volume)
gen lnyse_volume = log(nyse_volume)
gen size = log(emps)
gen act_div = 1-(((d_r/d)^2)+((d_f/d)^2)+((d_l/d)^2)+((d_c/d)^2)+((d_o/d)^2))
gen frm_div = 1-(((n_bio/d)^2)+((n_npr/d)^2)+((n_gov/d)^2)+((n_fin/d)^2)+((n_pha/d)^2)+((n_oth/d)^2))

//regular regressions
global controls "international size yfe1-yfe13 mfe1-mfe12"

xtreg turnover volatility aret klent500 $controls, fe robust

xtreg volatility aret turnover c.act_div##c.klent500 $controls, fe robust

margins, dydx(klent500) at(act_div=(0(0.1)1))
marginsplot


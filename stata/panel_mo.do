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


cd /Users/research/GDrive/Dissertation/thesis/stata
import delim using language_mo.csv, clear

gen lcon = 1-klent1000
collapse words vocab lcon, by(year)

import delim using language_mo.csv, clear
gen lcon = 1-klent1000
tabulate month, gen(mfe)

keep if year < 2004

gen date = ym(year, month)
format date %tm
tsset date

tsline lcon, graphregion(color(white)) xtitle("Date") ytitle("Language Consistency")
graph export "../figures/lcon1.png", replace
//issue with first couple of years and there may be some seasonality

keep if year > 1992
su lcon
//deseasonalize
//reg lcon mfe1-mfe12
//predict lcon, r

tsline lcon, graphregion(color(white)) ytitle("LCON") xtitle("") name(lcon,replace)
tsline D.lcon, graphregion(color(white)) ytitle("D.LCON") xtitle("") name(d_lcon,replace)
gr combine lcon d_lcon, col(1) iscale(1) graphregion(color(white))
graph export "../figures/lcon2.png", replace

tsline lcon, graphregion(color(white)) ytitle("LCON") xtitle("") xline(`=ym(1994,05)', lw(2) lc(gs15)) xline(`=ym(1997,1)', lw(2) lc(gs15)) xline(`=ym(2001,7)', lw(2) lc(gs15)) name(lcon_h,replace)
graph export "../figures/lcon3.png", replace

gen diff = lcon-L.lcon
su diff
replace hd = diff > r(mean) + 2*r(sd)
count if hd == 1


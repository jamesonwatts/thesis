cd /Users/research/GDrive/Dissertation/thesis/stata
import delim using language_mo.csv, clear

gen lcon = 1-klent2000
collapse words vocab lcon, by(year)

import delim using language_mo.csv, clear
gen lcon = 1-klent2000
tabulate month, gen(mfe)

gen date = ym(year, month)
format date %tm
tsset date

tsline lcon, graphregion(color(white)) xtitle("Date") ytitle("Language Consistency")
graph export "../figures/lcon1.png", replace
//issue with first couple of years and there may be some seasonality

keep if year > 1992
//deseasonalize
reg lcon mfe1-mfe12
predict rlcon, r

tsline rlcon, graphregion(color(white)) ytitle("LCON") xtitle("") name(lcon,replace)
tsline D.rlcon, graphregion(color(white)) ytitle("D.LCON") xtitle("") name(d_lcon,replace)
gr combine lcon d_lcon, col(1) iscale(1) graphregion(color(white))
graph export "../figures/lcon2.png", replace

tsline rlcon, graphregion(color(white)) ytitle("LCON") xtitle("") xline(`=ym(1994,6)', lw(2) lc(gs15)) xline(`=ym(1997,1)', lw(2) lc(gs15)) xline(`=ym(1999,8)', lw(2) lc(gs15)) xline(`=ym(2001,7)', lw(2) lc(gs15)) name(lcon,replace)
graph export "../figures/lcon3.png", replace

tsline D3.rlcon, graphregion(color(white)) xtitle("") 
graph export "../figures/lcon_lower.png", replace

gen diff = rlcon-L.rlcon
su diff
replace hd = diff > r(mean) + 2*r(sd)
count if hd == 1


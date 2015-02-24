cd /Users/research/GDrive/Dissertation/thesis/stata

use panel_yr, clear

sort year
by year: egen srisk = mean(irisk)
gen lsale = log(sale)

xtset FID year
keep if year > 1992 //& year < 2004

xtreg lemps l.lemps ecp i.year, fe
xtivreg lemps l.lemps i.year (ecp=d_r), fe
xtdpdsys lemps y1-y17, end(ecp) two vce(robust)

xtreg sale l.sale ecp i.year, fe
xtivreg sale l.sale i.year (ecp=d_r), fe
xtdpdsys sale y1-y17, end(ecp) two vce(robust)

xtreg nopi l.nopi ecp i.year, fe
xtivreg nopi l.nopi i.year (ecp=d_r), fe
xtdpdsys nopi y1-y17, end(ecp) two vce(robust)

xtreg patents l.patents ecp i.year, fe
xtivreg patents l.patents i.year (ecp=d_r), fe

xtdpdsys patents y1-y17, end(ecp) two vce(robust)

//with interactions

gen lmvcon = l.mvcon
gen mvecp = lmvcon*mecp
gen mvec = lmvcon*mec
gen mvdc = lmvcon*mdc

xtdpdsys lemps mvecp mlexp mlage y6-y17, end(lmvcon mecp) two vce(robust)
xtdpdsys lemps mvec mlexp mlage y6-y17, end(lmvcon mec) two vce(robust)
xtdpdsys lemps mvdc mlexp mlage y6-y17, end(lmvcon mdc) two vce(robust)

//age and experience not providing help
xtdpdsys sale mvecp y6-y17, end(lmvcon mecp) two vce(robust)
xtdpdsys sale mvec y6-y17, end(lmvcon mec) two vce(robust)
xtdpdsys sale mvdc y6-y17, end(lmvcon mdc) two vce(robust)

xtdpdsys nopi mvecp mlexp mlage y6-y17, end(lmvcon mecp) two vce(robust)
xtdpdsys nopi mvec mlexp mlage y6-y17, end(lmvcon mec) two vce(robust)
xtdpdsys nopi mvdc mlexp mlage y6-y17, end(lmvcon mdc) two vce(robust)

xtdpdsys patents mvecp mlexp mlage y6-y17, end(lmvcon mecp) two vce(robust)
xtdpdsys patents mvec mlexp mlage y6-y17, end(lmvcon mec) two vce(robust)
xtdpdsys patents mvdc mlexp mlage y6-y17, end(lmvcon mdc) two vce(robust)

xtdpdsys caret mvecp mlexp mlage y6-y17, end(lmvcon mecp irisk) two vce(robust)
xtdpdsys caret mvec mlexp mlage y6-y17, end(lmvcon mec irisk) two vce(robust)
xtdpdsys caret mvdc mlexp mlage y6-y17, end(lmvcon mdc irisk) two vce(robust)


//abnormal returns
set more off
xtdpdsys caret l.mvcon mve y1-y17, end(mec irisk) two vce(robust)
estat abond //, art(5)
vif, uncentered


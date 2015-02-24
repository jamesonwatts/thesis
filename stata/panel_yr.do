cd /Users/research/GDrive/Dissertation/thesis/stata

use panel_yr, clear

sort year
by year: egen srisk = mean(irisk)
gen lsale = log(sale)

xtset FID year

xtreg lemps l.lemps ec i.year, fe
xtivreg emps l.emps i.year (ec=d_r), fe
xtdpdsys lemps y1-y17, end(ec) two vce(robust)

xtreg sale l.sale ec i.year, fe
xtivreg sale l.sale i.year (ec=d_r), fe
xtdpdsys sale y1-y17, end(ec) two vce(robust)

xtreg nopi l.nopi ec i.year, fe
xtivreg nopi l.nopi i.year (ec=d_r), fe
xtdpdsys nopi y1-y17, end(ec) two vce(robust)

//with interactions
//keep if year > 1992 //& year < 2004
gen mve = l.mvcon*mec

xtdpdsys lemps l.mvcon mve y1-y17, end(mec) two vce(robust)
estat abond
vif, uncentered

xtdpdsys sale l.mvcon mve y1-y17, end(mec) two vce(robust)
estat abond
vif, uncentered

xtdpdsys nopi l.mvcon mve y1-y17, end(mec) two vce(robust)
estat abond
vif, uncentered


//abnormal returns
set more off
xtdpdsys aret l(0/2).(mvcon vep) mlexp mlage y6-y17, end(mec_pro mirisk, lags(2,.)) two vce(robust)
estat abond //, art(5)
vif, uncentered


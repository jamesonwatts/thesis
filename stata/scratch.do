//old regressions
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


sort year
by year: egen srisk = mean(irisk)


gen firms = 0
forvalues i=1993(1)2005 {
	count if year == `i' & month == 1
	replace firms = r(N) if year == `i'
}

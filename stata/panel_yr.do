cd /Users/research/GDrive/Dissertation/thesis/stata
use panel_yr, clear
set more off
sort year
by year: egen srisk = mean(irisk)
//keep if year > 1888 & year < 1999
keep if year > 1992 & emps != . //& year < 2000
//keep if year == 1993

sort year
by year: count if FID != .
by year: count if nopi != .
by year: count if caret != .
by year: count if public == 1
by year: su d

xtset FID year

replace patents = patents + pto1976 if year == 1993
replace patents2 = patents2 + pto1976 if year == 1993
bysort FID: gen tpat1 = sum(patents)
bysort FID: gen tpat2 = sum(patents2)
gen expr2 = expr*expr
replace vcon = 100*vcon
replace mvcon = 100*mvcon

la var d_r "R\&D Ties"
la var act_div "Diversity"
la var expr "Experience"
la var expr2 "Experience^2"
la var ecp "Centrality"
la var mecp "Centrality"
la var vcon "Lang Uncert."
la var mvcon "Lang Uncert."
la var patents2 "New Patents"
la var tpat2 "Cum. Patents"
la var sale "Sales"
la var nopi "Nonop. Income"
la var aret "Abnorm. Ret."
la var emps "Employees"
la var age "Age"
la var irisk "Idiosync. Risk"

sutex d_r act_div expr ecp patents2 tpat2 vcon sale nopi aret irisk emps age, title("Summary Statistics") lab min nobs file("../tex/summary.tex") replace
corrtex d_r act_div expr ecp patents2 tpat2 vcon sale nopi aret irisk emps age, title("Variable Correlations") file("../tex/corr.tex") replace


//employees: 
set more off
xtreg emps L.emps L.nopi I.year, fe
est sto m1
xtabond2 emps L.emps L.nopi I.year, gmm(L.emps L2.nopi, c) iv(I.year) two orthogonal robust noleveleq
est sto m2
//however doesn't appear to be driven by centrality?
xtivreg emps L.emps (L.nopi = mecp) I.year, fe
est sto m3
esttab m1 m2 m3 using "../tex/reg1.tex", nogaps l mtitle("Fixed Effects" "Arrellano-Bond" "Cent. $\rightarrow$ Nonop. Inc.") sca(r2_w hansenp ar2p) star(+ 0.1 * 0.05 ** 0.01 *** 0.001) drop(1994.year 1995.year 1996.year 1997.year 1998.year 1999.year 2000.year 2001.year 2002.year 2003.year _cons) replace

//sales: 
set more off
xtreg sale L.sale L.nopi I.year, fe
est sto m1
xtabond2 sale L.sale L.nopi I.year, gmm(L.sale L2.nopi, c) iv(I.year) two orthogonal robust noleveleq
est sto m2
xtivreg sale L.sale (L.nopi = mecp) I.year, fe
est sto m3
esttab m1 m2 m3 using "../tex/reg2.tex", nogaps l mtitle("Fixed Effects" "Arrellano-Bond" "Cent. $\rightarrow$ Nonop. Inc.") sca(r2_w hansenp ar2p) r2 star(+ 0.1 * 0.05 ** 0.01 *** 0.001) drop(1994.year 1995.year 1996.year 1997.year 1998.year 1999.year 2000.year 2001.year 2002.year 2003.year _cons) replace

//maybe driven by uncertainty in the environment
xtivreg emps L.emps (L.nopi = LC.mvcon##C.mecp) I.year, fe
xtabond2 emps L.emps L.nopi I.year, gmm(L.emps L2.nopi L2C.mvcon##LC.mecp, c) iv(I.year) two orthogonal robust noleveleq
xtivreg sale L.sale (L.nopi = LC.mvcon##C.mecp L.tpat2) I.year, fe
xtabond2 sale L(1/2).sale L.nopi I.year, gmm(L(1/2).sale L2.nopi L2C.mvcon##LC.mecp, c) iv(I.year) two orthogonal robust noleveleq
//absolutely in the case of sales... less so in the case of employee growth.
xtabond2 sale L(1/2).sale LC.mvcon##C.mecp L.nopi I.year, gmm(L(1/2).sale L2.nopi L2C.mvcon##LC.mecp, c) iv(I.year) two orthogonal robust noleveleq


//now let's look at centrality's effect on non operating income. Again we start with with Powell et al. 1999 model
xtreg nopi L.nopi mecp L.tpat2 I.year, fe
xtabond2 nopi L.nopi mecp L.tpat2 I.year, gmm(L.nopi L.mecp L2.tpat2, c) iv(I.year) two orthogonal robust noleveleq
//here the main effect of centrality is absent.
//it's possible that patents have shifted to the primary signal of quality rather than centrality
xtreg nopi L.nopi LC.mvcon##C.mecp LC.srisk##C.mecp L.tpat2 I.year, fe
xtabond2 nopi L.nopi LC.mvcon##C.mecp L.tpat2 I.year, gmm(L.nopi L2C.mvcon##LC.mecp L2.tpat2, c) iv(I.year) two orthogonal robust noleveleq
//however, interestingly the effect is pronounced under language uncertainty. 
//The value of existing patents may not tell us as much about future performance
//post hoc... both interactions
xtreg nopi L.nopi LC.mvcon##C.mecp LC.mvcon##LC.tpat2 I.year, fe
xtabond2 nopi L.nopi LC.mvcon##C.mecp LC.mvcon##LC.tpat2 I.year, gmm(L.nopi L2C.mvcon##LC.mecp L2C.mvcon##LC2.tpat2, c) iv(I.year) two orthogonal robust noleveleq


//now let's look at centrality's effect on R&D ties. Again we start with with Powell et al. 1999 model
xtreg d_r L.d_r L.mecp L2.emps L2.public I.year, fe
xtivreg d_r L.d_r (L2.public = L.mecp) I.year, fe
xtreg d_r L.d_r L2C.mvcon##LC.mecp I.year, fe
xtabond2 d_r L.d_r L2C.mvcon##LC.mecp I.year, gmm(L.d_r L3C.mvcon##L2C.mecp) iv(I.year) two orthogonal robust noleveleq
//opposite.

//now on to substantive

//patents: r&d to diversity and experience through centrality
xtreg patents2 L.patents2 L.tpat2 mecp act_div d_r L.expr L.expr2 I.year, fe
//this holds, however # of employees is also significant which might signal an ability to produce patents included and main effect disappears
xtreg patents2 L.patents2 L.tpat2 mecp act_div d_r L.expr L.expr2 L.emps I.year, fe
//however, two-stage effect is still there... centrality is an instrument for R&D, expr and diversity
xtivreg patents2 L.patents2 L.tpat2 (mecp = act_div d_r L.expr L.expr2) L.emps I.year, fe
//controlling for learning component of network there might still be a signaling effect
xtreg patents2 L.patents2 L.tpat2 LC.mvcon##C.mecp act_div d_r L.expr L.expr2 L.emps I.year, fe
xtreg patents2 L.patents2 L.tpat2 LC.mvcon##C.mecp L.emps I.year, fe
xtabond2 patents2 L.patents2 L.tpat2 LC.mvcon##C.mecp act_div d_r L.expr L.expr2 L.emps I.year, gmm(L.patents2 L.tpat2 L2C.mvcon##LC.mecp L.act_div L.d_r L2.expr L2.expr2 L2.emps, c) iv(I.year) two orthogonal robust noleveleq
//this could be due to more likely to be approved etc.
//however, the portion of centrality that's due to learning should not be affected (leave size as an instrument of centrality effect)
xtabond2 patents2 L.patents2 L.tpat2 LC.mvcon##C.mecp L.emps I.year, gmm(L.patents2 L.tpat2 L2C.mvcon##LC.mecp L2.emps, c) iv(I.year) two orthogonal robust noleveleq
//exactly... when centrality is capturing the "access" effect on patents the interaction is non-existent.
//possibly non-negative because of opposing effects. Move to abnormal returns.

//abnormal returns
xtreg caret L.caret mecp irisk lvolume act_div L.age L.expr I.year, fe
xtreg caret L.caret LC.mvcon##C.mecp L(0/2).irisk act_div L.age L.expr I.year, fe
xtabond2 aret L.aret LC.mvcon##C.mecp L(0/2).irisk act_div L.age L.expr I.year, gmm(L.aret L2C.mvcon##LC.mecp L3.irisk L.act_div L2.age L2.expr, c) iv(I.year) two orthogonal robust noleveleq

//steps
//difference gmm with forward orthogonal transformation
//when instruments > n, I collapsed them to single colume vector.
//if ar(2) test or hansen test fails first add additional lags of dependent variable
//second, try system gmm which adds additional instruments

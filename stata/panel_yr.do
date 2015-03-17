cd /Users/research/GDrive/Dissertation/thesis/stata
use panel_yr, clear
set more off
sort year
by year: egen srisk = mean(irisk)
//keep if year > 1888 & year < 1999
keep if year > 1992 & emps != . 
//keep if year == 1993

sort year
by year: count if FID != .
by year: count if nopi != .
by year: count if caret != .
by year: count if public == 1
by year: su d

xtset FID year

//replace patents = patents + pto1976 if year == 1993
//replace patents2 = patents2 + pto1976 if year == 1993
bysort FID: gen tpat1 = sum(patents)
replace tpat1 = tpat1+pto1976
bysort FID: gen tpat2 = sum(patents2)
replace tpat2 = tpat2+pto1976
gen expr2 = expr*expr
replace vcon = 100*vcon
replace mvcon = 100*mvcon

la var d_r "R\&D Ties"
la var act_div "Diversity"
la var expr "Experience"
la var expr2 "Experience^2"
la var ecp "Centrality"
la var mecp "Centrality"
la var vcon "Lang Unc."
la var mvcon "Lang Unc."
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
xtivreg emps L.emps (L.nopi = L.mecp) I.year, fe
est sto m3
esttab m1 m2 m3 using "../tex/reg1.tex", se nogaps l mtitle("Fixed Effects" "Arellano-Bond" "Cent. $\rightarrow$ Nonop. Inc.") sca(r2_w hansenp ar2p) star(+ 0.1 * 0.05 ** 0.01 *** 0.001) drop(1994.year 1995.year 1996.year 1997.year 1998.year 1999.year 2000.year 2001.year 2002.year 2003.year _cons) replace

//sales: 
set more off
xtreg sale L.sale L.nopi I.year, fe
est sto m1
xtabond2 sale L.sale L.nopi I.year, gmm(L.sale L2.nopi, c) iv(I.year) two orthogonal robust noleveleq
est sto m2
xtivreg sale L.sale (L.nopi = L.mecp) I.year, fe
est sto m3
esttab m1 m2 m3 using "../tex/reg2.tex", se nogaps l mtitle("Fixed Effects" "Arellano-Bond" "Cent. $\rightarrow$ Nonop. Inc.") sca(r2_w hansenp ar2p) star(+ 0.1 * 0.05 ** 0.01 *** 0.001) drop(1994.year 1995.year 1996.year 1997.year 1998.year 1999.year 2000.year 2001.year 2002.year 2003.year _cons) replace

//now let's look at centrality's effect on non operating income. Again we start with with Powell et al. 1999 model
set more off
xtreg nopi L.nopi mecp L.emps I.year, fe
est sto m1
xtabond2 nopi L.nopi mecp L.emps I.year, gmm(L.nopi L.mecp L2.emps, c) iv(I.year) two orthogonal robust noleveleq
est sto m2
xtabond2 nopi L.nopi LC.mvcon##C.mecp L.emps I.year, gmm(L.nopi L2C.mvcon##LC.mecp L2.emps) iv(I.year) two orthogonal robust noleveleq
est sto m3
esttab m1 m2 m3 using "../tex/reg3.tex", se nogaps l mtitle("Fixed Effects" "Arellano-Bond" "Lang Uncert x Cent.") sca(r2_w hansenp ar2p) star(+ 0.1 * 0.05 ** 0.01 *** 0.001) drop(1994.year 1995.year 1996.year 1997.year 1998.year 1999.year 2000.year 2001.year 2002.year 2003.year _cons) replace

//maybe driven by uncertainty in the environment
set more off
xtivreg emps L.emps (L.nopi = L2C.mvcon##LC.mecp) I.year, fe
est sto m1
xtivreg sale L.sale (L.nopi = L2C.mvcon##LC.mecp) I.year, fe
est sto m2 //voila!!
esttab m1 m2 using "../tex/reg4.tex", se nogaps l mtitle("Lang Unc. x Cent. $\rightarrow$ Nonop. Inc." "Lang Unc. x Cent. $\rightarrow$ Nonop. Inc.") sca(r2_w) star(+ 0.1 * 0.05 ** 0.01 *** 0.001) drop(1995.year 1996.year 1997.year 1998.year 1999.year 2000.year 2001.year 2002.year 2003.year _cons) replace

//now on to substantive


//patents: 
set more off
xtreg patents2 L.patents2 L.tpat2 mecp I.year if public, fe
est sto m1
xtabond2 patents2 L.patents2 L.tpat2 mecp I.year if public, gmm(L.patents2 L.tpat2 L.mecp, c) iv(I.year) two orthogonal robust noleveleq
est sto m2
xtivreg patents2 L.patents2 L.tpat2 (mecp = d_r) I.year if public, fe
est sto m3
esttab m1 m2 m3 using "../tex/reg5.tex", se nogaps l mtitle("Fixed Effects" "Arellano-Bond" "R\&D $\rightarrow$ Cent.") sca(r2_w hansenp ar2p) star(+ 0.1 * 0.05 ** 0.01 *** 0.001) drop(1994.year 1995.year 1996.year 1997.year 1998.year 1999.year 2000.year 2001.year _cons) replace
//no main effect

//abnormal returns
set more off
xtreg aret L.aret mecp L(0/2).irisk act_div L.emps I.year, fe
est sto m1 
xtabond2 aret L.aret mecp L(0/2).irisk act_div L.emps I.year, gmm(L.aret L.mecp L3.irisk L.act_div L2.emps, c) iv(I.year) two orthogonal robust noleveleq
est sto m2
xtivreg aret L.aret act_div L.emps L(0/2).irisk (mecp = d_r) I.year, fe
est sto m3
esttab m1 m2 m3 using "../tex/reg6.tex", se nogaps l mtitle("Fixed Effects" "Arellano-Bond" "R\&D $\rightarrow$ Cent.") sca(r2_w hansenp ar2p) star(+ 0.1 * 0.05 ** 0.01 *** 0.001) drop(1995.year 1996.year 1997.year 1998.year 1999.year 2000.year 2001.year 2002.year 2003.year _cons) replace
//no main effect

//maybe the effect of R&D on performance is more direct rather than traveling through experience and diversity

//patents and aret with interaction
set more off
xtabond2 patents2 L.patents2 L.tpat2 LC.mvcon##C.mecp I.year if public, gmm(L.patents2 L2.tpat2 L2C.mvcon##LC.mecp, c) iv(I.year) two orthogonal robust noleveleq
est sto m1
xtabond2 aret L.aret LC.mvcon##C.mecp L(0/2).irisk act_div L.emps I.year, gmm(L.aret L2C.mvcon##LC.mecp L3.irisk L.act_div L2.emps, c) iv(I.year) two orthogonal robust noleveleq
est sto m2
esttab m1 m2 using "../tex/reg7.tex", se nogaps l mtitle("Patents" "Abnorm. Ret.") sca(r2_w hansenp ar2p) star(+ 0.1 * 0.05 ** 0.01 *** 0.001) drop(1995.year 1996.year 1997.year 1998.year 1999.year 2000.year 2001.year 2002.year 2003.year) replace

//now let's look at centrality's effect on R&D ties. 
set more off
xtreg d_r L.d_r L.mecp I.year, fe
est sto m1
xtabond2 d_r L.d_r L.mecp I.year, gmm(L.d_r L2.mecp) iv(I.year) two orthogonal robust noleveleq
est sto m2
xtabond2 d_r L.d_r L2C.mvcon##LC.mecp I.year, gmm(L.d_r L3C.mvcon##L2C.mecp) iv(I.year) two orthogonal robust noleveleq
est sto m3
esttab m1 m2 m3 using "../tex/reg8.tex", se nogaps l mtitle("Fixed Effects" "Arellano-Bond" "Lang Uncert x Cent.") sca(r2_w hansenp ar2p) star(+ 0.1 * 0.05 ** 0.01 *** 0.001) drop(1994.year 1995.year 1996.year 1997.year 1998.year 1999.year 2000.year 2001.year 2002.year 2003.year _cons) replace



//graphs
set more off
reg nopi L.nopi LC.vcon##C.ecp L.tpat2 I.FID
margins, dydx(ecp) at(L.vcon=(0.3(0.1)1.1)) 
marginsplot


set more off
reg d_r L.d_r L2C.vcon##LC.ecp //I.year
margins, dydx(L.ecp) at(L2.vcon=(0.3(0.1)1.1)) 
marginsplot


xtabond2 aret L.aret LC.vcon##C.ecp L(0/2).irisk act_div L.patents2 I.year, gmm(L.aret L2C.vcon##LC.ecp L3.irisk, c) iv(I.year) two orthogonal robust noleveleq
margins, dydx(ecp) at(L.vcon=(0.3(0.1)1.1)) nose
marginsplot


//steps
//difference gmm with forward orthogonal transformation
//when instruments > n, I collapsed them to single colume vector.
//if ar(2) test or hansen test fails first add additional lags of dependent variable
//second, try system gmm which adds additional instruments

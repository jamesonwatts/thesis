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
xtreg nopi L.nopi mecp L.tpat2 I.year, fe
est sto m1
xtabond2 nopi L.nopi mecp L.tpat2 I.year, gmm(L.nopi L.mecp L2.tpat2, c) iv(I.year) two orthogonal robust noleveleq
est sto m2
xtabond2 nopi L.nopi LC.mvcon##C.mecp L.tpat2 I.year, gmm(L.nopi L2C.mvcon##LC.mecp L2.tpat2) iv(I.year) two orthogonal robust noleveleq
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
xtreg patents2 L.patents2 L.tpat2 mecp I.year, fe
est sto m1
xtabond2 patents2 L.patents2 L.tpat2 mecp I.year, gmm(L.patents2 L.mecp, c) iv(I.year) two orthogonal robust noleveleq
est sto m2
xtivreg patents2 L.patents2 L.tpat2 (mecp = L.act_div L2.expr L2.expr2) I.year, fe
est sto m3
esttab m1 m2 m3 using "../tex/reg5.tex", se nogaps l mtitle("Fixed Effects" "Arellano-Bond" "Div \& Expr. $\rightarrow$ Cent.") sca(r2_w hansenp ar2p) star(+ 0.1 * 0.05 ** 0.01 *** 0.001) drop(1994.year 1995.year 1996.year 1997.year 1998.year 1999.year 2000.year 2001.year 2002.year 2003.year _cons) replace
//no main effect

//abnormal returns
set more off
xtreg aret L.aret mecp L(0/2).irisk I.year, fe
est sto m1 
xtabond2 aret L.aret mecp L(0/2).irisk I.year, gmm(L.aret L.mecp L3.irisk, c) iv(I.year) two orthogonal robust noleveleq
est sto m2
xtivreg aret L.aret (mecp = L.act_div L2.expr L2.expr2) I.year, fe
est sto m3
esttab m1 m2 m3 using "../tex/reg6.tex", se nogaps l mtitle("Fixed Effects" "Arellano-Bond" "Div \& Expr. $\rightarrow$ Cent.") sca(r2_w hansenp ar2p) star(+ 0.1 * 0.05 ** 0.01 *** 0.001) drop(1995.year 1996.year 1997.year 1998.year 1999.year 2000.year 2001.year 2002.year 2003.year _cons) replace
//no main effect

//maybe the effect of R&D on performance is more direct rather than traveling through experience and diversity
set more off
xtivreg aret L.aret (mecp = d_r) I.year, fe
est sto m1
xtivreg patents2 L.patents2 L.tpat2 (mecp = d_r) I.year, fe
est sto m2
//okay, but only 3% variation explained by cent from r&d
esttab m1 m2 using "../tex/reg7.tex", se nogaps l mtitle("R\&D $\rightarrow$ Centrality" "R\&D $\rightarrow$ Centrality") sca(r2_w) star(+ 0.1 * 0.05 ** 0.01 *** 0.001) drop(1994.year 1995.year 1996.year 1997.year 1998.year 1999.year 2000.year 2001.year 2002.year 2003.year _cons) replace
//so what's going on????

//patents and aret with interaction
xtabond2 patents2 L.patents2 L.tpat2 LC.mvcon##C.mecp act_div L.expr L.expr2 I.year, gmm(L.patents2 L2.tpat2 L2C.mvcon##LC.mecp L.act_div L2.expr L2.expr2, c) iv(I.year) two orthogonal robust noleveleq
xtabond2 aret L.aret LC.mvcon##C.mecp L(0/2).irisk act_div L.expr L.expr2 I.year, gmm(L.aret L2C.mvcon##LC.mecp L3.irisk L.act_div L2.expr L2.expr2, c) iv(I.year) two orthogonal robust noleveleq








//post-hoc

//centrality:
set more off
xtreg ecp L.ecp L.act_div L2.expr L2.expr2 I.year, fe
est sto m1
xtabond2 ecp L.ecp L.act_div L2.expr L2.expr2 I.year, gmm(L.ecp L2.act_div L3.expr L3.expr2, c) iv(I.year) two orthogonal robust noleveleq
est sto m2
xtivreg ecp L.ecp (L.act_div = L.d_r) I.year, fe
est sto m3
xtivreg ecp L.ecp (L2.expr = L.d_r) I.year, fe
est sto m4
esttab m1 m2 m3 m4 using "../tex/reg5.tex", se nogaps l mtitle("Fixed Effects" "Arellano-Bond" "R\&D $\rightarrow$ Div." "R\&D $\rightarrow$ Expr." ) sca(r2_w hansenp ar2p) star(+ 0.1 * 0.05 ** 0.01 *** 0.001) drop(1994.year 1995.year 1996.year 1997.year 1998.year 1999.year 2000.year 2001.year 2002.year 2003.year _cons) replace
//nothin... what about direct effect of R&D?


//centrality direct effect of R&D controlling for others.
set more off
xtreg ecp L.ecp L.d_r L.act_div L2.expr L2.expr2 I.year, fe
est sto m1
xtabond2 ecp L.ecp L.d_r L.act_div L2.expr L2.expr2 I.year, gmm(L.ecp L2.d_r L2.act_div L3.expr L3.expr2, c) iv(I.year) two orthogonal robust noleveleq
est sto m2
esttab m1 m2 using "../tex/reg6.tex", se nogaps l mtitle("Fixed Effects" "Arellano-Bond") sca(r2_w hansenp ar2p) star(+ 0.1 * 0.05 ** 0.01 *** 0.001) drop(1995.year 1996.year 1997.year 1998.year 1999.year 2000.year 2001.year 2002.year 2003.year _cons) replace
//nope. but remember the interaction... let's look 


//now let's look at centrality's effect on R&D ties. Again we start with with Powell et al. 1999 model
xtreg d_r L.d_r L.mecp L2.emps L2.public I.year, fe
xtivreg d_r L.d_r (L2.public = L.mecp) I.year, fe
xtreg d_r L.d_r L2C.mvcon##LC.mecp I.year, fe
xtabond2 d_r L.d_r L2C.mvcon##LC.mecp I.year, gmm(L.d_r L3C.mvcon##L2C.mecp) iv(I.year) two orthogonal robust noleveleq
//opposite.


//steps
//difference gmm with forward orthogonal transformation
//when instruments > n, I collapsed them to single colume vector.
//if ar(2) test or hansen test fails first add additional lags of dependent variable
//second, try system gmm which adds additional instruments

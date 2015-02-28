cd /Users/research/GDrive/Dissertation/thesis/stata
use panel_yr, clear

sort year
by year: egen srisk = mean(irisk)

xtset FID year
//keep if year > 1888 & year < 1999
keep if year > 1992 //& year < 2000

replace patents = patents + pto1976 if year == 1993
replace patents2 = patents2 + pto1976 if year == 1993
bysort FID: gen tpat1 = sum(patents)
bysort FID: gen tpat2 = sum(patents2)
gen expr2 = expr*expr

//employees: 
xtreg emps L.emps L.nopi I.year, fe
xtabond2 emps L.emps L.nopi I.year, gmm(L.emps L2.nopi, c) iv(I.year) two orthogonal robust noleveleq
//however doesn't appear to be driven by centrality?
xtivreg emps L.emps (L.nopi = mecp) I.year, fe
//let's look at whether nopi is `instrument' for centrality's effect
xtabond2 emps L.emps L.nopi I.year, gmm(L.emps L2.nopi L.mecp, c) iv(I.year) two orthogonal robust noleveleq
//yes... let's check sales.

//sales: I also find that # of employess is a predictor unlike 1999
xtreg sale L.sale L.nopi I.year, fe
xtabond2 sale L.sale L.nopi I.year, gmm(L.sale L2.nopi) iv(I.year) two orthogonal robust noleveleq
//also no driven by centrality ...hmmm
xtivreg sale L.sale (L.nopi = mecp) I.year, fe
xtabond2 sale L(1/2).sale L.nopi I.year, gmm(L(1/2).sale L2.nopi L.mecp, c) iv(I.year) two orthogonal robust noleveleq
//ok but the effect is directional and marginal at best

//maybe driven by uncertainty in the environment
xtivreg emps L.emps (L.nopi = LC.mvcon##C.mecp L.tpat2) I.year, fe
xtabond2 emps L.emps L.nopi I.year, gmm(L.emps L2.nopi L2C.mvcon##LC.mecp, c) iv(I.year) two orthogonal robust noleveleq
xtivreg sale L.sale (L.nopi = LC.mvcon##C.mecp L.tpat2) I.year, fe
xtabond2 sale L(1/2).sale L.nopi I.year, gmm(L(1/2).sale L2.nopi L2C.mvcon##LC.mecp, c) iv(I.year) two orthogonal robust noleveleq
//absolutely in the case of sales... less so in the case of employee growth.


//now let's look at centrality's effect on non operating income. Again we start with with Powell et al. 1999 model
xtreg nopi L.nopi L.mvcon mecp L.patents2 I.year, fe
//here the main effect of centrality is absent.
xtreg nopi L.nopi LC.mvcon##C.mecp L.patents2 I.year, fe
xtabond2 nopi L.nopi mecp L.tpat2 I.year, gmm(L.nopi L.mecp L2.tpat2, c) iv(I.year) two orthogonal robust noleveleq
xtabond2 nopi L.nopi LC.mvcon##C.mecp L.patents2 I.year, gmm(L.nopi L2C.mvcon##LC.mecp L2.patents2, c) iv(I.year) two orthogonal robust noleveleq


//now let's look at centrality's effect on R&D ties. Again we start with with Powell et al. 1999 model
xtreg d_r L.d_r mecp I.year, fe
//here the main effect of centrality is absent.
xtreg d_r L.d_r LC.mvcon##C.mecp I.year, fe
xtabond2 d_r L.d_r LC.mvcon##C.mecp I.year, gmm(L.d_r L2C.mvcon##LC.mecp) iv(I.year) two orthogonal robust noleveleq
//not supported. Done with symbolic

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
xtregc aret L.caret mecp irisk lvolume act_div L.age L.expr L.expr2 d_r L.tpat2 L.emps I.year, fe
xtreg caret L.caret mecp irisk lvolume act_div L.age L.expr I.year, fe
xtreg caret L.caret LC.mvcon##C.mecp irisk lvolume act_div L.age L.expr I.year, fe
xtabond2 caret L.caret LC.mvcon##C.mecp irisk lvolume act_div L.age L.expr I.year, gmm(L.caret L2C.mvcon##LC.mecp irisk lvolume L.act_div L2.age L2.expr, c) iv(I.year) two orthogonal robust noleveleq

//steps
//difference gmm with forward orthogonal transformation
//when instruments > n, I collapsed them to single colume vector.
//if ar(2) test or hansen test fails first add additional lags of dependent variable
//second, try system gmm which adds additional instruments

cd /Users/research/GDrive/Dissertation/thesis/stata
use panel_yr, clear

xtset FID year
//keep if year > 1888 & year < 1999
keep if year > 1992
global exog = "act_div mlexp mlage foreign I.year"
gen r_ties = d_r
gen o_ties = d-d_r

//employees: centrality
xtreg emps L.emps mecp $exog, fe
xtreg emps L.emps LC.mvcon##C.mecp $exog, fe
xtabond2 emps L.emps mecp $exog, gmm(L.emps L.mecp) iv($exog) two orthogonal robust noleveleq
xtabond2 emps L.emps LC.mvcon##C.mecp $exog, gmm(L.emps L2C.mvcon##LC.mecp) iv($exog) two orthogonal robust noleveleq

//non operating income: centrality, patents accumulated
xtreg nopi L.nopi mecp $exog, fe
xtreg nopi L.nopi LC.mvcon##C.mecp $exog, fe
xtabond2 nopi L.nopi mecp $exog, gmm(L.nopi L.mecp) iv($exog) two orthogonal robust noleveleq
xtabond2 nopi L.nopi LC.mvcon##C.mecp $exog, gmm(L.nopi L2C.mvcon##LC.mecp) iv($exog) two orthogonal robust noleveleq

//sales: centrality
gen lsale = log(sale)
xtreg lsale L.lsale mecp $exog, fe
xtreg lsale L.lsale LC.mvcon##C.mecp $exog, fe
xtabond2 lsale L.lsale mecp $exog, gmm(L.lsale L.mecp) iv($exog) two orthogonal robust noleveleq
xtabond2 lsale L.lsale LC.mvcon##C.mecp $exog, gmm(L.lsale L2C.mvcon##LC.mecp) iv($exog) two orthogonal robust noleveleq

//minority equity: centrality


//patents: centrality, accumulated patents, minority equity
xtabond2 patents L.patents mecp $exog, gmm(L.patents L.mecp) iv($exog) two orthogonal robust noleveleq
xtabond2 patents L.patents Lmvcon mecp $exog, gmm(L.patents L2.mvcon L.mecp) iv($exog) two orthogonal robust noleveleq
xtabond2 patents L.patents LC.mvcon##C.mecp $exog, gmm(L.patents L2C.mvcon##LC.mecp) iv($exog) two orthogonal robust noleveleq

//abnormal returns
xtabond2 aret L.aret mecp $exog I.year, gmm(L.aret L.mecp) iv($exog I.year) two orthogonal robust noleveleq
xtabond2 aret L.aret L.mvcon mecp irisk $exog, gmm(L.aret L2.mvcon L.mecp L.irisk) iv($exog) two orthogonal robust noleveleq
xtabond2 aret L.aret LC.mvcon##C.mecp irisk $exog, gmm(L.aret L2C.mvcon##LC.mecp L.irisk) iv($exog) two orthogonal robust noleveleq


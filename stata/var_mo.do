cd /Users/research/GDrive/Dissertation/thesis/stata
import delim using language_mo.csv, clear
merge 1:m year month using panel_mo_basic
drop _merge

//keep if year > 1998 //& year < 2002
//keep if year > 1992 //& year < 1999
keep if year > 1992 & year < 2004

gen date = ym(year, month)
format date %tm
xtset FID date


by FID: gen tt = _n
tab year, gen(y)
tab month, gen(m)
gen lvolume = log(volume)
gen kld = klent1000
gen lcon  = (1 - kld) //*100
gen size = log(emps)

gen explore = (d_r)/d

reg lcon i.month
predict rlcon, r
//xtregar aret irisk c.lcon##c.explore size tt i.year i.month, fe
//xtregar aret irisk c.lcon##c.act_div size tt i.year i.month, fe
//xtregar aret irisk c.lcon##c.frm_div size tt i.year i.month, fe
//xtregar aret irisk c.lcon##c.ec size tt i.year i.month, fe

//margins, dydx(explore) at(l.lcon=(.93(.005).97))
//marginsplot

//robustness abond
keep if year > 1999
gen lcon_exp = lcon*explore
gen lcon_act = lcon*act_div
gen lcon_frm = lcon*frm_div
gen lcon_ec = lcon*ec



set more off
xtabond aret tt m1-m12, endogenous(lcon lcon_exp explore irisk turnover, lag(2,.)) two vce(robust) 
//estat sargan
estat abond


xtdpdsys aret, endogenous(lcon lcon_exp explore irisk, lag(2,.)) vce(robust)
estat abond //mo betta


//robustness VAR
egen id=group(FID)
su id
global last = r(max)

set more off
var D.lcon D.lcon_ec D.ec irisk aret if id==4, lags(1/2) small
vargranger
varlmar

forvalues i=1(1)$last {
	display `i'
 	qui var D.lcon D.irisk D.lvolume aret if id==`i', lags(1/3) small
	matrix b = e(b)
	qui vargranger
	matrix f = r(gstats)
	//for lag 3
	matrix s = (`i',f[5,1],(b[1,14]+b[1,15]+b[1,16]),f[9,1],(b[1,27]+b[1,28]+b[1,29]),f[13,1],(b[1,40]+b[1,41]+b[1,42]))
	//for lag 9
	//matrix s = (`i',f[5,1],(b[1,38]+b[1,39]+b[1,40]+b[1,41]+b[1,42]+b[1,43]+b[1,44]+b[1,45]+b[1,46]),f[9,1],(b[1,75]+b[1,76]+b[1,77]+b[1,78]+b[1,79]+b[1,80]+b[1,81]+b[1,82]+b[1,83]),f[13,1],(b[1,112]+b[1,113]+b[1,114]+b[1,115]+b[1,116]+b[1,117]+b[1,118]+b[1,119]+b[1,120]))
    if `i'==1 matrix stats=s
    else matrix stats=(stats \ s)
}
matrix colnames stats = id f_irisk b_irisk f_lvolume b_lvolume f_aret b_aret
matrix list stats
clear
svmat stats, names(col)

qui twoway scatter f_aret id, yline(1.5, lstyle(foreground)) name(f_aret, replace)
qui twoway scatter b_aret id, yline(0, lstyle(foreground)) name(b_aret, replace)
 gr combine f_aret b_aret, col(1) iscale(1)

 
 
 //pwcorr aret irisk turnover L.lcon tt
collapse (mean) aret act_div frm_div explore irisk size (sd) vent=lcon, by(FID year)
tab year, gen(y)
gen tt = year-1992
xtset FID year

xtreg aret vent explore act_div frm_div irisk, fe
xtreg aret c.vent##c.frm_div irisk, fe

gen vent_explore = vent*explore
gen vent_act_div = vent*act_div
gen vent_frm_div = vent*frm_div

xtdpdsys aret l.lcon tt m1-m12, endogenous(act_div lcon_act_div irisk size) vce(robust)
estat abond //yuck
//estat sargan

 

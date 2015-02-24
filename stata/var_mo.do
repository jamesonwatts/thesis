cd /Users/research/GDrive/Dissertation/thesis/stata
use panel_mo, clear
global excon = "lexp lage size foreign"

//robustness VAR
egen id=group(FID)
su id
global last = r(max)

set more off
var D.lcon irisk aret if id==2, lags(1/3) small ex($excon)
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

 

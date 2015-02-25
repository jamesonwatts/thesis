cd /Users/research/GDrive/Dissertation/thesis/stata
use panel_mo, clear
global excon = "mlexp mlage mlemps"
drop if aret == .
gen lcomm = log(co)
su lcomm
gen mlcomm = lcomm-r(mean)

//xtregar caret c.lcon##c.ec_pro irisk lvolume $excon, fe
keep if year > 1999 //& year < 2004
//xtregar caret c.lcon##c.mec_pro irisk lvolume $excon, fe

gen mlcon_mec = mlcon*mec_pro
set more off
xtabond caret l(0/2).(lcon mlcon_mec), end(mlcon mec_pro irisk turnover, lags(2,12)) two vce(robust)
estat abond
vif, uncentered

gen mlcon_mlcomm = mlcon*mlcomm
set more off
xtabond caret l(0/2).(mlcon_mlcomm), end(mlcon mlcomm irisk, lags(2,12)) two vce(robust)
estat abond
vif, uncentered



//robustness VAR
egen id=group(FID)
su id
global last = r(max)

set more off
varsoc lcon irisk aret if id==1
vecrank lcon irisk aret lvolume if id==1, lags(4)
vec lcon irisk lvolume aret if id==1, lags(4) 
vargranger
varlmar, ml(6)

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

 

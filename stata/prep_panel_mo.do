cd /Users/research/GDrive/Dissertation/thesis/stata

import delim using language_mo, clear
merge 1:m year month using panel_mo_basic
drop _merge
save panel_mo, replace


import delim using "./bio.csv", clear
rename fid FID 
merge 1:m FID year using panel_mo
drop _merge

gen date = ym(year, month)
format date %tm


gen act_div = 1-(((d_r/d)^2)+((d_f/d)^2)+((d_l/d)^2)+((d_c/d)^2)+((d_o/d)^2))
gen frm_div = 1-(((n_bio/d)^2)+((n_npr/d)^2)+((n_gov/d)^2)+((n_fin/d)^2)+((n_pha/d)^2)+((n_oth/d)^2))

gen fyrd = fyr / 10000
gen age = year - floor(fyrd)
gen lage = log(age)
su lage
gen mlage = lage-r(mean)
replace firsttie = . if firsttie == -1 | firsttie == -9
gen firsttied = firsttie / 100
gen expr = year - floor(firsttied)
replace expr = 0 if expr < 0
gen lexpr = log(expr)
su lexpr
gen mlexpr = lexpr-r(mean)
rename international foreign
gen lemps = log(emps)
su lemps
gen mlemps = lemps-r(mean)

gen kld = klent1000
gen lcon = 1-kld

tab year, gen(y)
tab month, gen(m)
gen lvolume = log(volume)
su lvolume
gen mlvolume = lvolume-r(mean)
su lcon
gen mlcon = lcon-r(mean)
su kld
gen mkld = kld-r(mean)
su ec_pro
gen mec_pro = ec_pro-r(mean)

xtset FID date
save panel_mo, replace

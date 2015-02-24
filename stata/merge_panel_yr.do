cd /Users/research/GDrive/Dissertation/thesis/stata
set more off
use daily, clear

gen turnover = cshtrd/cshoc

collapse (mean) volume=cshtrd turnover (last) price=prccd shares=cshoc datadate, by(FID year month)

save panel_yr, replace

use fama_french_mo, clear
gen year = year(dateff)
gen month = month(dateff)

merge 1:m year month using panel_yr
drop if _merge < 3
drop _merge

sort FID datadate
by FID: generate t=_n
xtset FID t

//drop if less than 5 years of trading data otherwise can't estimate two years of abnormal returns
by FID: egen obs=max(t)
keep if obs > 60

gen fret = (price-L.price)/L.price
//gen fret = log(prccd/L.prccd)
gen efret = fret-rf 


//gen abnormal returns and irisk
egen id=group(FID)
save panel_yr, replace

su id
global last = r(max)
keep if id==1
rolling, window(36) clear: reg efret mktrf smb hml umd
rename end t
save four_factor_mo, replace
forvalues i=2(1)$last {
	use panel_yr, clear
	keep if id==`i'
	rolling, window(36) clear: reg efret mktrf smb hml umd
	rename end t
	append using four_factor_mo
	save four_factor_mo, replace
}

use panel_yr, clear
merge 1:1 FID t using four_factor_mo
gen aret = efret - L2._b_cons+L2._b_mktrf*mktrf+L2._b_smb*smb+L2._b_hml*hml+L2._b_umd*umd
drop _merge
save panel_yr, replace

collapse (sd) irisk=aret (sum) caret=aret (mean) aret turnover, by(FID year)

save panel_yr, replace

//network variables
import delim using "./bio.csv", clear
rename fid FID

merge 1:m FID year using panel_yr
drop _merge

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

tab year, gen(y)
gen lvolume = log(volume)
su lvolume
gen mlvolume = lvolume-r(mean)
rename ec_pro ecp
su ecp
gen mecp = ecp-r(mean)
su ec
gen mec = ec-r(mean)

su irisk
gen mirisk = irisk-r(mean)

save panel_yr, replace

merge 1:1 FID year using annuals
drop _merge
save panel_yr, replace

//language
import delim using language_mo, clear
gen kld = klent1000
gen lcon = 1-kld

collapse (sd) vcon=lcon (mean) words vocab kld lcon, by(FID year)
su lcon
gen mlcon = lcon-r(mean)
su vcon
gen mvcon = vcon-r(mean)
su kld
gen mkld = kld-r(mean)

merge 1:m year using panel_yr
//drop if _merge < 3
drop _merge
save panel_yr, replace


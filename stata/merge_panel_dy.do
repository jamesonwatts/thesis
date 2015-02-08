cd /Users/research/GDrive/Dissertation/thesis/stata
set more off

import delim using nyse, clear
tostring sdate, replace
gen datadate = date(sdate,"YMD")
format datadate %td

sort datadate
quietly by datadate:  gen dup = cond(_N==1,0,_n)
list if dup
drop if dup==2

merge 1:m datadate using daily
drop if _merge < 3
drop _merge dup

rename datadate date

merge m:1 date using fama_french_dy
drop if _merge < 3
drop _merge

//drop if date < date("1998/01/01","YMD")

sort FID date
by FID: generate t=_n
xtset FID t

//drop if less than 3 years of trading data
by FID: egen obs=max(t)
keep if obs > 756

gen fret = (prccd-L.prccd)/L.prccd
//gen fret = log(prccd/L.prccd)
gen efret = fret-rf 
gen turnover = cshtrd/cshoc
//drop if turnover == .
drop obs sdate year_ month_ year_month_


//gen abnormal returns and irisk
egen id=group(FID)
save panel_dy_basic, replace
su id
global last = r(max)
keep if id==1
rolling, window(250) clear: reg efret mktrf smb hml umd
rename end t
save four_factor_basic, replace
forvalues i=2(1)$last {
	use panel_dy_basic, clear
	keep if id==`i'
	rolling, window(250) clear: reg efret mktrf smb hml umd
	rename end t
	append using four_factor_basic
	save four_factor_basic, replace
}

use panel_dy_basic, clear
merge 1:1 FID t using four_factor_basic
gen aret = efret - L._b_cons+L._b_mktrf*mktrf+L._b_smb*smb+L._b_hml*hml+L._b_umd*umd
drop _merge
save panel_dy_basic, replace


import delim using language_dy.csv, clear
gen date = date(sdate, "YMD")
format date %td
merge 1:m date using panel_dy_basic
//drop if _merge < 3
drop _merge
save panel_dy_basic, replace

//network variables
import delim using "./bio.csv", clear
label variable d "total # of alliances"
label variable dc "normalized degree centrality of all alliances"
label variable bc "betweenness centrality"
label variable cc "closeness centrality"
label variable d_r "# of research ties"
label variable d_f "# of finance ties"
label variable d_l "# of licensing ties"
label variable d_c "# of commerce ties"
label variable d_o "# of other ties"
label variable fyr "Founding year"
label variable eyr "Exit year"
rename fid FID

merge 1:m FID year using panel_dy_basic
drop _merge
keep if public==1

sort FID year month day
drop if t == .
save panel_dy_basic, replace

//for var month
use panel_dy_basic, clear
collapse (sd) irisk=aret vent=klent500 (sum) caret=aret (mean) klent500 aret turnover volume=cshtrd nyse_volume (last) emps d dc bc d_c d_f d_l d_r d_o n_oth n_pha n_fin n_gov n_npr n_bio tic shares=cshoc price=prccd, by(FID year month) 
gen act_div = 1-(((d_r/d)^2)+((d_f/d)^2)+((d_l/d)^2)+((d_c/d)^2)+((d_o/d)^2))
gen frm_div = 1-(((n_bio/d)^2)+((n_npr/d)^2)+((n_gov/d)^2)+((n_fin/d)^2)+((n_pha/d)^2)+((n_oth/d)^2))

save panel_mo_basic, replace

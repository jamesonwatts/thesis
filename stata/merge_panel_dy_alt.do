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

drop if date < date("1998/01/01","YMD")

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
drop if turnover == .
drop obs sdate year_ month_ year_month_

//gen abnormal returns and irisk
egen id=group(FID)
save panel_dy, replace
su id
global last = r(max)
keep if id==1
//arch efret mktrf smb hml umd, arch(1) garch(1)
rolling, window(250) clear: arch efret mktrf smb hml umd, arch(1) //garch(1)
rename end t
save four_factor_arch, replace
forvalues i=2(1)$last {
	use panel_dy, clear
	keep if id==`i'
	rolling, window(250) clear: arch efret mktrf smb hml umd, arch(1) garch(1)
	rename end t
	append using four_factor_arch
	save four_factor_arch, replace
}

use panel_dy, clear
merge 1:1 FID t using four_factor
drop if _merge < 3
drop _merge

replace aret = efret-(L.efret_b_cons+L.efret_b_mktrf*mktrf+L.efret_b_smb*smb+L.efret_b_hml*hml+L.efret_b_umd*umd)
gen irisk = L.ARCH_b_cons+L._stat_6*(aret)^2








import delim using language_mo, clear
merge 1:m year month using panel_mo
//drop if _merge < 3
drop _merge

save panel_mo, replace

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

merge 1:m FID year using panel_mo
drop if _merge < 3
drop _merge
keep if public==1

save panel_mo, replace

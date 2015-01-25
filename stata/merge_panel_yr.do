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

gen turnover = cshtrd/cshoc

collapse (mean) nyse_volume volume=cshtrd turnover (last) price=prccd shares=cshoc datadate, by(FID year month)

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

//gen fret = (price-L.price)/L.price
gen fret = log(price/L.price)
gen efret = fret-rf 

egen id=group(FID)
su id
global last = r(max)

gen ffres = .
gen aret = .
//reg efret mktrf smb hml umd if id==1, robust
forvalues i=1(1)$last {
	count if id==`i'
	if r(N) > 5{
		reg efret mktrf smb hml umd if id==`i'
		predict resid if id==`i', r
		replace ffres = resid if id==`i'
		replace aret = efret - ffres if id==`i'
		drop resid
		//replace aret = efret - _b[_cons]+_b[mktrf]*mktrf+_b[smb]*smb+_b[hml]*hml+_b[umd]*umd if id==`i'
	}
}

save panel_yr, replace

import delim using language_mo, clear
merge 1:m year month using panel_yr
//drop if _merge < 3
drop _merge

collapse (sd) irisk=aret (mean) aret turnover volume nyse_volume words vocab klent50 klent100 klent500 klent1000 klent2000, by(FID year)

save panel_yr, replace

//network variables
import delim using "./bio.csv", clear
label variable d "total # of alliances"
label variable dc "normalized degree centrality of all alliances"
//label variable ec "eigenvector centrality"
label variable bc "betweenness centrality"
label variable cc "closeness centrality"
label variable d_r "# of research ties"
label variable d_f "# of finance ties"
label variable d_l "# of licensing ties"
label variable d_c "# of commerce ties"
label variable d_o "# of other ties"
//label variable ec_c "eig. centrality of research ties"
//label variable ec_c "eig. centrality of finance ties"
//label variable ec_c "eig. centrality of licensing ties"
//label variable ec_c "eig. centrality of commerce ties"
label variable fyr "Founding year"
label variable eyr "Exit year"
rename fid FID

merge 1:1 FID year using panel_yr
drop if _merge < 3
drop _merge
keep if public==1

tabulate year, gen(yfe)
tabulate month, gen(mfe)

save panel_yr, replace

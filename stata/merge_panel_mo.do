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

sort FID datadate
by FID: generate t=_n
xtset FID t
gen lret = log(prccd/L.prccd)
gen turnover = cshtrd/cshoc
//drop if turnover == .

collapse (sd) volatility=lret price_sd=prccd (mean) nyse_volume volume=cshtrd turnover (last) price=prccd shares=cshoc datadate, by(FID year month)
save panel_mo, replace

use fama_french_mo, clear
gen year = year(dateff)
gen month = month(dateff)

merge 1:m year month using panel_mo
drop if _merge < 3
drop _merge
save panel_mo, replace

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
merge 1:m FID year using panel_mo
drop if _merge < 3
drop _merge
keep if public==1

tabulate year, gen(yfe)
tabulate month, gen(mfe)

save panel_mo, replace

sort FID datadate
by FID: generate t=_n
xtset FID t

gen fret = (price-L.price)/L.price
gen efret = fret-rf 

egen id=group(FID)
su id
global last = r(max)

gen m_b = .
gen s_b = .
gen h_b = .
gen u_b = .
gen constant = .
gen aret = .
//reg efret mktrf smb hml umd if id==1, robust
forvalues i=1(1)$last {
	count if id==`i'
	if r(N) > 5{
		reg efret mktrf smb hml umd if id==`i', robust
		replace aret = efret - _b[_cons]+_b[mktrf]*mktrf+_b[smb]*smb+_b[hml]*hml+_b[umd]*umd if id==`i'
	}
}

save panel_mo, replace

import delim using language_mo, clear
merge 1:m year month using panel_mo
//drop if _merge < 3
drop _merge
xtset FID t
save panel_mo, replace

use panel_mo, clear
collapse (mean) volatility turnover volume nyse_volume aret klent50 klent100 klent500 klent1000 klent2000 words vocab, by(t)
save series_mo, replace

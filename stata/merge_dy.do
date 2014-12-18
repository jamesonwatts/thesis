cd /Users/research/GDrive/Dissertation/thesis/stata
use daily, clear

//daily
tsset FID datadate

//drop if cshoc == .
gen turnover = cshtrd/cshoc

egen select = tag(FID)

collapse (count) firms=select (mean) turnover shares=cshoc volume=cshtrd, by(datadate)
save sdaily, replace

import delim using language_dy.csv, clear
gen datadate = date(sdate, "YMD")
format datadate %td

merge 1:1 datadate using sdaily
drop if _merge < 3
drop _merge
save series_dy, replace

import delim using nyse, clear
tostring sdate, replace
gen datadate = date(sdate,"YMD")
format datadate %td

sort datadate
quietly by datadate:  gen dup = cond(_N==1,0,_n)
list if dup
drop if dup==2

merge 1:1 datadate using series_dy
drop if _merge < 3
drop _merge
save series_dy, replace

cd /Users/research/GDrive/Dissertation/thesis/stata

import delim using nyse, clear
tostring sdate, replace
gen datadate = date(sdate,"YMD")
format datadate %td

sort datadate
quietly by datadate:  gen dup = cond(_N==1,0,_n)
list if dup
drop if dup==2

merge 1:m datadate using daily // panel_dy
drop if _merge < 3
drop _merge
drop dup
save panel_dy, replace

//monthly
collapse (mean) nyse_volume nyse_trades volume=cshtrd (last) price=prccd shares=cshoc datadate, by(FID year month)
gen fvalue = price*shares
collapse (sd) volatility=price (mean) fvalue price nyse_volume nyse_trades volume, by(FID year)

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
save panel_yr, replace


import delim using language_dy.csv, clear
gen datadate = date(sdate, "YMD")
format datadate %td
gen year = year(datadate)

collapse (mean) words vocab klent churn rank, by(year)

merge 1:m year using panel_yr
drop if _merge < 3
drop _merge
save panel_yr, replace


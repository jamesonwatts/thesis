cd /Users/research/GDrive/Dissertation/thesis/stata

import delim using language_dy.csv, clear
gen datadate = date(sdate, "YMD")
format datadate %td

merge 1:m datadate using daily
drop if _merge < 3
drop _merge
save panel_dy, replace
drop year_ month_

import delim using nyse, clear
tostring sdate, replace
gen datadate = date(sdate,"YMD")
format datadate %td

sort datadate
quietly by datadate:  gen dup = cond(_N==1,0,_n)
list if dup
drop if dup==2

merge 1:m datadate using panel_dy
drop if _merge < 3
drop _merge
drop dup
save panel_dy, replace

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
merge 1:m FID year using panel_dy
drop if _merge < 3
drop _merge

tabulate year, gen(yfe)
tabulate month, gen(mfe)
gen holidays = (month == 12 & day >= 20 & day <= 31) 
gen dow = dow(datadate)
tabulate dow, gen(wd)

rename prccd price
rename cshtrd volume
rename cshoc shares
gen turnover = volume/shares

tokenize "`c(current_date)'" ,parse(" ")
local seed_1 "`1'"
tokenize "`c(current_time)'" ,parse(":")
local seed_2 "`1'`3'`5'"
local seed_final "`seed_1'`seed_2'"
set seed `seed_final'
//take a sample then select one observation from each pair:
egen select = tag(FID)
//Now produce some random numbers and sort:
gen rnd = runiform()
sort select rnd 
//One observation per id has now been sorted to the end, and those observations have been shuffled on the fly, courtesy of the random numbers. Suppose you want 300000 pairs:
replace select = _n > (_N - 50)
//The indicator select is now 1 for the last 300k observations and 0 otherwise. Now we spread the word of being selected among the other pairs:
bysort FID (select): replace select = select[_N]
//Finally, keep only the selected and clean up
keep if select
drop rnd select

save panel_dy_sample, replace


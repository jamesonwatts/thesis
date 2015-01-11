cd /Users/research/GDrive/Dissertation/thesis/stata

import delim using dyngrph, clear
egen pid = group(pair)
save dyngrph, replace

use dyngrph, clear
gen tied_igrp=tied*cored
egen igrp = sum(tied_igrp), by(year)
gen tied_ogrp=tied*!cored
egen ogrp = sum(tied_ogrp), by(year)

//grab all observations from a random selection of pids	
tokenize "`c(current_date)'" ,parse(" ")
local seed_1 "`1'"
tokenize "`c(current_time)'" ,parse(":")
local seed_2 "`1'`3'`5'"
local seed_final "`seed_1'`seed_2'"
set seed `seed_final'
//take a sample then select one observation from each pair:
egen select = tag(pid)
//Now produce some random numbers and sort:
gen rnd = runiform()
sort select rnd 
//One observation per id has now been sorted to the end, and those observations have been shuffled on the fly, courtesy of the random numbers. Suppose you want 300000 pairs:
replace select = _n > (_N - 100000)
//The indicator select is now 1 for the last 300k observations and 0 otherwise. Now we spread the word of being selected among the other pairs:
bysort pid (select): replace select = select[_N]
//Finally, keep only the selected and clean up
keep if select
drop rnd select

save dyngrph_sample, replace

corr pscore nbrs closeness cored

import delim using language_dy.csv, clear
gen datadate = date(sdate, "YMD")
format datadate %td
gen year = year(datadate)
collapse (mean) words rank klent churn, by(year)

gen lwords = log(words)
gen tt = year-1991
gen crash = year > 1999

sort year
twoway line klent year

//reg rank lwords tt crash
//predict rrank, r
//reg klent lwords
//predict rklent, r

merge 1:m year using dyngrph_sample
drop if _merge < 3
drop _merge

xtset pid year
gen density = edges/((nodes*(nodes-1))/2)
gen iden = igrp/((nodes*(nodes-1))/2)
gen oden = ogrp/((nodes*(nodes-1))/2)
forvalues i = 2(1)10{
	gen den`i'= d`i'/((nodes*(nodes-1))/2)
}

set more off
logit tied L.tied L.nbrs L.pscore L.closeness L.klent density d2-d10, cl(pid) nocon
set more off
logit tied L.tied L.c.pscore##L.c.rrank tt density d2-d10, cl(pid) nocon



set more off
gen crank = closeness*rank
gen l_c = L.closeness
gen l_r = L.rank
gen l_cr = L.crank
logit tied L.tied l_c l_cr L.words density d2-d10 //, nocon //cl(pid) nocon

su l_r
global hr = r(mean)+r(sd)
global lr = r(mean)-r(sd)

gen eHR = _b[l_c]*(l_c) + _b[l_r]*($hr) + _b[l_cr]*(l_c)*($hr)
gen eLR = _b[l_c]*(l_c) + _b[l_r]*($lr) + _b[l_cr]*(l_c)*($lr)
sort l_c
twoway (line eHR l_c) (line eLR l_c), name(CRANK, replace) legend(ring(0) pos(3) order(1 "High Rank" 2 "Low Rank.")) xtitle("Closeness") ytitle("Tie Logit")


estat ic

set more off
logit tied L(1/3).tied crash edges triangles d2-d10 //, cl(pid) nocon
set more off
logit tied L.tied pscore nbrs cored tt crash edges triangles d2-d10, cl(pid) nocon

set more off
logit tied L.tied L.c.pscore##L.c.vrank L.c.nbrs##L.c.vrank tt crash edges triangles d2-d10, cl(pid) nocon




cd /Users/research/GDrive/Dissertation/thesis/stata



import delim using dyngrph, clear
egen pid = group(pair)
save dyngrph, replace

use dyngrph, clear
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

import delim using language_mo.csv, clear
collapse (mean) words rank churn  (sd) vrank=rank, by(year)
gen lwords = log(words)
reg rank lwords
predict rrank, r

merge 1:m year using dyngrph_sample

xtset pid year

gen density = edges/((nodes*(nodes-1))/2)
tabulate year, gen(yfe)
gen tt = year-1991

//interactions with rank
replace pscore_rank = pscore*rank
replace cmn_nbrs_rank = cmn_nbrs*rank

set more off
xtlogit tied L.tied L.pscore L.cmn_nbrs L.rank tt edges
xtlogit tied L.tied L.pscore L.cmn_nbrs L.rank L.pscore_rank L.cmn_nbrs_rank tt edges

sort year
twoway line rrank year

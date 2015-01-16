cd /Users/research/GDrive/Dissertation/thesis/stata


import delim using language_dy.csv, clear
gen datadate = date(sdate, "YMD")
format datadate %td
gen year = year(datadate)
collapse (mean) words rank klent churn, by(year)

gen lwords = log(words)
gen tt = year-1987
gen crash = year > 1999

merge 1:m year using dyngrph
drop if _merge < 3
drop _merge

xtset pid year
rename partner_exp partner_experience
set more off
logit tied L.tied L.klent L.c.firm_degree#L.c.partner_degree L.firm_experience L.new_partner L.partner_experience age_difference size_difference governance_similarity firm_cohesion partner_cohesion shared_cohesion age size governance edges triangles tt d2-d20, or nocon cl(pid)
set more off
logit tied L.tied L.c.klent##L.c.shared_cohesion L.firm_degree L.partner_degree L.firm_experience L.new_partner L.partner_experience age_difference size_difference governance_similarity firm_cohesion partner_cohesion age size governance edges triangles tt d2-d20, or nocon cl(pid)



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




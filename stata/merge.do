cd /Users/research/GDrive/Dissertation/thesis/stata
use daily, clear

//daily
tsset FID datadate
gen dyear = year - year[_n-1] //to make sure to skip discontinuities in data
gen dret = (prccd - prccd[_n-1])/prccd[_n-1] if dyear < 2
collapse (last) datadate (mean) volume=cshtrd, by(year month)
save monthly, replace

//monthly
clear
use sharsmonthly
duplicates report FID datadate
duplicates tag FID datadate, gen(isdup) 
//edit if isdup
drop if isdup
merge 1:1 FID month year using prcmonthly
drop _merge

//gen fvalue_fromdaily = cshoc * prc_month
gen fvalue = csho * prc_month

//yearly
collapse (sd) prc_sd=prc_month (mean) prc=prc_month fvalue aret=mret, by(FID year)

xtset FID year
gen lfvalue = log(fvalue)
gen lfvalue_ratio = lfvalue / lfvalue[_n-1]
gen tech_uncert = prc_sd/prc

save tmp, replace

//network variables
clear
import delim using "./bio.csv"
label variable comp_tot "# of commerce alliances held by partners"
label variable comp_foe "# of commerce alliances held by partners that aren't current R&D alliances"
label variable degree "total # of alliances"
label variable dc "normalized degree centrality of all alliances"
label variable d_c "# of commerce ties"
label variable d_cc "# of clinical ties"
label variable d_cm "# of strict marketing ties"
label variable ec_c "eig. centrality of commerce ties"
label variable ec_cm "eig. centrality of strict marketing ties"
label variable fyr "Founding year"
label variable eyr "Exit year"

rename fid FID
merge 1:1 FID year using tmp
drop _merge

merge 1:1 FID year using updatedCCMannuals_byFID
drop _merge

// act at bkvlps ch gdwl gp icapt intan lct lt ni nopi npat opiti re rect revt sale xopr xrd
save final, replace

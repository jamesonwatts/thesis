cd /Users/research/GDrive/Dissertation/thesis/stata
use daily, clear

//daily
tsset FID datadate
//gen dyear = year - year[_n-1] //to make sure to skip discontinuities in data
//gen dret = (prccd - prccd[_n-1])/prccd[_n-1] if dyear < 2

drop if cshoc == .
gen turnover = cshtrd/cshoc

collapse (last) datadate (sd) prccd_sd=prccd (mean) turnover shares=cshoc volume=cshtrd, by(FID year month)
egen select = tag(FID)
collapse (count) firms=select (last) datadate  (mean) turnover unc=prccd_sd shares volume, by(year month)
save monthly, replace

outsheet year month firms unc shares volume using "/Users/research/GDrive/Dissertation/thesis/code/resources/volume.csv" , comma replace 

import delim using language.csv, clear
merge 1:1 year month using monthly

save series_mo, replace

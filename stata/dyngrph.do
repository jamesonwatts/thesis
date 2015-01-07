cd /Users/research/GDrive/Dissertation/thesis/stata

import delim using dyngrph, clear
egen id = group(pid)
xtset id year
//save dyngraph, replace

gen density = edges/((nodes*(nodes-1))/2)
tabulate year, gen(yfe)

xtlogit tied pscore density yfe1-yfe3

use dyngraph, clear

twoway line (edges date) 

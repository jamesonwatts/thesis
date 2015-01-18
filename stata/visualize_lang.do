cd /Users/research/GDrive/Dissertation/thesis/stata
import delim using top_words, clear

gen t = _n
tsset t

tsline product patent

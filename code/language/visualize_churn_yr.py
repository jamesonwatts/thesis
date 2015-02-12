import pickle
import numpy as np
from dateutil import parser

top = 25
dists = {}
#grab data
xs = []
#grab data
for year in range(1991, 2005):
    for month in range(1,13):
        d = str(year)+'-'+str(month) if month > 9 else str(year)+'-0'+str(month)
        xs.append(parser.parse(d))
        with open('../resources/mo/fdist'+d+'.pkl', 'r') as f:
            if year in dists.keys():
                dists[year].update(pickle.load(f))
            else:
                dists[year] = pickle.load(f)

#dists[2001].plot(50)

data1 = np.zeros(top, dtype={'names':[str(year) for year in range(1991, 1998)], 'formats':['a256' for i in range(top)]})
data2 = np.zeros(top, dtype={'names':[str(year) for year in range(1998, 2005)], 'formats':['a256' for i in range(top)]})

for year in dists.keys():
    i = year-1991
    j = year-1998
    tw = dists[year].most_common(top)
    if year < 1998:
        for k in range(top):
            data1[k][i] = tw[k]
    else:
        for k in range(top):
            data2[k][j] = tw[k]

   
#save data to csv

np.savetxt("/Users/research/GDrive/Dissertation/thesis/figures/top_words1.tex",data1,header=",".join(data1.dtype.names),delimiter=' & ', fmt='%s', newline=' \\\\\n')
np.savetxt("/Users/research/GDrive/Dissertation/thesis/figures/top_words2.tex",data2,header=",".join(data2.dtype.names),delimiter=' & ', fmt='%s', newline=' \\\\\n')

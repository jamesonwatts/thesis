import pickle
import numpy as np
from dateutil import parser

#settings
ma = 3

dists = []
xs = []
#grab data
for year in range(1991, 2005):
    for month in range(1,13):
        d = str(year)+'-'+str(month) if month > 9 else str(year)+'-0'+str(month)
        xs.append(parser.parse(d))
        with open('../resources/mo/fdist'+d+'.pkl', 'r') as f:
            dists.append(pickle.load(f))

# create N month distributions
mdists = []
for i in range(len(dists)-ma-1):
    fd = dists[i]
    for j in range(ma-1):
        fd.update(dists[i+j])
    mdists.append(fd)
print "Done creating MA dists"


twords = mdists[0].most_common(100)
#ewords = mdists[len(mdists)-1].most_common(50)

words = {}

data = np.zeros(163, dtype={'names':[k for k,v in twords], 'formats':['i4' for i in range(len(twords))]})

for j in range(len(mdists)-1):
    for k,v in twords:
        data[k][j] = mdists[j][k]
   
#save data to csv

np.savetxt("/Users/research/GDrive/Dissertation/thesis/stata/top_words.csv",data,header=",".join(data.dtype.names),delimiter=",",fmt="%s")

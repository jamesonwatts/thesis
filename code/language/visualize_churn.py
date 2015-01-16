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


twords = mdists[0].most_common(50)
#ewords = mdists[len(mdists)-1].most_common(50)

words = {}
for k,v in twords:
    words[k] = []
for j in range(len(mdists)-1):
    for word in words:
        words[k].append(mdists[j][word])
   
#save data to csv
data = zip([dt.strftime("%Y-%m-%d") for dt in xs[ma:]],words[1],words[2],words[3],words[4],words[5],words[6],words[7],words[8],words[9],words[10],words[11],words[12],words[13],words[14],words[15])
np.savetxt("/Users/research/GDrive/Dissertation/thesis/stata/top_words.csv",data,delimiter=",",header="sdate,w1,w2,w3,w4,w5,w6,w7,w8,w9,w10,w11,w12,w13,w14,w15",fmt="%s")

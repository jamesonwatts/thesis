import pickle
import numpy as np
from dateutil import parser
import scipy.stats as stats
import os.path


ma = 30

dists = []
xs = []
#grab data
for year in range(1991, 2005):
    for month in range(1,13):
        for day in range(1,31):
            d = str(year)+'-'+str(month) if month > 9 else str(year)+'-0'+str(month)
            d = d+'-'+str(day) if day > 9 else d+'-0'+str(day)
            file_path = 'resources/dy/fdist'+d+'.pkl'
            if os.path.exists(file_path):         
                xs.append(parser.parse(d))
                with open(file_path, 'r') as f:
                    dists.append(pickle.load(f))

# create N day distributions
mdists = []
for i in range(len(dists)-ma-1):
    fd = dists[i]
    for j in range(ma-1):
        fd.update(dists[i+j])
    mdists.append(fd)

#calculate churn   
ll = 500
ul = 2001
inc = 100   
churn = {}
rankc = {}  
for i in range(ll,ul,inc):
    churn[i] = []
    rankc[i] = []

    for j in range(len(mdists)-1):
        w1 = mdists[j].most_common(i)
        w2 = dists[j+5].most_common(i)
        cw = set([x[0] for x in w1]).intersection(set([y[0] for y in w2]))
        
        r1 = [mdists[j][x] for x in cw]
        r2 = [dists[j+5][y] for y in cw]     
        
        churn[i].append(float(i-len(cw))/i)
        rankc[i].append(stats.spearmanr(r1, r2)[0])
    
    print "Done with churn "+str(i)

#calculate word counts
nvol = []
for dist in dists:
    nvol.append(float(sum([dist[word] for word in dist])))
   
   
#save data to csv
data = zip([dt.strftime("%Y") for dt in xs[3:]],[dt.strftime("%m") for dt in xs[3:]],nvol[2:],[len(dist) for dist in dists[2:]],churn[1000],rankc[500],rankc[1000],rankc[1500],rankc[2000])
np.savetxt("../stata/language.csv",data,delimiter=",",header="year,month,words,vocab,churn,rank500,rank1000,rank1500,rank2000",fmt="%s")

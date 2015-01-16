import pickle
import numpy as np
from dateutil import parser
import scipy.stats as stats
import os.path

#settings
ma = 10
wrange = [50,100,500,1000,2000]   

dists = []
xs = []
#grab data
for year in range(1991, 2005):
    for month in range(1,13):
        for day in range(1,31):
            d = str(year)+'-'+str(month) if month > 9 else str(year)+'-0'+str(month)
            d = d+'-'+str(day) if day > 9 else d+'-0'+str(day)
            file_path = '../resources/dy/fdist'+d+'.pkl'
            if os.path.exists(file_path):         
                xs.append(parser.parse(d))
                with open(file_path, 'r') as f:
                    dists.append(pickle.load(f))
    print "Done importing year: "+str(year)

# create N day distributions
mdists = []
for i in range(len(dists)-ma-1):
    fd = dists[i]
    for j in range(ma-1):
        fd.update(dists[i+j])
    mdists.append(fd)
print "Done creating MA dists"

#calculate churn   
churn = {}
rankc = {}
klent = {}
for i in wrange:
    churn[i] = []
    rankc[i] = []
    klent[i] = []

    for j in range(len(mdists)-1):
        w1 = mdists[j].most_common(i)
        w2 = dists[j+ma].most_common(i)
        cw = set([x[0] for x in w1]).intersection(set([y[0] for y in w2]))
        
        r1 = [mdists[j][x] for x in cw]
        r2 = [dists[j+ma][y] for y in cw]     
        
        churn[i].append(float(i-len(cw))/i)
        rankc[i].append(stats.spearmanr(r1, r2)[0])
        #entropy
        s1 = float(sum([mdists[j][word] for word in cw]))
        s2 = float(sum([dists[j+ma][word] for word in cw]))
        klent[i].append(stats.entropy([float(mdists[j][a]/s1) for a in cw],[float(dists[j+ma][b]/s2) for b in cw]))
        print "Done with mdist "+str(j)
    print "Done with churn "+str(i)

#calculate word counts
nvol = []
for dist in dists:
    nvol.append(float(sum([dist[word] for word in dist])))
   
#save data to csv
data = zip([dt.strftime("%Y-%m-%d") for dt in xs[ma:]],nvol[(ma-1):],[len(dist) for dist in dists[ma-1:]],klent[50],klent[100],klent[500],klent[1000],klent[2000],churn[50],churn[100],churn[500],churn[1000],churn[2000],rankc[50],rankc[100],rankc[500],rankc[1000],rankc[2000])
np.savetxt("/Users/research/GDrive/Dissertation/thesis/stata/language_dy.csv",data,delimiter=",",header="sdate,words,vocab,klent50,klent100,klent500,klent1000,klent2000,churn50,churn100,churn500,churn1000,churn2000,rank50,rank100,rank500,rank1000,rank2000",fmt="%s")

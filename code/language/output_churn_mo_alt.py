import pickle
#import matplotlib.pyplot as plt
import numpy as np
from dateutil import parser
import scipy.stats as stats

#settings
ma = 3
wrange = [50,100,500,1000,2000]  

dists = []
xs = []
#grab data
for year in range(1991, 2004):
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
        uw = set([x[0] for x in w1]).union(set([y[0] for y in w2]))


        #set zero masses
        for w in uw:
            if w not in mdists[j].keys():
                mdists[j][w] = 0
            if w not in dists[j+ma].keys():
                dists[j+ma][w] = 0

        #entropy
        s1 = float(sum([mdists[j][word] for word in uw]))
        s2 = float(sum([dists[j+ma][word] for word in uw]))
        klent[i].append(stats.entropy([float(mdists[j][a]/s1) for a in uw],[float(dists[j+ma][b]/s2) for b in uw]))
    
    print "Done with entropy "+str(i)

#calculate word counts
nvol = []
for dist in dists:
    nvol.append(float(sum([dist[word] for word in dist])))
   
   
#save data to csv
data = zip([dt.strftime("%Y") for dt in xs[ma:]],[dt.strftime("%m") for dt in xs[ma:]],nvol[(ma-1):],[len(dist) for dist in dists[(ma-1):]],klent[50],klent[100],klent[500],klent[1000],klent[2000])
np.savetxt("/Users/research/GDrive/Dissertation/thesis/stata/language_mo_alt.csv",data,delimiter=",",header="year,month,words,vocab,klent50,klent100,klent500,klent1000,klent2000",fmt="%s")


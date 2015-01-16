import pickle
import numpy as np
from dateutil import parser
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

words = {}
for j in range(len(mdists)-1):
    fd = mdists[j].most_common(10)
    for i in range(10):
        words[i] = fd[i]
    
   
#save data to csv
data = zip([dt.strftime("%Y-%m-%d") for dt in xs[ma:]],words[1],words[2],words[3],words[4],words[5],words[6],words[7],words[8],words[9],words[10])
np.savetxt("/Users/research/GDrive/Dissertation/thesis/stata/top_words.csv",data,delimiter=",",header="sdate,words,vocab,klent50,klent100,klent500,klent1000,klent2000,churn50,churn100,churn500,churn1000,churn2000,rank50,rank100,rank500,rank1000,rank2000",fmt="%s")

import pickle
import math
from pylab import polyfit

dist = []
words = []
fits = []
lim = 1000
xs = [math.log(x) for x in range(1,lim+1)]
for year in range(1991, 2013):
    for month in range(1,13):
        if month > 9:
            d = str(year)+'-'+str(month)
        else:
            d = str(year)+'-0'+str(month)
        with open('resources/mo/fdist'+d+'.pkl', 'r') as f:
            fdist = pickle.load(f)
        dist.append(fdist)
        mc = fdist.most_common(lim)
        words.append([y[0] for y in mc])
        lmc = [math.log(y[1]) for y in mc]
        m, b = polyfit(xs,lmc,1)
        fits.append(m)
        print "BA slope is: "+str(m)


churn = []
for i in range(1,len(words)):
    matches = 0
    for word in words[i-1]:
        if word in words[i]:
            matches+=1
    
    c = float(lim-matches)/lim
    churn.append(c)
    print "Churn = "+str(c)


from numpy import genfromtxt
my_data = genfromtxt('resources/volume.csv', delimiter=',')
volume = [math.log(y) for y in my_data[37:,5]]

#normalize 
from sklearn import preprocessing as prep
fits_n = prep.scale(fits)
churn_n = prep.scale(churn)
volume_n = prep.scale(volume)

from numpy import corrcoef
corrcoef(churn[:168], volume)

import matplotlib.pyplot as plt
fig, (ax) = plt.subplots(nrows=1, ncols=1)
fig.set_facecolor("#ffffff")
ax.plot(range(168),churn_n[:168],'',
        range(168),volume_n,'')
plt.show()


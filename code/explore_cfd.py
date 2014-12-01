import pickle
import math
from pylab import polyfit
from nltk.probability import FreqDist

dist = {}
freq = {}
lfreq = {}
fits = {}
lim = 1000
xs = [math.log(x) for x in range(1,lim+1)]
for year in range(1991, 2013):
    with open('resources/btxt'+str(year)+'.pkl', 'r') as f:
        txt = pickle.load(f)
    dist[year] = FreqDist(word.lower() for word in txt if len(word) > 3)
    freq[year] = dist[year].most_common(lim)
    lfreq[year] = [math.log(y[1]) for y in freq[year]]
    m, b = polyfit(xs,lfreq[year],1)
    fits[year] = m
    print "BA slope is: "+str(m)



from scipy.stats import spearmanr
x = [5.05, 6.75, 3.21, 2.66]
y = [1.65, 26.5, -5.93, 7.96]
z = [1.65, 2.64, 2.64, 6.95]
spearmanr(x,y)


import matplotlib.pyplot as plt
fig, (ax) = plt.subplots(nrows=1, ncols=1)
fig.set_facecolor("#ffffff")

ax.set_title('Frequency Distributions By Year')
ax.plot(range(1,lim),[y[1] for y in freq[1991]],'',
        range(1,lim),[y[1] for y in freq[1995]],'',
        range(1,lim),[y[1] for y in freq[1997]],'',
        range(1,lim),[y[1] for y in freq[1999]],'',
        range(1,lim),[y[1] for y in freq[2001]],'')
ax.set_xscale('log')
ax.set_yscale('log')
aleg = ax.legend(('1991','1995','1997','1999','2001'), loc='upper right',shadow=False)
plt.show()


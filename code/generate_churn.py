import pickle

freq = {}
lim = 1000
for year in range(1991, 2013):
    with open('resources/fdist'+str(year)+'.pkl', 'r') as f:
        dist = pickle.load(f)
    freq[year] = [w[0] for w in dist.most_common(lim)]
    
churn = {}
for year in range(1992, 2013):
    matches = 0
    for word in freq[year-1]:
        if word in freq[year]:
            matches+=1
        
    churn[year] = float(lim-matches)/lim
    print "Churn = "+str(churn[year])


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


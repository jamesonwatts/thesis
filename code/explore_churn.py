import pickle
import matplotlib.pyplot as plt
import numpy as np

def movingaverage(interval, window_size):
    window = np.ones(int(window_size))/float(window_size)
    return np.convolve(interval, window, 'same')

ll = 100
ul = 1025
inc = 25
dists = []
for year in range(1991, 2005):
    for month in range(1,13):
        d = str(year)+'-'+str(month) if month > 9 else str(year)+'-0'+str(month)
        with open('resources/mo/fdist'+d+'.pkl', 'r') as f:
            dists.append(pickle.load(f))
        
churn = {}       
for i in range(ll,ul,inc):
    churn[i] = []
    words = []
    for dist in dists:
        words.append([y[0] for y in dist.most_common(i)])
    
    print "Done loading words for "+str(i)
    
    for j in range(1,len(words)):
        matches = 0
        for word in words[j-1]:
            if word in words[j]:
                matches+=1
        
        c = float(i-matches)/i
        churn[i].append(c)
    
    print "Done with churn "+str(i)

#grab volume data from csv
my_data = np.genfromtxt('resources/volume.csv', delimiter=',')
volume = [np.log(v) for v in my_data[37:,5]]

#detrend and normalize
from scipy.signal import detrend
from sklearn import preprocessing as prep
volume_d = detrend(volume)
volume_n = prep.scale(volume)
volume_dn = prep.scale(volume_d)
churn_d = {}
churn_n = {}
churn_dn = {}
for key in churn.keys():
    churn_d[key] = detrend(churn[key])
    churn_n[key] = prep.scale(churn[key])
    churn_dn[key] = prep.scale(churn_d[key])

#check correlation and plot
#plt.tight_layout()
import scipy.stats as stats
gcorr = stats.pearsonr(churn_dn[1000], volume_dn[:167])
figV, v = plt.subplots(nrows=1, ncols=1)
figV.set_facecolor("#ffffff")
plt.text(0.3, 0.05,'pearson correlation is '+str(gcorr[0])[:6]+' (p < 0.01)', horizontalalignment='center',
         verticalalignment='center',
         transform=v.transAxes)
v.set_title("Normalized and Detrended Churn and Volume")
v.plot(range(167),churn_dn[1000],'',
       range(167),volume_dn[:167],'')
vleg = v.legend(('language churn','trading volume'),loc='upper right', shadow=False)
plt.savefig('../figures/normalized_and_detrended_churn_and_volume.png')

figV, v = plt.subplots(nrows=1, ncols=1)
figV.set_facecolor("#ffffff")
v.set_title("Churn and Volume (20 month MA)")
v.plot(range(167),movingaverage(churn_dn[1000],20),'',
        range(167),movingaverage(volume_dn[:167],20),'')
vleg = v.legend(('language churn','trading volume'),loc='upper right', shadow=False)
plt.savefig('../figures/normalized_and_detrended_churn_and_volume_ma.png')
plt.show()

#create correlations
corrs = []
for i in range(ll,ul,inc):
    corrs.append(stats.pearsonr(churn_n[i], volume_n[:167]))
  
fig1, ((ax,bx),(cx,dx)) = plt.subplots(nrows=2, ncols=2)
fig1.set_facecolor("#ffffff")
ax.set_title("250 Words")
ax.plot(churn_dn[250])
bx.set_title("500 Words")
bx.plot(churn_dn[500])
cx.set_title("750 Words")
cx.plot(churn_dn[750])
dx.set_title("1000 Words")
dx.plot(churn_dn[1000])
plt.savefig('../figures/churn_by_included_words.png')

fig2, ex = plt.subplots(nrows=1, ncols=1)
fig2.set_facecolor("#ffffff")
ex.set_title("Churn and Volume over time (no detrending)")
ex.plot(range(167),churn_n[1000],'',
        range(167),volume_n[:167],'')
plt.savefig('../figures/churn_and_volume.png')

fig3, fx = plt.subplots(nrows=1, ncols=1)
fig3.set_facecolor("#ffffff")
fx.set_title("Increse in (negative) correlation with increase in words used")
fx.plot([corr[0] for corr in corrs])
plt.savefig('../figures/correlation_by_words_used.png')

plt.show()

#create data structure for analysis
import statsmodels.tsa.api as tsa
x = np.zeros((166,),dtype=('f4,f4'))
x[:] = zip([churn[1000],volume[1:]])
mdata = np.diff(mdata)
churn_f = np.diff(churn[1000])
volume_f = np.diff(volume[1:])
stats.pearsonr(churn_f[1:], volume_f[:165])
model  = tsa.VAR(mdata)
results = model.fit()
results.summary()

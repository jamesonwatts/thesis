import pickle
#import matplotlib.pyplot as plt
import numpy as np
from dateutil import parser
import scipy.stats as stats

#settings
ma = 3
ll = 500
ul = 2001
inc = 500

dists = []
xs = []
#grab data
for year in range(1991, 2005):
    for month in range(1,13):
        d = str(year)+'-'+str(month) if month > 9 else str(year)+'-0'+str(month)
        xs.append(parser.parse(d))
        with open('resources/mo/fdist'+d+'.pkl', 'r') as f:
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
for i in range(ll,ul,inc):
    churn[i] = []
    rankc[i] = []

    for j in range(len(mdists)-1):
        w1 = mdists[j].most_common(i)
        w2 = dists[j+ma].most_common(i)
        cw = set([x[0] for x in w1]).intersection(set([y[0] for y in w2]))
        
        r1 = [mdists[j][x] for x in cw]
        r2 = [dists[j+ma][y] for y in cw]     
        
        churn[i].append(float(i-len(cw))/i)
        rankc[i].append(stats.spearmanr(r1, r2)[0])
    
    print "Done with churn "+str(i)

#calculate word counts
nvol = []
for dist in dists:
    nvol.append(float(sum([dist[word] for word in dist])))
   
   
#save data to csv
data = zip([dt.strftime("%Y") for dt in xs[ma:]],[dt.strftime("%m") for dt in xs[ma:]],nvol[(ma-1):],[len(dist) for dist in dists[(ma-1):]],churn[1000],rankc[2000])
np.savetxt("../stata/language_mo.csv",data,delimiter=",",header="year,month,words,vocab,churn,rank",fmt="%s")


#grab volume data from csv 36=1991 and 84=1995
#my_data = np.genfromtxt('resources/volume.csv', delimiter=',', skip_header=1)
#tvol = [np.log(v) for v in my_data[85:,5]]
#firms = [np.log(v) for v in my_data[85:,2]]
#
##detrend and normalize
#from scipy.signal import detrend
#from sklearn import preprocessing as prep
#firms_n = prep.scale(firms)
#tvol_d = detrend(tvol)
#tvol_n = prep.scale(tvol)
#tvol_dn = prep.scale(tvol_d)
#nvol_d = detrend(nvol)
#nvol_n = prep.scale(nvol)
#nvol_dn = prep.scale(nvol_d)
#churn_d = {}
#churn_n = {}
#churn_dn = {}
#for key in churn.keys():
#    churn_d[key] = detrend(churn[key])
#    churn_n[key] = prep.scale(churn[key])
#    churn_dn[key] = prep.scale(churn_d[key])
#rankc_n = {}
#rankc_d = {}
#rankc_dn = {}
#for key in rankc.keys():
#    rankc_d[key] = detrend(rankc[key])
#    rankc_n[key] = prep.scale(rankc[key])
#    rankc_dn[key] = prep.scale(rankc_d[key])
#
#    
##check correlation and plot
##plt.tight_layout()
#gcorr = stats.pearsonr(rankc_dn[1000], tvol_dn[2:])
#
#figV, v = plt.subplots(nrows=1, ncols=1)
#figV.set_facecolor("#ffffff")
#plt.text(0.3, 0.95,'pearson correlation is '+str(gcorr[0])[:6]+' (p < 0.01)', horizontalalignment='center',
#         verticalalignment='center',
#         transform=v.transAxes)
#v.set_title("Normalized and Detrended Churn and Volume")
#v.plot(xs[3:],rankc_dn[1000],'',
#       xs[3:],tvol_dn[2:],'')
#vleg = v.legend(('language churn','trading volume'),loc='upper right', shadow=False)
#plt.savefig('../figures/normalized_and_detrended_churn_and_volume.png')
#
#figV, v = plt.subplots(nrows=1, ncols=1)
#figV.set_facecolor("#ffffff")
#v.set_title("Churn and Volume (12 month MA)")
#v.plot(xs[3:],movingaverage(rankc_dn[1000],12),'',
#        xs[3:],movingaverage(tvol_dn[2:],12),'')
#vleg = v.legend(('language churn','trading volume','news_volume'),loc='upper right', shadow=False)
#plt.savefig('../figures/normalized_and_detrended_churn_and_volume_ma.png')
#plt.show()
#
##create correlations
#corrs = {}
#for i in range(ll,ul,inc):
#    corrs[i] = stats.pearsonr(churn[i], tvol[2:])
#  
#
#fig2, ex = plt.subplots(nrows=1, ncols=1)
#fig2.set_facecolor("#ffffff")
#ex.set_title("Churn and Volume over time (no detrending)")
#ex.plot(xs[3:],rankc_n[1000],'',
#        xs[3:],tvol_n[2:],'')
#plt.savefig('../figures/churn_and_volume.png')
#
#fig3, fx = plt.subplots(nrows=1, ncols=1)
#fig3.set_facecolor("#ffffff")
#fx.set_title("Increse in (negative) correlation with increase in words used")
#fx.plot(sorted(corrs),[corrs[key][0] for key in sorted(corrs)],'')
#plt.savefig('../figures/correlation_by_words_used.png')
#
#plt.show()
#
#
#
##rankc_f = np.diff(rankc[2000])
##tvol_f = np.diff(tvol[1:])
##stats.pearsonr(rankc_f, tvol_f)
##create data structure for analysis
##import statsmodels.tsa.api as tsa
##x = np.zeros((166,),dtype=('f4,f4'))
##x[:] = zip([churn[1000],tvol[1:]])
##mdata = np.diff(mdata)
##churn_f = np.diff(churn[1000])
##tvol_f = np.diff(volume[1:])
##stats.pearsonr(churn_f[1:], volume_f[:165])
##model  = tsa.VAR(mdata)
##results = model.fit()
##results.summary()

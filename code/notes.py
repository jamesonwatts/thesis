import pickle

freq = []
fdists = {}
lim = 100
for year in range(1991, 2013):
    for month in range(1,13):
        if month > 9:
            d = str(year)+'-'+str(month)
        else:
            d = str(year)+'-0'+str(month)
        with open('resources/mo/fdist'+d+'.pkl', 'r') as f:
            fdists[d] = pickle.load(f)
            freq.append([w[0] for w in fdists[d].most_common(lim)])
    



import matplotlib.pyplot as plt
fig, (ax) = plt.subplots(nrows=1, ncols=1)
fig.set_facecolor("#ffffff")

ax.set_title('Churn by Month')
ax.plot(churn)
plt.show()

fdists['1995-05'].plot(50)

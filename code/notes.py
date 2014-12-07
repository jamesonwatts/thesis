from pylab import polyfit

xs = [math.log(x) for x in range(1,lim+1)]

lmc = [math.log(y[1]) for y in mc]
        m, b = polyfit(xs,lmc,1)
        

#conditional frequency distribution
mytuples = [(target, year) for year in texts.keys() for w in texts[year] for target in ['licens','commercial','market','sales'] if w.lower().startswith(target)]
cfd = ConditionalFreqDist((w, year) for year in texts.keys() for w in texts[year])
with open("resources/cfd.pkl", 'w') as f:
    pickle.dump(cfd,f)  


#stemming
stxt = [porter.stem(t) for t in txt]
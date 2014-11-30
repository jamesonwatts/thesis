import pickle
from nltk.probability import FreqDist, ConditionalFreqDist

texts = {}
fdists = {}
for year in range(1991, 2013):
    y = str(year)
    with open('resources/btxt'+y+'.pkl', 'r') as f:
        texts[y] = pickle.load(f)
        fdists[y] = FreqDist(word.lower() for word in texts[y])
        print "Done with: %s" %(year)

for y in fdists.keys():
    with open("resources/fdist"+y+".pkl", 'w') as f:
        pickle.dump(fdists[y],f) 


mytuples = [(target, year) for year in texts.keys() for w in texts[year] for target in ['licens','commercial','market','sales'] if w.lower().startswith(target)]
cfd = ConditionalFreqDist((w, year) for year in texts.keys() for w in texts[year])
with open("resources/cfd.pkl", 'w') as f:
    pickle.dump(cfd,f)  

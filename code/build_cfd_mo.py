import pickle
from nltk.probability import FreqDist
from nltk.corpus import stopwords

for year in range(1991, 2013):
    for month in range(1,13):
        if month > 9:
            d = str(year)+'-'+str(month)
        else:
            d = str(year)+'-0'+str(month)

        with open('resources/mo/btxt'+d+'.pkl', 'r') as f:
            txt = pickle.load(f)
        fdist = FreqDist(word.lower() for word in txt if word not in stopwords.words('english') and len(word) >= 4)
        with open("resources/mo/fdist"+d+".pkl", 'w') as f:
            pickle.dump(fdist,f) 
            
        print "Done with: %s" %(d)
    
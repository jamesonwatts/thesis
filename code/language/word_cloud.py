from nltk.probability import FreqDist
import pickle

fdist = pickle.load(open("resources/fdist2004.pickle",'r'))

#fdist.plot(100, cumulative=True)

for word, count in fdist.iteritems():
    if count > 100:
        print "%s: %d" % (word, count)
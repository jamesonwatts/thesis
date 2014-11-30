import pickle
#import nltk 



        
        
with open('resources/fdist1991.pkl', 'r') as f:
    fdist = pickle.load(f)

#fdist = nltk.FreqDist(['dog', 'cat', 'dog', 'cat', 'dog', 'snake', 'dog', 'cat'])
fdist.plot(100)


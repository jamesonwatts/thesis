import pickle
#import nltk 


def lexical_diversity(text):
    return float(len(set(text))) / float(len(text))
    
def pct_occurence(text, word):
    return float(100 * text.count(word)) / float(len(text))

ldiv = {}
pcom = {}

for year in range(1991, 2013):
    y = str(year)
    with open('resources/btxt'+y+'.pkl', 'r') as f:
        txt = pickle.load(f)
        ldiv[year] = lexical_diversity(txt)
        pcom[year] = pct_occurence(txt, 'commercialize')
        
        
        
        
        
with open('resources/fdist1991.pkl', 'r') as f:
    fdist = pickle.load(f)

#fdist = nltk.FreqDist(['dog', 'cat', 'dog', 'cat', 'dog', 'snake', 'dog', 'cat'])
fdist.plot(100)


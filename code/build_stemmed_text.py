import pickle
import nltk

porter = nltk.PorterStemmer()
for year in range(1991, 2013):
    y = str(year)
    with open('resources/btxt'+y+'.pkl', 'r') as f:
        txt = pickle.load(f)
    stxt = [porter.stem(t) for t in txt]
    with open('resources/btxt_stems'+y+'.pkl', 'w') as f:
        pickle.dump(stxt,f) 
    
    print "Done with "+y

with open('resources/btxt.pkl', 'r') as f:
    txt = pickle.load(f)
stxt = [porter.stem(t) for t in txt]
with open('resources/btxt_stems.pkl', 'w') as f:
    pickle.dump(stxt,f) 
    
print "Done with big one"
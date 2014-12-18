import pickle
import matplotlib.pyplot as plt

def lexical_diversity(text):
    return float(len(set(text))) / float(len(text))
    
def pct_occurence(text, word):
    return float(100 * text.count(word)) / float(len(text))

ldiv = {}
pcom = {}
ppha = {}
pmar = {}

for year in range(1991, 2013):
    y = str(year)
    with open('resources/btxt_stems'+y+'.pkl', 'r') as f:
        txt = pickle.load(f)
    ldiv[year] = lexical_diversity(txt)
    pcom[year] = pct_occurence(txt, 'commerci')
    ppha[year] = pct_occurence(txt, 'pharmaceut')
    pmar[year] = pct_occurence(txt, 'market')
    print "Done with "+y
        
fig, ((ax),(bx)) = plt.subplots(nrows=2, ncols=1)
fig.set_facecolor("#ffffff")

ax.set_title('Lexical Diversity')
ax.plot(ldiv.keys(), ldiv.values(), 'ks')

bx.set_title('Stem Frequencies')
bx.plot(pcom.keys(), pcom.values(), 'ks',
        ppha.keys(), ppha.values(), 'k*',
        pmar.keys(), pmar.values(), 'kv')
bleg = bx.legend(('commerci','pharmaceut','market'),'upper right', shadow=False)

bx.set_xlabel('year')

plt.tight_layout()
plt.savefig('../figures/lexical_diversity.png')
plt.show()

#show dispersion of 
with open('resources/btxt_stems.pkl', 'r') as f:
    txt = pickle.load(f)
txt.dispersion_plot(["commerci","pharmaceut","market"])

#txt.similar("venture")

#txt.collocations(num=75,window_size=20)

#txt.concordance("commercialize", width=200)
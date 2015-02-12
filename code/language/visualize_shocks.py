import pickle
import numpy as np
import scipy.stats as stats

dates = [['1994-02','1994-03','1994-04','1994-05','1994-06','1994-07','1994-08'],
         ['1996-10','1996-11','1996-12','1997-01','1997-02','1997-03','1997-04'],
         ['1999-05','1999-06','1999-07','1999-08','1999-09','1999-10','1999-11'],
         ['2001-04','2001-05','2001-06','2001-07','2001-08','2001-09','2001-10']]
dists = {}
tests = {}
inter = 2000
top = 25
#grab data
for date in dates:
    with open('../resources/mo/fdist'+date[0]+'.pkl', 'r') as f:
        d1 = pickle.load(f)
    with open('../resources/mo/fdist'+date[1]+'.pkl', 'r') as f:
        d1.update(pickle.load(f))
    with open('../resources/mo/fdist'+date[2]+'.pkl', 'r') as f:
        d1.update(pickle.load(f))        
    with open('../resources/mo/fdist'+date[3]+'.pkl', 'r') as f:
        d2 = pickle.load(f)
    with open('../resources/mo/fdist'+date[4]+'.pkl', 'r') as f:
        d3 = pickle.load(f)
    with open('../resources/mo/fdist'+date[5]+'.pkl', 'r') as f:
        d3.update(pickle.load(f))
    with open('../resources/mo/fdist'+date[6]+'.pkl', 'r') as f:
        d3.update(pickle.load(f))        

    w1 = d1.most_common(inter)
    w2 = d2.most_common(inter)
    w3 = d3.most_common(inter)
    cw1 = set([x[0] for x in w1]).intersection(set([y[0] for y in w2]))
    cw2 = set([x[0] for x in w1]).intersection(set([y[0] for y in w3]))
    s11 = float(sum([d1[word] for word in cw1]))
    s21 = float(sum([d2[word] for word in cw1]))
    s12 = float(sum([d1[word] for word in cw2]))
    s32 = float(sum([d3[word] for word in cw2]))
    p1 = {}
    q1 = {}
    for w in cw1:
        p1[w] = float(d1[w]/s11)
        q1[w] = float(d2[w]/s21)
    p2 = {}
    q2 = {}
    for w in cw2:
        p2[w] = float(d1[w]/s12)
        q2[w] = float(d3[w]/s32)
    
    d1 = stats.entropy([p1[x] for x in p1],[q1[y] for y in q1])    
    d2 = stats.entropy([p2[x] for x in p2],[q2[y] for y in q2])    
    
    tests[date[3]] = (d1,d2)
    dists[date[3]] = [(w, abs(q1[w]-p1[w]),q1[w]-p1[w]) for w in cw1]


data = np.zeros(top, dtype={'names':dists.keys(), 'formats':['a256' for i in range(top)]})

j=0
for dt in dists.keys():
    tw = sorted(dists[dt], key=lambda tup: tup[1])
    for k in range(top):
        word, shock, value  = tw[len(tw)-k-1]
        v = "+ " if value > 0 else "- "
        idx = "("+str(list(cw1).index(word))+")"
        data[k][j] = v+idx+word.encode('utf8')
    j = j+1
   
#save data to csv

np.savetxt("/Users/research/GDrive/Dissertation/thesis/stata/shock_words.csv",data,header=",".join(data.dtype.names),delimiter=",",fmt="%s")

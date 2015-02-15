import pickle
import numpy as np
import scipy.stats as stats

dates = [['1994-08','1994-09','1994-10','1994-11','1994-06','1994-07','1994-08'],
         ['1996-10','1996-11','1996-12','1997-01','1997-02','1997-03','1997-04'],
         ['2001-04','2001-05','2001-06','2001-07','2001-08','2001-09','2001-10']]
dists = {}
tests = {}
inter = 1000
top = 40
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
    l1 = [x[0] for x in w1]
    w2 = d2.most_common(inter)
    l2 = [x[0] for x in w2]
    w3 = d3.most_common(inter)
    l3 = [x[0] for x in w3]
    cw1 = set(l1).intersection(set(l2))
    cw2 = set(l1).intersection(set(l3))
    cw3 = set(l2).intersection(set(l3))
    s11 = float(sum([d1[word] for word in cw1]))
    s21 = float(sum([d2[word] for word in cw1]))
    s12 = float(sum([d1[word] for word in cw2]))
    s32 = float(sum([d3[word] for word in cw2]))
    s23 = float(sum([d2[word] for word in cw3]))
    s33 = float(sum([d3[word] for word in cw3]))
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
    p3 = {}
    q3 = {}
    for w in cw2:
        p3[w] = float(d2[w]/s23)
        q3[w] = float(d3[w]/s33)
    
    r11 = [d1[x] for x in cw1]
    r21 = [d2[y] for y in cw1]
    r12 = [d1[x] for x in cw2]
    r32 = [d3[y] for y in cw2]
    r23 = [d2[x] for x in cw3]
    r33 = [d3[y] for y in cw3]     
    
    d1 = stats.spearmanr(r11, r21)[0] #stats.entropy([p1[x] for x in p1],[q1[y] for y in q1])    
    d2 = stats.spearmanr(r12, r32)[0] #stats.entropy([p2[x] for x in p2],[q2[y] for y in q2])    
    d3 = stats.spearmanr(r23, r33)[0] #stats.entropy([p3[x] for x in p3],[q3[y] for y in q3])    
    
    tests[date[3]] = (d1,d2,d3)
    dists[date[3]] = [(w, abs(q1[w]-p1[w]),q1[w]-p1[w],abs(l1.index(w)-l2.index(w)),l1.index(w),l2.index(w)) for w in cw1]


data = np.zeros(top, dtype={'names':dists.keys(), 'formats':['a256' for i in range(top)]})

j=0
for dt in dists.keys():
    tw = sorted(dists[dt], key=lambda tup: tup[2])
    for k in range(top):
        if k < 20:
            word, shock, value, rshock, start, finish  = tw[k]
        else:
            word, shock, value, rshock, start, finish  = tw[len(tw)-k+20-1]
        v = "+" if value > 0 else "- "
        data[k][j] = str(value)+","+str(finish)+","+word.encode('utf8')
    j = j+1
   
#save data to csv

np.savetxt("/Users/research/GDrive/Dissertation/thesis/stata/shock_words_pn.csv",data,header=",".join(data.dtype.names),delimiter=",",fmt="%s")


j=0
for dt in dists.keys():
    tw = sorted(dists[dt], key=lambda tup: tup[1])
    for k in range(top):
        word, shock, value, rshock, start, finish  = tw[len(tw)-k-1]
        v = "+" if value > 0 else "- "
        data[k][j] = str(value)+","+str(finish)+","+word.encode('utf8')
    j = j+1
   
#save data to csv

np.savetxt("/Users/research/GDrive/Dissertation/thesis/stata/shock_words_abs.csv",data,header=",".join(data.dtype.names),delimiter=",",fmt="%s")

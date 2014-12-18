import MySQLdb as mdb
import pickle
import re
from dateutil import parser
from bs4 import BeautifulSoup
import nltk
from nltk import word_tokenize
from nltk.text import Text
from nltk.probability import FreqDist
from nltk.corpus import stopwords

def sanitext(txt):
    porter = nltk.PorterStemmer()
    punctuation = re.compile(r'[-.?!,\'":;()|0-9]')
    tokens = [punctuation.sub("", word) for word in txt]
    tokens = [word.lower() for word in tokens if word not in stopwords.words('english') and len(word) >= 4]
    tokens = [porter.stem(t) for t in tokens]
    return tokens
     


con = mdb.connect(host='localhost', user='root', passwd='', db='biotech', charset='utf8')
with con:
    cur = con.cursor()
#    cur.execute("SELECT id, date_txt, text FROM Bioworld_Today ORDER BY date ASC")
    cur.execute("SELECT id, date_txt, text FROM Bioworld_Today WHERE date > '1990-12-31' and date < '2005-01-01' ORDER BY date ASC")
    articles = cur.fetchall()

    # build in order!!!
    documents = {}
    for idx, article in enumerate(articles):
        print "%d of %d" %(idx, len(articles))
        
        aid, date_txt, html = article
        d = parser.parse(date_txt)
        #year = str(date).split("-")[0]
        if d in documents:
            documents[d].append(BeautifulSoup(html.decode('utf8')).get_text())
        else:
            documents[d] = [BeautifulSoup(html.decode('utf8')).get_text()]
        
    
    dates = documents.keys()
    dates.sort()
    
    
    ts_m = {}
    ts_d = {}
    ts_y = {}
    for date in dates:
        #yearly
#        ty = date.strftime("%Y")        
#        if ty in ts_y:
#            ts_y[ty] += documents[date]
#        else:
#            ts_y[ty] = documents[date]    
        #monthly
        tm = date.strftime("%Y-%m")        
        if tm in ts_m:
            ts_m[tm] += documents[date]
        else:
            ts_m[tm] = documents[date]
        #daily
#        td = date.strftime("%Y-%m-%d")        
#        if td in ts_d:
#            ts_d[td] += documents[date]
#        else:
#            ts_d[td] = documents[date]    
    
    #yearly                 
#    for ty in ts_y:
#        txt = Text(word_tokenize("\n\n".join(ts_y[ty])))
#        fdist = FreqDist(sanitext(txt))
#        with open("resources/yr/fdist"+ty+".pkl", 'w') as f:
#            pickle.dump(fdist,f)  
#        print "Done with %s" %(ty)

    #monthly                 
    for tm in ts_m:
        txt = Text(word_tokenize("\n\n".join(ts_m[tm])))
        fdist = FreqDist(sanitext(txt))
        with open("resources/mo/fdist"+tm+".pkl", 'w') as f:
            pickle.dump(fdist,f)  
        print "Done with %s" %(tm)

    #daily                 
#    for td in ts_d:
#        txt = Text(word_tokenize("\n\n".join(ts_d[td])))
#        fdist = FreqDist(sanitext(txt))
#        with open("resources/dy/fdist"+td+".pkl", 'w') as f:
#            pickle.dump(fdist,f)  
#        print "Done with %s" %(td)

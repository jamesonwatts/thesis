import MySQLdb as mdb
import pickle
from dateutil import parser
from nltk import word_tokenize
from nltk.text import Text
from bs4 import BeautifulSoup

con = mdb.connect(host='localhost', user='root', passwd='', db='biotech', charset='utf8')
with con:
    cur = con.cursor()
    #cur.execute("SELECT id, date_txt, text FROM Bioworld_Today ORDER BY date ASC")
    cur.execute("SELECT id, date_txt, text FROM Bioworld_Today WHERE date > '1990-12-31' and date < '1993-01-01' ORDER BY date ASC")
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
    
    
    ts = {}
    for date in dates:
        yr = date.strftime("%Y")
        mo = date.strftime("%m")
        t = yr+"-"+mo        
        if t in ts:
            ts[t] += documents[date]
        else:
            ts[t] = documents[date]    
                     
    for t in ts:
        text = Text(word_tokenize("\n\n".join(ts[t])))
        with open("resources/mo/btxt"+t+".pkl", 'w') as f:
            pickle.dump(text,f)  
        print "Done with %s" %(t)


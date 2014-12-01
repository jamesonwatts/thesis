import MySQLdb as mdb
import pickle
from dateutil import parser
from nltk.tokenize import wordpunct_tokenize
from nltk.util import clean_html
from nltk.text import Text

con = mdb.connect(host='localhost', user='root', passwd='', db='biotech', charset='utf8')
with con:
    cur = con.cursor()
    cur.execute("SELECT id, date_txt, text FROM Bioworld_Today")
    #cur.execute("SELECT id, date_txt, text FROM Bioworld_Today WHERE date > '1990-12-31' and date < '1993-01-01'")
    articles = cur.fetchall()

    # build in order!!!
    documents = {}
    for idx, article in enumerate(articles):
        print "%d of %d" %(idx, len(articles))
        
        aid, date_txt, html = article
        d = parser.parse(date_txt)
        #year = str(date).split("-")[0]
        if d in documents:
            documents[d].append(clean_html(html.decode('utf8')))
        else:
            documents[d] = [clean_html(html.decode('utf8'))]
        
    
    dates = documents.keys()
    dates.sort()
    
    
    ts = {}
    for date in dates:
        year = date.strftime("%Y")
        month = date.strftime("%M")
        ds = year+":"+month        
        if ds in ts:
            ts[ds] += documents[date]
        else:
            ts[ds] = documents[date]    
                     
    for t in ts:
        text = Text(wordpunct_tokenize("\n\n".join(ts[t])))
        with open("resources/mo/btxt"+t+".pkl", 'w') as f:
            pickle.dump(text,f)  
        print "Done with %s" %(t)


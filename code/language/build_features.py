from HTMLParser import HTMLParser

class MLStripper(HTMLParser):
    def __init__(self):
        self.reset()
        self.fed = []
    def handle_data(self, d):
        self.fed.append(d)
    def get_data(self):
        return ''.join(self.fed)

def strip_tags(html):
    s = MLStripper()
    s.feed(html)
    return s.get_data()

import MySQLdb as mdb
import nltk
from gensim import corpora
import logging
logging.basicConfig(format='%(asctime)s : %(levelname)s : %(message)s', level=logging.INFO)

con = mdb.connect(host='localhost', user='root', passwd='', db='biotech', charset='utf8')
    
with con:
    cur = con.cursor()
    cur.execute("SELECT id, title, text FROM Bioworld_Today WHERE date > '1990-12-31' and date < '1992-01-01'")
    articles = cur.fetchall()
    documents = []
    for idx, article in enumerate(articles):
        aid, title, text = article
        text = strip_tags(text)
        text = text.replace("."," .").replace(",","")
        documents.append(text.decode('utf8'))
        #print text
        #if idx == 0: 
        #    break 

    # tokenize
    texts = [[word for word in document.lower().split()] for document in documents]  
    
    # get bigrams
    bigrams = [[word[0]+" "+word[1] for word in nltk.bigrams(text)] for text in texts]
    texts = texts + bigrams
    
#    # remove common words and tokenize
#    #stoplist = set('for a of the and to in as i is .'.split())
#    #texts = [[word for word in document.lower().split() if word not in stoplist] for document in documents]    
    
    # remove words that appear only once
    all_tokens = sum(texts, [])    
    tokens_once = set(word for word in set(all_tokens) if all_tokens.count(word) == 1)
    texts = [[word for word in text if word not in tokens_once] for text in texts]

    # create mapping of id to word and save dictionary for future reference
    dictionary = corpora.Dictionary(texts)
    dictionary.save('resources/today.dict')
    print dictionary
    
    corpus = [dictionary.doc2bow(text) for text in texts]
    corpora.MmCorpus.serialize('resources/today.mm', corpus)
    #print corpus
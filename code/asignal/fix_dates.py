import MySQLdb as mdb
from dateutil import parser

con = mdb.connect(host='localhost', user='root', passwd='', db='biotech', charset='utf8')
    
with con:
    cur = con.cursor()
    cur.execute("SELECT id, date_txt FROM Bioworld")
    articles = cur.fetchall()
    
    for article in articles:
       aid, date_txt = article
       d = parser.parse(date_txt)
       cur.execute("UPDATE Bioworld SET date='"+str(d)+"' WHERE id='"+str(aid)+"'") 
    
    con.commit()
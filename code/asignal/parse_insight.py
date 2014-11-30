import xml.etree.ElementTree as ET
import MySQLdb as mdb
import re
from dateutil import parser

con = mdb.connect(host='localhost', user='root', passwd='', db='biotech', charset='utf8')
    
with con:
    cur = con.cursor()
    
    tree = ET.parse('resources/insight.xml')
    items = tree.getroot()
    print len(items)
    for item in items.findall("item"):
        try:
            title = item.find("title").text
            date_txt = item.find("date").text
            text = item.find("text").text
            d = parser.parse(date_txt)
            cur.execute("INSERT INTO Bioworld_Insight SET date='"+str(d)+"', title='"+re.escape(title)+"', date_txt='"+re.escape(date_txt)+"', text='"+re.escape(text)+"'") 
        except:
            print date_txt
                
    con.commit()
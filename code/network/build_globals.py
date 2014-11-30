import MySQLdb as mdb
import csv

con = mdb.connect(host='localhost', user='root', passwd='', db='biotech', charset='utf8')
with con:
    cur = con.cursor()    
    with open('/Users/research/GDrive/Network Value/analysis/industry.csv', 'wb') as csvfile:
        bwriter = csv.writer(csvfile, delimiter=',')
        bwriter.writerow(['fid','year','zip','num_firms'])
        for year in range(198804, 200504, 100):

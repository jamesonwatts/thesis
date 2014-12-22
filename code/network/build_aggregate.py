import networkx as nx
import MySQLdb as mdb
import csv

#g = nx.MultiGraph(name="bio")

con = mdb.connect(host='localhost', user='root', passwd='', db='biotech', charset='utf8')
with con:
    cur = con.cursor()    
    with open('/Users/research/GDrive/Dissertation/thesis/stata/clstr.csv', 'wb') as csvfile:
        bwriter = csv.writer(csvfile, delimiter=',')
        bwriter.writerow(['year','month','avg_clstr','nodes','edges'])
        for year in range(1991, 1992, 1):
            for month in range(1,13):
                mo = str(month) if len(str(month)) > 1 else "0"+str(month)
                date = str(year)+mo
                g = nx.Graph(name="bio")
                
    
                #populate firms
                cur.execute("SELECT fid, firmname, fyr_mrg, ipoyr_mrg, exityear, firsttie, lasttie, emps, phds, publicco, zip FROM firms WHERE suppdate="+str(year)+"04 AND fyr_mrg <= "+date+"31 AND (exityear is Null OR exityear >= "+date+")") 
                firms = cur.fetchall()
                for firm in firms:
                    fid, firmname, fyr_mrg, ipoyr_mrg, exityear, firsttie, lasttie, emps, phds, publicco, zipcode = firm
                    international = 1 if len(str(zipcode)) <= 3 else 0
                    g.add_node(fid, label=firmname, fyr=int(fyr_mrg), ipoyr=int(ipoyr_mrg), eyr=int(exityear), firsttie=int(firsttie), lasttie=int(lasttie), emps=int(emps), phds=int(phds), public=int(publicco), international=int(international), zipcode=int(zipcode))        
                   
                #populate ties
                cur.execute("SELECT fid, tieid, pid1, pid2, pid3, pid4, tcode_new, tiechange, yearstart, yearend_kap, partcount, nih, consoltcode_new, aggtcode_new FROM ties WHERE suppdate="+str(year)+"04 AND yearstart <= "+date+" AND (yearend_kap is Null OR yearend_kap >= "+date+")") 
                ties = cur.fetchall()
        
                for tie in ties:
                    fid, tieid, pid1, pid2, pid3, pid4, tcode, tiechange, tstart, tend, pcount, nih, ctcode, atcode = tie
                    
                    partners = tie[2:6]
                    for partner in partners: #could have multiple partners
                        if partner != -2: #could it have another tie to same partner?
                            form = aggform = consolform = 1
                            if partner > 1000:
                                cur.execute("SELECT form, aggform, consolform FROM Partners WHERE pid="+str(partner))
                                parts = cur.fetchall()
                                form, aggform, consolform = parts[0]
                            g.add_edge(fid, partner, form=int(form), aggform=int(aggform), consolform=int(consolform))
                                        
                
                bwriter.writerow([str(year),str(month),nx.average_clustering(g),len(g.nodes()),len(g.edges())])
                                  
                print "Done with Ties for date %s" %(date)
    

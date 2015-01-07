import networkx as nx
import MySQLdb as mdb
import csv

with open('/Users/research/GDrive/Dissertation/thesis/stata/dyngrph.csv', 'wb') as csvfile:
    bwriter = csv.writer(csvfile, delimiter=',')
    bwriter.writerow(['year','pair','tied','pscore','avg_clstr','nodes','edges'])

    con = mdb.connect(host='localhost', user='root', passwd='', db='biotech', charset='utf8')
    with con:
        cur = con.cursor()
        for year in range(198804, 199104, 100):
            g = nx.Graph(name="bio")
                
            #populate firms
            cur.execute("SELECT fid, firmname, fyr_mrg, ipoyr_mrg, exityear, firsttie, lasttie, emps, phds, publicco, zip FROM firms WHERE fid !=-9 and suppdate = "+str(year))
            firms = cur.fetchall()
            for firm in firms:
                fid, firmname, fyr_mrg, ipoyr_mrg, exityear, firsttie, lasttie, emps, phds, publicco, zipcode = firm
                international = 1 if len(str(zipcode)) <= 3 else 0
                g.add_node(fid, label=firmname, fyr=int(fyr_mrg), ipoyr=int(ipoyr_mrg), eyr=int(exityear), firsttie=int(firsttie), lasttie=int(lasttie), emps=int(emps), phds=int(phds), public=int(publicco), international=int(international), zipcode=int(zipcode))        
               
            #populate ties
            cur.execute("SELECT fid, tieid, pid1, pid2, pid3, pid4, tcode_new, tiechange, yearstart, yearend_kap, partcount, nih, consoltcode_new, aggtcode_new FROM ties WHERE suppdate = "+str(year))
            ties = cur.fetchall()
    
            for tie in ties:
                fid, tieid, pid1, pid2, pid3, pid4, tcode, tiechange, tstart, tend, pcount, nih, ctcode, atcode = tie
                
                partners = tie[2:6]
                for partner in partners: #could have multiple partners
                    if partner != -2 and partner !=-9: #could it have another tie to same partner?
                        form = aggform = consolform = 1
                        if partner > 1000:
                            cur.execute("SELECT form, aggform, consolform FROM Partners WHERE pid="+str(partner))
                            parts = cur.fetchall()
                            form, aggform, consolform = parts[0]
                        g.add_edge(fid, partner, form=int(form), aggform=int(aggform), consolform=int(consolform))
                                    
    
            c = nx.average_clustering(g)
            n = len(g.nodes())
            e = len(g.edges())
            print "Graph has %d nodes and %d edges" %(n, e)
            
            pairs = list(nx.preferential_attachment(g))
            pairs += list(nx.preferential_attachment(g,g.edges()))        
    
            for pair in pairs:
                a,b,p = pair       
                pid = str(a)+":"+str(b) 
                bwriter.writerow([str(year)[0:4],pid,int(g.has_edge(a,b)),p,c,n,e])            
                              
            print "Done with Ties for date %s" %(year)
#    

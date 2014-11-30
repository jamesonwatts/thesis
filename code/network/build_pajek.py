import networkx as nx
import MySQLdb as mdb

#g = nx.MultiGraph(name="bio")

con = mdb.connect(host='localhost', user='root', passwd='', db='biotech', charset='utf8')
with con:
    cur = con.cursor()    
    #for year in range(198804, 200504, 100):
    for year in range(198804, 199004, 100):
        g = nx.MultiGraph(name="bio")        

        #populate firms
        cur.execute("SELECT fid, firmname, fyr_mrg, ipoyr_mrg, exityear, firsttie, lasttie, emps, phds, publicco, zip FROM firms WHERE suppdate = "+str(year))
        firms = cur.fetchall()
        for firm in firms:
            fid, firmname, fyr_mrg, ipoyr_mrg, exityear, firsttie, lasttie, emps, phds, publicco, zipcode = firm
            international = 1 if len(str(zipcode)) <= 3 else 0
            g.add_node(fid, label=firmname, fyr=int(fyr_mrg), ipoyr=int(ipoyr_mrg), eyr=int(exityear), firsttie=int(firsttie), lasttie=int(lasttie), emps=int(emps), phds=int(phds), public=int(publicco), international=int(international))        

            #populate ties
            cur.execute("SELECT pid1, pid2, pid3, pid4, tcode_new, tiechange, yearstart, yearend_kap, partcount, nih, consoltcode_new, aggtcode_new FROM ties WHERE fid = "+str(fid)+" AND suppdate = "+str(year))
            ties = cur.fetchall()

            for tie in ties:
                pid1, pid2, pid3, pid4, tcode, tiechange, tstart, tend, pcount, nih, ctcode, atcode = tie        
                
                partners = tie[0:4]
                for partner in partners: #could have multiple partners
                    if partner != -2: #could it have another tie to same partner?
                        form = aggform = consolform = 1
                        if partner > 1000:
                            cur.execute("SELECT pname, form, aggform, consolform FROM Partners WHERE pid="+str(partner))
                            parts = cur.fetchall()
                            pname, form, aggform, consolform = parts[0]
                        g.add_node(partner, label=pname, form=int(form), aggform=int(aggform), consolform=int(consolform))
                        g.add_edge(fid, partner, tcode=tcode, pcount=pcount, nih=nih, ctcode=ctcode, atcode=atcode)
            
            
             
                            
        nx.write_pajek(g, "../resources/graphs/bio"+str(year)[0:4]+".net")
        print "Done with Ties for year %d" %(year)
    

import networkx as nx
import MySQLdb as mdb
import csv

#g = nx.MultiGraph(name="bio")

con = mdb.connect(host='localhost', user='root', passwd='', db='biotech', charset='utf8')
with con:
    cur = con.cursor()    
    with open('/Users/research/GDrive/Dissertation/thesis/stata/bio.csv', 'wb') as csvfile:
        bwriter = csv.writer(csvfile, delimiter=',')
        bwriter.writerow(['year','month','avg_net_distance','avg_deg_distance','n_bio','n_npr','n_gov','n_fin','n_pha','n_oth'])
        for year in range(1988, 1989, 1):
            for month in range(1,13):
                date = str(year)+str(month)
                g = nx.Graph(name="bio")
                
    
                #populate firms
                cur.execute("SELECT fid, firmname, fyr_mrg, ipoyr_mrg, exityear, firsttie, lasttie, emps, phds, publicco, zip FROM firms WHERE suppdate = "+str(year))
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
                        if partner != -2: #could it have another tie to same partner?
                            form = aggform = consolform = 1
                            if partner > 1000:
                                cur.execute("SELECT form, aggform, consolform FROM Partners WHERE pid="+str(partner))
                                parts = cur.fetchall()
                                form, aggform, consolform = parts[0]
                            g.add_edge(fid, partner, form=int(form), aggform=int(aggform), consolform=int(consolform))
                                        
                
                
            
                d=nx.degree(g)
                nx.set_node_attributes(g,'degree',d)
                dc=nx.degree_centrality(g)
                nx.set_node_attributes(g,'dc',dc)
                ec=nx.eigenvector_centrality(g, 10000)
                nx.set_node_attributes(g,'ec',ec)
                            
                
                for n in g.nodes():
                    if(n < 1000 and n != -9):
                        
                        p_bio = 0
                        p_npr = 0
                        p_gov = 0
                        p_fin = 0
                        p_pha = 0
                        p_oth = 0
                        if n in g.nodes():
                            for edge in g.edges([n],data=True):
                                p_bio = p_bio+1 if edge[2]['consolform'] == 1 else p_bio
                                p_npr = p_npr+1 if edge[2]['consolform'] == 2 else p_npr
                                p_gov = p_gov+1 if edge[2]['consolform'] == 3 else p_gov
                                p_fin = p_fin+1 if edge[2]['consolform'] == 4 else p_fin
                                p_pha = p_pha+1 if edge[2]['consolform'] == 5 else p_pha
                                p_oth = p_oth+1 if edge[2]['consolform'] == 6 else p_oth
    
                        bwriter.writerow([
                            n,str(year)[0:4], 
                            g.node[n]['degree'], 
                            g.node[n]['dc'],
                            g.node[n]['ec'], 
                            g.node[n]['label'] if 'label' in g.node[n].keys() else None, 
                            g.node[n]['fyr'] if 'fyr' in g.node[n].keys() else None, 
                            g.node[n]['ipoyr'] if 'ipoyr' in g.node[n].keys() else None, 
                            g.node[n]['eyr'] if 'eyr' in g.node[n].keys() else None, 
                            g.node[n]['firsttie'] if 'firsttie' in g.node[n].keys() else None, 
                            g.node[n]['lasttie'] if 'lasttie' in g.node[n].keys() else None, 
                            g.node[n]['emps'] if 'emps' in g.node[n].keys() else None, 
                            g.node[n]['phds'] if 'phds' in g.node[n].keys() else None, 
                            g.node[n]['public'] if 'public' in g.node[n].keys() else None,
                            g.node[n]['international'] if 'international' in g.node[n].keys() else None,
                            g.node[n]['zipcode'] if 'zipcode' in g.node[n].keys() else None,
                            p_bio,
                            p_npr,
                            p_gov,
                            p_fin,
                            p_pha,
                            p_oth])
                                  
                print "Done with Ties for date %s" %(date)
    

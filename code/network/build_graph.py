import networkx as nx
from networkx.algorithms import bipartite
import MySQLdb as mdb
import csv
#import structural_holes as sh

con = mdb.connect(host='localhost', user='root', passwd='', db='biotech', charset='utf8')
with con:
    cur = con.cursor()    
    with open('/Users/research/GDrive/Dissertation/thesis/stata/bio.csv', 'wb') as csvfile:
        bwriter = csv.writer(csvfile, delimiter=',')
        bwriter.writerow(['fid','year','d','dc','ec','ec_pro','bc','cc','cl','co','d_r','d_f','d_l','d_c','d_o','name','fyr','ipoyr','eyr','firsttie','lasttie','emps','phds','public','international','zipcode','n_bio','n_npr','n_gov','n_fin','n_pha','n_oth'])
        for year in range(198804, 200404, 100):
            g = nx.Graph(name="bio")
            mg = nx.MultiGraph(name="mbio")
            g1 = nx.MultiGraph(name="research")
            g2 = nx.MultiGraph(name="finance")
            g3 = nx.MultiGraph(name="licensing")
            g4 = nx.MultiGraph(name="commerce")
            g5 = nx.MultiGraph(name="other")

            #populate firms
            cur.execute("SELECT fid, firmname, fyr_mrg, ipoyr_mrg, exityear, firsttie, lasttie, emps, phds, publicco, zip FROM firms WHERE suppdate = "+str(year))
            firms = cur.fetchall()
            for firm in firms:
                fid, firmname, fyr_mrg, ipoyr_mrg, exityear, firsttie, lasttie, emps, phds, publicco, zipcode = firm
                international = 1 if len(str(zipcode)) <= 3 else 0
                mg.add_node(fid, label=firmname, fyr=int(fyr_mrg), ipoyr=int(ipoyr_mrg), eyr=int(exityear), firsttie=int(firsttie), lasttie=int(lasttie), emps=int(emps), phds=int(phds), public=int(publicco), international=int(international), zipcode=int(zipcode)) 
                g.add_node(fid,label=firmname)
                g1.add_node(fid, label=firmname)        
                g2.add_node(fid, label=firmname)        
                g3.add_node(fid, label=firmname)        
                g4.add_node(fid, label=firmname)  
                g5.add_node(fid, label=firmname)
             
            cur.execute("SELECT fid, tieid, pid1, pid2, pid3, pid4, tcode_new, tiechange, yearstart, yearend_kap, partcount, nih, consoltcode_new, aggtcode_new FROM ties WHERE suppdate = "+str(year))
            ties = cur.fetchall()
    
            for tie in ties:
                fid, tieid, pid1, pid2, pid3, pid4, tcode, tiechange, tstart, tend, pcount, nih, ctcode, atcode = tie
                
                partners = tie[2:6]
                for partner in partners: #could have multiple partners
                    if partner != -2 and partner != fid: #could it have another tie to same partner?
                        form = aggform = consolform = 1
                        if partner > 1000:
                            cur.execute("SELECT form, aggform, consolform FROM Partners WHERE pid="+str(partner))
                            parts = cur.fetchall()
                            form, aggform, consolform = parts[0]
                        g.add_edge(fid, partner, form=int(form), aggform=int(aggform), consolform=int(consolform))
                        mg.add_edge(fid, partner, form=int(form), aggform=int(aggform), consolform=int(consolform))
                        if ctcode == 1:
                            g1.add_edge(fid, partner, form=int(form), aggform=int(aggform), consolform=int(consolform))
                        elif ctcode == 2:
                            g2.add_edge(fid, partner, form=int(form), aggform=int(aggform), consolform=int(consolform))                        
                        elif ctcode == 3:
                            g3.add_edge(fid, partner, form=int(form), aggform=int(aggform), consolform=int(consolform))                        
                        elif ctcode == 4:
                            g4.add_edge(fid, partner, form=int(form), aggform=int(aggform), consolform=int(consolform))  
                        else:
                            g5.add_edge(fid, partner, form=int(form), aggform=int(aggform), consolform=int(consolform))  
            
        
            d=nx.degree(mg)
            nx.set_node_attributes(mg,'d',d)
            dc=nx.degree_centrality(mg)
            nx.set_node_attributes(mg,'dc',dc)
            ec=nx.eigenvector_centrality(g, 10000)
            nx.set_node_attributes(g,'ec',ec)     
            bc=nx.betweenness_centrality(mg)
            nx.set_node_attributes(mg,'bc',bc)
            cc=nx.closeness_centrality(mg)
            nx.set_node_attributes(mg,'cc',cc)
            cl=nx.clustering(g)
            nx.set_node_attributes(g,'cl',cl)
            co=nx.communicability_centrality(g)
            nx.set_node_attributes(g,'co',co)
                       
            d=nx.degree(g1)
            nx.set_node_attributes(g1,'d',d)
            d=nx.degree(g2)
            nx.set_node_attributes(g2,'d',d)
            d=nx.degree(g3)
            nx.set_node_attributes(g3,'d',d)
            d=nx.degree(g4)
            nx.set_node_attributes(g4,'d',d)
            d=nx.degree(g5)
            nx.set_node_attributes(g5,'d',d)
            
            #projected eigenvector centrality
            bio_nodes = set(n for n in g.nodes() if n < 1000 and n > 0)
            eg = bipartite.projected_graph(g, bio_nodes)
            ec_pro=nx.eigenvector_centrality(eg, 1000)
            nx.set_node_attributes(eg,'ec',ec_pro) 
#            ho=sh.structural_holes(g)
            
            for n in g.nodes():
                if(n < 1000 and n != -9):
                    
                    
                    #calculate number of partner types
                    n_bio = 0
                    n_npr = 0
                    n_gov = 0
                    n_fin = 0
                    n_pha = 0
                    n_oth = 0
                    for edge in mg.edges([n],data=True):
                        n_bio = n_bio+1 if edge[2]['consolform'] == 1 else n_bio
                        n_npr = n_npr+1 if edge[2]['consolform'] == 2 else n_npr
                        n_gov = n_gov+1 if edge[2]['consolform'] == 3 else n_gov
                        n_fin = n_fin+1 if edge[2]['consolform'] == 4 else n_fin
                        n_pha = n_pha+1 if edge[2]['consolform'] == 5 else n_pha
                        n_oth = n_oth+1 if edge[2]['consolform'] == 6 else n_oth

                    bwriter.writerow([
                        n,str(year)[0:4], 
                        mg.node[n]['d'], 
                        mg.node[n]['dc'],
                        g.node[n]['ec'],
                        eg.node[n]['ec'],
                        mg.node[n]['bc'],
                        mg.node[n]['cc'],
                        g.node[n]['cl'],
                        g.node[n]['co'],
#                        ho[n]['C-Density'] if n in ho.keys() else None,
                        g1.node[n]['d'] if n in g1.nodes() else None,
                        g2.node[n]['d'] if n in g2.nodes() else None,
                        g3.node[n]['d'] if n in g3.nodes() else None,
                        g4.node[n]['d'] if n in g4.nodes() else None,
                        g5.node[n]['d'] if n in g5.nodes() else None,
                        mg.node[n]['label'] if 'label' in mg.node[n].keys() else None, 
                        mg.node[n]['fyr'] if 'fyr' in mg.node[n].keys() else None, 
                        mg.node[n]['ipoyr'] if 'ipoyr' in mg.node[n].keys() else None, 
                        mg.node[n]['eyr'] if 'eyr' in mg.node[n].keys() else None, 
                        mg.node[n]['firsttie'] if 'firsttie' in mg.node[n].keys() else None, 
                        mg.node[n]['lasttie'] if 'lasttie' in mg.node[n].keys() else None, 
                        mg.node[n]['emps'] if 'emps' in mg.node[n].keys() else None, 
                        mg.node[n]['phds'] if 'phds' in mg.node[n].keys() else None, 
                        mg.node[n]['public'] if 'public' in mg.node[n].keys() else None,
                        mg.node[n]['international'] if 'international' in mg.node[n].keys() else None,
                        mg.node[n]['zipcode'] if 'zipcode' in mg.node[n].keys() else None,
                        n_bio,
                        n_npr,
                        n_gov,
                        n_fin,
                        n_pha,
                        n_oth])
                              
            print "Done with Ties for year %d" %(year)
            #break
    

import networkx as nx
import MySQLdb as mdb
import csv

#g = nx.MultiGraph(name="bio")

con = mdb.connect(host='localhost', user='root', passwd='', db='biotech', charset='utf8')
with con:
    cur = con.cursor()    
    with open('/Users/research/GDrive/Network Value/analysis/bio.csv', 'wb') as csvfile:
        bwriter = csv.writer(csvfile, delimiter=',')
        bwriter.writerow(['fid','year','comp_tot','comp_foe','degree','dc','d_r','d_f','d_l','d_c','d_cc','d_cm','ec_r','ec_f','ec_l','ec_c','ec_cc','ec_cm','name','fyr','ipoyr','eyr','firsttie','lasttie','emps','phds','public','international','zipcode','p_bio','p_npr','p_gov','p_fin','p_pha','p_oth'])
        for year in range(198804, 200504, 100):
            g = nx.Graph(name="bio")
            g1 = nx.Graph(name="research")
            g2 = nx.Graph(name="finance")
            g3 = nx.Graph(name="licensing")
            g4 = nx.Graph(name="commerce_all")
            g5 = nx.Graph(name="commerce_cln")
            g6 = nx.Graph(name="commerce_mkt")
            

            #populate firms
            cur.execute("SELECT fid, firmname, fyr_mrg, ipoyr_mrg, exityear, firsttie, lasttie, emps, phds, publicco, zip FROM firms WHERE suppdate = "+str(year))
            firms = cur.fetchall()
            for firm in firms:
                fid, firmname, fyr_mrg, ipoyr_mrg, exityear, firsttie, lasttie, emps, phds, publicco, zipcode = firm
                international = 1 if len(str(zipcode)) <= 3 else 0
                g.add_node(fid, label=firmname, fyr=int(fyr_mrg), ipoyr=int(ipoyr_mrg), eyr=int(exityear), firsttie=int(firsttie), lasttie=int(lasttie), emps=int(emps), phds=int(phds), public=int(publicco), international=int(international), zipcode=int(zipcode))        
                g1.add_node(fid, label=firmname)        
                g2.add_node(fid, label=firmname)        
                g3.add_node(fid, label=firmname)        
                g4.add_node(fid, label=firmname)        
                g5.add_node(fid, label=firmname)        
                g6.add_node(fid, label=firmname)        

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
                        if ctcode == 1:
                            g1.add_edge(fid, partner, form=int(form), aggform=int(aggform), consolform=int(consolform))
                        if ctcode == 2:
                            g2.add_edge(fid, partner, form=int(form), aggform=int(aggform), consolform=int(consolform))                        
                        if ctcode == 3:
                            g3.add_edge(fid, partner, form=int(form), aggform=int(aggform), consolform=int(consolform))                        
                        if ctcode == 4:
                            g4.add_edge(fid, partner, form=int(form), aggform=int(aggform), consolform=int(consolform))
                        if atcode == 4:
                            g5.add_edge(fid, partner, form=int(form), aggform=int(aggform), consolform=int(consolform))
                        if atcode == 5:
                            g6.add_edge(fid, partner, form=int(form), aggform=int(aggform), consolform=int(consolform))
            
            
            
        
            d=nx.degree(g)
            nx.set_node_attributes(g,'degree',d)
            dc=nx.degree_centrality(g)
            nx.set_node_attributes(g,'dc',dc)
            
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
            d=nx.degree(g6)
            nx.set_node_attributes(g6,'d',d)
            
            ec=nx.eigenvector_centrality(g1, 10000)
            nx.set_node_attributes(g1,'ec',ec)
            ec=nx.eigenvector_centrality(g2, 10000)
            nx.set_node_attributes(g2,'ec',ec)
            ec=nx.eigenvector_centrality(g3, 10000)
            nx.set_node_attributes(g3,'ec',ec)
            ec=nx.eigenvector_centrality(g4, 10000)
            nx.set_node_attributes(g4,'ec',ec)
            
            try:
                ec=nx.eigenvector_centrality(g6, 10000)
                nx.set_node_attributes(g6,'ec',ec)
            except:
                print "Can't compute EC"
                for n in g6.nodes():
                    g6.node[n]['ec'] = None
            
            
            for n in g.nodes():
                if(n < 1000 and n != -9):
                    
                    #calculate competition
                    nbs = nx.neighbors(g4,n) if n in g4.nodes() else []
                    comp = []
                    for nb in nbs:
                        comp += list(nx.all_neighbors(g4,nb))
                    collab = list(nx.all_neighbors(g1,n)) if n in g1.nodes() else []
                    s1 = set(comp)
                    s2 = set(collab)
                    comp_tot = len(comp)
                    comp_foe = comp_tot - len(s1.intersection(s2))
                    
                    #calculate number of marketing partner types
                    p_bio = 0
                    p_npr = 0
                    p_gov = 0
                    p_fin = 0
                    p_pha = 0
                    p_oth = 0
                    if n in g4.nodes():
                        for edge in g4.edges([n],data=True):
                            p_bio = p_bio+1 if edge[2]['consolform'] == 1 else p_bio
                            p_npr = p_npr+1 if edge[2]['consolform'] == 2 else p_npr
                            p_gov = p_gov+1 if edge[2]['consolform'] == 3 else p_gov
                            p_fin = p_fin+1 if edge[2]['consolform'] == 4 else p_fin
                            p_pha = p_pha+1 if edge[2]['consolform'] == 5 else p_pha
                            p_oth = p_oth+1 if edge[2]['consolform'] == 6 else p_oth

                    bwriter.writerow([
                        n,str(year)[0:4], 
                        comp_tot,
                        comp_foe, 
                        g.node[n]['degree'], 
                        g.node[n]['dc'],
                        g1.node[n]['d'] if n in g1.nodes() else None,
                        g2.node[n]['d'] if n in g2.nodes() else None,
                        g3.node[n]['d'] if n in g3.nodes() else None,
                        g4.node[n]['d'] if n in g4.nodes() else None,
                        g5.node[n]['d'] if n in g5.nodes() else None,
                        g6.node[n]['d'] if n in g6.nodes() else None,
                        g1.node[n]['ec'] if n in g1.nodes() else None,
                        g2.node[n]['ec'] if n in g2.nodes() else None,
                        g3.node[n]['ec'] if n in g3.nodes() else None,
                        g4.node[n]['ec'] if n in g4.nodes() else None, 
                        None, #can't calculate eigenvector centrality for clinical-only 
                        g6.node[n]['ec'] if n in g6.nodes() else None, 
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
                              
            nx.write_gexf(g, "../resources/graphs/bio"+str(year)[0:4]+".gexf")
            nx.write_gexf(g4, "../resources/graphs/bio"+str(year)[0:4]+"_m.gexf")
            print "Done with Ties for year %d" %(year)
            #break
    

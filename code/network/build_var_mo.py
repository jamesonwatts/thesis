import networkx as nx
import MySQLdb as mdb
import csv
import copy

def closeness(g,x,y):
    try:
        return 1.0/float(nx.shortest_path_length(g,x,y))
    except nx.NetworkXNoPath:
        return 0.0

    

with open('/Users/research/GDrive/Dissertation/thesis/stata/grph_mo.csv', 'wb') as csvfile:
    bwriter = csv.writer(csvfile, delimiter=',')
    bwriter.writerow(['year','month','nodes','edges','nbrs','clse','degr','eigc'])

    con = mdb.connect(host='localhost', user='root', passwd='', db='biotech', charset='utf8')
    with con:
        cur = con.cursor()
        for year in range(1991, 2004, 1):
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
                        if partner != -2 and partner !=-9: #could it have another tie to same partner?
                            form = aggform = consolform = 1
                            if partner > 1000:
                                cur.execute("SELECT form, aggform, consolform FROM Partners WHERE pid="+str(partner))
                                parts = cur.fetchall()
                                form, aggform, consolform = parts[0]
                            if fid != partner: #no self loops
                                g.add_edge(fid, partner, nih=int(nih), form=int(form), aggform=int(aggform), consolform=int(consolform))
                                        
        
                n = nx.number_of_nodes(g)
                e = nx.number_of_edges(g)
#                d = nx.degree_histogram(g)
#                t = len(nx.triangles(g))
                cores = nx.core_number(g)
    #            nihs=nx.get_edge_attributes(g,'nih')
                print "Graph has %d nodes and %d edges" %(n, e)
                
                dc=nx.degree_centrality(g)
                nx.set_node_attributes(g,'dc',dc)
            
                ec=nx.eigenvector_centrality(g, 10000)
                nx.set_node_attributes(g,'ec',ec)
            
                igrp = 0
                
                nbrs = []
                clse = []
                degr = []
                eigc = []
                newg = copy.deepcopy(g)
    
                for edge in g.edges():
                    x,y = edge
                    newg.remove_edge(x,y)
                    nbrs.append(len(list(nx.common_neighbors(newg,x,y))))
                    clse.append(closeness(newg,x,y))
                    degr.append(abs(g.node[x]['dc']-g.node[y]['dc']))
                    eigc.append(abs(g.node[x]['ec']-g.node[y]['ec']))
                    newg.add_edge(x,y)
                
                bwriter.writerow([year,month,n,e,sum(nbrs)/float(len(nbrs)),sum(clse)/float(len(clse)),sum(degr)/float(len(degr)),sum(eigc)/float(len(eigc))])            
                                  
                print "Done with Ties for date %s" %(date)
#    

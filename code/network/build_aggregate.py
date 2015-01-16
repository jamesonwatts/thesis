import networkx as nx
import MySQLdb as mdb
import csv

def closeness(g,x,y):
    try:
        return 1.0/float(nx.shortest_path_length(g,x,y))
    except nx.NetworkXNoPath:
        return 0.0

    

with open('/Users/research/GDrive/Dissertation/thesis/stata/dyngrph.csv', 'wb') as csvfile:
    bwriter = csv.writer(csvfile, delimiter=',')
    bwriter.writerow(['year','pair','tied',
                      'firm_degree',
                      'partner_degree',
                      'firm_experience',
                      'new_partner',
                      'partner_experience',
                      'prior_ties',
                      'prior_experience',
                      'collab_distance',
                      'age_difference',
                      'size_difference',
                      'governance_similarity',
                      'co-location',
                      'dominant_trend',
                      'dominant_type',
                      'firm_cohesion',
                      'partner_cohesion',
                      'shared_cohesion',
                      'firm_tie_diversity',
                      'partner_tie_diversity',
                      'prospective_tie_diversity',
                      'age',
                      'size',
                      'governance',
                      'location',
                      'nodes','edges','triangles','d2','d3','d4','d5','d6','d7','d8','d9','d10','d11','d12','d13','d14','d15','d16','d17','d18','d19','d20'])

    con = mdb.connect(host='localhost', user='root', passwd='', db='biotech', charset='utf8')
    with con:
        cur = con.cursor()
        for year in range(198804, 200004, 100):
            g = nx.Graph(name="bio")
                
            #populate firms
            cur.execute("SELECT fid, firmname, fyr_bio, fyr_mrg, ipoyr_mrg, exityear, firsttie, lasttie, emps, phds, publicco, zip FROM firms WHERE fid !=-9 and suppdate = "+str(year))
            firms = cur.fetchall()
            for firm in firms:
                fid, firmname, fyr_bio, fyr_mrg, ipoyr_mrg, exityear, firsttie, lasttie, emps, phds, publicco, zipcode = firm
                international = 1 if len(str(zipcode)) <= 3 else 0
                fyr = int(fyr_bio) if int(fyr_bio) > 0 else int(fyr_mrg) if int(fyr_mrg) > 0 else None
#                firsttie = int(str(firsttie)[0:4]) if firsttie > 0 else None
                g.add_node(fid, label=firmname, fyr=fyr, ipoyr=int(ipoyr_mrg), eyr=int(exityear), firsttie=int(firsttie), lasttie=int(lasttie), emps=int(emps), phds=int(phds), public=int(publicco), zipcode=int(zipcode))        
               
            #populate ties
            cur.execute("SELECT fid, tieid, pid1, pid2, pid3, pid4, tcode_new, tiechange, yearstart, yearend_kap, partcount, nih, consoltcode_new, aggtcode_new FROM ties WHERE suppdate = "+str(year))
            ties = cur.fetchall()
    
            for tie in ties:
                fid, tieid, pid1, pid2, pid3, pid4, tcode, tiechange, tstart, tend, pcount, nih, ctcode, atcode = tie
                
                partners = tie[2:6]
                for partner in partners: #could have multiple partners
                    if partner != -2 and partner !=-9: #could it have another tie to same partner?
                        form = aggform = consolform = 1
                        if partner < 1000:   #only DBFs                     
#                            if partner > 1000:
#                                cur.execute("SELECT form, aggform, consolform FROM Partners WHERE pid="+str(partner))
#                                parts = cur.fetchall()
#                                form, aggform, consolform = parts[0]
                            if fid != partner: #no self loops
                                g.add_edge(fid, partner, nih=int(nih), form=int(form), aggform=int(aggform), consolform=int(consolform))
                                    
    
            n = nx.number_of_nodes(g)
            e = nx.number_of_edges(g)
            d = nx.degree_histogram(g)
            t = nx.transitivity(g)
            kc = nx.core_number(g)
            nx.set_node_attributes(g,'k_core',kc)
            dc=nx.degree_centrality(g)
            nx.set_node_attributes(g,'dc',dc)
            
#            nihs=nx.get_edge_attributes(g,'nih')
            print "Graph has %d nodes and %d edges and %f transitivity" %(n, e, t)
            
            #grab initial pairs
            pairs = list(nx.preferential_attachment(g))
            pairs += list(nx.preferential_attachment(g,g.edges()))            
            
            yr =  int(str(year)[0:4])
            for pair in pairs:
                x,y,p = pair 
                xyr = int(str(g.node[x]['fyr'])[0:4]) if 'fyr' in g.node[x].keys() else None
                yyr = int(str(g.node[y]['fyr'])[0:4]) if 'fyr' in g.node[y].keys() else None
                xft = int(str(g.node[x]['firsttie'])[0:4]) if 'firsttie' in g.node[x].keys() else None
                yft = int(str(g.node[y]['firsttie'])[0:4]) if 'firsttie' in g.node[y].keys() else None
                c = len(list(nx.common_neighbors(g,x,y)))
                row = [yr,str(x)+":"+str(y),int(g.has_edge(x,y)),
                       g.node[x]['dc'], 
                       g.node[y]['dc'],
                       yr-xft if xft > 0 and xft < yr else 0,
                       (1 if yr==yyr else 0) if yyr != None else None,
                       yr-yft if yft > 0 and yft < yr else 0,
                       'prior_ties',
                       'prior_experience',
                       'collab_distance',
                       abs(xyr-yyr) if xyr != None and yyr != None else None,
                       abs(g.node[x]['emps']-g.node[y]['emps']) if 'emps' in g.node[x].keys() and 'emps' in g.node[y].keys() else None,
                       (1 if g.node[x]['public'] and g.node[y]['public'] else 0) if 'public' in g.node[x].keys() and 'public' in g.node[y].keys() else None,
                       'co_location',
                       'dominant_trend',
                       'dominant_type',
                       g.node[x]['k_core'],
                       g.node[y]['k_core'],
                       min(g.node[x]['k_core'],g.node[y]['k_core']),
                       'firm_tie_diversity',
                       'partner_tie_diversity',
                       'prospective_tie_diversity',
                       yr-xyr if xyr != None else None,
                       g.node[x]['emps'] if 'emps' in g.node[x].keys() else None,
                       g.node[x]['public'] if 'public' in g.node[x].keys() else None,
                       g.node[x]['zipcode'] if 'zipcode' in g.node[x].keys() else None]

          
                row+= [n,e,t]
                bwriter.writerow(row+d)            

            print "Done with Ties for date %s" %(year)

import MySQLdb as mdb
import csv
 
con = mdb.connect(host='localhost', user='root', passwd='', db='biotech', charset='utf8')
with con:
    cur = con.cursor() 

    #static data and firm id map
    verts = {}
    idx = 1
    sta = {0:['id','foreign']}        
    cur.execute("SELECT fid, zip FROM firms GROUP BY fid ORDER BY fid ASC")
    firms = cur.fetchall()
    for firm in firms:
        fid, zipcode = firm
        verts[fid] = idx
        foreign = "NA" if zipcode < 0 else (1 if len(str(zipcode)) < 5 else 0)
        sta[idx] = [idx,foreign]
        idx += 1    
    
    with open('/Users/research/GDrive/Dissertation/proposal/networks/sta.tsv', 'wb') as tsvfile:    
        tw = csv.writer(tsvfile, delimiter='\t')
        tw.writerow(sta[0])
        for vert in verts:                
            tw.writerow(sta[verts[vert]])
        print "Done w/ Static"
    
    print len(verts)
    for year in range(198804, 200504, 100):
        #prime the pump
        yr = int(str(year)[0:4])
        adj = {0:['']+range(1,len(verts)+2)}
        atr = {0:['id','age','pub_exp','public','tie_exp','tie_drm','emps','phds','alive']}
        for vert in verts:
            adj[verts[vert]] = [0]*((len(verts)+1))
            atr[verts[vert]] = ["NA"]*7 + [0]
        
        #dynamic attributes
        cur.execute("SELECT fid, fyr_mrg, ipoyr_mrg, publicco, firsttie, lasttie, zip, emps, phds FROM firms WHERE suppdate = "+str(year))
        firms = cur.fetchall()
        alive = []
        for firm in firms:
            fid,onset,ipoyr,public,firsttie,lasttie,zipcode,emps,phds = firm
            alive.append(fid)
            age = "NA" if onset < 0 else yr - int(str(onset)[0:4])
            age = "NA" if age < 0 else age #weird data inconsistencies
            pub_exp = "NA" if ipoyr < 0 or not public else yr - int(str(ipoyr)[0:4])
            public = "NA" if public < 0 else public
            tie_exp = "NA" if firsttie < 0 or firsttie > year else yr - int(str(firsttie)[0:4])
            tie_drm = "NA" if lasttie < 0 or lasttie > year else yr - int(str(lasttie)[0:4])
            emps = "NA" if emps < 0 else emps
            phds = "NA" if phds < 0 else phds 
            
            atr[verts[fid]] = [age,pub_exp,public,tie_exp,tie_drm,emps,phds,1]
        
                   
        with open('/Users/research/GDrive/Dissertation/proposal/networks/'+str(yr)+'atr.tsv', 'wb') as tsvfile:    
            tw = csv.writer(tsvfile, delimiter='\t', quotechar='"')
            tw.writerow(atr[0])
            for vert in verts:                
                tw.writerow([verts[vert]]+atr[verts[vert]])
            print "Done w/ Attributes for year "+str(yr)
            
        
        #direct links
        links = {}   
        cur.execute("SELECT fid, pid1, pid2, pid3, pid4 FROM ties WHERE suppdate = "+str(year))
        ties = cur.fetchall()
        for tie in ties:
            f, p1, p2, p3, p4 = tie
            for p in [p1,p2,p3,p4]:
                if p > 0 and p < 1000:
                    adj[verts[f]][verts[p]] = 1
                    adj[verts[p]][verts[f]] = 1
                if p >= 1000:
                    if p in links:
                        links[p].append(f)
                    else:
                        links[p] = [f]
        
        #mapped links
        for p in links:
            while(len(links[p])>0):
                v = links[p].pop()
                for l in links[p]:
                   adj[verts[v]][verts[l]] = 1
                   adj[verts[l]][verts[v]] = 1                  
        
        #structural zeros
        for vert in verts:
            if atr[verts[vert]][7]==0:
                for tie in adj[verts[vert]]:
                   adj[verts[vert]][tie] = 10
                                                                                                                                                                    
        with open('/Users/research/GDrive/Dissertation/proposal/networks/'+str(yr)+'adj.tsv', 'wb') as tsvfile:    
            tw = csv.writer(tsvfile, delimiter='\t')
            tw.writerow(adj[0])
            for vert in verts:                
                tw.writerow([verts[vert]]+adj[verts[vert]])
            print "Done w/ Ties for year "+str(yr)
    
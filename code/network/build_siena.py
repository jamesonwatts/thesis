import MySQLdb as mdb
import csv
 
con = mdb.connect(host='localhost', user='root', passwd='', db='biotech', charset='utf8')
with con:
    cur = con.cursor() 
    #construct contiguous vertex map
    verts = {}
    idx = 1
    sta = {0:['id','foreign','form']}
    
    cur.execute("SELECT fid, zip FROM firms GROUP BY fid ORDER BY fid ASC")
    firms = cur.fetchall()
    
    for firm in firms:
        fid, zipcode = firm
        verts[fid] = idx
        foreign = "NA" if zipcode < 0 else (len(str(zipcode)) < 5)
        sta[idx] = [idx,foreign,'bio']
        idx += 1
            
    forms = {1:'bio',2:'npr',3:'gov',4:'fin',5:'pha',6:'oth'}
    cur.execute("SELECT pid, aggregion, consolform FROM partners ORDER BY pid ASC")
    partners = cur.fetchall()
    
    for partner in partners:
        pid, region, cform = partner
        verts[pid] = idx
        foreign = "NA" if region < 0 else (region > 1)
        form = forms[cform] if cform > 0 else "NA"
        sta[idx] = [idx,foreign,form]
        idx += 1
    
    
    with open('/Users/research/GDrive/Dissertation/proposal/networks/sta.tsv', 'wb') as tsvfile:    
        tw = csv.writer(tsvfile, delimiter='\t')
        tw.writerow(sta[0])
        for vert in verts:                
            tw.writerow(sta[verts[vert]])
        print "Done w/ Static"
    
    print len(verts)
    for year in range(198804, 200504, 100):
        yr = int(str(year)[0:4])
        adj = {0:['']+range(1,len(verts)+2)}
        atr = {0:['id','age','pub_exp','public','tie_exp','tie_drm','emps','phds','alive']}
        for vert in verts:
            adj[verts[vert]] = [0]*((len(verts)+1))
            atr[verts[vert]] = ["NA"]*7 + [0]
        

        cur.execute("SELECT fid, pid1, pid2, pid3, pid4 FROM ties WHERE suppdate = "+str(year))
        ties = cur.fetchall()
        for tie in ties:
            fid, p1, p2, p3, p4 = tie
            for p in [p1,p2,p3,p4]:
                if p > 0:
                    adj[verts[fid]][verts[p]] = 1
                    
        with open('/Users/research/GDrive/Dissertation/proposal/networks/'+str(yr)+'adj.tsv', 'wb') as tsvfile:    
            tw = csv.writer(tsvfile, delimiter='\t')
            tw.writerow(adj[0])
            for vert in verts:                
                tw.writerow([verts[vert]]+adj[verts[vert]])
            print "Done w/ Ties for year "+str(yr)

                
        cur.execute("SELECT fid, fyr_mrg, ipoyr_mrg, publicco, firsttie, lasttie, zip, emps, phds FROM firms WHERE suppdate = "+str(year))
        firms = cur.fetchall()
        for firm in firms:
            fid,onset,ipoyr,public,firsttie,lasttie,zipcode,emps,phds = firm
            age = "NA" if onset < 0 else yr - int(str(onset)[0:4])
            age = "NA" if age < 0 else age #weird data inconsistencies
            pub_exp = "NA" if ipoyr < 0 or not public else yr - int(str(ipoyr)[0:4])
            public = "NA" if public < 0 else public
            tie_exp = "NA" if firsttie < 0 or firsttie > year else yr - int(str(firsttie)[0:4])
            tie_drm = "NA" if lasttie < 0 or lasttie > year else yr - int(str(lasttie)[0:4])
            emps = "NA" if emps < 0 else emps
            phds = "NA" if phds < 0 else phds 
            
            atr[verts[fid]] = [age,pub_exp,public,tie_exp,tie_drm,emps,phds,1]
        
        cur.execute("SELECT pid, fyr_ptr, exityear FROM partners")
        firms = cur.fetchall()
        for firm in firms:
            pid,onset,terminus = firm
            age = "NA" if onset < 0 else yr - int(str(onset)[0:4])
            age = "NA" if age < 0 else age #weird data inconsistencies
            alive = 1 if age=="NA" or age>0 else 0
            alive = 0 if terminus > 0 and int(str(terminus)[0:4] < yr) else alive
            
            atr[verts[pid]] = [age,"NA","NA","NA","NA","NA","NA",alive]        
                                
        with open('/Users/research/GDrive/Dissertation/proposal/networks/'+str(yr)+'atr.tsv', 'wb') as tsvfile:    
            tw = csv.writer(tsvfile, delimiter='\t', quotechar='"')
            tw.writerow(atr[0])
            for vert in verts:                
                tw.writerow([verts[vert]]+atr[verts[vert]])
            print "Done w/ Attributes for year "+str(yr)
    
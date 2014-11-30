import MySQLdb as mdb
import csv
 
con = mdb.connect(host='localhost', user='root', passwd='', db='biotech', charset='utf8')
with con:
    cur = con.cursor() 
    #construct contiguous vertex map
    verts = {}
    idx = 1
    cur.execute("SELECT distinct fid FROM firms ORDER BY fid ASC")
    firms = cur.fetchall()
    for firm in firms:
        verts[firm[0]] = idx
        idx += 1
        
    #allfirms
    cur.execute("SELECT fid, fyr_mrg, exityear, suppdate FROM firms ORDER BY suppdate ASC")
    firms = cur.fetchall()
    frows = {}
    for firm in firms:
        fid, onset, terminus, suppdate = firm
        onset = int(str(onset)[0:4]) if onset > 0 else int(str(suppdate)[0:4])
        terminus = int(str(terminus)[0:4]) if terminus > 0 else float("Inf")
        while onset>=terminus:
            terminus = terminus+1
        if fid not in frows:
            frows[fid] = {'onset':onset,'terminus':terminus}
    
    #populate ties (and update firms)
    cur.execute("SELECT tieid, fid, pid1, pid2, pid3, pid4, yearstart, yearend_kap, suppdate, tcode_new, aggtcode_new, consoltcode_new, nih, suppdate FROM ties ORDER BY suppdate ASC")
    ties = cur.fetchall()
    erows = {}
    for tie in ties:
        tieid, fid, p1, p2, p3, p4, yearstart, yearend_kap, suppdate, tcode, atcode, ctcode, nih, suppdate = tie
        if ctcode == -9 or ctcode == 27 or ctcode == 26: #error in the db or unknown
            ctcode = 0
        year = int(str(suppdate)[0:4])
        onset = int(str(yearstart)[0:4])
        terminus = -9 if yearend_kap is None else int(str(yearend_kap)[0:4])
        if year < onset or onset < 0:
            onset = year
        if year > terminus:
            terminus = year
        for partner in [p1,p2,p3,p4]: #could have multiple partners
            if partner > 0 and partner < 1000: #only DBFs
                tail,head = [fid,partner] if fid < partner else [partner,fid]
                eid = str(head)+"~"+str(tail)
                tid = str(tcode)+"~"+str(atcode)+"~"+str(ctcode)+"~"+str(nih)
                if eid in erows:
                    if tid in erows[eid]:
                        if onset < erows[eid][tid]['onset']:
                            erows[eid][tid]['onset'] = onset
                        if terminus > erows[eid][tid]['terminus']:
                            erows[eid][tid]['terminus'] = terminus
                    else:
                        erows[eid][tid] = {'onset':onset,'terminus':terminus,'tail.id':tail,'head.id':head,'type':ctcode,'nih':nih}
                else:
                    erows[eid] = {tid:{'onset':onset,'terminus':terminus,'tail.id':tail,'head.id':head,'type':ctcode,'nih':nih}}
                
                                                                
    with open('/Users/research/GDrive/Dissertation/analysis/networks/edges.tsv', 'wb') as csvfile:
        bwriter = csv.writer(csvfile, delimiter='\t')
        bwriter.writerow(['onset','terminus','tail.id','head.id','type','nih'])
        for row in erows:
            
            for tie in erows[row]:
                onset = erows[row][tie]['onset']
                terminus = erows[row][tie]['terminus']
                while(terminus <= onset):
                    terminus = terminus+1
                bwriter.writerow([onset,terminus, verts[erows[row][tie]['tail.id']], verts[erows[row][tie]['head.id']], erows[row][tie]['type'], erows[row][tie]['nih']]) 
                
    print "Done w/ Ties"
    
    with open('/Users/research/GDrive/Dissertation/analysis/networks/vertices.tsv', 'wb') as csvfile:
        bwriter = csv.writer(csvfile, delimiter='\t')
        bwriter.writerow(['onset','terminus','id'])
        for row in frows:
            onset = frows[row]['onset']
            terminus = frows[row]['terminus']
            while(terminus <= onset):
                terminus = terminus+1
            bwriter.writerow([onset,terminus,verts[row]])
    print "Done w/ firms"                    
    
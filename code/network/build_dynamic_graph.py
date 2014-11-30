import networkx as nx
import MySQLdb as mdb
from datetime import date

g = nx.MultiGraph(name="bio")

con = mdb.connect(host='localhost', user='root', passwd='', db='biotech', charset='utf8')
with con:
    cur = con.cursor()
    cur.execute("SELECT fid, firmname, fyr_mrg, exityear FROM firms")
    firms = cur.fetchall()
    
    for firm in firms:
        fid, firmname, fdt, edt = firm
        if fdt == -9:
            fdt = 196801
        if edt == -9 or edt == -1:
            edt = 200501
        fyr = int(str(fdt)[0:4])
        fmo = int(str(fdt)[4:6])
        eyr = int(str(edt)[0:4])
        emo = int(str(edt)[4:6])
        if(fmo == 0): #if month is unknown, set to january
            fmo = 1
        if(emo == 0):
            emo = 1
        g.add_node(fid,label=firmname, start=str(date(fyr,fmo,01)), end=str(date(eyr,emo,01)))        
    print "Done with Firms"
    
    cur.execute("SELECT pid, pname, fyr_ptr, exityear FROM partners")
    partners = cur.fetchall()
    
    for partner in partners:
        pid, pname, fdt, edt = partner
        if fdt == -8 or fdt == -9:
            fdt = 196801
        if edt == -8 or edt == -9 or edt == -1:
            edt = 200501
        fyr = int(str(fdt)[0:4])
        fmo = int(str(fdt)[4:6])
        eyr = int(str(edt)[0:4])
        emo = int(str(edt)[4:6])
        
        if(fmo == 0 or fmo > 12): #if month is unknown, set to january
            fmo = 01
        if(emo == 0 or emo > 12): #weird mo == 66 error
            emo = 01
        
        g.add_node(pid,label=pname, start=str(date(fyr,fmo,01)), end=str(date(eyr,emo,01)))
    print "Done with Partners"
            
    cur.execute("SELECT fid, tieid, pid1, pid2, pid3, pid4, tcode_new, tiechange, yearstart, yearend_kap, partcount, nih FROM ties WHERE aggtcode_new = 5 ORDER BY yearstart ASC")
    ties = cur.fetchall()
    
    for tie in ties:
        fid, tieid, pid1, pid2, pid3, pid4, tcode, tiechange, fdt, edt, pcount, nih = tie
        if(fdt == -9):
            fdt = 196801
        if(edt == None):
            edt = 200501
        fyr = int(str(fdt)[0:4])
        fmo = int(str(fdt)[4:6])
        eyr = int(str(edt)[0:4])
        emo = int(str(edt)[4:6])
        if(fmo == 0): #if month is unknown, set to january
            fmo = 1
        if(emo == 0):
            emo = 1
        
        partners = tie[2:6]
        for partner in partners:
            if partner != -2:
                g.add_edge(fid, partner, key=int(tieid), start=str(date(fyr,fmo,01)), end=str(date(eyr,emo,01))) 
                
    nx.write_gexf(g, "../resources/graphs/bio.gexf")
    print "Done with Ties"
    
    

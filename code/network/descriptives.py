import MySQLdb as mdb
import csv

con = mdb.connect(host='localhost', user='root', passwd='', db='biotech', charset='utf8')
with con:
    cur = con.cursor()    
    with open('/Users/research/GDrive/Dissertation/analysis/descriptives.csv', 'wb') as csvfile:
        bwriter = csv.writer(csvfile, delimiter=',')
        header = ['year']
        rp = []
        fp = []
        lp = []
        cp = []
        for i in range(1,24):
            rp.append("r"+str(i))
            fp.append("f"+str(i))
            lp.append("l"+str(i))
            cp.append("c"+str(i)) 
        header = header + ['rd','ard','rt'] + rp + ['fd','afd','ft'] + fp + ['ld','ald','lt'] + lp + ['cd','acd','ct'] + cp  
        bwriter.writerow(header)
        
        for year in range(198804, 200504, 100):
        #for year in range(198804, 199004, 100):
            r_tot = f_tot = l_tot = c_tot = 0
            firms = {}                
            cur.execute("SELECT fid, tieid, pid1, pid2, pid3, pid4, tcode_new, tiechange, yearstart, yearend_kap, partcount, nih, consoltcode_new, aggtcode_new FROM ties WHERE suppdate = "+str(year))
            ties = cur.fetchall()            
            for tie in ties:
                fid, tieid, pid1, pid2, pid3, pid4, tcode, tiechange, tstart, tend, pcount, nih, ctcode, atcode = tie
                
                #diversity by FID
        
                if fid not in firms.keys():
                    firms[fid] = {'r':23*[0.0],'f':23*[0.0],'l':23*[0.0],'c':23*[0.0]}
                
                partners = tie[2:6]
                for partner in partners: #could have multiple partners
                    if partner != -2: #could it have another tie to same partner?
                        form = aggform = consolform = 1
                        if partner >= 1000:
                            cur.execute("SELECT form, aggform, consolform FROM Partners WHERE pid="+str(partner))
                            parts = cur.fetchall()
                            form = int(parts[0][0])
                            aggform = int(parts[0][1])
                            consolform = int(parts[0][2])
                        
                        if form > 0:        
                            if ctcode == 1: #research
                                r_tot += 1
                                firms[fid]['r'][form-1] += 1
                            if ctcode == 2: #finance
                                f_tot +=1
                                firms[fid]['f'][form-1] += 1
                            if ctcode == 3: #licensing
                                l_tot +=1
                                firms[fid]['l'][form-1] += 1
                            if ctcode == 4: #commerce
                                c_tot +=1
                                firms[fid]['c'][form-1] += 1
            
            #type totals
            r = 23*[0.0]
            f = 23*[0.0]
            l = 23*[0.0]
            c = 23*[0.0]

            for firm in firms:
                for i in range(0,23):
                    r[i] += firms[firm]['r'][i]
                    f[i] += firms[firm]['f'][i]
                    l[i] += firms[firm]['l'][i]
                    c[i] += firms[firm]['c'][i]

            #pcts
            rp = [t/r_tot for t in r]
            fp = [t/f_tot for t in f]
            lp = [t/l_tot for t in l]
            cp = [t/c_tot for t in c]

            #diversity
            rd = fd = ld = cd = 0.0
            for i in range(0,23):
                rd += rp[i]**2                        
                fd += fp[i]**2
                ld += lp[i]**2
                cd += cp[i]**2
            rd = 1-rd
            fd = 1-fd
            ld = 1-ld
            cd = 1-cd
            
            #avg firm-level diversity
            adiv = {'frd':[],'ffd':[],'fld':[],'fcd':[]}
            for firm in firms:
                frt = fft = flt = fct = 0.0
                for i in range(0,23):
                    frt += firms[firm]['r'][i]
                    fft += firms[firm]['f'][i]
                    flt += firms[firm]['l'][i]
                    fct += firms[firm]['c'][i]
                frp2 = [(t/frt)**2 for t in firms[firm]['r']] if frt != 0 else [1]
                ffp2 = [(t/fft)**2 for t in firms[firm]['f']] if fft != 0 else [1]
                flp2 = [(t/flt)**2 for t in firms[firm]['l']] if flt != 0 else [1]
                fcp2 = [(t/fct)**2 for t in firms[firm]['c']] if fct != 0 else [1]
                adiv['frd'].append(1-sum(frp2))
                adiv['ffd'].append(1-sum(ffp2))
                adiv['fld'].append(1-sum(flp2))
                adiv['fcd'].append(1-sum(fcp2))
            
            ard = sum(adiv['frd'])/len(firms)
            afd = sum(adiv['ffd'])/len(firms)
            ald = sum(adiv['fld'])/len(firms)
            acd = sum(adiv['fcd'])/len(firms)
           
            yr = str(year)[0:4]
            row = [yr,rd,ard,r_tot] + rp + [fd,afd,f_tot] + fp + [ld,ald,l_tot] + lp + [cd,acd,c_tot] + cp
            print yr
            bwriter.writerow(row)
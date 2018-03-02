#!/usr/bin/env python3
import csv, sys, re

if len(sys.argv) < 2:
    print("Expecting one filename argument")
    exit()

file = sys.argv[1]
#ofile = "indel_matrix.phy"
ofile = "snp_matrix.fasaln"
strains = []
aln = {}
with open(file,"r") as tablefh:
    reader = csv.reader(tablefh,delimiter="\t")
    for indel in reader:
        ref = re.sub(r'\/','',indel[4])
        alt = indel[5]
        
        if len(strains) == 0:
            aln['REF'] = ""
            for n in range(6,len(indel),1):
                strains.append(indel[n])
                aln[indel[n]] = ""
        else:
            print(indel[0],indel[1],indel[3],ref,alt)
            i = 0
            aln['REF'] += str(ref)
            for n in range(6,len(indel),1):
                allele = re.sub(r'\/','',indel[n])
                print(strains[i],allele)
                aln[strains[i]] += str(allele)
                i += 1

#with open(ofile,"w") as fh:
#    fh.write("%5d %5d\n" % (len(strains),len(strains[0])))
#    for strain in aln:
#        fh.write("%-10s %s\n" % (strain,aln[strain]))

with open(ofile,"w") as fh:
    for strain in aln:
        fh.write(">%s\n%s\n" % (strain,aln[strain]))

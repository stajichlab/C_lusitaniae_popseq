#!/usr/bin/env python3
import csv, sys, re

file = "Table_S2_final.csv";
ofile = "Table_S2_indel_matrix.fasaln"
ofileBinary = "Table_S2_indel_matrix_binaryonly.fasaln"
strains = []
aln = {}
alnB = {}
with open(file,"r") as tablefh:
    reader = csv.reader(tablefh,delimiter=",")
    for indel in reader:
        if len(strains) == 0:     # this is the header row
            aln['REF'] = ""
            alnB['REF'] = ""
            for n in range(6,len(indel),1):
                strains.append(indel[n])
                aln[indel[n]] = ""
                alnB[indel[n]] = ""
        else: # regular data row
            ref = re.sub(r'\/','',indel[4])
            alt = re.sub(r'[\[\]]','',indel[5])
            # remove white space and replace '*' with 'N'
            alts = [ re.sub(r'\*','N',re.sub(r'\s+','',i)) for i in alt.split(",") ]

            genolookup = {}
            genolookupBinary = {}
            genolookup[ref] = 0
            genolookupBinary[ref] = 0
            code = 1
            for n in alts:                                
                genolookupBinary[n] = 1
                genolookup[n] = code
                code += 1

            print(indel[0],indel[1],indel[2],indel[3],ref,alt,alts)
            i = 0
            aln['REF'] += str(0)
            alnB['REF'] += str(0)
            
            for n in range(6,len(indel),1):
                allele = re.sub(r'\/','',indel[n])
                if allele in genolookup:
                    print(strains[i],allele,genolookup[allele])
                else:
                    print("Cannot find ",allele, "in",genolookup)

                aln[strains[i]] += str(genolookup[allele])
                alnB[strains[i]] += str(genolookupBinary[allele])
                i += 1

#with open(ofile,"w") as fh:
#    fh.write("%5d %5d\n" % (len(strains),len(strains[0])))
#    for strain in aln:
#        fh.write("%-10s %s\n" % (strain,aln[strain]))

with open(ofile,"w") as fh:
    for strain in aln:
        fh.write(">%s\n%s\n" % (strain,aln[strain]))

with open(ofileBinary,"w") as fh:
    for strain in alnB:
        fh.write(">%s\n%s\n" % (strain,alnB[strain]))

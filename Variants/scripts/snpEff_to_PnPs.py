#Run in same folder as snpEff output. Takes snpEff_genes.txt table and computes ratios of Pn/Ps
import sys


snpsbygene = open("snpEff_genes.txt",'r')
snpsbygene.readline()
header = snpsbygene.readline()
headerarr = header.split()
#print headerarr
dict = {}
i=0
for col in headerarr:

#	if col != 'BioType':
	dict[col]=i
	i+=1
	
#		print col + " " + str(dict[col])
print 'GeneID\tPn\tPs\tPn/Ps\tTotal'
for line in snpsbygene:
	linearr=line.split()
#	print linearr
	pn = int(linearr[dict['variants_effect_missense_variant']]) + int(linearr[dict['variants_effect_stop_gained']]) + int(linearr[dict['variants_effect_start_lost']])
	ps = int(linearr[dict['variants_effect_synonymous_variant']])
	total = pn+ps
#	print '{}\t{}\t{}'.format(int(linearr[dict['variants_effect_missense_variant']]),int(linearr[dict['variants_effect_stop_gained']]),int(linearr[dict['variants_effect_start_lost']]))

	if ps == 0:
		ratio = 'Undef'
		print "{}\t{}\t{}\t{}\t{}".format(linearr[0],pn,ps,ratio,total)
	else:
		ratio = float(pn)/float(ps)
		print "{}\t{}\t{}\t{:.4}\t{}".format(linearr[0],pn,ps,ratio,total)


import sys
import vcf.parser
from Bio import SeqIO
# this script will convert a VCF from snpEff into a useful table

if len(sys.argv) < 2:
	print "Usage snpEff_to_table.py snpeff.vcf"

newfilename = sys.argv[1].strip('vcf')

count=0
vcf_reader = vcf.Reader(open(sys.argv[1], 'r'))


chrs={}
for seq in SeqIO.parse("/bigdata/stajichlab/shared/projects/Candida/HMAC/Clus_reseq/genome/candida_lusitaniae_ATCC42720_w_CBS_6936_MT.fasta", "fasta"):
	chrs[seq.id] = seq.seq
for record in vcf_reader:
	if count ==0:
		sampname = []
		for sample in record.samples:
        		sampname.append(sample.sample)
		samples = '\t'.join(map(str,sampname))
		print "CHROM\tPOS\tFLANKING\tTYPE\tGENE\tREF\tALT\t"+samples+"\tANN"
		count = 1
        anns =  record.INFO['ANN']
	arrayout = [record.CHROM,record.POS]
	flanking_seq = chrs[record.CHROM][record.POS-10:record.POS+10]
	arrayout.append(flanking_seq)
	annarr = anns[0].split('|')
#	if annarr[1] == 'missense_variant' or annarr[1] == 'synonymous_variant' or annarr[1] == 'stop_lost' or annarr[1] == 'stop_gained' or annarr[1] ==  'frameshift_variant':
#		arrayout.extend((annarr[1],annarr[3]))
#	else:
#		arrayout.extend(('intergenic',annarr[3]))
	if annarr[1] == 'upstream_gene_variant' or annarr[1] == 'downstream_gene_variant'or annarr[1] == 'intergenic_region':
		 arrayout.extend(('intergenic',annarr[3]))
	else:
		arrayout.extend((annarr[1],annarr[3]))
	arrayout.extend((record.REF,record.ALT))
	#print arrayout
        for sample in record.samples:
		if sample.gt_bases:
			arrayout.append(sample.gt_bases+"/")
		else:
			arrayout.append('./')
	for ann in anns:
                annarr=ann.split('|')
		readableann="("+annarr[3]+","+annarr[0]+","+annarr[1]+")"
		arrayout.append(readableann)	

	print('\t'.join(map(str,arrayout)))

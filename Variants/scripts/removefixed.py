#removes fixed (ie non segregating) variants. Compared to the other script, this one includes sites that are an unknown call

import sys
import vcf.parser


if len(sys.argv) < 2:
	print "Usage removedfixed.py infile.SNPSONLY.vcf"


newfilename = sys.argv[1].strip('vcf')
newfilelung = newfilename + "lungonly.vcf"
newfilefixed = newfilename + "fixed.vcf"

vcf_reader = vcf.Reader(open(sys.argv[1], 'r'))
vcf_writer_lung = vcf.Writer(open(newfilelung,'w'),vcf_reader)
vcf_writer_fixed = vcf.Writer(open(newfilefixed,'w'),vcf_reader)
for record in vcf_reader:


	if record.num_hom_ref > 0 or len(record.alleles) > 2 or record.num_unknown > 0): 
			#print record.num_hom_ref
		vcf_writer_lung.write_record(record) 
	else:
		vcf_writer_fixed.write_record(record)
		
vcf_writer_lung.close()
vcf_writer_fixed.close()

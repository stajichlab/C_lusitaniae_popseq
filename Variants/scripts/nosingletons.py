import sys
import vcf.parser


if len(sys.argv) < 2:
	print "Usage removedfixed.py infile.SNPSONLY.vcf"


newfilename = sys.argv[1].strip('vcf')
singletons = newfilename + "singletons.vcf"
nosingletons = newfilename + "nosingletons.vcf"

vcf_reader = vcf.Reader(open(sys.argv[1], 'r'))
vcf_writer_singletons = vcf.Writer(open(singletons,'w'),vcf_reader)
vcf_writer_nosingletons = vcf.Writer(open(nosingletons,'w'),vcf_reader)
for record in vcf_reader:
#	print record.num_hom_ref
	if record.num_hom_alt == 1:
#		print record.num_hom_alt
		vcf_writer_singletons.write_record(record)
	else:
		vcf_writer_nosingletons.write_record(record)  
vcf_writer_singletons.close()
vcf_writer_nosingletons.close()

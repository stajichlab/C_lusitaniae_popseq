#!/bin/bash
module load gatk
module load tabix

if [ -f PopA.SNP.lungonly_curated.vcf ]; then
	bgzip PopA.SNP.lungonly_curated.vcf
fi
if [ -f C_lusitaniae.genotypes_all_and_out.selected.SNPONLY.vcf ]; then
	bgzip C_lusitaniae.genotypes_all_and_out.selected.SNPONLY.vcf
fi
tabix C_lusitaniae.genotypes_all_and_out.selected.SNPONLY.vcf.gz
tabix PopA.SNP.lungonly_curated.vcf.gz

gatk SelectVariants -R ../../genome/candida_lusitaniae_ATCC42720_w_CBS_6936_MT.fasta --output C_lusitaniae.genotypes_all_and_out.selected.SNPONLY.lungonly_curated_subset.vcf \
	-L PopA.SNP.lungonly_curated.vcf.gz -V C_lusitaniae.genotypes_all_and_out.selected.SNPONLY.vcf.gz

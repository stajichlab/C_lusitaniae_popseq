module load vcftools
root=C_lusitaniae.genotypes_A+ctl.selected.SNPONLY.lungonly
vcf-to-tab < $root.vcf  > $root.tab
sed -i 's/\.\/\./\.\//g' $root.tab 
# move this to common repository eventually
perl  scripts/vcftab_to_fasta.pl ./$root.tab

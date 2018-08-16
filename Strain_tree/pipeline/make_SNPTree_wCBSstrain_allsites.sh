#!/usr/bin/bash
#SBATCH --nodes 1 --ntasks 8 --mem 8G --time 12:00:00  --out logs/strain_tree.%A.log

module load IQ-TREE
module load vcftools
BOOTSTRAPS=100
TREEDIR=SNP_tree
mkdir -p $TREEDIR
for VCF in vcf/C_lusitaniae.genotypes_all_and_out.selected.SNPONLY.vcf.gz
do
    VCFTAB=$(dirname $VCF)/$(basename $VCF .vcf.gz)".tab"
    PREF=$(basename $VCFTAB .SNPONLY.tab)
    if [ ! -f $VCFTAB ]; then
        zcat $VCF | vcf-to-tab > $VCFTAB
    fi
    OUTFAS=$(basename $VCFTAB .tab)".fasaln"
        # select a random subset of SNPs
    if [ ! -f $TREEDIR/$OUTFAS ]; then
    	perl scripts/vcftab_to_fasta.pl -o $TREEDIR/$OUTFAS $VCFTAB
    fi
    iqtree -nt 8 -s $TREEDIR/$OUTFAS -b $BOOTSTRAPS -m GTR+ASC
done

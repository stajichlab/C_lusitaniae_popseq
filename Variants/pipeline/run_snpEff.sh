#!/usr/bin/bash

#SBATCH -J snpEff --out snpEff.log --mem 8G --nodes 1 --ntasks 1 --time 2:00:00 -p short

module load snpEff


snpEffConfig=/bigdata/stajichlab/shared/projects/Candida/Candida_lusitaniae/lib/snpEff/snpEff.config
GENOME=C_lusitaniae
INVCF=../C_lusitaniae.genotypes_all.selected.SNPONLY.lungonly.vcf
OUTVCF=C_lusitaniae.genotypes_all.selected.SNPONLY.lungonly.snpEff.vcf

java -Xmx16g -jar $SNPEFFJAR eff -v -c $snpEffConfig $GENOME $INVCF > $OUTVCF

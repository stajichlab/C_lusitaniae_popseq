#!/usr/bin/bash 

#SBATCH --mem=16G
snpEff=/opt/linux/centos/7.x/x86_64/pkgs/snpEff/4.1K/snpEff.jar
snpEffConfig=~/bigdata/snpEff/snpEff.config
#GENOME=/bigdata/stajichlab/shared/projects/Candida/HMAC/Clus_reseq/genome/Candida_lusitaniae_CBS_6936.MT.fasta
GENOME=C_lusitaniae
INVCF=../C_lusitaniae.genotypes_A+ctl.selected.SNPONLY.fixed.vcf
OUTVCF=C_lus_A+ctl.fixed.snpEff.vcf

java -Xmx16g -jar $snpEff eff -v -c $snpEffConfig $GENOME $INVCF > $OUTVCF

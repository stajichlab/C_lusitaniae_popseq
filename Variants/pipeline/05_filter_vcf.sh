#!/usr/bin/bash
#SBATCH --nodes 1
#SBATCH --ntasks 1
#SBATCH --mem-per-cpu 16G
#SBATCH --job-name=GATK.select_filter
#SBATCH --output=GATK.select_filter.%A.log

#Filters and selects for high quality variants, splitting them up into INDELONLY and SNPONLY files. Adjust filter parameters as needed

module load gatk/3.6
module unload java
module load java/8
OUTDIR=.
G=all #base name
BASE=/bigdata/stajichlab/shared/projects/Candida/Clus_reseq #base directory
GENOME=$BASE/genome/candida_lusitaniae_ATCC42720_w_CBS_6936_MT.fasta #reference genome path

INFILE=C_lusitaniae.genotypes_${G}.vcf #Product of step 4
INSNP=$OUTDIR/C_lusitaniae.genotypes_${G}.SNPS.vcf #SNPs vcf (unfiltered)
ININDEL=$OUTDIR/C_lusitaniae.genotypes_${G}.INDEL.vcf #INDELs vcf (unfiltered)
FILTEREDSNP=$OUTDIR/C_lusitaniae.genotypes_${G}.filtered.SNPONLY.vcf
FILTEREDINDEL=$OUTDIR/C_lusitaniae.genotypes_${G}.filtered.INDELONLY.vcf

SNPONLY=$OUTDIR/C_lusitaniae.genotypes_${G}.selected.SNPONLY.vcf
INDELONLY=$OUTDIR/C_lusitaniae.genotypes_${G}.selected.INDELONLY.vcf

if [ ! -f $INSNP ]; then

 java -Xmx3g -jar $GATK \
 -T SelectVariants \
 -R $GENOME \
 --variant $INFILE \
 -o $INSNP \
 -env \
 -ef \
 -restrictAllelesTo BIALLELIC \
 -selectType SNP
fi

if [ ! -f $ININDEL ]; then
 java -Xmx3g -jar $GATK \
 -T SelectVariants \
 -R $GENOME \
 --variant $INFILE \
 -o $ININDEL \
 -env \
 -ef \
 -selectType INDEL -selectType MIXED -selectType MNP
fi

if [ ! -f $FILTEREDSNP ]; then
 java -Xmx3g -jar $GATK \
 -T VariantFiltration -o $FILTEREDSNP \
 --variant $INSNP -R $GENOME \
 --clusterWindowSize 10  -filter "QD<2.0" -filterName QualByDepth \
 -filter "MQ<40.0" -filterName MapQual \
 -filter "QUAL<100" -filterName QScore \
 -filter "FS>60.0" -filterName FisherStrandBias \
 -filter "ReadPosRankSum<-8.0" -filterName ReadPosRank \
 --missingValuesInExpressionsShouldEvaluateAsFailing 

#-filter "HaplotypeScore > 13.0" -filterName HaplotypeScore
#-filter "MQ0>=10 && ((MQ0 / (1.0 * DP)) > 0.1)" -filterName MapQualRatio \
fi

if [ ! -f $FILTEREDINDEL ]; then
 java -Xmx3g -jar $GATK \
 -T VariantFiltration -o $FILTEREDINDEL \
 --variant $ININDEL -R $GENOME \
 --clusterWindowSize 10  -filter "QD<2.0" -filterName QualByDepth \
 -filter "MQRankSum < -12.5" -filterName MapQualityRankSum \
 -filter "SOR > 4.0" -filterName StrandOddsRatio \
 -filter "FS>200.0" -filterName FisherStrandBias \
 -filter "InbreedingCoeff<-0.8" -filterName InbreedCoef \
 -filter "ReadPosRankSum<-20.0" -filterName ReadPosRank 
fi

if [ ! -f $SNPONLY ]; then
 java -Xmx16g -jar $GATK \
   -R $GENOME \
   -T SelectVariants \
   --variant $FILTEREDSNP \
   -o $SNPONLY \
   -env \
   -ef \
   --excludeFiltered
fi

if [ ! -f $INDELONLY ]; then
 java -Xmx16g -jar $GATK \
   -R $GENOME \
   -T SelectVariants \
   --variant $FILTEREDINDEL \
   -o $INDELONLY \
   --excludeFiltered 
fi


#!/bin/bash
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH  --mem=32G
#SBATCH  --time=36:00:00
#SBATCH --job-name realign
#SBATCH --output=realign.%A_%a.out

module unload java
module load java/8
module load gatk/3.7
module load picard

MEM=32g
BASE=/bigdata/stajichlab/shared/projects/Candida/Clus_reseq
GENOMEIDX=$BASE/genome/candida_lusitaniae_ATCC42720_w_CBS_6936_MT.fasta
BAMDIR=bam
SAMPLEFILE=samples.info

KNOWNSITES=../Sept2016_version/A.lungonly.noun.vcf
b=$(basename $GENOMEIDX .fasta)
dir=$(dirname $GENOMEIDX)

if [ ! -f $dir/$b.dict ]; then
 java -jar $PICARD CreateSequenceDictionary R=$GENOMEIDX O=$dir/$b.dict SPECIES="Candida lusitaniae" TRUNCATE_NAMES_AT_WHITESPACE=true
fi

if [ ! $CPU ]; then
 CPU=1
fi

LINE=${SLURM_ARRAY_TASK_ID}

if [ ! $LINE ]; then
 LINE=$1
fi

if [ ! $LINE ]; then
 echo "Need a number via PBS_ARRAYID or cmdline"
 exit
fi

SAMPLE=`sed -n ${LINE}p $SAMPLEFILE | awk '{print $1}'`
hostname

echo "SAMPLE=$SAMPLE"

if [ ! -f $BAMDIR/$SAMPLE.DD.bam ]; then
   java -jar $PICARD MarkDuplicates I=$BAMDIR/$SAMPLE.RG.bam O=$BAMDIR/$SAMPLE.DD.bam \ 
         METRICS_FILE=$SAMPLE.dedup.metrics CREATE_INDEX=true VALIDATION_STRINGENCY=SILENT
fi

if [ ! -f $BAMDIR/$SAMPLE.DD.bai ]; then
 java -jar $PICARD BuildBamIndex I=$BAMDIR/$SAMPLE.DD.bam TMP_DIR=/scratch
fi

if [ ! -f $BAMDIR/$SAMPLE.intervals ]; then 
 java -Xmx$MEM -jar $GATK \
   -T RealignerTargetCreator \
   -R $GENOMEIDX \
   -I $BAMDIR/$SAMPLE.DD.bam \
   -o $BAMDIR/$SAMPLE.intervals
fi

if [ ! -f $BAMDIR/$SAMPLE.realign.bam ]; then
 java -Xmx$MEM -jar $GATK \
   -T IndelRealigner \
   -R $GENOMEIDX \
   -I $BAMDIR/$SAMPLE.DD.bam \
   -targetIntervals $BAMDIR/$SAMPLE.intervals \
   -o $BAMDIR/$SAMPLE.realign.bam
fi

if [ -f $KNOWNSITES]; then
 if [ ! -f $BAMDIR/$SAMPLE.recal.grp ]; then
  java -Xmx$MEM -jar $GATK \
   -T BaseRecalibrator \
   -R $GENOMEIDX \
   -I $BAMDIR/$SAMPLE.realign.bam \
   --knownSites $KNOWNSITES \
   -o $BAMDIR/$SAMPLE.recal.grp
 fi
 if [ ! -f $BAMDIR/$SAMPLE.recal.bam ]; then
  java -Xmx$MEM -jar $GATK \
   -T PrintReads \
   -R $GENOMEIDX \
   -I $BAMDIR/$SAMPLE.realign.bam \
   -BQSR $BAMDIR/$SAMPLE.recal.grp \
   -o $BAMDIR/$SAMPLE.recal.bam
 fi

fi

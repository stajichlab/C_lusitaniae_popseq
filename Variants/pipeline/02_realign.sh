#!/bin/bash
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH  --mem=32G
#SBATCH  --time=36:00:00
#SBATCH --job-name realign
#SBATCH --output=realign.%A_%a.out

# Base, GenomeIDX, bamdir, and sample file should be same as in last step. Optional Knownsites file can be supplied if baserecalibration is required. Use known sites or high scoring sites from an intitial run of this pipeline.
# Takes the alignment from step 1 (01_bwa.sh) for each sample in sample file defined by array job input and realigns against reference genome using GATK's indel realigner. Optional base recalibration if known sites is supplied.
module unload java
module load java/8
module load gatk/3.7
module load picard

MEM=32g
BASE=/bigdata/stajichlab/shared/projects/Candida/Clus_reseq
GENOMEIDX=$BASE/genome/candida_lusitaniae_ATCC42720_w_CBS_6936_MT.fasta
BAMDIR=bam
SAMPLEFILE=samples.info

KNOWNSITES=../Sept2016_version/A.lungonly.noun.vcf #Optional. Required to execute base recalibration
b=$(basename $GENOMEIDX .fasta)
dir=$(dirname $GENOMEIDX)

if [ ! -f $dir/$b.dict ]; then #checks for exisiting dictionary
 java -jar $PICARD CreateSequenceDictionary R=$GENOMEIDX O=$dir/$b.dict SPECIES="Candida lusitaniae" TRUNCATE_NAMES_AT_WHITESPACE=true #creates sequence dictionary
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

if [ ! -f $BAMDIR/$SAMPLE.DD.bam ]; then #checks for exisiting output
   java -jar $PICARD MarkDuplicates I=$BAMDIR/$SAMPLE.RG.bam O=$BAMDIR/$SAMPLE.DD.bam \ 
         METRICS_FILE=$SAMPLE.dedup.metrics CREATE_INDEX=true VALIDATION_STRINGENCY=SILENT # marks duplicates if not there
fi

if [ ! -f $BAMDIR/$SAMPLE.DD.bai ]; then #checks for exisiting output
 java -jar $PICARD BuildBamIndex I=$BAMDIR/$SAMPLE.DD.bam TMP_DIR=/scratch #builds bam index for mark duplicates file
fi

if [ ! -f $BAMDIR/$SAMPLE.intervals ]; then #checks for exisiting output
 java -Xmx$MEM -jar $GATK \
   -T RealignerTargetCreator \
   -R $GENOMEIDX \
   -I $BAMDIR/$SAMPLE.DD.bam \
   -o $BAMDIR/$SAMPLE.intervals # Creates target intervals for use in GATK Indel realigner. 
fi

if [ ! -f $BAMDIR/$SAMPLE.realign.bam ]; then #checks for exisiting output
 java -Xmx$MEM -jar $GATK \
   -T IndelRealigner \
   -R $GENOMEIDX \
   -I $BAMDIR/$SAMPLE.DD.bam \
   -targetIntervals $BAMDIR/$SAMPLE.intervals \
   -o $BAMDIR/$SAMPLE.realign.bam # Realigns reads around putative indels.
fi

if [ -f $KNOWNSITES]; then #checks for optional KNOWNSITES input
 if [ ! -f $BAMDIR/$SAMPLE.recal.grp ]; then #checks for exisiting output
  java -Xmx$MEM -jar $GATK \
   -T BaseRecalibrator \
   -R $GENOMEIDX \
   -I $BAMDIR/$SAMPLE.realign.bam \
   --knownSites $KNOWNSITES \
   -o $BAMDIR/$SAMPLE.recal.grp # Recalibrates reads in from the realigned reads based on a known sites vcf
 fi
 if [ ! -f $BAMDIR/$SAMPLE.recal.bam ]; then #checks for exisiting output
  java -Xmx$MEM -jar $GATK \
   -T PrintReads \
   -R $GENOMEIDX \
   -I $BAMDIR/$SAMPLE.realign.bam \
   -BQSR $BAMDIR/$SAMPLE.recal.grp \
   -o $BAMDIR/$SAMPLE.recal.bam #Outputs recalibrated reads to recalibrated bam file
 fi

fi

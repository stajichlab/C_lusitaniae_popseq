#!/usr/bin/bash 

#SBATCH --nodes 1 --ntasks 8 --mem 24G

#This script takes a reference genome and a tab delimited sample list of: 
# sample name\tsample_reads_1.fq\tsample_reads_2.fq
# 
# the file used in this analysis samples.info

# For each line defined by the number in an array job, this script will align set 
# of reads to a reference genome using bwa mem.
# After, it uses picard to add read groups and mark duplicates. 

module load bwa
module load picard
module load samtools
module unload java
module load java/8

CPU=1
SAMPLEFILE=samples.info

BWA=bwa
BASE=/bigdata/stajichlab/shared/projects/Candida/Clus_reseq
TEMPDIR=/scratch # this might need to switch
GENOMEIDX=$BASE/genome/candida_lusitaniae_ATCC42720_w_CBS_6936_MT.fasta
OUTPUT=bam

hostname
mkdir -p $OUTPUT

if [ $SLURM_CPUS_ON_NODE ]; then
 CPU=$SLURM_CPUS_ON_NODE
fi

LINE=${SLURM_ARRAY_TASK_ID}

if [ ! $LINE ]; then
 LINE=$1
fi

if [ ! $LINE ]; then 
 echo "Need a number via slurm --array or cmdline"
 exit
fi

ROW=`head -n $LINE $SAMPLEFILE | tail -n 1`

sed -n ${LINE}p $SAMPLEFILE | while read SAMPLE READ1 READ2
do
 INDIR=$(dirname $READ1)
 echo "SAMPLE=$SAMPLE"
 if [ ! -f $OUTPUT/$SAMPLE.DD.bam ]  || [ ! -s $OUTPUT/$SAMPLE.DD.bam ]; then
  if [ ! -f $OUTPUT/$SAMPLE.bwa.bam ]; then
   $BWA mem -M -t $CPU $GENOMEIDX $READ1 $READ2 | samtools view -T $GENOMEIDX -b -o $OUTPUT/$SAMPLE.bwa.bam -
  fi
  if [ ! -f $OUTPUT/$SAMPLE.RG.bam ]; then
   java -jar $PICARD AddOrReplaceReadGroups I=$OUTPUT/$SAMPLE.bwa.bam O=$OUTPUT/$SAMPLE.RG.bam RGLB=$SAMPLE RGID=$SAMPLE RGSM=$SAMPLE RGPL=Illumina RGPU=$SAMPLE RGCN=CHUV RGDS="$READ1 $READ2" CREATE_INDEX=true SO=coordinate TMP_DIR=$TEMPDIR
   # rm $OUTPUT/$SAMPLE.sam
   # touch $OUTPUT/$SAMPLE.sam
  fi

  java -jar $PICARD MarkDuplicates I=$OUTPUT/$SAMPLE.RG.bam O=$OUTPUT/$SAMPLE.DD.bam METRICS_FILE=$SAMPLE.dedup.metrics CREATE_INDEX=true VALIDATION_STRINGENCY=SILENT
 fi
done

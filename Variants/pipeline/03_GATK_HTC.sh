#!/bin/sh
#SBATCH --nodes=1
#SBATCH --ntasks=16
#SBATCH  --mem-per-cpu=8G
#SBATCH  --time=48:00:00
#SBATCH --job-name HTC
#SBATCH --output=HTC.%A_%a.out

#Takes realigned or recalibrated bam (defined in BAMSUFFIX) and runs Haplotype caller on the sample. Last Array job step. 
module unload java
module load java/8
module load gatk/3.7
module load picard

MEM=32g
BASE=/bigdata/stajichlab/shared/projects/Candida/Clus_reseq #base directory. Should be defined as in previous scripts
GENOMEIDX=$BASE/genome/candida_lusitaniae_ATCC42720_w_CBS_6936_MT.fasta #Genome path. Should be defined as in previous scripts
BAMDIR=bam #bam directory. Should be same as defined by last scripts
BAMSUFFIX=realign.bam #Edit for suffix of bam file, typically recal or realign.
SAMPLEFILE=samples.info
b=$(basename $GENOMEIDX .fasta)
dir=$(dirname $GENOMEIDX)

OUTDIR=Variants_A #Output directory for variants for each sample
if [ ! -f $dir/$b.dict ]; then
 java -jar $PICARD CreateSequenceDictionary R=$GENOMEIDX O=$dir/$b.dict \ 
   SPECIES="Candida lusitaniae" TRUNCATE_NAMES_AT_WHITESPACE=true
fi

CPU=$SLURM_CPUS_ON_NODE

if [ ! $CPU ]; then 
 CPU=1
fi

LINE=${SLURM_ARRAY_TASK_ID}

if [ ! $LINE ]; then
 LINE=$1
fi

if [ ! $LINE ]; then
 echo "Need a number via slurm --array or cmdline"
 exit
fi

SAMPLE=`sed -n ${LINE}p $SAMPLEFILE | awk '{print $1}'`
hostname
echo "SAMPLE=$SAMPLE"


b=$(basename $GENOME .fasta)

N=$BAMDIR/$SAMPLE.$BAMSUFFIX

if [ ! -f $OUTDIR/$SAMPLE.g.vcf ]; then #checks for exisiting output
java -Xmx${MEM} -jar $GATK \
  -T HaplotypeCaller \
  -ERC GVCF \
  -ploidy 1 \
  -I $N -R $GENOMEIDX \
  -o $OUTDIR/$SAMPLE.g.vcf -nct $CPU #Runs haplotype caller for sample defined by sample file and array job index.
fi
#  -forceActive -disableOptimizations \


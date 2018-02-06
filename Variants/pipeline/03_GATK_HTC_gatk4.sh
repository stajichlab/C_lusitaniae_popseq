#!/bin/sh
#SBATCH --nodes=1
#SBATCH --ntasks=16
#SBATCH  --mem-per-cpu=8G
#SBATCH  --time=48:00:00
#SBATCH --job-name HTC
#SBATCH --output=HTC.%A_%a.out

module load java/8
module load gatk/4.beta.5
module load picard

MEM=32g
BASE=/bigdata/stajichlab/shared/projects/Candida/Clus_reseq
GENOMEIDX=$BASE/genome/candida_lusitaniae_ATCC42720_w_CBS_6936_MT.fasta
BAMDIR=bam
SAMPLEFILE=samples.info
b=$(basename $GENOMEIDX .fasta)
dir=$(dirname $GENOMEIDX)

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
SAMPLE=$(sed -n ${LINE}p $SAMPLEFILE | awk '{print $1}')
hostname
echo "SAMPLE=$SAMPLE"

OUTDIR=Variants_A_forced
b=$(basename $GENOME .fasta)

N=$BAMDIR/$SAMPLE.realign.bam

if [ ! -f $OUTDIR/$SAMPLE.g.vcf ]; then
$GATKDIR/gatk-launch --javaOptions -Xmx${MEM} \
  HaplotypeCaller \
  -ERC GVCF \
  -ploidy 1 \
  --disableOptimizations \
  -I $N -R $GENOMEIDX \
  -O $OUTDIR/$SAMPLE.g.vcf #-nct $CPU
fi
#  -forceActive -disableOptimizations

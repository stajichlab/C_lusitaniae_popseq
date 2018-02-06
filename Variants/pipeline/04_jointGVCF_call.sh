#!/usr/bin/bash
#SBATCH --nodes 1
#SBATCH --ntasks 16
#SBATCH --mem=96G
#SBATCH --job-name=GATK.GVCFGeno
#SBATCH --output=GATK.GVCFGeno.%A.log
#SBATCH --time=12000
#
MEM=96g
module load picard
module unload java
module load gatk/3.6
module load java/8

BASE=/bigdata/stajichlab/shared/projects/Candida/Clus_reseq
GENOME=$BASE/genome/candida_lusitaniae_ATCC42720_w_CBS_6936_MT.fasta
INDIR=Variants_B
OUT=C_lusitaniae.genotypes_B.vcf
CPU=1

if [ $SLURM_CPUS_ON_NODE ]; then
 CPU=$SLURM_CPUS_ON_NODE
fi

N=$(ls $INDIR/*.g.vcf | grep -v ATCC | grep -v SputuP | sort | perl -p -e 's/\n/ /; s/(\S+)/-V $1/')

java -Xmx$MEM -jar $GATK \
    -T GenotypeGVCFs \
    -R $GENOME \
    $N \
    --max_alternate_alleles 3 \
    -o $OUT \
    -nt $CPU 

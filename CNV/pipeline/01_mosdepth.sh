#!/bin/bash
#SBATCH --nodes 1 --ntasks 24 --time 2:00:00 -p short --mem 64G --out mosdepth.parallel.log
#SBATCH -J modepth
CPU=$SLURM_CPUS_ON_NODE
if [ ! $CPU ]; then
 CPU=2
fi
mkdir -p coverage/mosdepth

# UCR specific thigs to get mosdepth in path
module unload python/2.7.5
export PATH="/bigdata/stajichlab/jstajich/miniconda3/bin:$PATH"

# output filenames are based on bamfile names but removing the 'aln' and realign part
# this uses the package parallel to run these in pipeline - could be rewritten to a loop if easier
# to see

WINDOW=5000
parallel --jobs $CPU mosdepth -T 1,10,50,100,200 -n --by $WINDOW -t 2 "{= s:aln\/:coverage/mosdepth/:; s:\.realign\.bam:.${WINDOW}bp: =}" {} ::: aln/*.bam

WINDOW=10000
parallel --jobs $CPU mosdepth -T 1,10,50,100,200 -n --by $WINDOW -t 2 "{= s:aln\/:coverage/mosdepth/:; s:\.realign\.bam:.${WINDOW}bp: =}" {} ::: aln/*.bam

WINDOW=20000
parallel --jobs $CPU mosdepth -T 1,10,50,100,200 -n --by $WINDOW -t 2 "{= s:aln\/:coverage/mosdepth/:; s:\.realign\.bam:.${WINDOW}bp: =}" {} ::: aln/*.bam

./scripts/mosdepth_prep_ggplot.sh


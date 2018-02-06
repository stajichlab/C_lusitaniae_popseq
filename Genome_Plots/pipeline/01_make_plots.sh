#!/bin/bash
#SBATCH --nodes 1 --ntasks 1 --out makeplots.log --mem 2G

module load bedtools
module switch python/3

python3 ./scripts/bed_to_bins.py --window 10000
python3 ./scripts/bed_to_bins.py --window 20000
python3 ./scripts/bed_to_bins.py --window 50000

gzip -f tracks/*.tab
Rscript Rscripts/plot_tracks.R

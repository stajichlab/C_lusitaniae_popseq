#!/bin/bash
#SBATCH --ntasks 2 --nodes 1 --out iqtree.%A.outlog --mem 2G

module load IQ-TREE
iqtree-omp -nt 2 -s snp_matrix.fasaln -m GTR+ASC  -b 100 

#!/bin/bash
#SBATCH --ntasks 1 --nodes 1 --out iqtree.%A.outlog --mem 2G --time 2:00:00 -p short
module load IQ-TREE

cd INDEL_tree
#iqtree-omp -nt 2 -s Table_S2_indel_matrix.fasaln -m JC2+ASC  -b 100 
#iqtree-omp -nt 2 -s Table_S2_indel_matrix_binaryonly.fasaln -m JC2+ASC -b 100 
#iqtree-omp -nt 2 -s Table_S2_indel_matrix.fasaln -st MORPH -b 100 
iqtree-omp -nt 1 -s Table_S2_indel_matrix_noREF.fasaln -st MORPH -b 100 

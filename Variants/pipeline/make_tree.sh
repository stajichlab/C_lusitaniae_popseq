#!/usr/bin/bash

#SBATCH --mem=32G --ntasks 1 --nodes 1
#SBATCH --time=36:00:00
#SBATCH -J maketree

#module load fasttree
#FastTreeMP -gtr -nt < C_lusitaniae.genotypes_A+ctl.selected.SNPONLY.lungonly.fas > A+ctl.tre

module loqd IQ-TREE

iqtree-omp -nt 2 -s C_lusitaniae.genotypes_A+ctl.selected.SNPONLY.lungonly.fas -b 100 -m GTR+ASC

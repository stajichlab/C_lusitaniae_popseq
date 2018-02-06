#!/bin/bash
module load samtools


samtools mpileup -a -l A.unknown.bed -o A10.mpileup.table ../SUMMER_2016/bam/A10*realign.bam
#samtools mpileup -a -b bamfiles.list -l A.unknown.bed -o A.mpileup.table

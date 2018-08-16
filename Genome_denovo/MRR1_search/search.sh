#!/usr/bin/bash
#SBATCH --nodes 1 --ntasks 8 --mem 8G -p short --out fasta_search.log
hostname
module load fasta
module load hmmer/3
DBDIR=../genomes

fasta() {
   out=$(basename $1 .fasta)".tab"
   if [ ! -f $out ]; then
    fasta36 -E 1e-200 -m 8c MRR1_Clus.fa $1 > $out
   fi
}
export -f fasta

parallel -j 8 fasta ::: $DBDIR/*.fasta
#parallel -j 8 esl-sfetch --index {} ::: $DBDIR/*.fasta

for file in *.tab
do
    b=$(basename $file .tab)
    cut -f2,7,8,9,10 $file | while read CTG QS QE HS HE
    do
        if [ $QS -gt $QE ]; then
            THS=$HS
            HS=$HE
            HE=$THS
        fi
        echo "esl-sfetch -c $HS..$HE $DBDIR/$b.fasta $CTG"
        NAME="$b.$CTG/$HS-$HE"
        esl-sfetch -c $HS..$HE -n $NAME $DBDIR/$b.fasta $CTG > $b.MRR1.fas
    done
done

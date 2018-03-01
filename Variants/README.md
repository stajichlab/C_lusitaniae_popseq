This is the processing pipeline to call small variants (SNPs and Indels) using GATK 3.7 best practices. 

_Main workflow:_

* 01_bwa.sh: This script takes a reference genome and a tab delimited sample list of: 
```
sample name	sample_reads_1.fq	sample_reads_2.fq
```

   For each line defined by the number in an array job, this script will align set of reads to a reference genome using bwa mem. After, it uses picard to add read groups and mark duplicates. Outputs to defined bam folder. 

* 02_realign.sh: Array job that takes the bam file produced in previous step and realigns reads around putative indels using GATK's IndelRealigner for each sample defined in sample file. Also, if a set of known or high quality sites is provided, will recalibrate alignments using GATK's Base Recalibration 

* 03_GATK_HTC.sh: Array job that takes the bam file, either realigned or recalibrated (file ending defined by N), produced in previous step and used GATK's HaplotypeCaller to call variants within each sample defined in samplefile and array job targets. Outputs to defined Variants folder.

* 04_jointGVCF_call.sh: Combines each variants (vcf) file in defined variants folder and joint calls and combines them into single vcf file with all samples. 

* 05_filter_vcf.sh: Filters and selects for variants passing defined cutoffs. Outputs filtered and selected files for SNPs and INDELS

_Post-processing:_

removedfixed.py/removefixed.nounknowns.py: Splits vcf file into two vcf files. Fixed contains all snps that are variants from the reference that don't differ among the samples. Lungonly contains the variants that differ among the lung isolates. 

run_snpEff.sh: Runs SNP Effect to identify placement and type of variant using annotation. 

snpEff_to_PnPs.py: computes ratio of nonsynonymous and synonymous variants for each gene

snpEff_to_table.py: converts vcf output to more human readable table.

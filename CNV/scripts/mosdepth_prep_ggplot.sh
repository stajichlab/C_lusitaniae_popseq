#!/bin/bash

for WINDOW in 1000 5000 10000 20000;
do
 # only run on the A population strains (A2., A3., etc) and omit ATCC and ctl1 and ctl2 strains
 # convert into ggplot useable input data
 for file in $(ls coverage/mosdepth/A*.${WINDOW}bp.regions.bed.gz | grep -v ATCC | grep -v ctl[12])
 do
# b=$(basename $file .${WINDOW}bp.regions.bed.gz | perl -p -e 's/(ctl([12]))\.AL1B/A$1.L1B-$2/; s/(\S+)\.(\S+)/$2/')
 b=$(basename $file .${WINDOW}bp.regions.bed.gz | perl -p -e 's/(\S+)\.(\S+)/$2/')
# GROUP=$(echo $b | perl -p -e '%lookup = ("L" => "LL", "U" => "UL","S"=>"Sp1","A"=>"ATCC42720"); s/^(\S)(\S+)/$lookup{$1}/')
 GROUP=$(echo $b | perl -p -e '%lookup = ("L" => "LL", "U" => "UL","S"=>"Sp1"); s/^(\S)(\S+)/$lookup{$1}/')
# echo "$GROUP $b"
 mean=$(zcat $file | awk '{total += $4} END { print total/NR}') 
 zcat $file | awk 'BEGIN{OFS="\t"} {print $1,$2,$3,$4/'$mean','\"$GROUP\"','\"$b\"'}' 
 done > coverage/mosdepth.${WINDOW}bp.gg.tab
done

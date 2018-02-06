#!/usr/bin/env python3

from os import listdir
import os.path 
import pybedtools
import csv, re
from pybedtools import BedTool
from itertools import chain

import argparse

parser = argparse.ArgumentParser(description="Data file for genome plots: binsize and windowsize")

parser.add_argument('-w','--window','--windowsize',help='Window size',
                    default=10000,type=int)
parser.add_argument('-o','--offset',type=int,
                    help='Window offset (default is non-overlapping windows)')
parser.add_argument('-b','--bamlist',default="bam_list.csv",
                    help="List of BAM files to process and their codes")
parser.add_argument('-d','--depths',
                    default="strain_depth/strain.depths_noGCcor.tab",
                    help="Average strain depth for normalization")
parser.add_argument('-g','--genomefile',
                    default="genome/Clus.genomefile",
                    help="Genome file for bedtools with sorted option")
args = parser.parse_args()

def flatten(lis):
    """Given a list, possibly nested to any level, return it flattened."""
    new_lis = []
    for item in lis:
        if type(item) == type([]):
            new_lis.extend(flatten(item))
        else:
            new_lis.append(item)
    return new_lis

windowsize = int(args.window)
offset     = windowsize
bamlist    = args.bamlist

straindepths = {}
with open(args.depths,"r") as fh:
    header = fh.readline()
    for line in fh:
        line=line.strip("\n")
        row = line.split("\t")
        straindepths[row[1]] = float(row[2])

if args.offset:
    offset = int(args.offset)

print("running with window=%d offset=%d"%(windowsize,offset))


binfile = "tracks/binfile.%d.bed"%(windowsize)
genomefai = "genome/Clus.fasta.fai"
tracks = "tracks/bamtracks.bin%d.tab"%(windowsize)

counter = 0

if not os.path.isfile(binfile):
    with open(binfile,"w") as binout:
        with open(genomefai,"r") as fh:
            reader = csv.reader(fh, delimiter="\t")
            bedwrite = csv.writer(binout, delimiter="\t",
                                  quoting=csv.QUOTE_MINIMAL)
            for row in reader:
                stop = 0
                for n in range(0,int(row[1]),offset):
                    end = n + windowsize
                    if end > int(row[1]):
                        end = int(row[1])
                        stop = 1

                    bedwrite.writerow([row[0],n, end, counter,
                                       ".","+"])
                    counter += 1
                    if stop:
                        break

bins = BedTool(binfile)
strains = {}
Results = {}

with open(bamlist,"r") as fh:
    reader = csv.reader(fh,delimiter=",")
    for row in reader:
        filename  = row[0]
        strain = row[1]
        group  = row[2]
        print(row)
        strains[strain] = group
        bam = BedTool(filename)
        cov = bins.coverage(bam,sorted=True,g=args.genomefile,bed=True)
        for interval in cov:
            window = interval[3]
            print("window is",window)
            if not window in Results:
                Results[window] = {"coords": [interval[0],interval[1],
                                              interval[2]]}
            m = Results[window]
            normdepth = "%.2f"%(int(interval[6]) / straindepths[strain])
            if not "coverage" in m:
                m["coverage"] = {strain: normdepth}
            else:
                m["coverage"][strain] = normdepth

with open(tracks,"w") as ggtrack:
    ggwrite = csv.writer(ggtrack,delimiter = "\t", 
                         quoting=csv.QUOTE_MINIMAL)

    ggwrite.writerow(flatten(['Window','Chr','Chr_start','Chr_end',
                              'Group','Strain','Density']))

    for window in Results:
        for strain in strains:
            row = [window, Results[window]["coords"],
                   strains[strain],strain,
                   Results[window]["coverage"][strain]]
            ggwrite.writerow(flatten(row))

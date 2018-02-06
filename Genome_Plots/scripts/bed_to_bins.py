#!/usr/bin/env python3

from os import listdir
import os.path 
import pybedtools
import csv, re, gzip
from pybedtools import BedTool
from itertools import chain

import argparse

parser = argparse.ArgumentParser(description="Data file for genome plots: binsize and windowsize")

parser.add_argument('-w','--window','--windowsize',help='Window size',default=20000,type=int)
parser.add_argument('-o','--offset',type=int,
                    help='Window offset (default is non-overlapping windows)')

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
if args.offset:
    offset = int(args.offset)

print("running with window=%d offset=%d"%(windowsize,offset))

indir    = "tracks/bed"
tracks = "tracks/alltracks.bin%d.tab"%(windowsize)
binfile = "tracks/binfile.%d.bed"%(windowsize)

genomelens = "genome/Clus.lens"
bedfiles = []

for f in listdir(indir):
    if (os.path.isfile( os.path.join(indir, f)) and 
        ( f.endswith(".bed") or f.endswith(".vcf.gz")
	or f.endswith(".gff"))):
        bedfiles.append(os.path.join(indir,f))

counter = 0

if not os.path.isfile(binfile):
    with open(binfile,"w") as binout:
        with open(genomelens,"r") as fh:
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

Results = {}
tracknames = []
for bed in sorted(bedfiles):
    (vol,fname) = os.path.split(bed)
    #    fname = "Density_"+re.sub('\.(bed|vcf)','',fname)
    fname = re.sub('\.(bed|vcf\.gz|gff)','',fname)
    print(fname)
    tracknames.append(fname)
    bedtrack = BedTool(bed)
    cov = bins.coverage(bedtrack)
    for interval in cov:
        window = interval[3]
#        print("window is",window)
        if not window in Results:
            Results[window] = {"coords": [interval[0],interval[1],interval[2]]}

        m = Results[window]
        if not "coverage" in m:
            m["coverage"] = {fname: interval[6]}
        else:
            m["coverage"][fname] = interval[6]


with open(tracks,"w") as ggtrack:
    ggwrite = csv.writer(ggtrack,delimiter = "\t", 
                         quoting=csv.QUOTE_MINIMAL)

    ggwrite.writerow(flatten(['Window','Chr','Chr_start','Chr_end',
                              'Track', 'Density']))

    for window in Results:
        for t in tracknames:
            row = [window, Results[window]["coords"],t,
                   Results[window]["coverage"][t]]
            ggwrite.writerow(flatten(row))

#    ggwrite.writerow(flatten(['Window','Chr','Chr_start','Chr_end',
#        tracknames]))
#    for window in Results:
#        row = [window, Results[window]["coords"]]
#        for t in tracknames:
#            row.append(Results[window]["coverage"][t])
#        ggwrite.writerow(flatten(row))

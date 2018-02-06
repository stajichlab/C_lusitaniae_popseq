library(ggplot2)
library(RColorBrewer)
#library(colorRamps)
#library(extrafont) # loaded Arial on mac with instructions here https://github.com/wch/extrafont
#Clus

bedwindows = read.table("coverage/mosdepth.10000bp.gg.tab.gz",header=F)
colnames(bedwindows) = c("Chr","Start","End","Depth","Group","Strain")
#bedwindows = subset(bedwindows,bedwindows$Chr != "MT_CBS_6936") # drop MT for this

bedwindows$CHR <- sub("Supercontig_1\\.","",bedwindows$Chr,perl=TRUE)
chrlist = c(1:8)
d=bedwindows[bedwindows$CHR %in% chrlist, ]

d <- d[order(d$CHR, d$Start), ]
d$index = rep.int(seq_along(unique(d$CHR)), times = tapply(d$Start,d$CHR,length)) 

d$pos=NA

nchr = length(unique(d$CHR))
lastbase=0
ticks = NULL
minor = vector(,8)
for (i in 1:8 ) {
    if (i==1) {
        d[d$index==i, ]$pos=d[d$index==i, ]$Start
    } else {
        ## chromosome position maybe not start at 1, eg. 9999. So gaps may be produced. 
        lastbase = lastbase + max(d[d$index==(i-1),"Start"])
	minor[i] = lastbase
        d[d$index == i,"Start"] =
             d[d$index == i,"Start"]-min(d[d$index==i,"Start"]) +1
        d[d$index == i,"End"] = lastbase
        d[d$index == i, "pos"] = d[d$index == i,"Start"] + lastbase
    }
}
ticks <-tapply(d$pos,d$index,quantile,probs=0.5)
ticks
minorB <- tapply(d$End,d$index,max,probs=0.5)
minorB
minor
d$Group = factor(d$Group, levels = c("LL", "UL", "Sp1"))
xmax = ceiling(max(d$pos) * 1.03)
xmin = floor(max(d$pos) * -0.03)

pdffile="plots/Genomewide_cov_by_10kb_win_mosdepth.pdf"
pdf(pdffile,width=7,height=2.5)
Title="Depth of sequence coverage"

#What about the color scheme I have for Ul/LL/Sp in Fig 1 which is Upper=bright blue, lower=red, sputum=black/dark gray


manualColors = c("dodgerblue2","red1","grey20")
p <- ggplot(d,
            aes(x=pos,y=Depth,color=Group)) +
	        geom_vline(mapping=NULL, xintercept=minorB,alpha=0.5,size=0.1,colour='grey15')	+
    geom_point(alpha=0.8,size=0.4,shape=16) +
    scale_color_manual(values = manualColors) +
    labs(title=Title,xlab="Position",y="Normalized Read Depth") +
    scale_x_continuous(name="Chromosome", expand = c(0, 0),
                       breaks = ticks,                      
                       labels=(unique(d$CHR))) +
    scale_y_continuous(name="Normalized Read Depth", expand = c(0, 0),
                       limits = c(0,3)) + theme_classic() + 
    guides(fill = guide_legend(keywidth = 3, keyheight = 1)) 

p


bedwindows = read.table("coverage/mosdepth.5000bp.gg.tab.gz",header=F)
colnames(bedwindows) = c("Chr","Start","End","Depth","Group","Strain")
#bedwindows = subset(bedwindows,bedwindows$Chr != "MT_CBS_6936") # drop MT for this

bedwindows$CHR <- sub("Supercontig_1\\.","",bedwindows$Chr,perl=TRUE)
chrlist = c(1:8)
d=bedwindows[bedwindows$CHR %in% chrlist, ]

d <- d[order(d$CHR, d$Start), ]
d$index = rep.int(seq_along(unique(d$CHR)), times = tapply(d$Start,d$CHR,length)) 

d$pos=NA

nchr = length(unique(d$CHR))
lastbase=0
ticks = NULL
minor = vector(,8)
for (i in 1:8 ) {
    if (i==1) {
        d[d$index==i, ]$pos=d[d$index==i, ]$Start
    } else {
        ## chromosome position maybe not start at 1, eg. 9999. So gaps may be produced. 
        lastbase = lastbase + max(d[d$index==(i-1),"Start"])
	minor[i] = lastbase
        d[d$index == i,"Start"] =
             d[d$index == i,"Start"]-min(d[d$index==i,"Start"]) +1
        d[d$index == i,"End"] = lastbase
        d[d$index == i, "pos"] = d[d$index == i,"Start"] + lastbase
    }
}
ticks <-tapply(d$pos,d$index,quantile,probs=0.5)
ticks
minorB <- tapply(d$End,d$index,max,probs=0.5)
minorB
minor
d$Group = factor(d$Group, levels = c("LL", "UL", "Sp1"))
xmax = ceiling(max(d$pos) * 1.03)
xmin = floor(max(d$pos) * -0.03)



# # test plot one chrom
# dprime = d[d$CHR %in% 6:6, ]
# dprime$bp = dprime$Start
# Title=sprintf("Chr%s depth of coverage","6")
# p <- ggplot(dprime,
#             aes(x=bp,y=Depth,color=Group))  +
#     geom_point(alpha=0.9,size=0.5,shape=16) +
#     scale_color_manual(values = manualColors) +
#     labs(title=Title,xlab="Position",y="Normalized Read Depth") +
#     scale_x_continuous(name="Chromosome bp", expand = c(0, 0)) +
#     scale_y_continuous(name="Normalized Read Depth", expand = c(0, 0),
#                        limits = c(0,3)) + theme_classic() +
#     guides(fill = guide_legend(keywidth = 3, keyheight = 1))
# p


for (strain in unique(d$Strain) ) { 
 l = subset(d,d$Strain == strain)
 Title=sprintf("Chr coverage plot for %s",strain)
 p <- ggplot(l,
            aes(x=pos,y=Depth,color=CHR))  + 
    scale_colour_brewer(palette = "Set2") +
    geom_point(alpha=0.9,size=1,shape=16) +
    labs(title=Title,xlab="Position",y="Normalized Read Depth") +
    scale_x_continuous(name="Chromosome", expand = c(0, 0),
                       breaks=ticks,
                       labels=(unique(d$CHR))) +
    scale_y_continuous(name="Normalized Read Depth", expand = c(0, 0),
                       limits = c(0,3)) + theme_classic() +
    guides(fill = guide_legend(keywidth = 3, keyheight = 1))
 ggsave(sprintf("plots/StrainPlot_5kb.%s.pdf",strain),p,width=7,height=2.5)
}

for (n in chrlist ) {
    Title=sprintf("Chr%s depth of coverage",n)
 print(Title)
 l <- subset(d,d$CHR==n)
 l$bp <- l$Start
p<-ggplot(l,
           aes(x=bp,y=Depth,color=Group)) +
        geom_point(alpha=0.7,size=0.75,shape=16) +
	    scale_color_manual(values = manualColors) +
    labs(title=Title,xlab="Position",y="Normalized Read Depth") +
    scale_x_continuous(expand = c(0, 0), name="Position") +
    scale_y_continuous(name="Normalized Read Depth", expand = c(0, 0),
                       limits = c(0,3)) + theme_classic() +
    guides(fill = guide_legend(keywidth = 3, keyheight = 1))
 ggsave(sprintf("plots/ChrPlot_5kb.Chr%s.pdf",n),p,width=7,height=2.5)
 p
}



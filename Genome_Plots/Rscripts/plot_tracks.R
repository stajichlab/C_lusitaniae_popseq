# -*-R-*-

library(ggplot2)
library(RColorBrewer)
library(colorRamps)

for (WINDOWSIZE in c(10000,20000,50000) ) {
    infile = sprintf("tracks/alltracks.bin%d.tab.gz",WINDOWSIZE)
    df <- read.table(infile,header=T,sep="\t")

    df$Chr <- sub("Supercontig_1\\.","",df$Chr,perl=TRUE)
    chrlist = c(1:8)
    d=df[df$Chr %in% chrlist, ]
    d <- d[order(d$Chr, d$Chr_start), ]
    d$index = rep.int(seq_along(unique(d$Chr)), times = tapply(d$Chr_start,d$Chr,length)) 
    
    d$pos=NA
    
    nchr = length(unique(d$Chr))
    lastbase=0
    ticks = NULL
    minor = vector(,8)
    for (i in 1:8 ) {
        if (i==1) {
            d[d$index==i, ]$pos=d[d$index==i, ]$Chr_start
        } else {
            ## chromosome position maybe not start at 1, eg. 9999. So gaps may be produced. 
            lastbase = lastbase + max(d[d$index==(i-1),"Chr_start"])
            minor[i] = lastbase
            d[d$index == i,"Chr_start"] =
                d[d$index == i,"Chr_start"]-min(d[d$index==i,"Chr_start"]) +1
            d[d$index == i,"End"] = lastbase
            d[d$index == i, "pos"] = d[d$index == i,"Chr_start"] + lastbase
        }
    }

    ticks <-tapply(d$pos,d$index,quantile,probs=0.5)
    print(ticks)

    pdffile= sprintf('plots/Clus_density_%dkb_all.pdf',WINDOWSIZE/1000)
    Title = "Feature density"
    d$Chromosome <- df$Chr
    d$Track.order = factor(df$Track,levels = c("Genes",                                                                        "PopA.SNP.lungonly_curated_final",
                                               "PopA.INDEL.lungonly_curated_final"
                                                ),
                            labels=c("Genes",
                                     "SNPs",
                                     "INDELs"
                                     ))
    
    p <- ggplot(d, aes(pos, Density)) + geom_point(aes(color=Chromosome),
                                              alpha=0.5,size=0.5) +
    facet_wrap( ~Track.order, ncol=1) +
        labs(title=Title,xlab="Chromosome",scales="free_y") +
        scale_x_continuous(name="Chromosome", expand = c(0, 0),
                           breaks=ticks,
                           labels=(unique(d$Chr))) +
        scale_y_continuous(expand=c(0,0))+
        scale_colour_brewer(palette = "Dark2") + theme_minimal() +
        theme(legend.position="none", panel.border = element_blank(),panel.grid.minor = element_blank(),
              panel.grid.major = element_blank())
    ggsave(pdffile,p,width=7,height=3)

    ## pdffile= sprintf('plots/Clus_density_%dkb.pdf',WINDOWSIZE/1000)
    ## Title = "Feature density"
    ## df$Chromosome <- df$Chr
    ## df$Track.order = factor(df$Track,levels = c("Genes",
    ##                                             "PopA.SNP.lungonly_curated_final",
    ##                                             "PopA.INDEL.lungonly_curated_final"
    ##                                             ), 
    ##                         labels=c("Genes",
    ##                                  "SNPs",
    ##                                  "INDELs"
    ##                                  ))
    ## df <- df[complete.cases(df),]
    
    ## p<- ggplot(df, aes(Window, Density)) + geom_point(aes(color=Chromosome),
    ##                                               alpha=1/2,size=0.5) +
    ##     facet_wrap( ~Track.order, ncol=1,scales="free_y") +
    ##     scale_x_continuous(name="Chromosome", expand = c(0, 0),
    ##                        breaks=ticks,
    ##                        labels=(unique(d$Chr))) +
    ##     labs(title=Title,xlab="Chromosome") +
    ##     scale_colour_brewer(palette = "Dark2") + theme_minimal() + theme(legend.position="none")
    ## ggsave(pdffile,p,width=7,height=6)
}    



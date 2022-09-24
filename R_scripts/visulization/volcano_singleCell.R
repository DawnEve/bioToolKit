#1.define main function
VolcanoPlot=function(dif, log2FC=log2(1.5), padj=0.05, 
                 label.symbols=NULL, label.max=30,
                 cols=c("#497aa2", "#ae3137"), title=""){
  if( all( !c("log2FoldChange", "padj", "symbol") %in% colnames(dif) )){
    stop("Colnames must include: log2FoldChange, padj, symbol")
  }
  rownames(dif)=dif$symbol
  
  # (1) define up and down
  dif$threshold="ns";
  dif[which(dif$log2FoldChange > log2FC & dif$padj < padj),]$threshold="up";
  dif[which(dif$log2FoldChange < (-log2FC) & dif$padj < padj),]$threshold="down";
  dif$threshold=factor(dif$threshold, levels=c('down','ns','up'))
  #head(dif)
  #
  tb2=table(dif$threshold); print(tb2)
  library(ggplot2)
  # (2) plot
  g1 = ggplot(data=dif, aes(x=log2FoldChange, y=-log10(padj), color=threshold)) +
    geom_point(alpha=0.8, size=0.8) +
    geom_vline(xintercept = c(-log2FC, log2FC), linetype=2, color="grey")+
    geom_hline(yintercept = -log10(padj), linetype=2, color="grey")+
    labs(title= ifelse(""==title, "", paste("DEG:", title)))+
    xlab(bquote(Log[2]*FoldChange))+
    ylab(bquote(-Log[10]*italic(P.adj)) )+
    theme_classic(base_size = 14) +
    theme(legend.box = "horizontal",
          legend.position="top",
          legend.spacing.x = unit(0, 'pt'),
          legend.text = element_text( margin = margin(r = 20) ),
          legend.margin=margin(b= -10, unit = "pt"),
          plot.title = element_text(hjust = 0.5, size=10)
          ) +
    scale_color_manual('',labels=c(paste0("down(",tb2[[1]],')'),'ns',
                                   paste0("up(",tb2[[3]],')' )),
                       values=c(cols[1], "grey", cols[2]) )+
    guides(color=guide_legend(override.aes = list(size=3, alpha=1))); g1;
  # (3)label genes
  if(is.null(label.symbols)){
    dif.sig=dif[which(dif$threshold != "ns" ), ]
    len=nrow(dif.sig)
    if(len<label.max){
      label.symbols=rownames(dif.sig)
    }else{
      dif.sig=dif.sig[order(dif.sig$log2FoldChange), ]
      dif.sig= rbind(dif.sig[1:(label.max/2),], dif.sig[(len-label.max/2):len,])
      label.symbols=rownames(dif.sig)
    }
  }
  dd_text = dif[label.symbols, ]
  print((dd_text))
  # add text
  library(ggrepel)
  g1 + geom_text_repel(data=dd_text,
                       aes(x=log2FoldChange, y=-log10(padj), label=row.names(dd_text)),
                         #size=2.5, 
                         colour="black",alpha=1)
}

# 2.get DEG, using Seurat 4

deg_all=FindMarkers(scObj, ident.1 = "DSS", ident.2 = "WT", group.by="origin", min.pct = 0.001)
dim(deg_all) #2137    5
head(deg_all)


# 3.get data.frame: dif
dif=data.frame(
  symbol=rownames(deg_all),
  log2FoldChange=deg_all$avg_log2FC,
  padj=deg_all$p_val_adj
)

# 4.draw
# method1: 可以指定要标记的DEG数量，选出FC最大和最小的基因标记
VolcanoPlot(dif, padj=0.05, title="DSS vs WT", label.max = 50)
# 自定义颜色
VolcanoPlot(dif, padj=0.05, title="DSS vs WT", label.max = 50, cols=c("blue", "red"))


# method2: 也可以指定要标记的基因名字
VolcanoPlot(dif, padj=1e-10, title="DSS vs WT -2", 
            label.symbols=dif[ ((abs(dif$log2FoldChange) > 2) & (dif$padj < 1e-50) ) | 
                                      abs(dif$log2FoldChange) > 4,]$symbol )
# multi-volcano plot for scRNA-seq
# 2 version
# a) for step-wise use;
# b) an user-frindly function (Good!)

# cell 2019 fig2D,H: https://pubmed.ncbi.nlm.nih.gov/31835037/
# paper: A Spatiotemporal Organ-Wide Gene Expression and Cell Atlas of the Developing Human Heart (DOI: 10.1016/j.cell.2019.11.025)

# https://mp.weixin.qq.com/s/KQ9z5I0x-tIhwQqN6jIFWQ
# https://mp.weixin.qq.com/s?__biz=MzA3OTA4MjcxNw==&mid=2247484465&idx=1&sn=94d81c60dfe774d33ce66a0ebff6d733





###############
# input dataset
###############
DimPlot(pbmc, label = T)
pbmc.markers <- FindAllMarkers(pbmc, min.pct = 0.25, logfc.threshold = 0.25)
pbmc.markers %>% group_by(cluster) %>% top_n(n = 2, wt = abs(avg_log2FC) )

head(pbmc.markers )
# > head(pbmc.markers )
#p_val avg_log2FC pct.1 pct.2     p_val_adj     cluster  gene
#RPS12 1.273332e-143  0.7298951 1.000 0.991 1.746248e-139 Naive CD4 T RPS12
#RPS6  6.817653e-143  0.6870694 1.000 0.995 9.349729e-139 Naive CD4 T  RPS6


###############
# begin to plot
###############
# get data
DEG = pbmc.markers

# p.adj<0.01? In origin paper
#DEG$label <- ifelse(DEG$p_val_adj<0.01, "adjusted P-value<0.01", "adjusted P-value>=0.01")
DEG$label <- ifelse(DEG$p_val_adj<0.0001,
                    ifelse(DEG$avg_log2FC>0, "Up", "Down"),
                    "None")
DEG$label = factor(DEG$label, levels = c("Up", "None", "Down"))
table(DEG$label)
#Down None   Up
# 931 2048 1680
#adjusted P-value<0.01 adjusted P-value>=0.01
#                 3144                   1515


if(0){
  cut_off_pvalue = 0.0001
  cut_off_logFC = 2
  # only used for single volcano plot. not used later
  DEG$Sig = ifelse(DEG$p_val_adj< cut_off_pvalue & abs(DEG$avg_log2FC) >= cut_off_logFC,
                   ifelse(DEG$avg_log2FC > cut_off_logFC ,'Up','Down'),
                   'None')
  table(DEG$Sig)
  #Down None   Up
  #115 4330  214

  head(DEG)
  #              p_val avg_log2FC pct.1 pct.2     p_val_adj     cluster  gene  Sig
  #RPS12 1.273332e-143  0.7298951 1.000 0.991 1.746248e-139 Naive CD4 T RPS12 None


  # only one volcano
  ggplot(DEG, aes(x = avg_log2FC, y = -log10(p_val_adj), colour=Sig)) +
    geom_point(alpha=0.4, size=1.5) +
    scale_color_manual(values=c("#546de5", "#d2dae2","#ff4757"))+
    geom_vline(xintercept=c(-1,1),lty=4,col="black",lwd=0.8) +
    labs(x="log2(Fold Change)",y="-log10 (P-value)")+
    theme_bw()+
    ggtitle("Volcano Plot")+
    theme(
      plot.title = element_text(hjust = 0.5),
      legend.position="right",legend.title = element_blank()
    )
}

# expand cluster on x axis;
# Among p.adj <0.05 genes, select logFC top10 & bottom10, annotate gene symbol
DEG.text = NULL;
for(cluster.name in unique(DEG$cluster) ){
  print(cluster.name)
  tmp=DEG %>% filter(cluster==cluster.name & p_val_adj <0.05) %>% top_n(n = 10, wt = avg_log2FC)
  DEG.text=rbind(DEG.text, tmp);
  tmp=DEG %>% filter(cluster==cluster.name & p_val_adj <0.05 ) %>% top_n(n = 10, wt = -avg_log2FC)
  DEG.text=rbind(DEG.text, tmp);
}
dim(DEG.text)
table(DEG.text$label, DEG.text$cluster)
head(DEG.text)



# plot
p1 =  ggplot() +
  geom_jitter(data = DEG, aes(cluster, y=avg_log2FC, color=label), size = 0.85,width =0.4)+
  geom_jitter(data = DEG.text, aes(x = cluster, y = avg_log2FC, color = label), size = 1,width =0.4)
p1


# bar background of each cluster
len = nlevels(DEG$cluster)

dfbarUp  <- data.frame(x=c(1:len),
                       y=DEG %>% group_by(cluster) %>% top_n(1, wt=avg_log2FC) %>% pull(avg_log2FC))
dfbarDown<- data.frame(x=c(1:len),
                       y=DEG %>% group_by(cluster) %>% top_n(1, wt=-avg_log2FC) %>% pull(avg_log2FC))
p1bar <- ggplot()+
  geom_col(data = dfbarUp,  mapping = aes(x = x,y = y),fill = "#dcdcdc",alpha = 0.6)+
  geom_col(data = dfbarDown,mapping = aes(x = x,y = y),fill = "#dcdcdc",alpha = 0.6)
p1bar


###############
# Error: when putting background bar at back? ----
###############
p1bar + geom_jitter(data = DEG, aes(cluster, y=avg_log2FC, color=label), size = 0.85,width =0.4)
# Error: Discrete value supplied to continuous scale

# store the original value, and change it to numeric
#DEG$cluster2=DEG$cluster
#DEG$cluster=as.numeric(DEG$cluster) # solve the error, but revoke another: figure legend





# Another way: put background bar at front of dots.
p2=ggplot() +
  #2. dot plot
  geom_jitter(data = DEG, aes(cluster, y=avg_log2FC, color=label), size = 0.55,width =0.4, show.legend = F)+
  geom_jitter(data = DEG.text, aes(x = cluster, y = avg_log2FC, color = label), size = 1,width =0.4, show.legend = F)+
  #theme_classic()
  #1. bar background
  geom_col(data = dfbarUp,  mapping = aes(x = x, y = y),fill = "#dcdcdc",alpha = 0.2)+
  geom_col(data = dfbarDown,mapping = aes(x = x, y = y),fill = "#dcdcdc",alpha = 0.2)
p2


# add color box on x axis
dfcol <- data.frame(x=c(1:len), y=0, label=c(1:len), cluster=levels(DEG$cluster) )
dfcol
mycol <- scales::hue_pal()(len)  #c("#E64B357F","#00A0877F","#F39B7F7F","#8491B47F","#DC00007F")
p3 <- p2 +
  geom_tile(data = dfcol, aes(x=x, y=y, fill=cluster), height=0.5, color = NA,
            #fill = mycol,
            alpha = 1, show.legend = F)
p3


# annotate gene symbol on plot
library(ggrepel)
p4 <- p3+geom_text_repel(data=DEG.text,
                         aes(x=cluster,y=avg_log2FC,label=gene),
                         force = 1.2,
                         size = 2.5, #font size of gene symbols
                         arrow = arrow(length = unit(0.008, "npc"), type = "open", ends = "last"))+
  scale_color_manual(name=NULL, breaks = c("Up", "None", "Down"),values = c("#c0252d", "grey", "navy")) # dot color
p4

# add text/number in box on x axis
p5 <- p4+
  labs(x="Cluster",y="average log2FC")+
  geom_text(data=dfcol, aes(x=x, y=y, label=label),
            size = 6, #cluster font size
            color ="white")+
  guides( color = guide_legend(override.aes = list(size=5))) #legend circle size
p5

# themes
p6 <- p5+theme_minimal()+theme(
  axis.title = element_text(size = 13, #face = "bold",
                            color = "black"),
  axis.line.y = element_line(color = "black", size = 1.2),
  axis.line.x = element_blank(),

  #axis.text.x = element_blank(), #no x axis text
  axis.text.x = element_text(angle=60, hjust=1,size=12,color="black"), #rotate x axis text

  panel.grid = element_blank(),
  #legend.position = "top",
  legend.direction = "vertical",
  legend.justification = c(1,0),
  legend.text = element_text(size = 15)
); 
p6

# save: 004_3volcano_singleCell_multi
ggsave(filename = "01/004_3volcano_singleCell_multi.pdf", width=7.1, height=8.2, useDingbats=F)







###################
# Part II: circled number followed by text
###################
# circle filled background followed by text ----
# len = nlevels(DEG$cluster)
# dfcol <- data.frame(x=c(1:len), y=0, label=c(1:len), cluster=levels(DEG$cluster) )
dfcol
#  x y label      cluster
#1 1 0     1  Naive CD4 T
#2 2 0     2   CD14+ Mono
#3 3 0     3 Memory CD4 T
#4 4 0     4            B
#5 5 0     5        CD8 T
#6 6 0     6 FCGR3A+ Mono
#7 7 0     7           NK
#8 8 0     8           DC
#9 9 0     9     Platelet

# use 2 col: label and cluster
pb2=ggplot( dfcol, aes(x=0, y=-label, color=cluster) )+
  geom_point(size=8, show.legend = F)+
  xlim(-0.1, 0.5) +
  geom_text(data=dfcol, aes(x=0, y=-label, label=label), color="white", size=6)+
  geom_label(data=dfcol, aes(x=0.03, y=-label, label=cluster), color="black", size=6,
             hjust="left", label.size=0)+
  theme_nothing()
pb2
ggsave(filename = "01/004_3volcano_singleCell_circleAnnotation.pdf",
       plot=pb2,
       width=2.8, height=2.3, useDingbats=F)

# with DimPot
pb1=DimPlot(pbmc, label=T)+NoLegend();
pb1
library(patchwork)
pb1 / pb2












# > head(DEG)
#              p_val avg_log2FC pct.1 pct.2     p_val_adj     cluster  gene label
#RPS12 1.273332e-143  0.7298951 1.000 0.991 1.746248e-139 Naive CD4 T RPS12    Up
#RPS6  6.817653e-143  0.6870694 1.000 0.995 9.349729e-139 Naive CD4 T  RPS6    Up
#


color.pals = c("#DC143C","#0000FF","#20B2AA","#FFA500","#9370DB","#98FB98","#F08080","#1E90FF","#7CFC00","#FFFF00",
               "#808000","#FF00FF","#FA8072","#7B68EE","#9400D3","#800080","#A0522D","#D2B48C","#D2691E","#87CEEB","#40E0D0","#5F9EA0",
               "#FF1493","#0000CD","#008B8B","#FFE4B5","#8A2BE2","#228B22","#E9967A","#4682B4","#32CD32","#F0E68C","#FFFFE0","#EE82EE",
               "#FF6347","#6A5ACD","#9932CC","#8B008B","#8B4513","#DEB887")

#
#' multi volcano plot for scRNA-seq
#' @version 0.2 change legend order
#' @version 0.3 add max_overlaps for annotation
#'
#' @param dat Seurat FindAllMarkers returns, must set only.pos = F;
#' @param color.arr color list, default same as Seurat
#' @param onlyAnnotateUp only annote gene symbols for up genes
#' @param log2Foldchang threshold for annotation
#' @param adjp  threshold for annotation
#' @param top_marker gene number for annotation
#' @param max_overlaps annotation label overlapping
#'
#' @return ggplot2 obj
#' @export
#'
#' @examples
multiVolcanoPlot = function(dat, color.arr=NULL, onlyAnnotateUp=T,
                            log2Foldchang=0.58, adjp=0.05, top_marker=5, 
                            max_overlaps=10, width=0.9){
  library(dplyr)
  library(ggrepel)
  # set default color list
  if(is.null(color.arr)){
    len = length(unique(dat$cluster))
    color.arr=scales::hue_pal()(len)
  }
  
  dat.plot <- dat %>% mutate(
    "significance"=case_when(p_val_adj < adjp & avg_log2FC >= log2Foldchang  ~ 'Up',
                             p_val_adj < adjp & avg_log2FC <= -log2Foldchang  ~ 'Down',
                             TRUE ~ 'None'))
  tbl = table(dat.plot$significance)
  print( tbl )
  background.dat <- data.frame(
    dat.plot %>% group_by(cluster) %>% filter(avg_log2FC>0) %>%
      summarise("y.localup"=max(avg_log2FC)),
    dat.plot %>% group_by(cluster) %>% filter(avg_log2FC<=0) %>%
      summarise("y.localdown"=min(avg_log2FC)),
    x.local=seq(1:length(unique(dat.plot$cluster)))
  ) %>% select(-cluster.1)
  #names(background.dat)
  #head(background.dat)
  #dim(background.dat)
  
  #
  x.number <- background.dat %>% select(cluster, x.local)
  dat.plot <- dat.plot%>% left_join(x.number,by = "cluster")
  #names(dat.plot)
  #head(dat.plot)
  
  #selecting top-up and top-down proteins
  dat.marked.up <- dat.plot %>% filter(significance=="Up") %>%
    group_by(cluster) %>% arrange(-avg_log2FC) %>%
    top_n(top_marker,abs(avg_log2FC))
  dat.marked.down <- dat.plot %>% filter(significance=="Down") %>%
    group_by(cluster) %>% arrange(avg_log2FC) %>%
    top_n(top_marker,abs(avg_log2FC))
  dat.marked <- dat.marked.up %>% bind_rows(dat.marked.down)
  #referring group information data
  dat.infor <- background.dat %>%
    mutate("y.infor"=rep(0,length(cluster)))
  #names(dat.infor)
  #dim(dat.infor)
  #head(dat.infor)
  
  ##plotting:
  #setting color by loading local color schemes
  vol.plot <- ggplot()+
    # background
    geom_col(background.dat,mapping=aes(x.local, y.localup),
             fill="grey80", alpha=0.2, width=0.9, just = 0.5)+
    geom_col(background.dat,mapping=aes(x.local,y.localdown),
             fill="grey80", alpha=0.2, width=0.9, just = 0.5)+
    # point plot
    geom_jitter(dat.plot, mapping=aes(x.local, avg_log2FC, #x= should be number, Not string or factor
                                      color=significance),
                size=0.8, width = 0.4, alpha= 1)+
    scale_color_manual(name="significance", 
                       breaks = c('Up', 'None', 'Down'),
                       values = c("#d56e5e","#cccccc", "#5390b5")) + #set color for: Down None   Up
    geom_tile(dat.infor, mapping=aes(x.local, y.infor), #x axis color box
              height = log2Foldchang*1.3,
              fill = color.arr[1:length(unique(dat.plot$cluster))],
              alpha = 0.5,
              width=width) +
    labs(x=NULL,y="log2 Fold change")+
    geom_text(dat.infor, mapping=aes(x.local,y.infor,label=cluster))+
    # Down is not recommend, not meaningful, hard to explain; so prefer dat.marked.up to dat.marked
    ggrepel::geom_label_repel(data=if(onlyAnnotateUp) dat.marked.up else dat.marked, #gene symbol, of up group default
                              mapping=aes(x=x.local, y=avg_log2FC, label=gene),
                              force = 2, #size=2,
                              max.overlaps = max_overlaps,
                              label.size = 0, #no border
                              fill="#00000000", #box fill color
                              seed = 233,
                              min.segment.length = 0,
                              force_pull = 2,
                              box.padding = 0.1,
                              segment.linetype = 3,
                              #segment.color = 'black',
                              #segment.alpha = 0.5,
                              #direction = "x", #line direction
                              hjust = 0.5)+
    annotate("text", x=1.5, y=max(background.dat$y.localup)+1,
             label=paste0("|log2FC|>=", log2Foldchang, " & FDR<", adjp))+
    theme_classic(base_size = 12)+
    
    theme(
      axis.title = element_text(size = 13, color = "black"),
      axis.text = element_text(size = 15, color = "black"),
      axis.line.y = element_line(color = "black", size = 0.8),
      #
      axis.line.x = element_blank(), #no x axis line
      axis.ticks.x = element_blank(), #no x axis ticks
      axis.title.x = element_blank(), #
      axis.text.x = element_blank(),
      #
      legend.spacing.x = unit(0.1,'cm'),
      legend.key.width = unit(0.5,'cm'),
      legend.key.height = unit(0.5,'cm'),
      legend.background = element_blank(),
      legend.box = "horizontal",
      legend.position = c(0.13, 0.77),legend.justification = c(1,0)
    )+
    guides( #color = guide_legend( override.aes = list(size=5) ), #legend circle size
      color=guide_legend( override.aes = list(size=5), title="Change")
    )
  #guides(fill=guide_legend(title="Change"))+ #change legend title
  vol.plot
}
#multiVolcanoPlot(DEG, color.pals)
multiVolcanoPlot(scObj.markers.time)
multiVolcanoPlot(scObj.markers.time, onlyAnnotateUp = F)


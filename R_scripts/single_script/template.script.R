# aim: do monocle2 for Seurat object
# how to use: $ Rscript this.script.R xx.Seurat.obj [outputRoot [keyword]]
# Env: R 4.1.0
# v0.3 fix filter line.
# v0.4 for Seurat object

# set timezone
if( OlsonNames()[grep("Shanghai", OlsonNames())] =="Asia/Shanghai" ){
	Sys.setenv(TZ = "Asia/Shanghai")
}
start.time=Sys.time() # time

if(0){
  # how to run as a script? 
  # in Docker shell R4:
  # $ whereis Rscript
  # $ /usr/local/bin/Rscript do_CellCycle_Drop-seq2015.script.R /path/Seurat.obj.Rds /output/dir/ keyword
  # Must set at least 1 parameters, or stop.
  #
  # example
  # $ /usr/local/bin/Rscript ~/data/script_single/do_monocle2.script.R sc.Seurat.Rds ~/PBMC/trajectory/dustbin/ PBMC
}

# ** Settings Begin ###############
# default
myArgs<-commandArgs(TRUE)
if(length(myArgs)==0){
  stop("You must give at least 1 parameter to run this R script:\n$ Rscript this.script.R seurat_filename [outputRoot [keyword]]")
}

seurat_filename=myArgs[1]
outputRoot = "./"
keyword="monocle"

# set
if(! file.exists(seurat_filename) ){
  stop("input seurat file not exists: ", seurat_filename)
}

if(length(myArgs)>=2){
  outputRoot=myArgs[2] 
  # must end with /
  if(substring(outputRoot, nchar(outputRoot)) != "/"){
    outputRoot=paste0(outputRoot, "/")
  }
  # the dir must exist
  if(!dir.exists(outputRoot)){
    stop( sprintf("Error: dir not exist, outputRoot=%s", outputRoot) )
  }
}

if(length(myArgs)>=3){
  keyword=paste0(keyword, "_", myArgs[3])
  if( length(grep("/", myArgs[3]) )){
    stop( sprintf("Error: keyword must NOT contain '/', keyword=%s", myArgs[3]) )
  }
}

message( sprintf("###### \n=>parameters: \n\t seurat_filename=%s, outputRoot=%s, keyword=%s", 
                 seurat_filename, outputRoot, keyword) )
# ** Settings End ###############










# Functions & Tools ----

now=function(style=4){
  switch(
    EXPR = style,
    "1"={format(Sys.time(), '_%Y%m%d_%H%M%S')},
    "2"={format(Sys.time(), '%Y%m%d_%H%M%S')},
    "3"={format(Sys.time(), '[%Y%m%d_%H%M%S]')},
    "4"={format(Sys.time(), '[%Y/%m/%d_%H:%M:%S]')},
    stop("Invalid style. Please choose one of 1,2,3,4")
  )
}
#now()

# colors
library(RColorBrewer)
colorset.cycle6 = RColorBrewer::brewer.pal(n = 6,name = "Set2")

# lib
library(ggplot2)
library(pheatmap)
library(patchwork)










# 1. load data ----
message(now(), "1. loading Seurat data: ", keyword) # [2024/05/06_11:50:02]1. loading Seurat data: PBMC

## (1) Seurat obj ====
library(Seurat)
scObj=readRDS(seurat_filename)
DimPlot(scObj, label=T)










# 2. begin ----
##step7: Plot ====
message(now(), "2.7: Plot")

# pheatmap
result=pheatmap::pheatmap()

pdf( paste0( outputRoot, keyword, "_07_A_PhasePlot.heatmap.pdf"), width=4, height=2.5)
grid::grid.newpage()
grid::grid.draw(result$gtable)
dev.off()
#
ggsave(file= paste0(outputRoot, keyword,'_3_02C_split_time.UMAP.pdf'), width=5.1, height=2.5)










# for DotPlot width and height----
# width
length(auto.markers)
# x, y
# 55,15
# 87,22
# 129, 30
# lm(y~x, data=data.frame(x=c(55,87,129), y=c(15,22,30)))
# y=0.2021*x+4.0787
pdf_width = 0.2021*length(auto.markers) +4.0787
#
#pdf_height = 
# x,y
# 12, 4.5
# 10, 4
# lm(y~x, data=data.frame(x=c(12,10), y=c(4.5, 4)))
# y=0.25*x+1.5
pdf_height = 0.25*nlevels(sce) +1.5
message(sprintf("pdf size: {width:%s, height:%s}", pdf_width, pdf_height) )
pdf( paste0(outputRoot, keyword, "_05_1.Auto.topN.DotPlot.pdf"), width=pdf_width, height=pdf_height)
dev.off()










# for VlnPlot width and height----
# width
# x, y
# 10 2.82
# 5  1.9
# 9  2.86
#lm(y~x, data.frame(x=c(10,5,9), y=c(2.85,1.9,2.85)))
#y=0.2036*x+0.9048
vln_width = 0.2036*nlevels(pbmc2)+0.9048
#
#height
# x, y
# 5, 9.6
# 4, 7.4
# 3, 5.4
#lm(y~x, data.frame(x=c(5,4,3), y=c(9.6,7.4,5.4)))
#y=2.1*x - 0.9333
vln_height=-0.9333+2.1*sum(c("nFeature_RNA", "nCount_RNA", "percent.mt", "percent.rp","percent.ery") %in% colnames(pbmc2@meta.data))
#
pdf(paste0(outputRoot, keyword, "_01-QC.VlnPlot.pdf"), width=vln_width, height=vln_height)
VlnPlot( pbmc, features = c("nFeature_RNA", "nCount_RNA", "percent.mt",
                             "percent.rp","percent.ery"), 
         #group.by = "seurat_clusters",
         ncol = 1, pt.size=0)
dev.off()
#










#100 end of this script ----
message(now(), "End of run this R script, keyword:", keyword, 
        ", time:", round(difftime(Sys.time(), start.time, units="sec"), 2), "sec")
print("Success!")

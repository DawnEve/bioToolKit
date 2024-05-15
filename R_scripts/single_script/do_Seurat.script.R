# Aim: Seurat re-clustering, cell markers
# how to use: $ Rscript this.script.R xx.Seurat.obj [outputRoot [keyword]]
# Env: R 4.2.0
# version: 0.1-20240509
# version: 0.2-20240510 set para 4-7: All Or None.

if(0){
  # how to run as a script? 
  # H3:8890 in Docker shell R4:
  # $ whereis Rscript
  # $ Rscript do_Seurat.script.R /path/Seurat.obj.Rds /output/dir keyword
  # at least 1 parameters, or stop and give help information.
  # para 4-7 must set All Or None!
  #
  # example: 3k 346s=5.7min; 30k 1890s=30min; 30k 3117s=51min;
  # $ /usr/local/bin/Rscript /home/wangjl2/data/others/zhaoym/script/do_Seurat.script.R \
  #/data/BMMC/PBMC/data_bmmc_demo_init.Rds /data/others/zhaoym/output/tmp02/ bmmc 2000 20 0.5 5
}

# set timezone
if( OlsonNames()[grep("Shanghai", OlsonNames())] =="Asia/Shanghai" ){
  Sys.setenv(TZ = "Asia/Shanghai")
}
start.time=Sys.time() # time


# Settings Begin ########
# default
myArgs<-commandArgs(TRUE)
if(length(myArgs)==0){
  stop("You must give at least 1 parameter to run Seurat:\n", 
       "$ Rscript /path/to/this.script.R seurat_filename [outputRoot [keyword[n_HVG pc_num resolution workers]]]")
}
seurat_filename=myArgs[1]
outputRoot = "./"
keyword="Seurat"
#
n_HVG=2000 #HVG nubmer
pc_num=30 #use how many PC to do UMAP
resolution=0.2 #res to do cellcluster
workers=5 #Find marker session number

#set
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

if(length(myArgs)>=4){
  if( length(myArgs)<7 ){
    stop("Parameter 4th-7th must be set All Or None: n_HVG pc_num resolution workers, \ndefault is ", 
          sprintf("%s %s %s %s", n_HVG, pc_num, resolution, workers) )
  }
  # set
  n_HVG= as.numeric(myArgs[4]) # 2000 #HVG nubmer
  pc_num=as.numeric(myArgs[5]) #30 #use how many PC to do UMAP
  resolution=as.numeric(myArgs[6])  #0.1 #res to do cellcluster
  workers=as.numeric(myArgs[7])  #5
  # check
  stopifnot( as.character(n_HVG) == myArgs[4] )
  stopifnot( as.character(pc_num) == myArgs[5] )
  stopifnot( as.character(resolution) == myArgs[6] )
  stopifnot( as.character(workers) == myArgs[7] )
}
sharp.marks="##################"
message(sprintf("%s\nsettings: \n[1]seurat_filename=%s \n[2]outputRoot=%s \n[3]keyword=%s \n[4]n_HVG=%s \n[5]pc_num=%s \n[6]resolution=%s \n[7]workers=%s\n%s\n",
                sharp.marks,
                seurat_filename, outputRoot, keyword, n_HVG, pc_num, resolution, workers,
                sharp.marks))

library(Seurat)
library(ggplot2)
# Settings End ########



warning("The script will start in 10 seconds... \n", 
        ">> you can cancle easily at this point, click the red button[top right At Rstudio]")
Sys.sleep(10)








# Functions & Tools ----
FeaturePlot2=function(obj, features, cols = c("lightgrey", 'red'), ncol=1, ...){
  FeaturePlot(obj, features =features, 
              cols=cols,
              ncol = ncol, ... ) & NoLegend() & NoAxes() & theme(
                panel.border = element_rect(color = "black", size = 1)
              )
}

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

# libs
library(dplyr)
library(Seurat)
library(patchwork)






# 1. load data ----
message(now(), "1. load data")
#pbmc.data <- Read10X(data.dir = "published_data/bpmc3k_filtered_gene_bc_matrices/hg19/")
#sce=CreateSeuratObject(counts = pbmc.data, project = "Tcell", min.cells = 3, min.features = 200)

sce=readRDS(file=seurat_filename)



#2. QC fig1----
message(now(), "2. QC fig1")
sce[["percent.mt"]] <- PercentageFeatureSet(sce, pattern = "^MT-")
sce[["percent.rp"]] <- PercentageFeatureSet(sce, pattern = "^RP[SL]")
sce[["percent.ery"]] <- PercentageFeatureSet(sce, pattern = "^HB[AB]*")

pdf(paste0(outputRoot, keyword, "_01-QC.pdf"), width=10, height=4)
VlnPlot(sce, features = c("nFeature_RNA", "nCount_RNA", "percent.mt",
                          "percent.rp","percent.ery"), ncol = 3, pt.size=0)
dev.off()
#sce <- subset(sce, subset = nFeature_RNA > 200 & nFeature_RNA < 2500 & percent.mt < 5)

#
pdf(paste0(outputRoot, keyword, "_01-QC.FeatureScatter.pdf"), width=9.5, height=4)
plot1 <- FeatureScatter(sce, feature1 = "nCount_RNA", feature2 = "percent.mt")
plot2 <- FeatureScatter(sce, feature1 = "nCount_RNA", feature2 = "nFeature_RNA")
plot1 + plot2
dev.off()



#3. Normalize Data ----
message(now(), "3. Normalize Data")
sce <- NormalizeData(sce)

#4. HVG fig2----
message(now(), "4. HVG fig2")
sce <- FindVariableFeatures(sce, selection.method = "vst", nfeatures = n_HVG)

pdf(paste0(outputRoot, keyword, "_02-HVG.pdf"), width=7, height=4)
VariableFeaturePlot(sce)
dev.off()


#5. scale ----
message(now(), "5. scale")
all.genes <- rownames(sce)
sce <- ScaleData(sce, features = all.genes)

#6. PCA fig3----
message(now(), "6. PCA fig3")
sce <- RunPCA(sce, features = VariableFeatures(object = sce), npcs = 100)

pdf(paste0(outputRoot, keyword, "_03-PCA_Elbow.pdf"), width=5, height=4)
DimPlot(sce, reduction = "pca")
DimPlot(sce, reduction = "pca", dims = c(1,3))
DimPlot(sce, reduction = "pca", dims = c(2,3))
ElbowPlot(sce, ndims = 100)+
  ggtitle( paste( "project.name:", sce@project.name ) )
dev.off()


#7. UMAP ----
message(now(), "7. UMAP")
sce <- RunUMAP(sce, dims = 1:pc_num)
#sce <- RunTSNE(sce, dims = 1:10)
#DimPlot(sce, reduction = "tsne")



#8. cell cluster fig4----
message(now(), "8. cell cluster fig4")
sce <- FindNeighbors(object = sce, dims=1:pc_num)
sce <- FindClusters(object = sce, resolution = resolution)

pdf(paste0(outputRoot, keyword, "_04-CellCluster.UMAP.pdf"), width=5, height=4)
DimPlot(sce, reduction = "umap")+
  ggtitle( paste0( sce@project.name, "> ", paste(c("gene", "cell"), dim(sce), collapse = ", ", sep = ":") ) )
DimPlot(sce, reduction = "umap", label=T)+
  ggtitle( sprintf("HVG:%s, PC:%s, res:%s", n_HVG, pc_num, resolution) )
#DimPlot(sce, reduction = "umap", group.by = "Sample_Origin")
dev.off()

pdf(paste0(outputRoot, keyword, "_04-QC2.pdf"), width=6, height=10)
VlnPlot(sce, features = c("nFeature_RNA", "nCount_RNA", "percent.mt",
                          "percent.rp","percent.ery"), ncol = 1, pt.size=0)
dev.off()



#9. Find Marker fig5----
message(now(), "9. Find Marker fig5")
if(1==workers){
  sce.markers <- FindAllMarkers(sce, only.pos = TRUE, min.pct = 0.25, logfc.threshold = 0.25)
}else{
  message(now(), "using multisession, workers=", workers)
  library(future)
  plan(strategy = "multisession", workers=workers) #multi-thread
  sce.markers <- FindAllMarkers(sce, only.pos = TRUE, min.pct = 0.25, logfc.threshold = 0.25)
  plan(strategy = "sequential") #restore to 1-thread
}

sce.markers %>% group_by(cluster) %>% top_n(n = 2, wt = avg_log2FC)

# insert to Obj
sce@misc[['markers']]=sce.markers

## save Rds ====
message(now(), " save Rds")
saveRDS(sce, file = paste0(outputRoot, keyword, "_05-final-with_DEG.Seurat.Rds") )





## (1) auto marker plot ====
message(now(), "9 (1) auto marker plot")
auto.markers=unique(c(  "PTPRC",
                        "CD3D","CD3E", "CD4", "CD8A", "CD8B", 
                        "CD19", 'MS4A1', "CD79A", "CD79B", 
                        "MZB1", "SDC1","IGHG1",
                        "NKG7",
                        'LYZ','CD68', 'CD163', 'CD14', 
                        "CD1C", 'NOS2','ARG1',
                        "MKI67",
                        sce.markers %>% group_by(cluster) %>% top_n(n = 4, wt = avg_log2FC) %>% pull(gene),
                        "GAPDH"
))
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
#
pdf( paste0(outputRoot, keyword, "_05_1.Auto.topN.DotPlot.pdf"), width=pdf_width, height=pdf_height)
DotPlot( sce, #subset(sce, seurat_clusters %in% c(1:8) ), 
         features = auto.markers, cluster.idents = F, cols=c('lightgrey', "red")) + RotatedAxis()+
  ggtitle( paste0("Top N markers of ", keyword ))
#
DotPlot( sce, #subset(sce, seurat_clusters %in% c(1:8) ), 
         features = auto.markers, cluster.idents = T, cols=c('lightgrey', "red")) + RotatedAxis()+
  ggtitle( paste0("Top N markers of ", keyword ))
dev.off()




## (2) manual marker plot ====
message(now(), "9 (2) manual marker plot")
markers=list(
  epithelial=c(#'KRT14', 'KRT17', 'KRT6A', 'KRT5', 
    'EPCAM', 'KRT8', 'KRT18','KRT19',  #'KRT16', 'KRT6B', 'KRT15', 'KRT6C', 'KRTCAP3', 
    'SFN', 'PROM1', 'ALDH1A1', 'CD24'), 
  fibro=c("MME",'FAP', 'PDPN', 'COL1A2', 'DCN', 'COL3A1', 'COL6A1'), 
  endo =c('PECAM1', 'VWF', 'ENG'),
  
  myocytes=c('ACTA1', 'ACTN2', 'MYL2', 'MYH2'), 
  
  "T" =c("PTPRC", 'CD2', 'CD3D', 'CD3E', 'CD3G', 'CD4', 'CD8A', 'CD8B', 'SELL',
         'FOXP3', "CTLA4", "CD274", "PRF1", "IFNG", "RUNX3", "ZBTB7B"),
  NK=c('NKG7', 'GNLY', 'GZMA', 'GZMB', "NCAM1",  'FGFBP2', 'CX3CR1'),
  B = c( 'CD79A', 'CD79B', 'CD19', 'MS4A1', 'VPREB3', 'SLAMF7','BLNK', 'FCRL5'), 
  Plasma=c('IGHG1', 'MZB1', 'SDC1'),
  mono=c('CD14', "FCGR3A"),
  macro=c('CD163', 'CD68', 'FCGR2A', 'CSF1R'), 
  M1=c('NOS2', 'IRF5', 'PTGS2'),
  M2=c( 'VSIG4', 'MS4A4A'), #'CD163',
  DC=c('ITGAX','CD40', 'CD80', 'CD83', 'CCR7'), 
  mast = c('CMA1', 'MS4A2', 'TPSAB1', 'TPSB2'),
  
  eryth=c("HBA1",  "HBA2",  "HBB",   "HBD"),
  
  stem=c('CD34', 'KIT', 'SOCS2', 'SOCS1'),
  cycle=c('MKI67', 'CCND1', 'CCND3', 'CCNE1', 'CCNE2', 'CCNB1', 'CCNB2'),
  APA =c('NUDT21', "CPSF6"),
  meta=c("GAPDH", 'ACTB', "SCCPDH")
)
#
pdf( paste0(outputRoot, keyword, "_05_2.Manual.marker.DotPlot.pdf"), width=26, height=pdf_height)
DotPlot(sce, features = markers, cluster.idents = T, cols=c('lightgrey', "red")) + RotatedAxis()+
  ggtitle(keyword)
dev.off()
#

#
pdf( paste0(outputRoot, keyword, "_05_3.wide.FeaturePlot2.pdf"), width=6.27, height=6.25)
FeaturePlot2(sce, features =c(
  "PTPRC", "CD3D", "CD4", "CD8A", "CD79A", "NKG7", "GZMB", "CD14", "CD68", "CCR7", 
  "LYZ",
  "KRT8", "EPCAM", "COL1A2", "COL3A1", "VWF", "MKI67", "CCNB1", "CD34", "SOCS2"
), ncol=5, pt.size=0.1)
dev.off()
#
# "CSF1R"
#FeaturePlot(sce, features = c("MS4A1", "GNLY", "CD3E", "CD14", "FCER1A", "FCGR3A", 
#                              "LYZ", "PPBP", "CD8A"))




#100 end of this script ----
message(now(), "End of do Seurat script, keyword:", keyword, 
        ", time:", round(difftime(Sys.time(), start.time, units="sec"), 2), "sec")
print("end of this R script")

# Aim: do CytoTRACE from Seurat obj
# how to use: $ Rscript /data/wangjl/scPolyA-seq2/chenxi/pipeline/script_single/do_CytoTRACE.script.R xx.Seurat.obj
# Env: R 4.3.3 on CentOS7.9
# R pkg: CytoTRACE 0.3.3
# version: 0.2 [2024.5.2]

myArgs<-commandArgs(TRUE)
if(length(myArgs)==0){
	stop("You must give at least 1 parameter:\n$ Rscript /path/to/this.script.R seurat_filename [cell_type [outputRoot [keyword]]]")
}

# settings
#################
# default settins
seurat_filename=myArgs[1] #at least one parameter
cell_type="seurat_clusters"
outputRoot="./"
keyword="CytoTRACE"
if(length(myArgs)>=2){ cell_type=myArgs[2] }
if(length(myArgs)>=3){ 
	outputRoot=myArgs[3] 
	# must end with /
	if(substring(outputRoot, nchar(outputRoot)) != "/"){
		outputRoot=paste0(outputRoot, "/")
	}
	# the dir must exist
	if(!dir.exists(outputRoot)){
		stop( sprintf("Error: dir not exist, outputRoot=%s", outputRoot) )
	}
}

if(length(myArgs)>=4){ 
	keyword=paste0(keyword, "_", myArgs[4])
	if( length(grep("/", myArgs[4]) )){
		stop( sprintf("Error: keyword must NOT contain '/', keyword=%s", myArgs[4]) )
	}
}
setwd(outputRoot)
message( sprintf("[%s] output to: %s", date(), outputRoot))
#################


# init pkg
library(ggplot2)
library(Seurat)
# set python to repress Qeustions from CytoTRACE
library("reticulate")
use_python("/home/wangjl/soft/python3/python-3.10.14/bin/python3", required = T)
py_config()
library(CytoTRACE)


# 1. load data----
message( sprintf("[%s] step 1: loading Seurat object", date()))
scObj=readRDS(seurat_filename)
# cell_type must in meta data col
if(!cell_type %in% names(scObj@meta.data)){
	stop( sprintf("Error: cell_type=\"%s\" must be one of meta.data=%s", cell_type, names(scObj@meta.data) |> jsonlite::toJSON()|>as.character() ))
}
DimPlot(scObj, label=T)
ggsave( paste0(outputRoot, keyword, "-01_1.DimPlot.pdf"), width=4, height=3.5)

# 2. CytoTRACE ----
message( sprintf("[%s] step 2: do CytoTRACE", date()))
results <- CytoTRACE(scObj@assays$RNA@counts |> as.matrix(), enableFast = FALSE)
saveRDS(results, file=paste0(outputRoot, keyword, "-02_1.CytoTRACE.results.Rds") )

message( sprintf("[%s] save CytoTRACE score", date()))
score = results$CytoTRACE|> as.data.frame()
umap_cord=FetchData(scObj, vars = c("UMAP_1", "UMAP_2"))
# re-plot
dif=cbind(umap_cord, data.frame(score=results$CytoTRACE[rownames(umap_cord)]))
# save data: 3 col(cid as row names): umap1-2, CytoTRACEscore
write.table(dif, file=paste0(outputRoot, keyword, "-02_2.CytoTRACE.score.df.txt"), quote = F)
#
ggplot(dif, aes(UMAP_1, UMAP_2, color=score))+
  geom_point(size=0.1)+
  scale_color_gradientn(colors = c("navy", "grey", "red"))+
  theme_classic()
ggsave( paste0(outputRoot, keyword, "-02_3.CytoTRACE.score.DimPlot.pdf"), width=2.7, height=2)


# 3. visulisation ----
message( sprintf("[%s] step 3: CytoTRACE visulisation", date()))
# reuse cell type
phe=scObj@meta.data[, cell_type] |> as.character()
names(phe)=scObj@meta.data |> rownames()
# re-use UMAP embedding
plotCytoTRACE(results, phenotype = phe, emb=umap_cord, outputDir=outputRoot ) #use UMAP from Seurat, Good

#可视化与 CytoTRACE 相关的基因
plotCytoGenes(results, numOfGenes = 10, outputDir=outputRoot)

message( sprintf("[%s]%s: %s\n", date(), "CytoTRACE end for file:",  seurat_filename) )


# How to run
if(0){
	#give help if no parameter given
	$ Rscript /data/wangjl/scPolyA-seq2/chenxi/pipeline/script_single/do_CytoTRACE.script.R 
	
	# demo
	$ Rscript /data/wangjl/scPolyA-seq2/chenxi/pipeline/script_single/do_CytoTRACE.script.R \
/data/wangjl/scPolyA-seq2/chenxi/PBMC/UMAP/star_solo/scObj_final-PBMC_8plates.Star_Solo_PC25res0.8.CellCycle.withDEG.Seurat.Rds seurat_clusters /data/wangjl/scPolyA-seq2/chenxi/PBMC/trajectory/ CD4T_PBMC
}
# Aim: do monocle2 as a script, output to a dir
# how to use: $ Rscript this.script.R xx.Seurat.obj [outputRoot]
# Env: R 4.1.0
# version: 0.2-20240504
# version: 0.3-20240504 set parameters

if(0){
  # how to run as a script? 
  # in Docker shell R4:
  # $ whereis Rscript
  # $ /usr/local/bin/Rscript ~/data/scPolyA-seq2/chenxi/PBMC/script/monocle2_test2.R /path/to/Seurat.obj.Rds /output/dir
  # at least 2 parameters, or stop and give help information.
  #
  # example
  # $ /usr/local/bin/Rscript ~/data/scPolyA-seq2/chenxi/PBMC/script/monocle2_test2.R \
  # /data/wangjl/scPolyA-seq2/chenxi/PBMC/UMAP/star_solo/scObj_final-PBMC_8plates.Star_Solo_PC25res0.8.CellCycle.withDEG.Seurat.Rds \
  # /data/wangjl/scPolyA-seq2/chenxi/PBMC/trajectory/ CD4_PBMC
}

start.time=Sys.time() # time


# settings begin ###############
# default
myArgs<-commandArgs(TRUE)
if(length(myArgs)==0){
  stop("You must give at least 1 parameter to run monocle2:\n$ Rscript /path/to/this.script.R seurat_filename [outputRoot [keyword [need_filter_cells [only.pos]]]]")
}

seurat_filename=myArgs[1]
outputRoot = "./"

#keyword="monocle2Test5"  # F, F 4.1: NO branch, 500s
#keyword="monocle2Test6" # T, T 4.1: NO branch, 300s
#keyword="monocle2Test7" # F, T 4.1: NO branch, 300s
#keyword="monocle2Test8" # T, F 4.1: branch OK, 500s  <<<===---
keyword="monocle2"

# if you want branches, you have 2 essentials:
# 1. must filter cells with 3.2
# 2. use only.pos=F in Seurat DEG 4.1
# About 590s totally for 3k cells
need_filter_cells=T #T more branches
only.pos=F #F more branches

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
  need_filter_cells=myArgs[4] |> as.logical()
}
if(length(myArgs)>=5){
  only.pos=myArgs[5] |> as.logical()
}
message( sprintf("###### \n=>parameters: need_filter_cells=%s, only.pos=%s", 
                 need_filter_cells, only.pos) )
# settings end ###############





# functions & tools ----
# large dot in legend
LargeLegend = function(size=5){
  guides(colour = guide_legend(override.aes = list(alpha = 1,size=size)))
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

# library
#library(dplyr)
library(ggplot2)
library(Seurat)
library(monocle) #2.22.0





# 1. load Seurat data ----
message(now(), "1. loading Seurat data: ", keyword) #[20220701_111547]warning:xxx

sce=readRDS(seurat_filename)
sce #15855 features across 3066 samples within 1 assay 



# 2. to monocle2 obj ----
message(now(), "2. seurat to monocle2")

#' get Monocle2 obj from Seurat obj
#'
#' @param sce Seurat obj
#'
#' @return Monocle2 obj
#' @export
#'
#' @examples
Seurat2Monocle2=function(sce){
  #1. to monocle obj
  #expr_matrix=as.matrix(sce@assays$RNA@counts)
  #expr_matrix=GetAssayData(sce, assay = 'RNA', slot = 'counts')
  expr_matrix= as(as.matrix(sce@assays$RNA@counts), 'sparseMatrix')
  
  cell_data=sce@meta.data
  gene_data=data.frame(
    gene_short_name=row.names(expr_matrix), #must have this column
    row.names = row.names(expr_matrix)
  )
  #
  pd <- new("AnnotatedDataFrame", data = cell_data)
  fd <- new("AnnotatedDataFrame", data = gene_data)
  cds <- newCellDataSet(expr_matrix, 
                        phenoData = pd, 
                        featureData = fd,
                        expressionFamily=negbinomial.size())
  #2. pre processing
  cds <- estimateSizeFactors(cds)
  cds <- estimateDispersions(cds)
  
  return(cds)
}
monocle_cds = Seurat2Monocle2(sce)
monocle_cds





#3. QC (essential if you want branches) ----
message(now(), "3. (0) detectGenes")
monocle_cds <- detectGenes(monocle_cds, min_expr = 0.1) #rm low QC gene
print( head(fData(monocle_cds), n=3) )
print(dim(fData(monocle_cds))) #15855     2

if(0){
  # to determin the threshold of num_cells_expressed
  hist( fData(monocle_cds)[,2], n=1000)
  hist( fData(monocle_cds)[,2], n=1000, ylim=c(0, 100))
  # log scale
  hist( log2(fData(monocle_cds)[,2] +1), n=1000, ylim=c(0, 100))
  abline(v=6, col="red", lty=2) 
  message(now(), "num_cells_expressed>=", 2**6 -1)#63
  
  head(pData(monocle_cds))
}

## (1) filter low exp genes ----
message(now(), "3. (1) filter low exp genes")
#expressed_genes <- row.names(subset(fData(monocle_cds), num_cells_expressed >= 50))
expressed_genes <- row.names(subset(fData(monocle_cds), num_cells_expressed >= 10))
message( sprintf("[%s] expressed_genes n=%s", date(),  length(expressed_genes) )  )#11818

monocle_cds <- monocle_cds[expressed_genes,]


## (2)filter cells ----
message(now(), "3. (2) filter cells")
# i)done by Seurat: ignore
#valid_cells <- row.names(subset(pData(monocle_cds),num_genes_expressed >= 200 & Mapped.Fragments > 1000000))
#length(valid_cells)
#HSMM <- HSMM[,valid_cells]


# ii) if you need branches, set TRUE
if(!need_filter_cells){
  warning("warn: setting need_filter_cells=F may results only 1 state and no branch!")
}else{
  message("setting need_filter_cells=T: may results more states and more branches.")
  # use exprs() to get counts matrix
  expdt <- exprs(monocle_cds)
  print( dim(expdt) ) #11818  3066
  # calculate mRNA(UMI/cout)sum: colSum of matrix, and add Total_mRNAs column to phenoData df
  pData(monocle_cds)$Total_mRNAs <- Matrix::colSums(expdt)
  head(pData(monocle_cds), n=3)
  print(dim(monocle_cds))
  
  # filter cell by Total_mRNAs: less than 1m mRNA
  #valid_cells2 <- pData(monocle_cds)$Total_mRNAs < 1e6 #Too large for 10x? 需要重新确定边界
  #HSMM <- HSMM[,valid_cells2]
  
  #异常值范围边界确定：mean ± 2sd；
  HSMM=monocle_cds
  upper_bound <- 10^(mean(log10(pData(HSMM)$Total_mRNAs)) +
                       2*sd(log10(pData(HSMM)$Total_mRNAs)))
  lower_bound <- 10^(mean(log10(pData(HSMM)$Total_mRNAs)) -
                       2*sd(log10(pData(HSMM)$Total_mRNAs)))
  
  # plot density plot of total mRNA of each cell:绘制细胞总mRNA数的核密度分布曲线：
  pdf(paste0(outputRoot,keyword,"_00_filterCell.cutoff.DensPlot.pdf"),width=4,height=2)
  p1=qplot(Total_mRNAs, data = pData(HSMM), color = time, geom ="density") +
    geom_vline(xintercept = c(lower_bound,upper_bound), color="red", linetype=2 )+
    theme_classic(base_size = 12)+ Seurat::FontSize(12,12, 12, 12)+
    #scale_color_manual(values=c("#FFA500", "#FF1493", "#4876FF") )+
    ggtitle("Density plot of total mRNA per cell")
  print(p1)
  #保留“中间”区域；
  valid_cells3 = pData(HSMM)$Total_mRNAs > lower_bound & pData(HSMM)$Total_mRNAs < upper_bound
  HSMM <- HSMM[,valid_cells3]
  
  print(dim(HSMM))
  #Features  Samples 
  #11818     2957
  
  # (3)density plot(optional) ----
  #对表达量矩阵取对数得到新矩阵；
  L <- log(exprs(HSMM[expressed_genes,]))
  # 使用scale()函数对基因表达量进行标准化,函数默认对列标准化，需转置；
  M <- Matrix::t(scale(Matrix::t(L)))
  #使用Melt函数进行表格“整形”；
  library(reshape2)
  melted_dens_df <- melt(M)
  
  p2=qplot(value, geom = "density", data = melted_dens_df) +
    stat_function(fun = dnorm, size = 0.5, color = 'red') +
    xlab("Standardized log(FPKM)") +
    ylab("Density")+
    theme_classic(base_size = 12)+ Seurat::FontSize(12,12, 12, 12)+
    scale_color_manual(values=c("#FFA500", "#FF1493", "#4876FF") )
  print(p2)
  dev.off()
  monocle_cds=HSMM;
}




#4. Monocle2 trajectory ----

## (1) 3 steps And Save Rds ----
message(now(), "4. (1) monocle 3 main steps")
### step 1: DEG by Seurat
library(future)
plan(strategy = "multisession", workers=4)
#deg.cluster <- FindAllMarkers(sce) #must not use only.pos=F to get branches
deg.cluster <- FindAllMarkers(sce, only.pos = only.pos)
#deg.cluster <- FindAllMarkers(sce, only.pos = TRUE, min.pct = 0.25, logfc.threshold = 0.25)
plan(strategy = "sequential")

#
diff.genes <- unique( subset(deg.cluster,p_val_adj<0.05)$gene )
message(now(), "length(diff.genes)=", length(diff.genes)) #3232
# 4135, no only pos
monocle_cds <- setOrderingFilter(monocle_cds, diff.genes)

pdf(paste0(outputRoot, keyword, "_01.plot_ordering_genes.pdf"), width=4, height=4)
plot_ordering_genes(monocle_cds)+
  ggtitle(sprintf("diff.genes n=%s", length(diff.genes)))
dev.off()


### step 2:  reduce data dimensionality
monocle_cds <- reduceDimension(monocle_cds, max_components = 2, method = 'DDRTree')
### step 3: order cells along the trajectory
monocle_cds <- orderCells(monocle_cds)

# save the R obj
saveRDS(monocle_cds, paste0(outputRoot, keyword, "-monocle2.cds.Rds"))


## (2) visualization ----
message(now(), "4. (2) visualization")
pdf(paste0(outputRoot, keyword, "_02.trajectory.pdf"), width=4, height=4)
DimPlot(sce, label=T)
plot_cell_trajectory(monocle_cds, color_by = "Pseudotime", cell_size = 0.75)
plot_cell_trajectory(monocle_cds, color_by = "State", cell_size = 0.75)+
  LargeLegend(2)
plot_cell_trajectory(monocle_cds, color_by = "seurat_clusters", cell_size = 0.75)+
  LargeLegend(2)
dev.off()
#
pdf(paste0(outputRoot, keyword, "_02B.facet-trajectory.pdf"), width=6, height=6)
plot_cell_trajectory(monocle_cds, color_by = "seurat_clusters", cell_size = 0.25)+
  facet_wrap(~seurat_clusters)+
  LargeLegend(2)
dev.off()





## (3) cell dens along Pseudotime ----
df <- pData(monocle_cds)

pdf(paste0(outputRoot, keyword, "_03B.CellDens_Pseudotime.pdf"), width=3.7, height=6)
ggplot(df, aes(Pseudotime, colour = seurat_clusters, fill=seurat_clusters)) +
  geom_density(bw=0.5,size=1,alpha = 0.5)+
  facet_wrap(~seurat_clusters, ncol=1)+
  theme_void()
dev.off()



## (4) plot_genes_in_pseudotime ----
#gene_symbols=row.names(subset(fData(monocle_cds), gene_short_name %in% c("YWHAB", "ICAM2", "ICAM2")))
gene_symbols=row.names(subset(fData(monocle_cds), use_for_ordering==T))[c(1,2,5)]
print(gene_symbols)
pdf(paste0(outputRoot, keyword, "_03C.plot_genes_in_pseudotime.pdf"), width=4.3, height=3.9)
plot_genes_in_pseudotime(monocle_cds[gene_symbols, ], color_by =  "seurat_clusters", cell_size = 0.5)+
  LargeLegend(3)
dev.off()

#
# plot_genes_jitter(monocle_cds[gene_symbols,], grouping = "State", color_by = "State")
#plot_genes_jitter(monocle_cds[gene_symbols,], grouping = "State", color_by = "State", 
#                  cell_size = 0.5, plot_trend = TRUE)
#pdf(paste0(outputRoot, keyword, "_03d1.plot_genes_jitter.pdf"), width=4.3, height=3.9)
#plot_genes_jitter(monocle_cds[gene_symbols,],
#                  grouping = "seurat_clusters", color_by = "seurat_clusters", plot_trend = TRUE) +
#  facet_wrap( ~ time, scales= "free_y")
#dev.off()

#
pdf(paste0(outputRoot, keyword, "_03d.plot_genes_violin.pdf"), width=4.3, height=3.9)
plot_genes_violin(monocle_cds[gene_symbols,], grouping = "seurat_clusters", color_by = "seurat_clusters")+
  theme_classic()+
  theme(
    strip.background = element_blank()
  )
dev.off()




# 5. Genes Change along Pseudotime ----
##(1) DEG along Pseudotime----
message(now(), "5. (1) differentialGeneTest")
pseudotime_deg <- differentialGeneTest(monocle_cds, 
                                       fullModelFormulaStr= " ~sm.ns(Pseudotime)", 
                                       cores = 4)
#pseudotime_deg[,c("gene_short_name", "pval", "qval")] |> head()
gene_symbols2=subset(pseudotime_deg, qval<0.01 & use_for_ordering==T) |> rownames() |> head(3)
print(gene_symbols2)
pdf(paste0(outputRoot, keyword, "_04.plot_genes_in_pseudotime.pdf"), width=4.3, height=3.9)
plot_genes_in_pseudotime(monocle_cds[gene_symbols2,], 
                         color_by = "seurat_clusters")
dev.off()


##(2) DEG heatmap----
# re-use above dataset
#diff_test_res = differentialGeneTest(monocle_cds[marker_genes,], 
#                                     fullModelFormulaStr="~sm.ns(Pseudotime)")
diff_test_rtes=subset(pseudotime_deg, use_for_ordering==T)
sig_gene_names = row.names(subset(diff_test_rtes, qval<0.01))
length(sig_gene_names)
p3=plot_pseudotime_heatmap(monocle_cds[sig_gene_names,], num_clusters=4, 
                           cores=1, show_rownames=T, return_heatmap = T)
pdf(paste0(outputRoot, keyword, "_05.plot_pseudotime_heatmap.pdf"), width=4, height=6)
print(p3)
dev.off()







# 6. BEAM ----
# view branch point
#plot_cell_trajectory(monocle_cds, color_by = "State")
message(now(), "6. BEAM")
BEAM_res = BEAM(monocle_cds[expressed_genes, ], 
                branch_point=1, # branch point, important
                cores=4)

# order by q value
BEAM_res=BEAM_res[order(BEAM_res$qval),]
#BEAM_res=BEAM_res[, c("gene_short_name", "pval", "qval")]

my_branched_heatmap = plot_genes_branched_heatmap(
  monocle_cds[row.names(subset(BEAM_res, qval<1e-4)),], 
  branch_point=1,
  num_clusters=4, 
  cores=2, 
  branch_labels = c("Cell fate A", "Cell fate B"), #label for the two branch
  branch_colors = c("#C7C7C7", "#F05662", "#7990C8"), #pre-branch(#979797), Cell fate A, Cell fate B colors
  #hmcols = colorRampPalette(rev(brewer.pal(9, "PRGn")))(62), #gradient color for main fig
  use_gene_short_name=T,
  show_rownames=T,
  return_heatmap = T)
pdf(paste0(outputRoot, keyword, "_06.plot_genes_branched_heatmap.pdf"), width=8, height=7)
my_branched_heatmap$ph_res
dev.off()

#
#test_genes=c("TFF3","GUCA2B")
test_genes=sig_gene_names[c(1,2,5)]
print(test_genes)
#
pdf(paste0(outputRoot, keyword, "_07.plot_genes_branched_pseudotime.pdf"), width=4.3, height=3.9)
plot_genes_branched_pseudotime(monocle_cds[test_genes,],
                               branch_point = 1,
                               color_by = "seurat_clusters",
                               cell_size=0.2,
                               # branch_labels=c(),
                               ncol = 1)+LargeLegend(3)
dev.off()






#100 end of this script ----
message(now(), "End of do monocle2 script, keyword:", keyword, 
        ", time:", round(difftime(Sys.time(), start.time, units="sec"), 2), "sec")
print("end of this R script")
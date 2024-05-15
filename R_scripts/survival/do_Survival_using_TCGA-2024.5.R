# survival for a given gene in AML from TCGA dataset
# http://www.360doc.com/content/23/0811/10/45289182_1092099021.shtml
# 2024.5.11

outputRoot="E:\\research\\AML-SCCPDH\\output\\"
keyword="AML"


#1. load data----
## (1)fpkm ====
fpkm=read.table(paste0(outputRoot, "../TCGA-LAML.htseq_fpkm.tsv"), row.names = 1, header = T )
fpkm[1:3,1:4]
dim(fpkm) # 60483   151

## (2) gene anno ====
anno=read.table(paste0(outputRoot, "../gencode.v22.annotation.gene.probeMap"), row.names = 1, header = T )
anno[1:3,1:4]
dim(anno) # 60483     5

## (3) clinic ====
clin=read.table(paste0(outputRoot, "../survival_LAML_survival.txt"), 
                row.names = 1, 
                header = T, sep="\t" )
clin[1:3, ]
dim(clin) #200 10
#



## (4) try connect dataset ====
if(0){
  table(anno$gene ) |> sort() |> tail()
  
  table(table(anno$gene ) == 1 )
  #FALSE  TRUE 
  # 399 57988
  
  grep("SCCPDH", anno$gene, value=T)
  
  # uniq gene list
  genes = unique(anno$gene )
  genes |> head()
  # combine same genes?
}






# 2. suivival ----
getData_exp_clin=function(symbol, anno, fpkm, clin){ 
  #(1) for a given gene
  #symbol="SCCPDH"
  #(2) get several ensembl ID(s)
  ensemble=subset(anno, gene==symbol)
  #(3) get exp of the ensemble ID(s), pool to one
  expression=fpkm[rownames(ensemble),]
  #dim(expression)
  colnames(expression)=gsub("\\.", "\\-", colnames(expression))
  #expression[, 1:4]
  # rm col names
  exp_df = data.frame(
    cell = colnames(expression),
    
    #if many ensemble IDs, then default use mean, you can also try sum
    fpkm = as.numeric( colMeans(expression) ) 
  )
  #(4) change cell id, to match clin
  exp_df$cid= sapply(exp_df$cell, function(cell){
    arr=strsplit(cell, "-")[[1]]
    paste0(arr[1:3], collapse = "-")
  })
  rownames(exp_df)=exp_df$cid
  #head(exp_df)
  #
  #(5) get common patient ID of exp and clin data
  common_pid=intersect(clin$X_PATIENT, exp_df$cid)
  #head(common_pid)
  #length(common_pid)
  #
  #(6) combine exp to clin data
  exp_df = exp_df[common_pid, ]
  dat=clin[common_pid, c('OS', 'OS.time')]
  dat$fpkm=exp_df$fpkm
  #head(dat)
  #                OS OS.time     fpkm
  #TCGA-AB-2805-03  1     577 4.348631
  #TCGA-AB-2806-03  1     945 5.701728
  #TCGA-AB-2808-03  0    2861 5.993745
  #
  #fit=survfit(Surv(time, status)~sex, data=lung)
  
  #add explevel
  dat2=dat
  dat2$level=ifelse(dat2$fpkm> median(dat2$fpkm), 
                       paste0(symbol, "_high"), 
                       paste0(symbol, "_low") )
  print(table(dat2$level))
  return(dat2)
}

## (1) get data: exp and clin ----
{
symbol="SCCPDH" #sig
symbol="COX11"
symbol="MSL1"
symbol="CD47"
symbol="CD34"
symbol="NUDT21"
symbol="CPSF6" #sig
symbol="CSTF2" #sig
symbol="FIP1L1" #sig
symbol="MKI67"
symbol="CPSF3"
symbol="KIT" #sig
symbol="PDGFRA"
if(0 == length(grep(symbol, anno$gene, value=T) ) ){
  stop("No item found: gene=", symbol)
}else{
  message("Exp data of this gene exists: gene=", symbol)
}
dat=getData_exp_clin(symbol, anno, fpkm, clin)

## (2) suivival analysis fit ----
library(survival)
fit=survfit(Surv(OS.time, OS)~level, data=dat)
#fit
#summary(fit)
summary(fit)$table
#str(fit)

## (3) plot ----
library(survminer)
#http://127.0.0.1:40979/graphics/plot_zoom_png?width=501&height=448
pdf( paste0(outputRoot, keyword, "_", symbol, "_01_survival.plot.pdf"), width=5, height=4.4)
p1=ggsurvplot(fit,
           pval = TRUE, conf.int = TRUE,
           break.time.by = 500, # break X axis in time intervals by 200.
           #conf.int.style = 'step', # customize style of confidence intervals
           risk.table = TRUE, # Add risk table
           risk.table.col = 'strata', # Change risk table color by groups
           risk.table.y.text = T,# show bars instead of names in text annotations
           linetype = 'strata', # Change line type by groups
           xlab = 'Time in days',
           surv.median.line = 'hv', # Specify median survival
           
           #xlim = c(0, 365*5),
           ggtheme = theme_classic(), # Change ggplot2 theme
           legend.labs=c("high", "low"),
           palette = c('#E7B800', '#2E9FDF'))+
  ggtitle(symbol)
print(p1)
dev.off()
message("End of: ", symbol)
}

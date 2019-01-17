#目的: 给出数据矩阵，计算gene1和其余gene的相关系数，并画cor的heatmap。
# v0.1
#pheatmap 帮助文档 https://www.jianshu.com/p/1c55ea64ff3f

source("https://bioconductor.org/biocLite.R")
#biocLite("WGCNA")
#biocLite("ggplot2")
#biocLite("dplyr")
#biocLite("Seurat")
#biocLite("monocle")


setwd("C:\\Users\\DELL\\Desktop")


################
#read file H
msiH=read.csv("MSI-h.csv",row.names = 1)
msiH[1:3,1:3]
dim(msiH) #[1]  45 135


################
#read file 
msiM=read.csv("MSIL-MSS.csv",row.names = 1)
msiM[1:3,1:3]
dim(msiM) #[1] 199 135



#check 重复项
genelist=colnames(msiM);genelist



#################
#defin function
getCorDF=function(msi){
  #cor.test
  ido1=msi$IDO1
  df=NULL
  for(i in 3:ncol(msi)){
    
    data2=msi[,i]
    symbol=colnames(msi)[i]
    
    rs=cor.test(ido1, data2)
    p=rs$p.value
    correlation=as.numeric(rs$estimate)
    
    tmp_df=data.frame(
      symbol=symbol,
      p=p,
      correlation=correlation
    )
    
    #
    df=rbind(df, tmp_df)
  }
  return(df)
}


df.h=getCorDF(msiH)
dim(df.h) #[1] 133   2
head(df.h)
row.names(df.h)=df.h$symbol
#df.h=df.h[,-1]


df.m=getCorDF(msiM)
dim(df.m) #[1] 133   2
row.names(df.m)=df.m$symbol
#df.m=df.m[,-1]
head(df.m)

cDF=data.frame(
  symbol=row.names(df.m),
  "MSI_H"=df.h$correlation,
  "NON_MSI_H"=df.m$correlation,
  row.names = 1
)
head(cDF)
dim(cDF) #[1] 133   2

###
#heatmap
library(pheatmap)

# 构建列 注释信息
type=read.csv("type.csv")
head(type)
dim(type) #[1] 133   2

annotation_col = data.frame(
  #CellType = factor(rep(c("CT1", "CT2","CT3", "CT4","CT5"), 27))
  type=type$type
)
rownames(annotation_col) = rownames(cDF)  #type$sample # paste("Test", 1:10, sep = "")
head(annotation_col)


#
# 自定注释信息的颜色列表
ann_colors = list(
  #Time = c("white", "firebrick"),
  type = c("Act CD4" = "#FF81F2", "Act CD8" = "#00B9FF","HLA" = "#39B54A",
           "immune checkpoint" = "#FF0000","Tem CD4" = "#FF8B99","Tem CD8" = "#0000FF",
           "Treg" = "#FF8000")
)
head(ann_colors)



# pheatmap 
library(Cairo)
CairoPDF("sunjiaxin_10_col.pdf",width=25,height=3)
pheatmap(t(cDF), cluster_rows=F,#是否聚类 row
         cluster_cols=T, #是否聚类 列
         #display_numbers = TRUE,number_color = "blue", #标上p值
         
         annotation_col = annotation_col, #列 注释
         
         annotation_colors = ann_colors,
         
         angle_col=90,fontsize=10, #角度，字号
         border=FALSE #没有边框
)
dev.off()

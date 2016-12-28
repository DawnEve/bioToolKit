#library("pheatmap")
#biocLite("pheatmap")
library("pheatmap")

#读取数据
#data=read.table("D://R_code/expAll_norm.txt",header = TRUE)
data=read.table("D://R_code/expAvg.txt",header = TRUE,)
selected=as.matrix(data)  #转换矩阵
selected=t(selected)
head(selected)


#添加红蓝横条
color.map <- function(clazz) {
  last=substring(clazz,nchar(clazz))
  #print(last)
  if (last=="1") "#FF0000" else "#0000FF" }
patientcolors <- unlist(lapply(colnames(selected), color.map))



#粗糙的热力图
heatmap(selected)
heatmap(selected, ColSideColors=patientcolors,scale="row")


#对数据做归一化
#TODO


#####################################
library("gplots")

heatmap(selected, col=topo.colors(100), ColSideColors=patientcolors,scale="none")


#最好。控制是否对行列进行聚类Colv=FALSE
heatmap.2(selected, col=greenred(200), scale="column", ColSideColors=patientcolors,
          key=TRUE, symkey=FALSE, density.info="none", trace="none",Colv=FALSE)
heatmap.2(selected, col=greenred(200), scale="column", ColSideColors=patientcolors,
          key=TRUE, symkey=FALSE, density.info="none", trace="none")




heatmap.2(selected, col=topo.colors(200), scale="none", ColSideColors=patientcolors,
          key=TRUE, symkey=FALSE, density.info="none", trace="none")

heatmap.2(selected, col=redgreen(175), scale="row", ColSideColors=patientcolors,
          key=TRUE, symkey=FALSE, density.info="none", trace="none",cexRow=0.5)




########################################
#使用pheatmap包作图
#scale是什么意思？
#按列表转化色彩。最好
pheatmap(selected, color=colorRampPalette(c("green","black","red"))(50), cluster_cols=FALSE,
         fontsize_row = 8,scale="column", border_color = NA)

#原始值
pheatmap(selected, color=colorRampPalette(c("green","black","red"))(50), cluster_cols=FALSE,
         fontsize_row = 10,scale="none", border_color = NA)

#没法看
pheatmap(selected, color=colorRampPalette(c("green","black","red"))(50), cluster_cols=FALSE,
         fontsize_row = 10,scale="row", border_color = NA)



#What about other microarray data?
#Well, I have also documented how you can load NCBI GEO SOFT files into R as a BioConductor expression set object. As long as you can get your data into R as a matrix or data frame, converting it into an exprSet shouldn't be too hard.


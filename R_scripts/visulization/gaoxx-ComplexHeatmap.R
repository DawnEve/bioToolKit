#画热图
# v0.3

library(ComplexHeatmap)
library(circlize)
setwd("/home/wangjl/web/docs/docs")


see=function(df){
  print(dim(df))
  print(df[1:3,])
}

#read data
mat1=read.table("self_made_data.txt",sep="\t",header=T,row.names=1)
mat2=read.table("self_made_data2.txt",sep="\t",header=T,row.names=1)
mat3=read.table("self_made_data3.txt",sep="\t",header=T,row.names=1)
see(mat1) #7 9
#
mat=rbind(mat1,mat2,mat3)
see(mat) #21 9
#
rt = as.matrix(mat)
is.matrix(rt)
#colors = structure(circlize::rand_color(7), names = c("1", "2", "3", "4","5","6","7"))
colors = colorRamp2(c(-0.4,-0.01,0,0.01,0.5),
                    c("blue", "light blue","white","orange", "brown"))
p1 <- Heatmap(rt, 
              col = colors,
              show_heatmap_legend = T, name = "p-value", #显示图例，图例标题
              cluster_rows = FALSE, cluster_columns = FALSE,#不聚类行和列
              #
              rect_gp = gpar(col="white",lwd=1), #每个最小方框的描边
              #width = unit(10, "cm"), height = unit(10, "cm"), #尺寸自动好了
              #
              row_names_side = "left",column_names_side = "top",#xy坐标显示位置
              #
              #row_title = expression(PTEN^MUT/SDH^WT), #添加左侧标题，只有一个
              row_split = c( rep("A",7),rep("B",7),rep("C",7) ), #添加左侧标题3个，表明来源
              #row_split = c( rep(expression(PTEN^MUT/SDH^WT),7), #显示表达式会报错
              #               rep(expression(PTEN^WT/SDH^MUT),7),
              #               rep(expression(PTEN^WT/SDH^WT),7) )
              #为row标注(y轴刻度)设置不同的颜色和字号
              row_title_gp = gpar(col = c("green", "orange", "purple"), font =c(20,20) ),
              row_names_gp = gpar(col = c("green", "orange", "purple"), fontsize = c(10, 10, 10)),
              column_title_gp = gpar(fontsize = 10),
              
              row_gap = unit(5, "mm") #三个文件之间的距离
);p1
library(Cairo)
CairoPDF(file='test3.pdf',width=8,height=5)
p1
dev.off()

## end
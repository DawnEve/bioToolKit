# 输入vntr的矩阵数据  
#http://bbs.pinggu.org/thread-772338-1-1.html
vntr=read.csv('clipboard',sep="\t",header=T)
vntr2=vntr[,-1] #去掉第一列 
#rownames(vntr2)=vntr2[,1]
head(vntr2)


######################## 
#数据过滤部分可以忽略了  
n=sum(is.na(vntr))#输出缺失值个数    
n
#缺失值替换为0
vntr[is.na(vntr)]=0
#如果是？?"",替换???0
vntr[vntr=="???"]=0
vntr[vntr=="?"]=0
vntr[vntr==""]=0
vntr[vntr==" "]=0
write.csv(vntr,file="c:\\vntr_filterd.txt")

n=sum(is.na(vntr))#输出缺失值个数  
####################


vntr3=data.matrix(vntr2)
heatmap(vntr3)



boxplot(vntr3,horizontal=F)#绘制水平箱形图  
########
library("pheatmap")
library("RColorBrewer")
pheatmap(vntr3, color=col.pal <- brewer.pal(9,"Blues"),
         #colorRampPalette(c("blue","black","red"))(50), 
         #cluster_cols=FALSE,
         fontsize_row = 10,scale="none", border_color = NA)
#









##########
# http://rstudio-pubs-static.s3.amazonaws.com/1876_df0bf890dd54461f98719b461d987c3d.html
# Visualizing Dendrograms in R
#

vntr_data=read.csv('clipboard',sep="\t",header=T)
vntr=vntr_data[,-1]
row.names(vntr)=vntr_data[,1]
View(vntr)

# prepare hierarchical cluster
hc = hclust(dist(vntr))
# very simple dendrogram
plot(hc)


# Alternative dendrograms
# using dendrogram objects
hcd = as.dendrogram(hc)
# alternative way to get a dendrogram
plot(hcd)

# using dendrogram objects
# plot(hcd, type = "triangle")


#确定切割位点 

tmp=cut(hcd, h = 23.5)$lower #找5类分割点
#21 8
# 22 6 -22.5 
#23 6 
#23.5 5
#24 4

# Zooming-in on dendrograms
op = par(mfrow = c(2, 1))
plot(cut(hcd, h = 23.5)$upper, main = "Upper tree of cut at h=23.5")
plot(cut(hcd, h = 23.5)$lower[[1]], main = "1st branch of lower tree with cut at h=23.5")

plot(cut(hcd, h = 23.5)$lower[[2]], main = "2nd branch of lower tree with cut at h=23.5")
plot(cut(hcd, h = 23.5)$lower[[3]], main = "3rd branch of lower tree with cut at h=23.5")

plot(cut(hcd, h = 23.5)$lower[[4]], main = "4th branch of lower tree with cut at h=23.5")
plot(cut(hcd, h = 23.5)$lower[[5]], main = "5th branch of lower tree with cut at h=23.5")




##
## Phylogenetic trees
# load package ape; remember to install it: install.packages('ape')
library(ape)
# plot basic tree
plot(as.phylo(hc), cex = 0.9, label.offset = 1)

# unrooted
plot(as.phylo(hc), type = "unrooted")

# fan
plot(as.phylo(hc), type = "fan")

# radial
plot(as.phylo(hc), type = "radial")




##############
# Color in leaves
# install.packages('sparcl')
library(sparcl)
# colors the leaves of a dendrogram
y = cutree(hc, 23.5)
# ColorDendrogram(hc, y = y, labels = names(y), branchlength = 2)
ColorDendrogram(hc, y = y, labels = NULL, branchlength = 7)


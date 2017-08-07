
# 1.在excel中整理数据，基本格式如下。
#TYPE	TIGIT	PDCD1
#Normal	0.34962296	0.25532365
#Normal	0.29923558	0.65144324
#Tumor	-0.10962081	-0.006217718
#Tumor	-0.30285764	0.23765111
#Tumor	-0.00884223	-0.16199994

#2.从excel中复制数据，在R中逐行执行如下代码

genes=read.csv('clipboard',sep="\t",header=T)


#############
library("lattice")
#图1 点图
View(genes)
xyplot(TIGIT~TYPE,genes,main="TIGIT")
xyplot(PDCD1~TYPE,genes,main="PDCD1")



#分隔画布
par(cex = 0.6);
par(mar = c(3,3,2,1))
par(mfrow=c(1,2)) 

hist(genes$TIGIT,n=100)
hist(genes$PDCD1,n=100)


#################
#按照什么标准分高低：中位数？平均数？

par(mfrow=c(1,2)) 

boxplot(TIGIT ~ TYPE, genes, outpch = NA,par(lwd=1),main="TIGIT",ylab="expression") 
# (Setting 'outpch = NA' avoids plotting outliers.) 
stripchart(TIGIT ~ TYPE, genes, 
           vertical = TRUE, method = "jitter", 
           pch = 21, col = "maroon", bg = "bisque", 
           add = TRUE) 



boxplot(PDCD1 ~ TYPE, genes, outpch = NA,par(lwd=1),main="PDCD1",ylab="expression") 
# (Setting 'outpch = NA' avoids plotting outliers.) 
stripchart(PDCD1 ~ TYPE, genes, 
           vertical = TRUE, method = "jitter", 
           pch = 21, col = "maroon", bg = "bisque", 
           add = TRUE) 
  
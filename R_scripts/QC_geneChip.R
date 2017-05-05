#
source("http://bioconductor.org/biocLite.R")

setwd("D:/R_code/GSE1323")
getwd()

#######
library(simpleaffy)
celfiles <- read.affy(covdesc="phenodata.txt", path="./")
#查看文件
celfiles 

#3.去掉cel后缀
sampleNames(celfiles)=gsub(".CEL$","",sampleNames(celfiles))
sampleNames(celfiles)


#芯片质控总览图
data.qc=qc(celfiles)
plot(data.qc)



#########################
library("affyPLM")
#打印四方格 - 数据集权重残差图
celfiles.qc <- fitPLM(celfiles)

par(mfrow=c(2,2),mar=c(1,1,2,1), mgp=c(2,.7,0), tck=-.01)#下、左、上、右

image(celfiles[,1]) #第一张芯片的原始图
image(celfiles.qc, which=1, main="Weights", type="weights") #权重 
image(celfiles.qc, which=1, main="Residuals", type="resids") #残差 
image(celfiles.qc, which=1, main="Residuals.sign", type="sign.resids") #残差符号图 



#########################
par(mfrow=c(1,2),mar=c(6,3,2,1))#下、左、上、右

#rle boxplot
RLE(celfiles.qc, main="RLE", las=3)

#nuse boxplot
NUSE(celfiles.qc, main="NUSE", las=3)




#####################################
#RNA降解曲线图
library(affy)
library(RColorBrewer)
#获取降数据
data.deg=AffyRNAdeg(celfiles)

#载入一组颜色
totalNumber=length(celfiles@phenoData@data$sample)
totalNumber
colors=brewer.pal(totalNumber,"Set2")


#绘制RNA降解图
par(mfrow=c(1,1),mar=c(5,4,2,1))#下、左、上、右
plotAffyRNAdeg(data.deg, col=colors)
#左上角加上图注
legend("topleft",rownames(pData(celfiles)),col=colors,lwd=1,inset=0.05,cex=0.5)
#从CLL数据集中去除质量不好的样品，CLL1，CLL10，CLL13
#celfiles=celfiles[,-match(c("CLL10.CEL","CLL1.CEL","CLL13.CEL"),sampleNames(celfiles))]





#####################################
# 聚类分析图

# 标准化之后再聚类才有意义
celfiles.mas5 <- mas5(celfiles,sc = 1000)
celfiles.mas5


celfiles.rma <- rma(celfiles)
celfiles.rma

celfiles.gcrma <- gcrma(celfiles) # gcRMA标准化
celfiles.gcrma

#Quality control checks 质量控制检查
#颜色库
library(RColorBrewer)
cols <- brewer.pal(6, "Set1")


#直方图
library(affyPLM)
par(mfrow=c(2,2),mar=c(6,2,2,1))

hist(celfiles, col=cols,main="origin")
hist(celfiles.mas5, col=cols,main="mas5")
hist(celfiles.rma, col=cols,main="rma")
hist(celfiles.gcrma, col=cols,main="gcrma")


#箱线图
par(mfrow=c(2,2),mar=c(6,2,2,1))
boxplot(celfiles, col=cols,main="origin", notch=T, outline=FALSE, las=2)
#boxplot(celfiles.mas5, col=cols, main="mas5")
#,notch=T, outline=FALSE, las=2
boxplot(celfiles.mas5, col=cols,main="mas5",notch=T, outline=FALSE, las=2)
boxplot(celfiles.rma, col=cols,main="rma",notch=T, outline=FALSE, las=2)
boxplot(celfiles.gcrma, col=cols,main="gcrma",notch=T, outline=FALSE, las=2)


#探索更多样式
#boxplot(celfiles, col=cols,main="origin",notch=T, las=0) #y坐标竖着
#boxplot(celfiles, col=cols,main="origin",notch=T, las=1) #x注释横着，y坐标|
#boxplot(celfiles, col=cols,main="origin",notch=T, las=2) #x注释竖着
#boxplot(celfiles, col=cols,main="origin",notch=T, las=3)


#用gcrma标准化后的数据聚类
eset <- exprs(celfiles.gcrma)

#----11
# cluster Method 1
distance <- dist(t(eset),method="maximum")
clusters <- hclust(distance)

#par(mfrow=c(1,1),mar=c(6,5,2,1))
#plot(clusters)

#----12
# cluster Method 2
#Person相关系数
person_cor = cor(eset)
#get the 下三角矩阵 
dist.lower=as.dist(1-person_cor)
#cluster
hc=hclust(dist.lower,"ave")
#plot
#par(mfrow=c(1,1),mar=c(6,5,2,1))
#plot(hc)

#----21
#用mas5标准化后的数据聚类
eset2 <- exprs(celfiles.mas5)

# cluster Method 1
distance2 <- dist(t(eset2),method="maximum")
clusters2 <- hclust(distance2)

#----22
person_cor2 = cor(eset2)
#get the 下三角矩阵 
dist.lower=as.dist(1-person_cor2)
#cluster
hc2=hclust(dist.lower,"ave")

#---------------画图
par(mfrow=c(2,2),mar=c(6,5,2,1))
plot(clusters, main="gcrma|dist")
plot(hc, main="gcrma|cor")
plot(clusters2, main="mas5|dist")
plot(hc2, main="mas5|dist")



#######################
# 主成分分析
library("affycoretools")
samplenames=sub(pattern="\\.CEL",replacement="",colnames(eset))
samplenames

#--gcrma方法标准化后PCA
sampleTypes <- celfiles.gcrma$Target
sampleTypes
groups <- as.factor(sampleTypes)
#groups=samples

#--mas5方法标准化后PCA
sampleTypes2 <- celfiles.mas5$Target
sampleTypes2
groups2 <- as.factor(sampleTypes2)
#groups=samples


# plot PCA
par(mfrow=c(1,2),mar=c(6,5,2,1))
#?报错 Please give the x-coordinate for a legend.
plotPCA(eset,addtext=samplenames,groups=groups,groupnames=levels(groups), x.coord = "PC1")
#?报错 Please give the x-coordinate for a legend.
plotPCA(eset2,addtext=samplenames,groups=groups2,groupnames=levels(groups2))
#todo


#######################################
#热力图，比较丑
heatmap(exprs(celfiles)[1:5000,])






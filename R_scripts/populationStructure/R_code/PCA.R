###################
#主成分分析
# http://blog.csdn.net/wangyajie_11/article/details/53785528
###################

#step1 load data
data <- read.csv('D:/R_data/liver.txt', sep="\t", header = T)
#SGPT INDEX ZnT AFP

#相关性
#http://blog.sina.com.cn/s/blog_9de40b570102vx8r.html
cor(data, use='complete.obs') #计算相关系数
pairs(data) #画图
#cor.test（）进行了Pearson相关性检验
cor.test(data$SGPT,data$INDEX)

#step2 PCA
#注：cor = T的意思是用相关系数进行主成分分析。
data.pr <- princomp(data, cor = T)

## Formula interface
#princomp(~ ., data = data, cor = TRUE)

#step3 view
summary(data.pr, loadings = T)
loadings(data.pr)  # note that blank entries are small but not zero
## The signs of the columns are arbitrary
plot(data.pr) #可视化
biplot(data.pr) #???
data$originlines(c(-10,10),c(0,0))
lines(c(0,0),c(-10,10))
#选择累计贡献大于80%的最大的几个主成分

#step4.画主成分的碎石图并预测
screeplot(data.pr,type="lines")
temp<-predict(data.pr)
temp
plot(temp[,1:3])  



#step5 计算得到各个样本主成分的数据
#接下来，在得到主成分的基础上进行回归也好进行聚类也好，
#就不再使用原始的X1、X2、X3和X4了，而是使用主成分的数据。
#但现在还没有各个样本的主成分的数据，所以，最后一步就是得到各个样本主成分的数据。

pca_data <- predict(data.pr)

pca_data #只保留前两列主成分。

plot(pca_data[,1], pca_data[,2], pca_data[,3])

tab=pca_data

#如果知道原始数据的分类信息，比如身高、体重、分数等信息，据此分类
data2$origin=c("Beijing","Beijing","Hebei","Xinjiang",  "Hebei","Guangzhou","Guangzhou","Xinjiang", "Xinjiang","Hebei",
             "Hebei","Guangzhou",  "Hebei","Hebei","Hebei","Hebei",  "Hebei","Beijing","Guangzhou","Hebei")
col.list <- c("gray", "blue", "green", "red", "orange", "yellow")
groups=as.factor(data2$origin) 

par(mfrow=c(1,2))   #分割画布为1行2列
plot(tab[,1], tab[,2], col=col.list[as.integer(groups)],cex=1.2,pch=20, xlab="eigenvector 2", ylab="eigenvector 1") 
legend("topleft", legend=levels(groups), cex=1,pch=20, col=col.list)

biplot(data.pr)
#legend("topleft", legend=levels(groups), cex=1,pch=20, col=1:nlevels(groups))

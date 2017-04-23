
genes=read.csv('clipboard',sep="\t")

#子集
subs=genes[which(genes$CD3D>0 & genes$CD8A),]


#############
library("lattice")
#图1 点图
xyplot(CD103~stage,genes,main="CD103")


View(genes)
xyplot(CD3D~stage,genes)
xyplot(CD103~stage,genes)
xyplot(CD8A~stage,genes)
xyplot(PDL1~stage,genes)
xyplot(PD1~stage,genes)

#图2 按照另一个变量分隔的多个图
CD3_ <- equal.count(genes$CD3D, number=4, overlap=0)
xyplot(CD103 ~ stage | CD3_, data = genes)
#############

#图3 二维图
# z-score和表达量怎么换算？
x=genes$CD3D
y=genes$CD8A
plot(x,y,xlab="CD3D",ylab="CD8A",main="z-score plot") #没法看
plot(10**x,10**y) 
plot(log10(x+10),log10(y+10),col="red")
#######################

#分隔画布
par(cex = 0.6);
par(mar = c(3,3,2,1))
par(mfrow=c(3,2)) 

hist(genes$CD3D,n=100)
hist(genes$CD8A,n=100)
hist(genes$CD103,n=100)
hist(genes$PD1,n=100)
hist(genes$PDL1,n=100)
hist(genes$GAPDH,n=100)

#################
#按照什么标准分高低：中位数？平均数？
#subs1=genes[genes$CD3D>median(genes$CD3D),] #46
#subs2=subs1[subs1$CD8A>median(genes$CD8A),] #40
title="CD103 in CD3-CD8-"
subs2=genes[which(genes$CD3D<median(genes$CD3D) & genes$CD8A<median(genes$CD8A)),]
par(mfrow=c(1,2)) 

#1
hist(subs2$CD103,n=100,main=title)

#2
boxplot(CD103 ~ stage, subs2, outpch = NA,par(lwd=1),main=title,ylab="z-score") 
# (Setting 'outpch = NA' avoids plotting outliers.) 
stripchart(CD103 ~ stage, subs2, 
           vertical = TRUE, method = "jitter", 
           pch = 21, col = "maroon", bg = "bisque", 
           add = TRUE) 







data=genes
#http://r.789695.n4.nabble.com/overlap-dot-plots-with-box-plots-td2134530.html
boxplot(CD103 ~ stage, data, outpch = NA,par(lwd=1),main="CD103",ylab="z-score") 
# (Setting 'outpch = NA' avoids plotting outliers.) 
stripchart(CD103 ~ stage, data, 
           vertical = TRUE, method = "jitter", 
           pch = 21, col = "maroon", bg = "bisque", 
           add = TRUE) 

################
#for CD8
boxplot(CD8A ~ stage, data, outpch = NA,par(lwd=1),main="CD8A",ylab="z-score") 
# (Setting 'outpch = NA' avoids plotting outliers.) 
stripchart(CD8A ~ stage, data, 
           vertical = TRUE, method = "jitter", 
           pch = 21, col = "maroon", bg = "bisque", 
           add = TRUE) 

################
#for CD3D
boxplot(CD3D ~ stage, data, outpch = NA,par(lwd=1),main="CD3D",ylab="z-score") 
# (Setting 'outpch = NA' avoids plotting outliers.) 
stripchart(CD3D ~ stage, data, 
           vertical = TRUE, method = "jitter", 
           pch = 21, col = "maroon", bg = "bisque", 
           add = TRUE) 

################
#for PDL1
boxplot(PDL1 ~ stage, data, outpch = NA,par(lwd=1),main="PDL1",ylab="z-score") 
# (Setting 'outpch = NA' avoids plotting outliers.) 
stripchart(PDL1 ~ stage, data, 
           vertical = TRUE, method = "jitter", 
           pch = 21, col = "maroon", bg = "bisque", 
           add = TRUE) 

################
#for PD1
boxplot(PD1 ~ stage, data, outpch = NA,par(lwd=1),main="PD1",ylab="z-score") 
# (Setting 'outpch = NA' avoids plotting outliers.) 
stripchart(PD1 ~ stage, data, 
           vertical = TRUE, method = "jitter", 
           pch = 21, col = "maroon", bg = "bisque", 
           add = TRUE) 
################
#for CD4
boxplot(CD4 ~ stage, data, outpch = NA,par(lwd=1),main="CD4",ylab="z-score") 
# (Setting 'outpch = NA' avoids plotting outliers.) 
stripchart(CD4 ~ stage, data, 
           vertical = TRUE, method = "jitter", 
           pch = 21, col = "maroon", bg = "bisque", 
           add = TRUE) 
################
#for GAPDH
boxplot(GAPDH ~ stage, data, outpch = NA,par(lwd=1),main="GAPDH",ylab="z-score") 
# (Setting 'outpch = NA' avoids plotting outliers.) 
stripchart(GAPDH ~ stage, data, 
           vertical = TRUE, method = "jitter", 
           pch = 21, col = "maroon", bg = "bisque", 
           add = TRUE) 






#置换检验
a<-c(24,43,58,67,61,44,67,49,59,52,62,50,42,43,65,26,33,41,19,54,42,20,17,60,37,42,55,28) 
group<-factor(c(rep("A",12),rep("B",16))) 
data<-data.frame(group,a) 
find.mean<-function(x){ mean(x[group=="A",2])-mean(x[group=="B",2]) } 
results<-replicate(999,find.mean(data.frame(group,sample(data[,2])))) 
p.value<-length(results[results>mean(data[group=="A",2])-mean(data[group=="B",2])])/1000
hist(results,breaks=20,prob=TRUE)
lines(density(results))







#############
# 按照c变量，画a-b二维点图。
  Depth <- equal.count(quakes$depth, number=8, overlap=.1)
  xyplot(lat ~ long | Depth, data = quakes)
  update(trellis.last.object(),
         strip = strip.custom(strip.names = TRUE, strip.levels = TRUE),
         par.strip.text = list(cex = 0.75),
         aspect = "iso")
  
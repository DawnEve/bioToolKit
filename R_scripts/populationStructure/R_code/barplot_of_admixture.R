###############
#可视化admixture数据
setwd("D:\\R_data")
tbl=read.table("hapmap3.3.Q")
barplot(t(as.matrix(tbl)),col=rainbow(3), 
        space=0, #条形间距
        xlab="Individual #", ylab="Ancestry",border=NA)


#############

#从剪切板读取数据
tbl2=read.table('clipboard',header=T)
#画条状图
barplot(t(as.matrix(tbl2))[-1,],col=rainbow(4), 
  #names.arg=(paste(substr(FirstName,1,1),".",LastName)),   #设定横坐标名�?
  names.arg=tbl2$province,
  space=0, #条形间距
  xlab="Individual #", ylab="Ancestry",border=NA)
#axis(las=3,labels=tbl2$province)






#############
#example
attach(mtcars)
opar<-par(no.readonly=TRUE)
par(mfrow=c(2,2))
plot(wt,mpg,main="Scatterplot of wt vs.mpg")
plot(wt,disp,main="Scatterplot of disp")
hist(wt,main="Histogram of wt")
boxplot(wt,main="Boxplot of wt")
par(opar)


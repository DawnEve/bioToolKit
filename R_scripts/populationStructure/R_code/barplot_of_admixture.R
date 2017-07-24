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
  #names.arg=(paste(substr(FirstName,1,1),".",LastName)),   #设定横坐标名称
  names.arg=tbl2$province,
  space=0, #条形间距
  xlab="Individual #", ylab="Ancestry",border=NA)
#axis(las=3,labels=tbl2$province)

#refer
#http://blog.163.com/imnoqiao@126/blog/static/35265851201611633153720/
#http://blog.sina.com.cn/s/blog_670445240102uwo3.html
#axis(1, lab=(t(as.matrix(tbl2))[1,]), cex.axis = 1.2)
#0.098 0.072 0.109 0.135 0.115 0.103 0.103 0.101 0.103 0.061
par(mfrow=c(1,2))

data=read.table('clipboard', sep="\t")
plot(data,type="o",xlab="K",ylab="Ln P(D)")

data=read.table('clipboard', sep="\t")
plot(data,type="o",xlab="K",ylab="delta[Ln P(D)]")








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


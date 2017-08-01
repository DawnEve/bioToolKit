#break_axis 坐标轴打断的图怎么画？
#http://www.dataguru.cn/article-4827-1.html
# to do

#R当中的坐标中断一般都使用plotrix库中的axis.break(), 
#gap.plot(), gap.barplot(), gap.boxplot()等几个函数来实现，例：

#install.packages("plotrix")
library(plotrix)
opar=par(mfrow=c(3,2)) #3行2列
plot(sample(5:7,20,replace=T),main="Axis break test",ylim=c(2,8))
axis.break(axis=2,breakpos=2.5,style="gap")
axis.break(axis=2,breakpos=3.5,style="slash")
axis.break(axis=2,breakpos=4.5,style="zigzag")
#fig2
twogrp<-c(rnorm(5)+4,rnorm(5)+20,rnorm(5)+5,rnorm(5)+22)
gpcol<-c(2,2,2,2,2,3,3,3,3,3,4,4,4,4,4,5,5,5,5,5)
gap.plot(twogrp,gap=c(8,16),xlab="Index",ylab="Group values",
         main="Gap on Y axis",col=gpcol)
gap.plot(twogrp,rnorm(20),gap=c(8,16),gap.axis="x",xlab="X values",
         xtics=c(4,7,17,20),ylab="Y values",main="Gap on X axis with added lines")
gap.plot(twogrp,gap=c(8,16,25,35),
         xlab="X values",ylab="Y values",xlim=c(1,30),ylim=c(0,42),
         main="Test two gap plot with the lot",xtics=seq(0,30,by=5),
         ytics=c(4,6,18,20,22,38,40,42),
         lty=c(rep(1,10),rep(2,10)),
         pch=c(rep(2,10),rep(3,10)),
         col=c(rep(2,10),rep(3,10)),
         type="b")
#?为什么报警告？

#fig3
gap.plot(21:30,rnorm(10)+40,gap=c(8,16,25,35),add=TRUE,
         lty=rep(3,10),col=rep(4,10),type="l")

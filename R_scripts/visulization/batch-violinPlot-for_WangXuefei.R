###############
#模仿 张泽民 批量基因表达图，没有完全实现，可能还需要AI拼接
###############

library(vioplot)
m1=min(iris[,1:4]); m2=max(iris[,1:4]) #极值
#基本画图函数，依赖于2个极值
vioDraw=function(data,col){
  plot(NA,type="n",xlim=c(0.5,1.5),ylim=c(m1,m2),
       axes=FALSE,ann=FALSE)
  vioplot(data, col=col,
          #col="gold",
          border = NA, #violin边框
          drawRect=F, #不要violin中间的box
          add=T)
  box(col="white") #覆盖边框
}

#测试颜色条（清除后再画）
n=1000
mycolors = colorRampPalette(c("yellow", "red","black"))(n)
barplot(rep(1,times=n),col=mycolors,border=mycolors,axes=FALSE); #box()
#自己画标度 ***
#或者用image函数画


# 画热图（清除后再画）
image(x=0:n, y=1, matrix(0:n),  
      #breaks=n+1,
      col=mycolors, 
      #axes = F, #下面自定义坐标轴
      cex = 1.5,
      yaxt="n", xaxt="n",
      mgp=c(0,1,0),
      xlab = "", ylab = "")
text(x=-30,y=1,labels=c("Exp"),xpd=T)
axis(1,at=seq(0,n,length.out=8), #seq(0,n,by=200),
     labels=c(0,2,4,6,8,10,12,14),
     cex=2,
     col.axis="black",las=0) 
#自定义坐标轴2左侧，las=0垂直于轴，2平行于轴



#画一堆violin图
par(oma=c(5,5,1,1))
par(mfrow=c(8,9),mar=c(0,0,0,0))
for(ii in 1:72){
  #计算出颜色
  i=ii%%4+1
  col=mycolors[round((mean(iris[,i])-m1)/(m2-m1)*1000,0)]
  #画图
  vioDraw(iris[,i],col)
}


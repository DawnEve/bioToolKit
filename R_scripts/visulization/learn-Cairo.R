#Cairo
#https://www.cnblogs.com/payton/p/5391680.html
#R语言不仅在统计分析，数据挖掘领域，计算能力强大。在数据可视化上，也不逊于昂贵的商业。当然，背后离不开各种开源软件包的支持，Cairo就是这样一个用于矢量图形处理的类库。
# Cairo可以创建高质量的矢量图形(PDF, PostScript, SVG) 和 位图(PNG, JPEG, TIFF)，同时支持在后台程序中高质量渲染！
# 本文将介绍，Cairo在R语言中的使用。
#特别是原生画图命令失效的时候。
#莫名其妙不能使用X11生成图片, 只好使用图形渲染库Cairo。
#> plot(c(1,2,3))
#Error in RStudioGD() : 
#  Shadow graphics device error: r error 4 (R code execution error)


#1.安装
# sudo apt-get install libcairo2-dev
# sudo apt-get install libxt-dev
#chooseBioCmirror() #选择最近的镜像
#install.packages("Cairo")
library(Cairo)
Cairo.capabilities()
#png   jpeg   tiff    pdf    svg     ps    x11    win raster 
#TRUE   TRUE  FALSE   TRUE   TRUE   TRUE   TRUE  FALSE   TRUE


#2.使用：Cairo使用起来非常简单，和基础包grDevices中的函数对应。
# CairoPNG: 对应grDevices:png()
# CairoJPEG: 对应grDevices:jpeg()
# CairoTIFF: 对应grDevices:tiff()
# CairoSVG: 对应grDevices:svg()
# CairoPDF: 对应grDevices:pdf()


#3.实例
#数据
x<-rnorm(6000)
y<-rnorm(6000)

#开始画图
CairoPDF(file="Cairo4.pdf",width=10,height=10)

#画图语句
plot(x,y,col="#ff000018",pch=19,cex=2,main = "Cairo")

#结束画图
dev.off()


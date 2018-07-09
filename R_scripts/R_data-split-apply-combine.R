#R_data-split-apply-combine.R
#https://www.imooc.com/article/26186
#aggregate(formula, data, FUN,subset,na.action=na.omit)


#################
#测试图
plot( speed ~ dist, data = cars)



#################
#保存到文件
library(ggplot2)
head(diamonds) #使用ggplot2作为测试数据

data1=diamonds

# Start the graphics device
pdf(file = "MyAwsomeFigure.pdf", useDingbats = FALSE)

# Do some plotting
par( mai = c(1,2,1,2), lwd = 96/72, pch = 16, ps = 8 )
# par( mai = c(1,2,1,2), lwd = 1.5, pch = 16, ps = 15 ) #加粗版
#mai: 设置空白。 A numerical vector of the form c(bottom, left, top, right) 
#which gives the margin size specified in inches.
#
#mar: 设置空白行数。 A numerical vector of the form c(bottom, left, top, right) 
#which gives the number of lines of margin to be specified 
#on the four sides of the plot. The default is c(5, 4, 4, 2) + 0.1.

#lwd 线条宽度
#By default, pdf measures fonts in points (1/72 in.), but everything else in 1/96 in.
#pch:点的类型。
#ps: integer; the point size of text (but not symbols).


#plot( value ~ group, data = diamonds)#,...
plot( price ~ cut, data = data1, las=1)
      
# Close the graphics device
dev.off()

getwd() #查看生成文件的位置




##############
x=cars$speed
y=cars$dist

library(Cairo)
#pdf(file="plot4.pdf",width=640,height=480)
pdf(file="plot4.pdf")
plot(x,y,col="#ff000018",pch=19,cex=2,main = "plot")
dev.off()

#CairoPDF(file="Cairo4.pdf",width=640,height=480)
CairoPDF(file="Cairo4.pdf")
plot(x,y,col="#ff000018",pch=19,cex=2,main = "Cairo")
dev.off()


##########
CairoPDF(file="Cairo5.pdf",width=9, height=9)
plot( price ~ cut, data = diamonds,las=1, cex=0.5)
#las=3, las表示坐标刻度值文字方向，las=0表示文字方向与坐标轴平行，
#1表示始终为水平方向，2表示与坐标轴垂直，3表示终为垂直方向。
dev.off()


CairoPDF(file="Cairo6.pdf")
p<-ggplot(diamonds,aes(x=cut, y=price))+
  geom_boxplot()+
  theme(axis.text.x = element_text(angle = 45, hjust = 0.5, vjust = 0.5))
p = p+labs(x="Cut status",y='Price(RMB)') #修改横轴坐标
p
dev.off()

#字体字号等参数设置
#https://blog.csdn.net/weixin_40628687/article/details/79254791

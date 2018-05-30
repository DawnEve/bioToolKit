#learn ggplot2
# http://ggplot2.org
#docs: http://ggplot2.tidyverse.org/reference/
#ggplot2作者出的测试题： http://stat405.had.co.nz/drills/ggplot2.html

library(ggplot2) # http://stackoverflow.com/tags/ggplot2
# str(mpg)
p=ggplot(data=mpg, mapping=aes(x=cty,y=hwy))
p+geom_point() #pic


#P是什么？
summary(p)
# data: manufacturer, model, displ, year, cyl, trans, drv, cty, hwy, fl, class [234x11]
# mapping:  x = cty, y = hwy
# faceting: <ggproto object: Class FacetNull, Facet>

summary(p+geom_point())
# data: manufacturer, model, displ, year, cyl, trans, drv, cty, hwy, fl, class [234x11]
# mapping:  x = cty, y = hwy
# faceting: <ggproto object: Class FacetNull, Facet>
#
# geom_point: na.rm = FALSE
# stat_identity: na.rm = FALSE
# position_identity 


#将年份映射到[颜色属性]
p=ggplot(mpg, aes(x=cty,y=hwy,color=factor(year)))
p+geom_point()


#增加平滑曲线
p+geom_point() + stat_smooth()


#想画出一条总的趋势曲线，而点的颜色还是按照年份区别呢？
p=ggplot(mpg,aes(x=cty,y=hwy))
p+geom_point(aes(color=factor(year))) + stat_smooth() # 

##################
# 和以上等价的绘图方式
# 绘图方式2： 
p2=ggplot()+
  geom_point(data=mpg,aes(x=cty,y=hwy,color=factor(year)))+
  stat_smooth(data=mpg,aes(x=cty,y=hwy)) #注意 data= 不能省略
p2 #或者 print(p2)
print(p2)

# 此时除了底层画布外，有两个图层，分别定义了geom和 stat。
summary(p2)
#geom_point: na.rm = FALSE
#geom_smooth: na.rm = FALSE





#用标度来修改颜色取值
p=ggplot(mpg,aes(x=cty,y=hwy))
p + geom_point(aes(colour=factor(year)))+
  stat_smooth()+
  scale_color_manual(values =c('black','red'))


#将排量映射到散点大小
p=ggplot(mpg,aes(x=cty,y=hwy))
p+geom_point(aes(color=factor(year),size=displ))+
  stat_smooth()+
  scale_color_manual(values=c("blue2","red4"))

#添加不透明度 alpha
p=ggplot(mpg,aes(x=cty,y=hwy))
p+geom_point(aes(color=factor(year), size=displ), alpha=0.5) + #不加jitter则点会重叠
  stat_smooth()

p+geom_point(aes(color=factor(year), size=displ), alpha=0.5, position="jitter") +
  stat_smooth()

p+geom_point(aes(color=factor(year), size=displ), alpha=0.5, position="jitter") +
  stat_smooth()+
  scale_color_manual(values=c("blue2","red4"))
  scale_size_continuous(range=c(4,10))




# 用坐标控制图形显示的范围
p=ggplot(mpg,aes(x=cty,y=hwy))
p+geom_point(aes(color=factor(year),size=displ),
             alpha=0.5, position="jitter")+
  stat_smooth()+
  #scale_color_manual(values=c("blue2","red4"))+
  scale_size_continuous(range=c(4,10))+
  coord_cartesian(xlim=c(15,25),ylim=c(15,40))
  
  
#利用facet分别显示不同年份的数据
p+geom_point(aes(color=class,size=displ),
             alpha=0.5, position="jitter")+
  stat_smooth()+
  scale_size_continuous(range=c(4,10))+
  facet_wrap(~year,ncol=2)

#增加图名并精细修改图例
p=ggplot(mpg, aes(x=cty,y=hwy))
p+geom_point(aes(color=class,size=displ),
             alpha=0.5, position = "jitter")+
  stat_smooth()+
  scale_size_continuous(range=c(4,10))+
  facet_wrap(~year, ncol=1)+
  labs(title="T汽车油耗与型号", y="y每加仑高速公路行驶距离", x="x每加仑城市公路行驶距离")+
  guides(size=guide_legend(title='排量'), color=guide_legend(title='车型',override.aes = list(size=5)))




###########################
# 直方图 his (横坐标是连续的)
###########################
g <- ggplot(mpg,aes(x=hwy))
g + geom_histogram()

#直方图的几何对象中内置有默认的统计变换
summary(g + geom_histogram())
#data: manufacturer, model, displ, year, cyl, trans, drv, cty, hwy, fl, class [234x11]
#mapping:  x = hwy
#faceting: <ggproto object: Class FacetNull, Facet>
#
#stat_bin


#设置bin宽度
g + geom_histogram(binwidth = 1)
g + geom_histogram(binwidth = 3)

#设置填充颜色
g+geom_histogram(aes(fill=factor(year)), alpha=0.3, color='black') #y为统计个数
g+geom_histogram(aes(fill=factor(year),y=..density..), alpha=0.3, color='black') #y=..density..表示把y设置为频率

#增加密度曲线
g+geom_histogram(aes(fill=factor(year),y=..density..), alpha=0.3, color='black') +
  stat_density(geom='line', position='identity',size=1.5,aes(color=factor(year)))

#分面显示 每年统计结果
g+geom_histogram(aes(fill=factor(year),y=..density..), alpha=0.3, color='black') +
  stat_density(geom='line', position='identity',size=1.5,aes(color=factor(year)))+
  facet_wrap(~year,ncol=1)




###########################
# 条形图 bar (横坐标是不连续的)
###########################
b=ggplot(mpg, aes(x=class))
b+geom_bar()

#添加 class 图例，并上色
class2=mpg$class
class2=reorder(class2,class2,length) #这个reorder函数真是统计神器
b=ggplot(mpg,aes(x=class2))
b+geom_bar(aes(fill=class2))


#根据年份分别绘制条形图，position控制位置调整方式
b=ggplot(mpg, aes(class2, fill=factor(year)))
b+geom_bar(position='identity', alpha=0.5) #柱子互相覆盖

#并立方式柱子
b+geom_bar(position='dodge')

#堆叠柱子
b+geom_bar(position='stack')

#相对比例-堆叠(归一化为1)
b+geom_bar(position='fill')

#分面显示-按年份
b+geom_bar(aes(fill=class2))+facet_wrap(~year)




###########################
# 饼图
###########################
p=ggplot(mpg, aes(x=factor(1), fill=factor(class)))
p+geom_bar(width=1)  #todo 不懂
#p+coord_polar(theta='x') #默认是x
p+coord_polar(theta='y')





###########################
# 箱线图
###########################
p=ggplot(mpg, aes(class,hwy,fill=class))
p+geom_boxplot()


###########################
# 小提琴图
###########################
p=ggplot(mpg, aes(class,hwy,fill=class))
p+geom_violin(alpha=0.3,width=0.9)+
  geom_jitter(shape=21)




######################
#点的不透明度
p=ggplot(diamonds, aes(carat, price))
p+geom_point()

## 观察密集散点的方法
#1.增加扰动（jitter）
p+geom_point(position='jitter') 
#2.增加透明度(alpha)
p+geom_point(alpha=1/10)  #10个点重叠就是完全不透明。

#3.二维直方图（stat_bin2d) :其实就是二维热图。
p+stat_bin2d(bins = 60) #设置bin的个数，x和y方向。
#4.密度图（stat_density2d)
p+stat_density2d(aes(fill=..level..), geom="polygon")+
  coord_cartesian(xlim=c(0,1.5), ylim=c(0,6000))+
  scale_fill_continuous(high='red2',low='blue4')





####################
#风向风速玫瑰图
####################

#随机生成100次风向，并汇集到16个区间内
dir=cut_interval(runif(100,0,360), n=16 )
#随机生成100次风速，并划分为4种强度
mag=cut_interval(rgamma(100,15),4)
sample=data.frame(dir=dir,mag=mag)

#将风向映射到x轴，频数映射到y轴，
#风速大小映射到填充色，生成条形图后再转化为极坐标形式即可。
p=ggplot(sample, aes(x=dir, y=..count.., fill=mag))
p+geom_bar()+coord_polar()




####################
# 插入数学符号
####################
#使用的是老版本ggplot2，新版未测试
slope=-0.8
intercept <- sin(4)-slope*4
x <- seq(from=0,to=2*pi,by=0.01)
y <- sin(x)
p <- ggplot(data.frame(x,y),aes(x,y))
p + geom_area(fill=alpha('blue',0.3))+
  geom_abline(intercept=intercept,slope=slope,linetype=2)+
  scale_x_continuous(breaks=c(0,pi,2*pi),labels=c('0',expression(pi),expression(2*pi)))+ 
  geom_text(parse=T,aes(x=pi/2,y=0.3,label='integral(sin(x)*dx, 0, pi)'))+
  #geom_line()+ 
  geom_point(aes(x=4,y=sin(4)),size=5,colour=alpha('red',0.5))





####################
# 时间序列
####################
#install.packages('quantmod')
library(quantmod)
library(ggplot2)
getSymbols('^SSEC',src='yahoo',from = '1997-01-01')
close <- (Cl(SSEC))
time <- index(close)
value <- as.vector(close)
yrng <- range(value)
xrng <- range(time)
data <- data.frame(start=as.Date(c('1997-01-01','2003-01-01')),end=as.Date(c('2002-12-30','2012-01-20')),core=c('jiang','hu'))
timepoint <- as.Date(c('1999-07-02','2001-07-26','2005-04-29','2008-01-10','2010-03-31'))
events <- c('证券法实施','国有股减持','股权分置改革','次贷危机爆发','融资融券试点')
data2 <- data.frame(timepoint,events,stock=value[time %in% timepoint])
p <- ggplot(data.frame(time,value),aes(time,value))
p + geom_line(size=1,colour='turquoise4')+
  geom_rect(alpha=0.2,aes(NULL,NULL,xmin = start, xmax = end, fill = core),ymin = yrng[1],ymax=yrng[2],data = data)+
  scale_fill_manual(values = c('blue','red'))+
  geom_text(aes(timepoint, stock, label = events),data = data2,vjust = -2,size = 5)+
  geom_point(aes(timepoint, stock),data = data2,size = 5,colour = 'red',alpha=0.5)



####################
# 时间序列
####################





#learn ggplot2
# http://ggplot2.org
#docs: http://ggplot2.tidyverse.org/reference/
#ggplot2作者出的测试题： http://stat405.had.co.nz/drills/ggplot2.html

library(ggplot2) # http://stackoverflow.com/tags/ggplot2
 str(mpg)
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





#
###############################
#20180706
#重新学习笔记
library("ggplot2")

#1. 抽样
set.seed(1410) #让样本可重复
dsmall <- diamonds[sample(nrow(diamonds), 100), ]

#2.3钻石价格和重量之间的关系
qplot(carat, price, data=diamonds)

#使用对数变换，更像是线性了
qplot(log(carat),log(price), data=diamonds)

#点很多是重叠的，所以下结论时要小心

#如果我们研究体积和重量的关系？
qplot(carat, x*y*z, data=diamonds)


#####
#2.4 属性：颜色、大小、形状等
qplot(carat, price, data=dsmall)
qplot(carat, price, data=dsmall, color=color)
qplot(carat, price, data=dsmall, shape=cut)
qplot(carat, price, data=dsmall, size=z)


#手动设置属性：color=I("red")或者 size=I(2)

#设置透明度可以看出，数据大概在哪里重叠
qplot(carat, price, data=diamonds, alpha=I(1/10)) #表示10个点重复将变成不透明。
qplot(carat, price, data=diamonds, alpha=I(1/100)) 
qplot(carat, price, data=diamonds, alpha=I(1/200)) 

#2.5 几何对象，
qplot(carat, price, data=dsmall, geom="point") #默认是点
qplot(carat, price, data=dsmall, geom="smooth") #平滑曲线：曲线和标准误
#
qplot(cut, price, data=dsmall, geom="boxplot") #箱线图，表述分布

#探索实践和其他变量之间的关系
qplot(carat, price, data=dsmall, geom="path") #数据点之间连线
qplot(carat, price, data=dsmall, geom="line") #数据点之间连线

qplot(price, binwidth=1000, data=dsmall, geom="histogram") #连续变量直方图
qplot(price, binwidth=1000, data=dsmall) #连续变量直方图(传入单个变量，默认画直方图)
qplot(price, data=dsmall, geom="density") #绘密度曲线
qplot(price, binwidth=1000, data=dsmall, geom="freqpoly") #绘密度曲线
qplot(cut, data=dsmall, geom="bar") #离散型变量，绘制条形图


###
#2.5.1 像图中添加平滑曲线
qplot(carat, price, data=dsmall)
#通过c()函数传递向量给geom，几何对象会按照指定的顺序进行堆叠
qplot(carat, price, data=dsmall, geom=c("point","smooth")) #线在上部(推荐)
#`geom_smooth()` using method = 'loess'
?loess #局部回归方法

qplot(carat, price, data=dsmall, geom=c("smooth","point")) #点在上
qplot(carat, price, data=dsmall, geom=c("smooth","point"), se=F)#不想画标准误

qplot(carat, price, data=diamonds, geom=c("point","smooth"))#数据太多没平滑线？Warning
#`geom_smooth()` using method = 'gam' 数据超过1000时，mothod使用gam。


#曲线的平滑程度: span控制，从0(很不平滑)到1(很平滑)
qplot(carat, price, data=dsmall, geom=c("point", "smooth"), span=0.2)
qplot(carat, price, data=dsmall, geom=c("point", "smooth"), span=1)

# 这两个参数已经不认可了
library("mgcv")
qplot(carat, price, data=dsmall, geom=c("point", "smooth")
      #,method="gam"
      ,formula = y~s(x)
)




#
###
#2.5.2 箱线图和扰动点图
#钻石单价随颜色的变化
qplot(color, price/carat, data=diamonds) #很多重叠了，很不直观
qplot(color, price/carat, data=diamonds, geom="jitter", alpha=I(1/5))
qplot(color, price/carat, data=diamonds, geom="jitter", alpha=I(1/50))
qplot(color, price/carat, data=diamonds, geom="jitter", alpha=I(1/200))

#画箱线胡须图
qplot(color, price/carat, data=diamonds, geom="boxplot")
# 还可以用color控制外框线的颜色，用fill设置填充色，用size设置线的粗细
qplot(color, price/carat, data=diamonds, geom="boxplot",
      color=I("red"), fill=I("white"), size=I(1))




#####################
#扰动图上添加箱线图 good
#####################
qplot(color, price/carat, data=diamonds, geom=c("jitter","boxplot"))
qplot(color, price/carat, data=diamonds, geom=c("boxplot","jitter")
      ,alpha=I(1/50),size=I(1)) #推荐

qplot(color, price/carat, data=dsmall, geom=c("boxplot","jitter")
      ,size=I(1))#点稀疏的时候效果很好


#2.5.3 直方图和密度曲线图
qplot(carat, data=diamonds, geom="histogram")
qplot(carat, data=diamonds, geom="density")
qplot(carat, data=diamonds, geom=c("histogram","density") )#并没有重叠着画 why?

qplot(carat, data=diamonds, geom="histogram",binwidth=1)
qplot(carat, data=diamonds, geom="histogram",binwidth=1,xlim=c(-0.5,3.5))
qplot(carat, data=diamonds, geom="histogram",binwidth=0.1,xlim=c(-0.5,3.5))
qplot(carat, data=diamonds, geom="histogram",binwidth=0.01,xlim=c(-0.5,3))
#用最小的binwidth发现，钻石主要集中在整0.25附近

#如果想在不同的颜色中比较
#重叠密度图(真实理解密度曲线的含义比较困难)
qplot(carat, data=diamonds, geom="density",color=color,binwidth=0.1,xlim=c(-0.5,3))
#堆叠直方图
qplot(carat, data=diamonds, geom="histogram",fill=color,binwidth=0.1,xlim=c(-0.5,3))


#2.5.4条形图
qplot(color, data=diamonds, geom="bar")#每种颜色的数量
#使用 weight 几何对象加权
qplot(color, data=diamonds, geom="bar",weight=carat)#每种颜色的克拉重量
qplot(color, data=diamonds, geom="bar",weight=carat)+ #这个+仅仅是改y坐标轴标签？
  scale_y_continuous("carat")



#2.5.5 线条图和路径图 - 常用于可视化时间序列数据
#使用带有时间的economics数据，包含美国过去40年的经济数据
library(ggplot2)
head(economics)
# A tibble: 6 x 6
#date         pce    pop psavert uempmed unemploy
#<date>     <dbl>  <int>   <dbl>   <dbl>    <int>
#1 1967-07-01   507 198712    12.5    4.50     2944
#2 1967-08-01   510 198911    12.5    4.70     2945
qplot(date, unemploy/pop, data=economics, geom="line")




#

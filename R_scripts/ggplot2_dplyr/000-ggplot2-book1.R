#learn ggplot2 看书学
# http://ggplot2.org
#docs: http://ggplot2.tidyverse.org/reference/
#ggplot2作者出的测试题： http://stat405.had.co.nz/drills/ggplot2.html
# http://stackoverflow.com/tags/ggplot2



#
###############################
#20180706
#重新学习笔记
library("ggplot2")

ggplot(mpg, aes(displ, hwy, colour = class)) + 
  geom_point()


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
qplot(color, price/carat, data=diamonds)+geom_boxplot(aes(color=color)) #设置颜色
qplot(color, price/carat, data=diamonds, geom="boxplot",color=color) #设置颜色
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

#时间序列分析暂时用不到，先跳过去。//todo


#
#############
#为什么没有背景阴影分割线？//done debug
#
#ggplot2默认主题怎么设置？
#Cowplot made ggplot2 theme disappear / How to see current ggplot2 theme, and restore the default?
#https://stackoverflow.com/questions/41096293/cowplot-made-ggplot2-theme-disappear-how-to-see-current-ggplot2-theme-and-res
#library(cowplot)
theme_set(theme_grey())
#############




#2.6 分面，是对图形属性（颜色、形状）的另一种可视化表现形式。
qplot(carat,data=diamonds,facets=color~., geom="histogram", binwidth=0.1, xlim=c(0,3))
qplot(carat,..density.., data=diamonds,facets=color~., geom="histogram", binwidth=0.1, xlim=c(0,3))
#..density.. 表明经密度而不是频数映射到y轴。

qplot(carat,data=diamonds,facets=color~cut, geom="histogram", binwidth=0.1, xlim=c(0,3))+theme_gray()



#2.7其他选项
#CairoPDF(file="fig1.pdf",width=12,height=6)

qplot(
  carat, price, data=dsmall
  ,xlab="Price($)", ylab="Weight (Carats)"  #坐标轴文字
  ,main="Price-weight relationship" #顶部图片标题
) #+ theme_gray()

#dev.off()
getwd()

qplot(
  carat, price, data=dsmall
  ,log="xy" #对坐标取对数
) + theme_gray()




#
###############
# 第3章 语法突破
###############
#3.2 耗油量数据
head(mpg)
#3.3 绘制散点图
#数据集 mpg: 发动机排量 displ， 高速路每加仑行驶的公里数hwy
qplot(displ, hwy, data=mpg, color=factor(cyl))  #加factor()后就是离散变量
qplot(displ, hwy, data=mpg, color=cyl)  #不加factor()就是连续变量
#结论：排量越大，每加仑行驶距离越小。


#图形属性aesthetic:点的x，y，size，color，shape等。
#集合对象：点points、线lines、条bars
#标度变换 scaling：
#坐标系统 coord

#完整图形需要三类图形对象：
#1.数据
#2.标度和坐标系
#3.图形注释




#3.4 更复杂的图形示例
#分面 facet panel
head(mpg)
qplot(displ,hwy, data=mpg,facets=.~year) #行~列
qplot(displ,hwy, data=mpg,facets=.~year) + geom_smooth()



#三种变换的先后顺序：标度变换、统计变换、坐标变换；

#三种不同的坐标系
#1.笛卡尔Cartesian
#2.半对数semi-log
#3.极坐标polar

g=qplot(displ,hwy,data=mpg,color=factor(cyl))
g
summary(g) #简单查看对象结构

save(g, file="plot.rdata")#保存图形对象
load("plot.rdata")
#将图形保存为png格式
ggsave("plot.png", width=5, height=5)
getwd()








#
###############
# 第4章 用图层构建图像P42-p67
###############

p <- ggplot(diamonds, aes(carat))
p <- p + layer( #报错，说明ggplot2已经改了这部分
  geom="bar",
  geom_params=list(fill="steelblue"),
  stat="bin",
  stat_params=list(binwidth=2)
)
p
########

head(diamonds)
p <- ggplot(diamonds, aes(carat)) + 
  #geom_histogram()
  geom_histogram(stat="bin",binwidth=0.3,fill="steelblue")
p


# ggplot和qplot具有部分等价性
head(msleep)
ggplot(msleep, aes(sleep_rem/sleep_total, awake))+geom_point()
#等价于
qplot(sleep_rem/sleep_total,awake,data=msleep)


#也可以给qplot添加图层
qplot(sleep_rem/sleep_total, awake, data=msleep)+geom_smooth()
#等价于
qplot(sleep_rem/sleep_total,awake,data=msleep,
      geom=c("point","smooth"))
#或者
qplot(sleep_rem/sleep_total,awake,data=msleep)+
  geom_point() + geom_smooth()

#

#图层是普通的R对象，可以保存到变量中
install.packages("scales")
library(scales)
bestfit <- geom_smooth(method="lm",se=F,
        color=alpha("steelblue",0.5),size=2)
#保存到变量中的图层，可以多次使用
qplot(sleep_rem, sleep_total, data=msleep)+bestfit
qplot(awake, brainwt, data=msleep, log="y")+bestfit
qplot(bodywt, brainwt, data=msleep, log="xy")+bestfit



#数据集
p <- ggplot(mtcars, aes(mpg, wt, color=cyl))+geom_point()
p
mtcars2 <- transform(mtcars, mpg=mpg^2) #新定义的数据集
p %+% mtcars2 #换成新定义的数据集


#4.5 图形属性映射
aes(x=weight, y=height, color=age)

aes(x=weight, y=height, color=sqrt(age))
#

#4.5.1 图和图层
p <- ggplot(mtcars)
summary(p)
#
p <- p+aes(wt, hp)
summary(p)
#

#添加基本图层
p <- ggplot(mtcars, aes(x=mpg, y=wt))
p+geom_point()
#
p+geom_point(aes(color=factor(cyl)))
p+geom_point(aes(y=disp)) #y轴label并没有改变，一个图层内的设置只影响本图层。
p+geom_point(aes(y=NULL)) #删除y


#4.5.2 设定和映射
p=ggplot(mtcars, aes(mpg, wt))
p+geom_point(color="darkblue") #将颜色设置为darkblue

#和下面有很大区别：
p+geom_point(aes(color="darkblue"))  #将颜色映射为darkblue
#为什么是粉红色的点？
# 相当于先创建一个新变量，只有一个值"darkblue",
# 然后将color映射到这个新变量。
# 新变量是离散的，默认使用色轮上等间距的颜色，第一个是桃花红色。

#qplot()可以将某个值放到I()里来实现映射。
qplot(mpg, wt, data=mtcars, geom=c("point"), color=I("darkblue"))



#4.5.3 分组 group
#离散型变量的交互作用被设计为分组的默认值。
#单个变量分组用group;
#两个变量的组合来分组用 interaction()函数;

#数据集：nlme包中的简单纵向数据集Oxboys,
#26名男孩Subject在9个不同时期Occasion所测量的身高height和去中心化后的年龄age
library(nlme)
dim(Oxboys); head(Oxboys)
#我们希望区分个体，而不是识别他们。细面图 (spaghetti plot)
#
p=ggplot(Oxboys, aes(age,height,group=Subject)) + geom_line() #第一个图层
p #可见每条线代表一个男孩

ggplot(Oxboys, aes(age,height)) + geom_line()#不加分组的效果：没有意义的折线图。
ggplot(Oxboys, aes(age,height,group=1)) + geom_line()#和group=1是一个效果


#不同图层上的不同分组
p+geom_smooth(method="lm", se=F) #默认采用上面设置的分组
p+geom_smooth(aes(group=Subject), method="lm", se=F) #这相当于每个男孩加了一条趋势线，不是我们想要的
#平滑层使用aes(group=1)得到所有男孩的拟合曲线
p+geom_smooth(aes(group=1), method="lm", se=F) #明确就是1组，只有一条趋势线


#
#修改默认分组
g=ggplot(Oxboys, aes(Occasion, height))+geom_boxplot()#默认分组就是离散型变量Occasion
g
#如果添加个体轨迹，则使用aes(group=Subject)修改第一层的默认分组
g+geom_line(aes(group=Subject),color="#3366FF")#aes只在图层有效



#4.5.4 匹配图形属性和图形对象 P54 todo 

#群体几何对象?? todo


#----
#不懂？线性插值法做渐变线条颜色。
df=data.frame(
  x=c(1,2,3),
  y=c(1,2,3),
  color=c(1,3,5)
)



#没做出来效果,没有连线的颜色 todo
ggplot(df, aes(x,y,color=factor(color))) + 
  geom_line(size=2) + 
  geom_point(size=5) #无连线
#v2
ggplot(df, aes(x,y)) + 
  geom_line(size=2) +
  geom_point(aes(color=factor(color)),size=5) #连线是黑色的
#
#geom_path: Each group consists of only one observation. Do you need to adjust the group aesthetic?



#每段线段一个颜色：最后一个点没有对应的线条。
ggplot(df, aes(x,y,color=color)) + geom_line(size=2) + geom_point(size=5)#线性颜色不同


#
#如果让线条颜色可控，可以用线性插值法
xgrid=with(df, seq(min(x), max(x), length=50))
xgrid

interp=data.frame(
  x=xgrid,
  y=approx(df$x,df$y,xout=xgrid)$y,
  color=approx(df$x, df$color, xout=xgrid)$y
)
interp
# 渐变线条
qplot(x,y,data=df,color=color, size=I(5))+
  geom_line(data=interp, size=2)
#





#
##4.6 几何对象 geom 
###P58表格列举ggplot2中所有可用几何对象
ggplot(diamonds, aes(color))+#离散值
  geom_histogram(stat="count") #只能如此？
  #geom_bar(aes(y=..count..)) #组的中心位置
#
ggplot(diamonds, aes(color))+
  geom_histogram(aes(fill=cut),stat="count") #填充颜色，作为一个细分维度
#





#
##4.7 统计变换 stat
###p60表格列举ggplot2中的统计变换，
#每种统计变换都有生成变量的名字，如果使用生成变量，必须用..围起来。
ggplot(diamonds, aes(carat))+ #连续性变量，默认使用bin统计( stat_bin )变换
  geom_histogram(aes(y=..density..), binwidth=0.1) #密度
#
ggplot(diamonds, aes(carat))+
  geom_histogram(aes(y=..count..), binwidth=0.1) #观测值的数目
ggplot(diamonds, aes(carat))+
  geom_histogram(binwidth=0.1) #直方图默认是频数
#
ggplot(diamonds, aes(carat))+
  geom_histogram(aes(y=..x..), binwidth=0.1) #组的中心位置？？todo这个什么意思？
#

#对应的qplot版本
qplot(carat, ..density.., data=diamonds, geom="histogram", binwidth=0.1)





#
## 4.8 位置调整 position
head(diamonds) #离散型变量
ggplot(diamonds, aes(clarity, fill=factor(cut)))+ #堆叠图。factor一定要加上！
  geom_histogram(stat="count") #默认是stack

ggplot(diamonds, aes(clarity, fill=factor(cut)))+
  geom_histogram(stat="count",position="stack")

ggplot(diamonds, aes(clarity, fill=factor(cut)))+
  geom_histogram(stat="count",position="fill") #高度标准化为1

ggplot(diamonds, aes(clarity, fill=factor(cut)))+
  geom_histogram(stat="count",position="dodge") #并排放置

#
#done
a=ggplot(diamonds, aes(clarity, fill=factor(cut)))+
  geom_histogram(stat="count",position="identity") #不做任何调整，则会产生遮挡
a
ggplot(diamonds, aes(clarity, fill=factor(cut)))+
  geom_histogram(stat="count",position="identity",alpha=0.25) #加不透明度,效果不好
#如何用线条画出来？P63
b=ggplot(diamonds, aes(clarity, color=cut)) + 
  geom_line(stat="count", aes(y=..count.., group=cut), size=1)
b
ggplot(diamonds, aes(clarity, color=factor(cut))) +  #加不加factor没啥影响
  geom_line(stat="count", aes(y=..count.., group=cut))

#
library(scater)
multiplot(a, b, cols=2)


#
## 4.9 整合
#-- 结合几何对象 + 统计变换 = 产生很多不同的图形
d=ggplot(diamonds, aes(carat))+xlim(0,3) #基于直方图的统计变换，但是使用3种几何对象(面积、点、瓦片)。
#变形1:频率多边形
d+stat_bin(aes(y=..count..), binwidth=0.1, geom='area')

#变形2：散点图，点的大小和高度都映射给了频率
d2=d+stat_bin(aes(size=..density..), binwidth=0.1,geom='point',position='identity')
d2
#变形3：热图heatmap用颜色来表示频率; 该图失败P64 todo
d+stat_bin(aes(fill=..count..), binwidth=0.1,geom='tile', position='identity')

#
d+geom_tile(aes(fill=..count..), stat="count", binwidth=0.1, position='identity')




#4.9.2 显示已计算过的统计量
stat_identity()





#4.9.3 改变图形属性和数据集
require(nlme, quiet=T, warn.conflicts=F)
model=lme(height~age, data=Oxboys, random=~1+age|Subject)
oplot=ggplot(Oxboys, aes(age, height, group=Subject))+
  geom_line()
oplot

#建立预测模型？？
age_grid=seq(-1,1,length=10)
subjects=unique(Oxboys$Subject)

preds=expand.grid(age=age_grid, Subject=subjects)
preds$height=predict(model, preds)
#画出预测值，在原图上覆盖一层
oplot+geom_line(data=preds, color="#3366FF", size=0.4)
#
#不过很难看清楚。另一种估算差异的方法是看残差
#
Oxboys$fitted=predict(model)
Oxboys$resid=with(Oxboys, fitted-height)
#
oplot %+% Oxboys+aes(y=resid)+geom_smooth(aes(group=1))
#
#残差分布并不是随机分布，因此模型有缺陷
#模型中添加二次项，再次计算残差图
model2=update(model, height~age+I(age^2))
Oxboys$fitted2=predict(model2)
Oxboys$resid2=with(Oxboys, fitted2-height)
oplot %+% Oxboys + aes(y=resid2)+geom_smooth(aes(group=1))
#这一次模型好点 ？？？ todo





#
###############
# 第5章 工具箱P68-97
###############

#5.3 基本图形类型
#二维图形，x和y是不可或缺的，同时可以接受color、size属性。
#对于填充型结合对象（条形、瓦片tile和多边形）还接受fill图形属性。
#点使用shape图形属性
#线和路径接受linetype图形属性


geom_area()

df=data.frame(
  x=c(3,1,5,10),
  y=c(2,4,6,-15),
  label=c("a","b","c","d")
)
p=ggplot(df, aes(x,y)) + xlab(NULL) + ylab(NULL)
p+geom_point()+labs(title="geom_point")
#
p+geom_bar(stat="identity") + #todo 为什么画的不是3 1 5？以为y轴是2 4 6
  labs(title="geom_bar(stat=\"identity\")")
#
p+geom_line()+labs(title="geom_line") #从左到右连线
p+geom_area()+labs(title="geom_area")
p+geom_path()+labs(title="geom_path")#按照给出的顺序连线
p+geom_text(aes(label=label))+labs(title="geom_text")
p+geom_tile()+labs(title="geom_tile") #瓦片图-热图
p+geom_polygon()+labs(title="geom_polygon")#多边形



#5.4 展示数据分布
ggplot(diamonds, aes(depth))+geom_histogram() #不要指望默认参数能出好图。

#缩小x范围，缩小binwidth
depth_dist=ggplot(diamonds, aes(depth))+xlim(55,70)
#1 
depth_dist + geom_histogram(aes(y=..density..), binwidth=0.1)
#2 分面直方图
depth_dist + geom_histogram(aes(y=..density..), binwidth=0.1)+
  facet_grid(cut~.) #加一个分面
#3 条件密度图
depth_dist+geom_histogram(aes(fill=cut), binwidth=0.1)
depth_dist+geom_histogram(aes(fill=cut), binwidth=0.1,position="fill")#标准化到1
#4 频率多边形
depth_dist+geom_freqpoly(aes(y=..density.., color=cut), binwidth=0.1)
#结论：随着钻石品质的提高，分布逐渐向左偏移且愈发对称。


#
#boxplot用于离散型变量
qplot(cut,depth,data=diamonds,geom="boxplot")
#boxplot如果用于连续性变量，需要做小心的封箱处理binnig
qplot(carat,depth,data=diamonds, geom='boxplot')#没有做封箱，就只有一个箱子

library(plyr) #round_any()
qplot(carat,depth,data=diamonds, geom='boxplot',
      #group=round_any(carat,0.1,floor))
      group=round_any(carat,0.1,floor), xlim=c(0,3.5))
#获得以0.1位封箱的箱线图。


# 直接jitter没法看，边界不清晰
qplot(class,cty,data=mpg,geom='jitter')#不好
qplot(class,cty,data=mpg,geom='jitter',color=class)#加上颜色

#为什么箱线图顶部还有几个不是彩色颜色的黑点？
qplot(class,cty,data=mpg,geom=c('boxplot')) +geom_jitter()#不好
qplot(class,cty,data=mpg,geom=c('boxplot')) +geom_jitter(aes(color=class))

#换个y，离散型的y
qplot(class,drv,data=mpg) +geom_jitter(aes(color=class))#加黑点什么意思？
qplot(class,drv,data=mpg,geom='jitter',color=class)
qplot(class,drv,data=mpg,geom='point',color=class)#正常就是这几个固定点，怎么控制大小？
qplot(class,drv,data=mpg,geom='point',color=class,stat="count",size=..count..)#正常就是这个点
#todo
#


#
#density 密度图实际上就是直方图的平滑化版本。但是难以由图回溯数据本身。
qplot(depth, data=diamonds, geom="density", xlim=c(54,70))
qplot(depth, data=diamonds, geom="density", xlim=c(54,70),
      fill=cut,alpha=I(0.2))





#
#5.5 处理遮盖绘制问题 overplotting
df=data.frame(
  x=rnorm(2000),
  y=rnorm(2000)
)

norm=ggplot(df,aes(x,y))
norm+geom_point() #原始点图
norm+geom_point(shape=1) #中空的小点效果好一点
norm+geom_point(shape=".") #点的大小为像素级

#
#使用不透明度，效果也不好
norm+geom_point(color="black", alpha=1/3)
norm+geom_point(color="black", alpha=1/5)
norm+geom_point(color="black", alpha=1/10)


#
#实例：diamond数据集中table和depth组成的图形
td=ggplot(diamonds, aes(table, depth))+
  xlim(50,70) +ylim(50,70)
td+geom_point() #点聚集在竖线条上，无法判断密度
td+geom_jitter()#扰动后，效果还是不理想

jit=position_jitter(width=0.5)#横向扰动单位0.5，就是横轴单位距离的一半
td+geom_jitter(position=jit)#扰乱开了，一大团，还是分不清哪里聚集多
td+geom_jitter(position=jit, alpha=1/10)
td+geom_jitter(position=jit, alpha=1/50)
td+geom_jitter(position=jit, alpha=1/200)
#其实结果还是不理想
#


#
#使用分箱，正方形和六边形来实现效果
d=ggplot(diamonds, aes(carat, price))+xlim(1,3) #+theme(legend.position="none") 
  #去掉图例与否
d
#正方形，颜色表示密度
#stat_bin2d 计算矩形封箱内观测值个数，并默认映射到这些矩形的fill属性。
d+stat_bin2d() #图1
d+stat_bin2d(bins=10) #图1
d+stat_bin2d(binwidth=c(0.02,200))
#据说矩形会造成视觉假象，Carr等建议用六边形代替。
#切换为六边形
d+stat_binhex()
d+stat_binhex(bins=10)
d+stat_binhex(binwidth=c(0.02,200))

# 加上等高线
d=ggplot(diamonds, aes(carat,price))+xlim(1,3)
d+geom_point()+geom_density2d() #等高线
d+stat_density2d(geom="point", aes(size=..density..),contour=F)+
  scale_size_area()
#上图为2基于点和等高线的密度展示，下图为
d+stat_density2d(geom="tile", aes(fill=..density..), contour = F) #看不清
last_plot()+scale_fill_gradient(limits=c(1e-5, 8e-4))
#



#
#5.6曲面图
#二维平面上展示三维曲面的常用工具：等高线图、找色瓦片colored tiles以及气泡图。



#
#5.7 绘制地图
略



#
#5.8 揭示不确定性
d=subset(diamonds, carat<2.5 & rbinom(nrow(diamonds),1,0.2)==1)
#rbinom(10,1,0.2)#rbinom(n, size, prob)#size 就是可能的实验结果个数
dim(diamonds)
dim(d) #抽样0.2
ggplot(d, aes(carat,price))+geom_point(aes(color=color))
#对数变换
d$lcarat=log10(d$carat)
d$lprice=log10(d$price)
ggplot(d, aes(lcarat,lprice))+geom_point(aes(color=color))#目测线性了

#剔除整体的线性趋势
detrend=lm(lprice~lcarat, data=d)
detrend
d$lprice2=resid(detrend)#计算残差
d$lprice2[c(1:10)]
#
mod=lm(lprice2~lcarat*color, data=d)
mod #todo??
#



#install.packages("effects")
library(effects)
#effect: Functions For Constructing Effect Displays 构建交叉效应
effectdf=function(...){
  suppressWarnings(as.data.frame(effect(...)))
}
color=effectdf("color",mod)
color
both1=effectdf("lcarat:color", mod)
both1
#
carat=effectdf("lcarat",mod, default.levels=50)
carat
#
both2=effectdf("lcarat:color",mod,default.levels=3)
both2
# 图 5.14
qplot(lcarat, lprice, data=d, color=color)
qplot(lcarat, lprice2, data=d, color=color)
# 图 5.15
fplot=ggplot(mapping=aes(y=fit, ymin=lower, ymax=upper))+
  ylim(range(both2$lower, both2$upper))
fplot %+% color+aes(x=color)+geom_point()+geom_errorbar()
fplot %+% both2 + 
   aes(x=color, color=lcarat, group=interaction(color,lcarat))+
   geom_errorbar()+geom_line(aes(group=lcarat))+
   scale_color_gradient() #p87
# 图 5.16
fplot %+% carat + aes(x=lcarat)+
  geom_smooth(stat="identity")
ends=subset(both2,lcarat==max(lcarat))
fplot %+% both1 + aes(x=lcarat, color=color)+
  geom_smooth(stat="identity")+
  scale_color_hue()+theme(legend.position="none")+
  geom_text(aes(label=color, x=lcarat+0.02), ends)
#


#
##5.9统计摘要
ggplot(diamonds, aes(carat, price))+
  stat_summary()

#mean(x, trim = 0.1)
#就是先把x的最大的10%的数和最小的10%的数去掉，然后剩下的数算平均。
dd=c(-1,0,2,3,4,5,6,70,80,90); mean(dd,trim=0.1)
mean(c(0,2,3,4,5,6,70,80))
#
dd=c(1,2,3,4,5,6,70,80,90,100); mean(dd,trim=0.2)#[1] 28
dd=c(2,3,4,5,6,70,80,90); mean(dd)#[1] 32.5

#
midm=function(x) mean(x,trim=0.5)
ggplot(diamonds, aes(carat, price))+
  stat_summary(aes(color="trimmed"), fun.y=midm,geom="point")+
  stat_summary(aes(color="raw"), fun.y=mean, geom="point")+
  scale_color_hue("Mean")
#??不理解 todo



#
### 5.9.2 统一的摘要计算函数
#自定义摘要计算函数：要返回一个各元素有名称的向量作为输出
quantile(as.numeric(c(1,2,3,4,5,6,7,8,9,10)), c(0,0.1,0.5,0.75,0.9,1))
#0%   10%   50%   75%   90%  100% 
#1.00  1.90  5.50  7.75  9.10 10.00 

iqr=function(x, ...){
  qs=quantile(as.numeric(x), c(0.25, 0.75), na.rm=T)
  names(qs)=c('ymin','ymax')
  qs
}
ggplot(diamonds, aes(carat, price))+
  stat_summary(fun.data='iqr', geom='ribbon')
#更多其他封装函数
ggplot(diamonds, aes(carat, price))+
  stat_summary(fun.data='mean_c1_normal', geom='ribbon')
#todo 报错 函数没找到 P91



#
## 5.10 添加图形注释（记住：注释就是额外的数据）

#美国失业数据
unemp=qplot(date, unemploy, data=economics, geom='line', 
            xlab='',ylab='No. unemployed (1000s)')
unemp
#美国总统在位时间 name,start,end,party     
head(presidential)
dim(presidential)#[1] 11  4
presidential=presidential[-c(1:3),]

yrng=range(economics$unemploy)
yrng
xrng=range(economics$date)
xrng
#添加竖线，表示总统执政开始时间
unemp+
  geom_vline(aes(xintercept=as.numeric(start)), data=presidential)
#

#为不同政党画不同颜色
library(scales)
unemp+
  geom_rect(aes(NULL, NULL, xmin=start, xmax=end,fill=party),
            ymin=yrng[1], ymax=yrng[2],
            data=presidential, alpha=0.2)+
  scale_fill_manual(values=c("blue","red"))

#为上图添加总统名字
last_plot()+
  geom_text(aes(x=start, y=yrng[1],label=name),
            data=presidential, size=3, hjust=0, vjust=-1)

#在图上添加一句话
caption=paste(strwrap("Unemployment rates in the US have varied a lot over the years",40),
                collapse="\n")
caption
unemp+
  geom_text(aes(x,y,label=caption), 
            data=data.frame(x=xrng[2], y=yrng[1]+2000),
            hjust=1, vjust=1, size=4)

#高亮显示最高点
highest=subset(economics, unemploy==max(unemploy))
highest #最高点
unemp+geom_point(data=highest, size=3, color='red', alpha=0.5)

#
# geom_text 可添加文字叙述或为点添加标签。
# geom_vline, geom_hline: 添加垂直线或水平线
# geom_abline: 向图中添加任意斜率和截距的直线
# geom_rect 强调感兴趣的矩形区域，又有属性xmin,xmax,ymin,ymax
# geom_line, geom_path, geom_segment 都可以添加直线，都有arraw参数，
#  用来在线上放置一个箭头。 
#也可以使用arrow()函数绘制箭头，属性 angle,length,ends,type


#
##5.11 含权数据
#
dim(midwest)
head(midwest)
# 用图形属性size来改变点的大小。
qplot(percwhite,percbelowpoverty, data=midwest)#x白人比例，y贫困人口比例
qplot(percwhite,percbelowpoverty, data=midwest, size=poptotal/1e6) #直接用人口控制点大小
qplot(percwhite,percbelowpoverty, data=midwest, size=poptotal/1e6) + 
  scale_size_area() #这个有啥用呢？ done 调用scale_size_area()函数使数据点的面积正比于变量值。
qplot(percwhite,percbelowpoverty, data=midwest, size=poptotal/1e6) +
  scale_size_area("Population\n(millions)", breaks=c(0.5, 1,2,4))
#
qplot(percwhite,percbelowpoverty, data=midwest, size=area) +
  scale_size_area()
#


#
#涉及到统计变换时，修改weight图形属性来表现权重。
#如果权重有意义，各种元素基本都支持权重的设定，如各类平滑器、分位回归、箱线图、直方图以及各类密度图。
#我们无法直接看到这个权重变量，而且也没有对应的图例，但它却会改变统计汇总的结果。
#如作为权重的人口密度如何影响白种人比例，和贫困线以下人口的关系。
lm_smooth=geom_smooth(method=lm, size=1)
qplot(percwhite, percbelowpoverty, data=midwest)+lm_smooth
#这个权重仅仅体现在拟合线上
qplot(percwhite, percbelowpoverty, data=midwest, weight=popdensity)+lm_smooth #权重怎么参与计算的
#
qplot(percwhite, percbelowpoverty, data=midwest, weight=popdensity,size=popdensity)+lm_smooth#点大就影响力大

#加上人口权重，视角由对郡数量分布的观察转为对人口数量分布的观察
qplot(percbelowpoverty, data=midwest, binwidth=1)
qplot(percbelowpoverty, data=midwest, weight=poptotal, binwidth=1)+ylab("population")
#

#







#
###############
# 第6章 标度、坐标轴和图例 P98-P122
###############


#图形属性：位置、颜色、形状、大小、线条类型，所有图中能看到的元素都是标度。是对数据的某种展示。
#在ggplot2中标度都有默认值，但是理解标度并学会如何操纵它们则将赋予我们对图形更强的控制能力。
#执行标度的过程分为三步：变换(transformation)、训练(training)和映射(mapping)

#标度粗略分为四类：位置标度、颜色标度、手动离散型标度、同一型标度

#对图例和坐标轴的控制：通过 guides()函数和 guide_XXX一系列函数增强了对图例(legend)的直接控制。
p=qplot(cty, hwy, data=mpg)
p
#现在ggplot2已经能实现自动映射坐标，所以下面两个效果相同。
p+aes(x=drv)
p+aes(x=drv)+scale_x_discrete()
#

#所有的标度构造器scale constructor都以1. scale_开头，2. 接下来是图形属性的名字(color_, shape_, x_),
# 3.最后是标度的名称(gradient, hue, manual) . 各种标度名称 P101
#   如离散型数据的颜色属性的默认标度名为 scale_color_hue()
#   填充色用Brewer配色标度名为 scale_fill_brewer()
p=qplot(sleep_total, sleep_cycle, data=msleep, color=vore)
p #默认
#显式添加默认标度
p+scale_color_hue()#啥变化都没有

#修改默认标度的参数，这里改变了图例的外观
p+scale_color_hue("What does\nit eat?")#修改图例标题
p+scale_color_hue("What does\nit eat?"
            ,breaks=c("herbi","carni","omni",NA)#修改图例顺序。删除图例一项，但是主图没变:蓝点还在
            ,labels=c("plants", "meat","both","dont't know")
            )
#使用一种不同的标度
p+scale_color_brewer(palette="Set1")#使用ColorBrewer配色方案中的Set1，NA没有颜色怎么办？
#




#
##6.4 标度详解
#细节查文档,如 
?scale_color_brewer
# https://ggplot2.tidyverse.org/reference/


#
###6.4.1 通用参数
p=qplot(cty, hwy, data=mpg, color=displ)
p
#
p+scale_x_continuous("City mpg")

#
p+xlab("City mpg")
p+ylab("Highway mpg")
p+labs(x="City mpg", y="Highway", color="Displacement")
p+xlab(expression(frac(miles,gallon)))


#查看更多表达式帮助 
?plotmath

p+ylab( expression(paste(italic("Sox2"), " Expression") ))#斜体基因名字
p+ylab( expression(paste(italic("Sox2"), " Expression\nNormalized") ))#换行失败！todo

#
head(mtcars)
p=qplot(cyl,wt,data=mtcars)
p
p+scale_x_continuous(breaks=c(5.5,6.5)) #x轴只有5.5和6.5
p+scale_x_continuous(limits=c(5.5,6.5))#范围
#
p=qplot(wt,cyl,data=mtcars,color=cyl)
p
p+scale_color_gradient(breaks=c(5.5,6.5))#只影响图例
p+scale_color_gradient(limits=c(5.5,6.5))#颜色范围外的是灰色

p+scale_color_gradient(formatter="percent")#todo 报错，且找不到帮助。P105
#

#
#设置xlim和ylim，在这个范围之外的数据不会被绘制，也不会被包括在统计变换的过程中。
#这就意味着，设置limits所得到的结果和视觉上局部放大的结果不同。
#后者可以设置coord_cartesian()函数的参数xlim和ylim，见7.3.3节。

#
#默认位置标度limits会被数据略大，以便使点不会和边界重叠。使用expand来控制溢出量。
#expand参数是长度为2的数值型向量，第一个是乘法溢出量，第二个是加法溢出量。
#如果不想留多余空间，就使用expand=c(0,0)

#
# 连续型
#最常用的连续型位置标度为 scale_x_continous和 scle_y_continuous
#变换器 transformer：描述了变换本身和对应的逆变换，以及如何去绘制标签。
#对于xyz标度都有简便写法， scale_x_log10()和 scale_x_continuous(trans="log10")是等价的。
#trans写法对下文的颜色也有效，但是简便写法仅针对位置标度。

p=qplot(carat, price, data=diamonds, color=color)
p
#试试坐标变换
p+scale_y_continuous(trans="log10")

p+scale_y_continuous(trans="log10")+scale_x_continuous(trans="log10")
p+scale_y_log10()+scale_x_log10() #简便写法

qplot(carat, price, data=diamonds, color=color, log="xy") #更简便的写法
#
#如何直接输入log10(x)会怎么样呢？
qplot(log10(carat), log10(price), data=diamonds, color=color) #点完全一样，就是坐标轴标记不同

#变换器也可用于 coord_trand() 中，此时变换将在统计量计算完成后进行，因此将影响图形主体的外观。



#
library(scales)
head(economics)
p=qplot(date, psavert, data=economics, geom="line")+
  ylab("Personal savings rate")+
  geom_hline(yintercept=0, color="grey50")
p
#
p+scale_x_date(breaks=date_breaks("10 years")) #按10年为x刻度

p+scale_x_date(
  limits=as.Date(c("2004-01-01","2005-01-01")),
  labels=date_format("%Y-%m-%d") #日期格式
)

#
# 离散型



#
### 6.4.3 颜色标度
# 更详细的颜色模型参考： http://www.handprint.com/HP/WCL/color7.html
# visicheck 是避免红绿对比、模拟色盲情形的解决方案。
# 
#提供色盲人士也可识别的配色方案R包：dichromat包
#https://cran.r-project.org/web/packages/dichromat/
#

#对边界颜色color和填充色fill均有效：

#
#连续型
#1. scale_color_gradient() 和 scale_fill_gradient() 双色梯度。
#   从地到高用low和high控制两端的颜色。
#2. scale_color_gradient2() 和 scale_fill_gradient2() 三色梯度。
#   顺序为低-中-高，参数low和high作用同上，还有一个中间色。
#  中点默认为0，可以由midpoint设定。这个参数对发散性（ diverging ）配色方案特别有用。


#3. scale_color_gradientn()和 scale_fill_gradientn() ：自定义的n色梯度。

head(faithful)#记录黄石公园x喷泉两次喷发的间隔时间和每次喷发的持续时间。
dim(faithful)#[1] 272   2

qplot(eruptions, waiting, data=faithful) #基础图
qplot(eruptions, waiting, data=faithful)+geom_density2d()#密度等高线
#怎么给等高线涂色
qplot(eruptions, waiting, data=faithful)+
  geom_density2d(aes(fill=..level.., stat='polygon'))#密度等高线


f2d=with(faithful, MASS::kde2d(eruptions, waiting, h=c(1,10), n=50)) #?? todo 不懂
str(f2d)#List of 3 x y z
head(f2d)

#
df=with(f2d, cbind(expand.grid(x,y), as.vector(z))) #todo 不懂
head(df)

names(df)=c("eruptions", "waiting", "density")
erupt=ggplot(df, aes(waiting, eruptions, fill=density))+
  geom_tile()+
  scale_x_continuous(expand=c(0,0))+
  scale_y_continuous(expand=c(0,0)) #不留边界
erupt
#
erupt+scale_fill_gradient(limits=c(0,0.04))
erupt+scale_fill_gradient(limits=c(0,0.04),
                          low="white", high="black")
erupt+scale_fill_gradient2(limits=c(0,0.04), midpoint=mean(df$density))#2才有这个参数
#


#
library(colorspace)
library(vcd) #vcd包能生成调色板，其论文介绍了创建一个优秀颜色标度的复杂性。
fill_gradn=function(pal){
  scale_fill_gradientn(colors=pal(7), limits=c(0,0.04))
}

erupt+fill_gradn(rainbow_hcl)
#等价于：
erupt+scale_fill_gradientn(colors=rainbow_hcl(7), limits=c(0,0.04))

erupt+fill_gradn(diverge_hcl)
erupt+fill_gradn(heat_hcl)
#


#
#离散型
#默认配色方案可以对多到8种颜色有很好的区分度，缺点是黑白打印则没有区别。

#
#最感兴趣的调色板是 Set1 Dark2
# 对面积而言是 Set2 Pastel1 Pastel2 Accent
RColorBrewer::display.brewer.all() #列出所有的调色板。


#
head(msleep) #带有缺失值
dim(msleep)#[1] 83 11
point=qplot(brainwt, bodywt, data=msleep, log="xy", color=vore)
point
area=qplot(log10(brainwt), data=msleep, fill=vore, binwidth=.5)
area

point+scale_color_brewer(palette = "Set1")
point+scale_color_brewer(palette = "Set2")
point+scale_color_brewer(palette = "Pastel1") #太淡了,点不好看清
#
area+scale_fill_brewer(palette="Set1") #但是太重的颜色，让条形图太刺眼
area+scale_fill_brewer(palette="Set2")
area+scale_fill_brewer(palette="Pastel1")
#总结：点图要重色，条形图要淡色。





#
### 6.4.4 手动离散型标量
p=qplot(brainwt, bodywt, data=msleep, log="xy")
p
p+aes(color=vore) #默认颜色
p+aes(color=vore)+
  scale_color_manual(na.value="blue",
                     values=c("red","orange","yellow","green")) #手动指定颜色,NA没有颜色 done
#
colors=c(carni="red",insecti="yellow",herbi="green",omni="blue")
p+aes(color=vore)+scale_color_manual(values=colors,na.value="black")# NA没有颜色 done

#
p+aes(shape=vore)+
  scale_shape_manual(values=c(1,2,6,0,23))

#
str(LakeHuron)
head(LakeHuron)
length(LakeHuron)#[1] 98

huron=data.frame(year=1875:1972,level=LakeHuron)

ggplot(huron, aes(year))+
  geom_line(aes(y=level-5), color="blue")+
  geom_line(aes(y=level+5), color="red") #两种颜色，怎么添加图例？

##在aes中映射出颜色
ggplot(huron, aes(year))+
  geom_line(aes(y=level-5, color="below"))+
  geom_line(aes(y=level+5, color="above")) #基本符合我们的预期，稍微修正图例即可。
#
ggplot(huron, aes(year))+
  geom_line(aes(y=level-5, color="below"))+
  geom_line(aes(y=level+5, color="above")) +
  scale_color_manual("Direction", values=c("below"="blue", "above"="red"))+ #纠正图例
  ylab("level") #纠正y标签
#


#
### 6.4.5 同一型标度



#
## 6.5 图例和坐标轴

# 坐标轴和图例的组成部分
# Axis, Axis label; Tick mark and label; legend, legend title, Key, Key label;











#
###############
# 第7章 定位 P123-P146)
###############

#
mpg2=subset(mpg, cyl!=5 & drv %in% c('4','f'))
head(mpg)
dim(mpg)
table(factor(mpg$drv))
table(factor(mpg$cyl))
#
qplot(cty, hwy, data=mpg2)
qplot(cty, hwy, data=mpg2)+facet_null()#不分面，和上面没啥区别.
#
qplot(cty, hwy, data=mpg2)+facet_grid(.~cyl)#一行多列，比较y位置
qplot(cty, data=mpg2, geom="histogram", binwidth=2)+
  facet_grid(cyl~.) #多行一列，适合比较x位置，比如数据分布
qplot(cty, hwy, data=mpg2)+facet_grid(drv~cyl)#多行多列
#多个变量水平在行或者列: .~a+b或者 a+b~.  不过不常用。
qplot(cty, hwy, data=mpg2)+facet_grid(drv+cyl~.)#多行，变量1x变量2
#
#边际图
p=qplot(displ, hwy, data=mpg2)+
  geom_smooth(method='lm', se=F)
p
p+facet_grid(cyl~drv) #分面图
p+facet_grid(cyl~drv, margins=T) #分面图+边际图

# 不同的drv拟合曲线设置不同颜色
qplot(displ, hwy, data=mpg2)+
  geom_smooth(aes(color=drv), method="lm", se=F)+
  facet_grid(cyl~drv, margins=T)



#
### 7.2.2 封装分面
library(ggplot2movies)
dim(movies) #[1] 58788    24
head(movies)
#
library(plyr) #round_any 需要加载plyr包
movies$decade=round_any(movies$year,10,floor)
qplot(rating, ..density.., data=subset(movies, decade>1890),
      geom="histogram", binwidth=0.5)+
  facet_wrap(~decade, ncol=6)
#
### 7.2.3 控制标度
p=qplot(cty, hwy, data=mpg)
p
p+facet_wrap(~cyl) #默认是fixed，都不能变化
p+facet_wrap(~cyl,scales="free") #xy的标度都可变
p+facet_wrap(~cyl,scales="free_y") #y的标度都可变
#

#数据由宽变长
library(reshape2)
em=melt(economics, id="date")
head(em)
qplot(date, value, data=em, geom='line', group=variable)+
  facet_grid(variable~., scale="free_y") 
#不同的y坐标标度，便于比较同时间点的各参数的变化
#
mpg3=within(mpg2,{
  model=reorder(model, cty)
  manufacturer=reorder(manufacturer, -cty)
})
head(mpg3) #结果
models=qplot(cty, model, data=mpg3)
models #
#
models+facet_grid(manufacturer~.) #简直没法看，每个厂家一行（右侧分组）
models+facet_grid(manufacturer~., scales="free") #纵坐标只有有数据的部分，但是每一行宽度一样
models+facet_grid(manufacturer~., space="free")  #space貌似只有配合scales才有意义。
#
models+facet_grid(manufacturer~., scales="free", space="free") #较好效果
models+facet_grid(manufacturer~., scales="free", space="free")+
  theme(strip.text.y=element_text(angle=0)) #设置分组标度横着写。
# 分组横着写才能看清楚, how:done
#  theme(axis.text=element_text(angle=90))


#
### 7.2.4 分面变量缺失

#
### 7.2.5 分组与分面
xmaj=c(0.3,0.5, 1, 3, 5)
xmin=as.vector(outer(1:10, 10^c(-1,0)))
ymaj=c(500, 1000, 5000, 10000)
ymin=as.vector(outer(1:10, 10^c(2,3,4)))
dplot=ggplot(subset(diamonds, color %in% c("D", "E", "G", "J")),
             aes(carat, price, color=color))+
  scale_x_log10(breaks=xmaj, labels=xmaj, minor=xmin)+
  scale_y_log10(breaks=ymaj, labels=ymaj, minor=ymin)+
  scale_color_hue(limits=levels(diamonds$color))+
  theme(legend.position="none")
dplot
dplot+geom_point()
dplot+geom_point()+facet_grid(.~color) # 每列不同颜色
#
dplot+geom_smooth(method=lm, se=F, fullrange=T) #通过回归线，我们知道J组离群。
dplot+geom_smooth(method=lm, se=F, fullrange=T)+facet_grid(.~color)
#为什么合并显示的margin是点，不是线呢？ todo
dplot+geom_smooth(method=lm, se=F, fullrange=T)+facet_grid(.~color,margins = T)

#
### 7.2.6 并列与分面
qplot(color,data=diamonds, geom="bar", fill=cut) #dodge是堆积起来的
qplot(color,data=diamonds, geom="bar", fill=cut, position="dodge") #`position` is deprecated 
# https://ggplot2.tidyverse.org/reference/qplot.html
#可能已经不能用qplot设置position了，只好用ggplot了
#
# 柱状图，堆叠的
ggplot(diamonds, aes(x=color, fill=cut))+
  geom_bar(position="dodge")
#按照颜色分面，x轴为cut
ggplot(diamonds, aes(x=cut, fill=cut))+
  geom_bar(position="dodge")+
  facet_grid(.~color) +
  theme(axis.text=element_text(angle=60, #旋转坐标轴文字
       hjust=1,size=8,color="grey50")) 
#
#
#这个是啥??
ggplot(diamonds, aes(x=color,y=carat, fill=cut))+
  geom_histogram(stat="identity",position="dodge")

#
###
mpg4=subset(mpg, manufacturer %in% c("audi", "volkswagen", "jeep"))
dim(mpg4) #[1] 53 11
head(mpg4)
base=ggplot(mpg4, aes(fill=model))+
  geom_bar(position="dodge")+
  theme(legend.position="none")
base #Errpr
base+aes(x=model)
base+aes(x=model)+facet_grid(.~manufacturer)
#
last_plot()+facet_grid(.~manufacturer, scales="free_x", space="free") #x轴自由
base+aes(x=manufacturer)

#
### 7.2.7 连续型变量
#需要把连续型变量，转为离散型
#1.数据分为n个长度相同的部分 
  # cut_interval(x, n=10) 控制划分数目
  # cut_interval(x, length=1) 控制每个部分的长度。
#3. 分为n个有相同点的部分：cut_number(x,n=10)
head(mpg2);dim(mpg2)
mpg2$disp_ww=cut_interval(mpg2$displ, length=1)
mpg2$disp_wn=cut_interval(mpg2$displ, n=6)
mpg2$disp_nn=cut_number(mpg2$displ, n=6)
head(mpg2)
#
plot=qplot(cty,hwy, data=mpg2, color= factor(cyl))+
  #labs(x=NULL, y=NULL)+
  scale_color_hue("Cyl")+ #修改图例标题
  theme( axis.text.x=element_text(angle=90))
plot+facet_wrap(~disp_ww, nrow=1) #1位单位长度分面
plot+facet_wrap(~disp_wn, nrow=1) #一共6个，端点太难看
plot+facet_wrap(~disp_nn, nrow=1) #6个区间内点数相同

#
# 7.3 坐标系

## 7.3.1 变换
#坐标系变换，将改变图形的几何形状。

## 7.3.2 统计量

## 7.3.3 笛卡尔坐标系
#标度范围会删除范围外的数据，所以统计量（比如拟合曲线）会和局部放大不一样。
#而坐标系范围，则使用所有数据，但是只展示局部区域，和大图放大效果一致。


#
p=qplot(disp, wt,data=mtcars)+geom_smooth()
p
# 标度范围=取子集，仅用可见点拟合
p+scale_x_continuous(limits=c(325,500))
# 坐标系范围=，就像放大镜
p+coord_cartesian(xlim=c(325,500))
#
#另一个例子
d=ggplot(diamonds,aes(carat, price))+
  stat_bin2d(bins=25, color="grey70")+
  theme(legend.position="none")
d
d+scale_x_continuous(limits = c(0,2)) #为什么有空白区域？
d+coord_cartesian(xlim = c(0,2)) #覆盖区域没变
#
#坐标轴翻转
a=qplot(displ, cty, data=mpg)+geom_smooth()#计算x精确，y上的误差
b=qplot(cty, displ, data=mpg)+geom_smooth()#计算x精确，y上的误差
c=qplot(cty, displ, data=mpg)+geom_smooth()+coord_flip() #逆时针旋转90度
library(scater)
multiplot(a,b,c, cols=3)
#
# 变换
qplot(carat, price, data=diamonds)
qplot(carat, price, data=diamonds)+geom_smooth(method="lm") #为什么坐标会缩水？
a=qplot(carat, price, data=diamonds, log="xy")+ #标度层面：对xy做对数变换
  geom_smooth(method="lm")
a
#
library(scales)
a+coord_trans(x=exp_trans(10), y=exp_trans(10)) #曲线，拟合曲线过长了
#怎么限制y的显示范围呢？
a + coord_trans(x=exp_trans(10), y=exp_trans(10))+
  #scale_y_continuous(limits = c(100,15000)) #只有一条线，why?
  coord_cartesian(ylim = c(300,2e4)) #差不多，想要的效果
#
#为啥啥都不显示呢？ todo
qplot(carat, price, data=diamonds)+geom_smooth(method="lm") +
  coord_trans(x=exp_trans(10), y=exp_trans(10))

#
### 7.3.4 非笛卡尔坐标系








#
###############
# 第8章 精雕细琢(P147-P163)
###############

#
## 8.1 标度
### 8.1.1 内置主题
head(mtcars)
ggplot(mtcars, aes(disp,mpg, color=factor(gear)))+geom_point()+theme_gray() #灰背景
ggplot(mtcars, aes(disp,mpg, color=factor(gear)))+geom_point()+theme_bw() #白背景

#
h=qplot(rating, data=movies, binwidth=1)
h #主题1
previous_theme=theme_set(theme_bw()) #设置了全局主题2，但是该函数返回的是之前的主题1
h#用当前主题：主题2。主题在绘制时才影响图形
h+previous_theme #用之前的主题1绘制
#永久性设置全局为主题1
theme_set(previous_theme)
h

#
### 8.1.2 主题元素和元素函数
ht=h+labs(title="This is a histogram") #设置标题
ht
# element_text()绘制标签和标题
ht+theme(plot.title=element_text(family="Times New Roman")) #字体设置失败，todo
ht+theme(plot.title=element_text(size=20)) #标题的字号。20挺好。
ht+theme(plot.title=element_text(size=20, color="red")) #标题颜色
ht+theme(plot.title=element_text(size=20, hjust=1)) #标题右对齐
ht+theme(plot.title=element_text(size=20, face="bold")) #加粗
ht+theme(plot.title=element_text(size=20, lineheight=2)) #不知道lineheight什么意思？ todo
ht+theme(plot.title=element_text(size=20, angle=180)) #倒着写
#
# element_line() 绘制线条和线段。
h
h+theme(panel.grid.major=element_line(color="red")) #背景网格主线
h+theme(panel.grid.major=element_line(size=2)) #背景网格线宽度
h+theme(panel.grid.major=element_line(color="red",linetype="dotted")) #背景网格主线用点画
h #坐标轴默认是很浅的，还是没有显示？
h+theme(axis.line=element_line()) #坐标轴默认加黑
h+theme(axis.line=element_line(color="red")) #坐标轴红色
h+theme(axis.line=element_line(size=0.5, linetype="dashed")) #坐标轴虚线
#
# element_rect() 绘制供背景使用的矩形。
h
h+theme(plot.background = element_rect(fill="grey80", color=NA)) #周围画布上灰色了
h+theme(plot.background = element_rect(color="red"))
h+theme(plot.background = element_rect(fill="grey80", color="red")) #周围画布边框红色
h+theme(plot.background = element_rect(size=20)) #没啥影响？ todo
h+theme(plot.background = element_rect()) #没变化
h+theme(plot.background = element_rect(color=NA)) #没变化
h+theme(plot.background = element_rect(linetype="dotted",color="red")) #点图
#
# element_blank()表示空主题。
# 之前的 color=NA; fill=NA 让某些元素不可见，可达到相同的效果。
ht
ht+theme(panel.grid.minor=element_blank()) #没小格子
ht+theme(panel.grid.major=element_blank()) #没大格子
ht+theme(panel.background=element_blank()) #没背景灰了
ht+theme(axis.title.x = element_blank()) #x轴标签没了
ht+theme(axis.title=element_blank()) #x和y轴标签没了
ht+theme(axis.line=element_blank()) #干了什么？ todo

#
theme_get() #可得到当前主题的设置
theme() #可在一幅图中对某些元素进行局部的修改，
#theme_update() 可为后面图形的绘制进行全局性的修改。
old_theme=theme_update(
  plot.background=element_rect(fill="#3366FF"),
  panel.background=element_rect(fill="#003DF5"),
  axis.text.x=element_text(color="#CCFF33"),
  axis.text.y=element_text(color="#CCFF33", hjust=1),
  axis.title.x=element_text(color="#CCFF33", face="bold"),
  axis.title.y=element_text(color="#CCFF33", face="bold", angle=90)
)
qplot(cut, data=diamonds, geom="bar")
qplot(cty, hwy, data=mpg)
theme_set(old_theme) #恢复全局设置
qplot(cty, hwy, data=mpg)
#
#自定义主题很繁琐，不过如果你想拥有自己的主题，
#最好写一个函数来最小化这种重复。

#
## 8.2 自定义标度和几何对象
#格式 scale_aesthetics_continuous 或者 scale_aesthetics_discrete
#替换中间 aesthetic 为图形属性，如 color，fill, size等。
p=qplot(mpg, wt, data=mtcars, color=factor(cyl))
p
scale_color_discrete=scale_color_brewer #发生了什么？ todo
p


#
### 8.2.2 几何对象和统计变换
#类似 update_geom_defaults() 和 update_stat_defaults()， 
#我们也可以自定义集合对象和统计变换。
update_geom_defaults("point", aes(color="darkblue"))
qplot(mpg, wt, data=mtcars)
update_stat_defaults("bin", aes(y=..density..))
qplot(rating, data=movies, geom="histogram",binwidth=1)
#
#恢复默认
theme_set(theme_gray()) #恢复失败，怎么恢复默认值 todo


#
## 8.3 存储输出
#ggsave:path; width,height; dpi;
setwd("F://Temp")
#
q=qplot(mpg, wt, data=mtcars)
q
ggsave(file="ggsave.pdf") #保存当前图形
# 两个图形保存到一个文件，则需要打开基于磁盘的图形设备(比如png(), pdf()),然后关闭dev.off()
pdf(file="pdf.pdf", width=6, height=6)
qplot(mpg, wt, data=mtcars) #图1
qplot(wt, mpg, data=mtcars) #图2
dev.off()
#
png(file="dev.png", width=400, height=400) #怎么设置分辨率？ todo
qplot(mpg, wt, data=mtcars) #图1
dev.off()
#

#
## 8.4 一页多图

(a=qplot(date, unemploy, data=economics, geom="line"))
(b=qplot(uempmed, unemploy, data=economics)+ geom_smooth(se=F))
(c=qplot(uempmed, unemploy, data=economics, geom="path"))
#
## 8.4.1 子图
# 
library(grid)
##
#默认的单位是npc，范围是(0,0)是左下角，(1,1)是右上角。
##
#
#一个占据整个图形设备的视图窗口
vp1=viewport(width=1, height=1, x=0.5, y=0.5)
vp1=viewport()
# 只占图形设备一半的宽和高的视图窗口
# 定位在图形的中间位置
vp2=viewport(width=0.5, height=0.5, x=0.5, y=0.5)
vp2=viewport(width=0.5, height=0.5)
#一个2cm x 3cm 的视图窗口，定位在图形设备中心
vp3=viewport(width=unit(2,"cm"), height=unit(3,"cm"))
#
# 默认地，x和y参数控制着视图窗口的中心位置，若想调整图形位置，用just控制放在哪个角落
#放在右上角的视图窗口
vp4=viewport(x=1, y=1, just=c("right", "top"))
#处在左下角
vp5=viewport(x=0, y=0, just=c("right", "bottom"))
#
pdf("polishing-subplot-1.pdf", width=4, height=4)
subvp=viewport(width=0.4, height=0.4, x=0.75, y=0.35)
b
print(c, vp=subvp)
dev.off()
#
#效果不好，还要移除坐标轴标签，缩减边界
csmall=c+theme_gray(9)+
  labs(x=NULL, y=NULL)+
  theme(plot.margin=unit(rep(0,4), "lines")) #周围四个全是0
csmall
#
pdf("polishing-subplot-2.pdf", width=4, height=4)
b
print(csmall, vp=subvp)
dev.off()
# ggsave只有保存一幅图，所以使用pdf或者png保存多图。

#
### 8.4.2 矩形网络
grid.layout() #只需要设置布局 layout 的行数和列数即可。
pdf("polishing-layout.pdf", width=8, height=6)
grid.newpage()
pushViewport(viewport(layout=grid.layout(2,2))) #指定了2行2列
#grid.layout中默认每个单元格大小相同， help(grid.layout)
#可以设置 widths和heights参数使它们具有不同的大小。
vplayout=function(x,y){
  viewport(layout.pos.row=x, layout.pos.col=y)
}
print(a, vp=vplayout(1,1:2))
print(b, vp=vplayout(2,1))
print(c, vp=vplayout(2,2))
dev.off()
#








#
###############
# 第9章 数据操作(P164-P)
###############


#

#

#

#

#

#

#

#

#

#


#合并到一张图
library(scater)
multiplot(p1, p2, p3, p4, cols=2)



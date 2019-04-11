############
#画heatmap图，自定义热图颜色，比如按照p值显著性标记颜色。
############
#for 王志伟
#2019.4.11

#载入包
library(Cairo)
library(pheatmap)

#设定工作目录
setwd('/data/wangjl/temp')

#读取数据
load("d1.rData")
#d1=read.table("clipboard", sep="\t",header=T,row.names = 1)
d1
#        30	42	52	57	62	67	69
#DonorB	0.0957	0.0985	0.0918	0.0211	0.0377	0.0209	0.0403
#DonorC	0.2187	0.0034	0.171	0.2886	0.0611	0.0339	0.4722
#DonorD	0.3828	0.3167	0.4028	0.0064	0.2454	0.1383	0.0281
#DonorE	0.009	0.4567	0.187	0.2691	0.1672	0.0185	0.2335
#DonorF	0.183	0.4269	0.4357	0.0087	0.172	0.0182	0.0118

#绘图函数
drawHM=function(w,h,mycolor){
  CairoPDF(file="heatmap1.pdf",width=w,height=h)
  pheatmap(d1, border=FALSE, 
           cluster_cols = F,
           cluster_rows = F,
           #scale="row",
           #annotation_col=tmp.type,
           display_numbers = TRUE, number_format = "%2.4f",
           number_color = "black",
           #color
           color = mycolor
             #colorRampPalette(c("firebrick3", "white","blue"))(20)
           #legend_breaks=seq(-6,6,2),
           #breaks=bk
  )
  dev.off()
}
mycolor=c("#CD2626", "#D23C3C", "#D75353", "#DC6A6A", "#E28181",
  "#F9E6E6", "#F9E6E6", "#F9E6E6", "#F9E6E6", "#F9E6E6") #blue
drawHM(5,3,mycolor)
getwd()
#save(d1,file="d1.rData")
# 第一次尝试失败











#######
#try2 使用image画热图
#https://www.jianshu.com/p/c17a7c92b7fe

#image(x, y, z, zlim, xlim, ylim, col = heat.colors(12), 
#      xlab, ylab, breaks, ...)　　
#z: 用于画图的数据，矩阵类型
#x, y: 数据在x和y轴的坐标
#zlim: 数据的范围，默认值是z矩阵中的最小值到最大值
#xlim, ylim: 图片中x和y的数据阈值
#col: 设定颜色阈值
#breaks: 颜色对应的数据断点
#xlab, ylab: x轴和y轴的标题


# 读取样本数据
#m <- data.frame(
#  rep1 = sample(1:20),
#  rep2 = sample(1:20)
#)
m=t(d1) #使用数据
m

################
#1.矩阵转为列向量
tmp=NULL
for(i in 1:nrow(d1)){
  tmp=c(as.double(unname(d1[i,])) ,tmp)
}
tmp
tmp2=tmp[order(tmp)]
tmp2
max(tmp2) #[1] 0.4722
min(tmp2) #[1] 0.0034
ddiff=max(tmp2)-min(tmp2)
ddiff #[1] 0.4688


################
#2.定义颜色向量(为每个最小的变量设置颜色，共设置了4688个颜色值，每个颜色值都来自以下四个中的一个)
#MyCOLOR=c("#FF0000","#E38686","#F9E6E6","#eeeeee") #定义四种区间的颜色 <1>0.001<2>0.01<3>0.05<4>
MyCOLOR=c("#FF0000","#FF5555","#FFA3A3","#EFEEEF") 

mycolor=NULL
for(i in 1:(10000*ddiff)){
  num=min(tmp2)+0.0001*i;
  if(num<=0.001){
    mycolor=c(mycolor,MyCOLOR[1])
  }else if(num<=0.01){
    mycolor=c(mycolor,MyCOLOR[2])
  }else if(num<=0.05){
    mycolor=c(mycolor,MyCOLOR[3])
  }else{
    mycolor=c(mycolor,MyCOLOR[4])
  }
}
mycolor

################
# 写一个绘图函数
draw_image <- function(data, label = FALSE,mycolor) {
  # 设定绘图参数
  #breaks.frequency <- seq(from=min(data), to=max(data), length.out=10)
  #myColors <- colorRampPalette(c("white", "#2874A6"))
  
  # 产生图片
  image(1:nrow(data), 1:ncol(data), as.matrix(data),  
        #breaks=breaks.frequency,
        #col=myColors(length(breaks.frequency)-1), 
        col=mycolor,
        axes = F, cex = 1.5, xlab = "", ylab = "")

  # 自定义axis
  axis(3, #3是top显示坐标轴
       at=1:nrow(data), #坐标轴刻度位置
       substr(rownames(data),2,3), #坐标轴刻度
       lwd=0,lwd.ticks=0) #隐藏坐标轴和刻度, cex.axis=2.5 定义字体大小
  axis(2, at=1:ncol(data), colnames(data), 
       las=2, #旋转坐标轴文字90度
       lwd=0,lwd.ticks=0) #y, cex.axis=2.5

  # 自定义热图文本
  if (label) {
    for (x in 1:nrow(data)) {
      for (y in 1:ncol(data))  {
        text(x, y, data[x, y])#, cex = 2
      }
    }
  }
}
# 绘制图形
CairoPDF(file="heatmap2.pdf",width=7,height=3.5)
#1.图下面留空
par(mai=c(1,1,0.5,0.5))
#画图
draw_image(m, T,mycolor)
#2.图例
legend(x=1,y=-0,border = "black",lty=0,
       legend=c("<=0.001", "0.001~0.01", "0.01~0.05", ">0.05"),
       fill=MyCOLOR,
       xpd=T, #要设置xpd=T才能在图外画图例
       ncol=4,#ncol几列
       bty="n"
       ) 
dev.off()


#函数库 v2.0

#载入包
library(Cairo)

#定义四种基本颜色 <1>0.001<2>0.01<3>0.05<4>
BaseColor=c("#FF0000","#FF5555","#FFA3A3","#EFEEEF") 

################
#function 获取颜色列表
################
getMyColor=function(d){
  #1.求极差
  minD=min(d)
  ddiff=max(d)-minD
  print(paste0("ddiff=",ddiff)) #[1] 0.4688

  #2.使用基本颜色，按照p值生成一系列颜色向量
  #按照1步长逐个从min到max为p值指定颜色（四个基本颜色之一）
  myColor=NULL
  for(i in 1:(10000*ddiff)){#==========Attention: 根据ddiff结果调整倍率，使其乘积为正整数
    num=minD+0.0001*i;
    if(num<0.001){
      myColor=c(myColor,BaseColor[1])
    }else if(num<0.01){
      myColor=c(myColor,BaseColor[2])
    }else if(num<0.05){
      myColor=c(myColor,BaseColor[3])
    }else{
      myColor=c(myColor,BaseColor[4])
    }
  }
  print( paste0("length(myColor)=",length(myColor) ) ) #4688
  return(myColor)
}



################
#function 画热图函数
################
heatmap_p <- function(data, colorArr, txt="", label = T) {
  # 设定绘图参数
  #1.图下面留空c(bottom, left, top, right) 
  par(mai=c(0.8,2,1,0.5)) ##==========Attention: 修改画布的边距
  
  #热图主体
  image(1:nrow(data), 1:ncol(data), as.matrix(data),col=colorArr, axes = F, 
        cex = 1.5, xlab = "", ylab = "")
  
  # 自定义axis
  axis(3, #3是top显示x坐标轴
       mgp=c(1,0.2,0), #控制坐标轴刻度与坐标轴的距离
       at=1:nrow(data), #坐标轴刻度位置
       rownames(data), #substr(rownames(data),2,3), #坐标轴刻度
       las=2,
       lwd=0,lwd.ticks=0) #隐藏坐标轴和刻度, cex.axis=2.5 定义字体大小
  axis(2, at=1:ncol(data), colnames(data), 
       mgp=c(1,0.2,0),
       las=2, #旋转坐标轴文字90度
       lwd=0,lwd.ticks=0)
  #调整轴元素之间的距离：mgp=c(2.5,1,0)
  # mgp:坐标轴各部件的位置。
  #第一个元素为坐标轴位置到坐标轴标签的距离，以文本行高为单位。
  #第二个元素为坐标轴位置到坐标刻度标签的距离。
  #第三个元素为坐标轴位置到实际画的坐标轴的距离，通常是0。
  
  #图片的标题
  title(main=txt)
  # 自定义热图文本
  if (label) {
    for (x in 1:nrow(data)) {
      for (y in 1:ncol(data))  {
        text(x, y, round(data[x, y],4) )#, cex = 2
      }
    }
  }

  #2.图例
  legend(x=1,y=0.5,border = "black",lty=0,
         legend=c("<0.001", "0.001~0.01", "0.01~0.05", ">=0.05"),
         fill=BaseColor,
         xpd=T, #要设置xpd=T才能在图外画图例
         ncol=4,#ncol几列
         bty="n" #不要图例边框
  )
}

############
#画heatmap图，自定义热图颜色，比如按照p值显著性标记颜色。
############
#for 王志伟
#2019.4.11
# version: 1.0.2 简化
#使用image画热图 https://www.jianshu.com/p/c17a7c92b7fe

#step0 预备
#设定工作目录
setwd('F:\\Temp\\DESeq2\\wangzw\\');##==========注意：所有文件都要放到这里
#（提前把数据用excel另存为csv格式的，不要出现中文文件名）
getwd()
#载入函数库
source("heatmap_p-lib.R")


#step1.读取数据
fname="data3" #==========修改csv的文件名
d1=read.csv(paste0(fname,".csv"), sep=",",header=T,row.names = 1); 
#颠倒行顺序
d1=d1[rev(rownames(d1)),];
dim(d1) #检查数据行列数，是否异常
d1[1:3,1:3] #检查前3行前3列，是否异常


#step2.设置颜色list
myColor=getMyColor(d1)
#3.绘制图形
CairoPDF(file=paste0("heatmapP-",fname,".pdf"),width=8,height=5)#==========设置pdf的宽高(7,3.5)(12,8)
#只要这一句就可以看到图，但是有上下两句可以得到高清pdf文件。
heatmap_p(d1,myColor, fname) 
dev.off()

#然后可以清理R环境，
rm(d1,fname,myColor)
#从step1开始，接着做下一个图。
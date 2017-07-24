# 输入vntr的矩阵数据
#http://bbs.pinggu.org/thread-772338-1-1.html
vntr=read.csv('clipboard',sep="\t")
vntr2=vntr[,-1] #去掉第一列
#rownames(vntr2)=vntr2[,1]
head(vntr2)

n=sum(is.na(vntr))#输出缺失值个数

#缺失值替换为0
vntr[is.na(vntr)]=0
#如果是？?"",替换为0
vntr[vntr=="？"]=0
vntr[vntr=="?"]=0
vntr[vntr==""]=0
write.csv(vntr,file="d:\\vntr_filterd.txt")

n=sum(is.na(vntr))#输出缺失值个数



vntr3=data.matrix(vntr2)
heatmap(vntr3)



boxplot(vntr3,horizontal=F)#绘制水平箱形图
########
library("pheatmap")
pheatmap(vntr3, color=colorRampPalette(c("green","black","red"))(50), 
         #cluster_cols=FALSE,
         fontsize_row = 10,scale="none", border_color = NA)

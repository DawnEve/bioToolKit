#获取各个基因的在各个分期的平均值

#############
# v0.1
# 参考
# http://www.cnblogs.com/studyzy/p/4316118.html
# https://cos.name/cn/topic/12365/
#############

setwd("D:\\data\\meanGEO")
getwd();

###############读取表达数据
expdata=read.csv("expression.csv",header=T)
rownames(expdata)=expdata[,1]
expdata=expdata[,-1] #减去第一列
#expdata=t(expdata)

###############读取临床数据
clinicalData=read.csv("clinical_data.csv",header=T)
#rownames(clinicalData)=clinicalData[,1]
#clinicalData=clinicalData[,-1] #减去第一列

###########
#从namedNum中获取数值数组
getNum=function(namedNum){
  arr=c();
  len=length(namedNum)
  for(i in 1:len){
    arr[i]=namedNum[[i]]
  }
  return(arr)
}

###############按照TNM分期获得GSM编号
tnm=clinicalData$TNM

for(i in unique(tnm)){
  subgroup=expdata[,which(clinicalData$TNM==i)] #获得GSM列
  #求行的平均数
  assign(paste('T',i,sep=""), getNum(rowMeans(subgroup)))
}


############## 合并成数据框
result=data.frame(T1=T1,T2=T2,T3=T3,T4=T4)
rownames(result)=rownames(expdata)

############## 输出结果
write.csv(result,file="result2.csv")



############# 画heatmap图

library("pheatmap")
selected=result;
#按列表转化色彩。最好
pheatmap(selected, color=colorRampPalette(c("green","black","red"))(50), cluster_cols=FALSE,
         fontsize_row = 10,scale="row", border_color = NA)




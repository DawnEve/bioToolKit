#source("https://bioconductor.org/biocLite.R")

#source("http://bioc.ism.ac.jp/biocLite.R")
#biocLite("hgu133acdf")

#biocLite() #推荐先安装默认组件 
#biocLite('affy') #再具体安装某一个
#setwd("C:/Users/Administrator/Desktop/GSE41258/") #输入文件路径
#getwd()
#install.packages("ggplot2")
#biocLite("ggplot2")




#http://www.dxy.cn/bbs/topic/24357513

#读取数据
setwd("C:/Users/Administrator/Desktop/GSE")
affybatch <- ReadAffy(celfile.path = "../GSE41258" )

#标准化
library(hgu133acdf)
library(affy)
eset <- rma(affybatch)

#保存数据
write.exprs(eset,file="mydata.txt" )
#读取数据
gse=read.table("mydata.txt",sep="\t",header = T,row.names = 1)
head(gse[1:5,1:5])

#获取表达矩阵
exp <- exprs(eset)
exp[1:5,1:5]
#exp就是数字化的表达谱矩阵了
#请注意，rma只使用pm信号，exp数据已经进行log2处理。mas5综合考虑pm和mm信号，exp数据没有取对数。

###############
#基因注释
library(annotate)
#获取 GPL 平台名
affydb=annPkgName(affybatch@annotation,type="db");affydb #"hgu133a.db"
#载入注释信息包
library(affydb, character.only = TRUE)

#添加基因注释
dif=data.frame(
  symbols=getSYMBOL(rownames(exp),affydb),
  EntrezID=getEG(rownames(exp),affydb)
)
head(dif,n=10)



#
exp[1:3, c(1,3)]

write.table(colnames(exp),"colname2.txt",quote=F,row.names =F)

#去掉列名的后缀
tmp=colnames(exp)
head(tmp)
tmp2=gsub('_.*gz',"",tmp)
head(tmp2)
exp2=exp
colnames(exp2)=tmp2
exp2[1:3,1:3]
exp=exp2
rm(exp2)


#获取每一类的GSM number
#Liver Metastasis
#Normal Liver 
#Normal Colon
#Primary Tumor
getGSMNo=function(fname){
  #fname="PT.txt"
  tmp=read.table(fname,sep="\t")$V1
  print(length(tmp))
  tmp
}
PT=getGSMNo("PT.txt")#186
NC=getGSMNo("NC.txt")#54
NL=getGSMNo("NL.txt")#13
LM=getGSMNo("LM.txt")#47


#获取基因表达信息，比如
head(dif)
gname="ALDOB"

which(dif$symbols==gname)
# grep("ALDOB",dif$symbols)
# [1]  4231  4232 10773 13802 13803 15970 16605
dif$symbols[13804]
dif[13803,]

#注释表达矩阵，多个探针的取平均值
#
exp[1:3,1:3] #表达矩阵
head(dif) #注释
dif[1,1]==NULL


#重新使用GPL文件注释
#读取注释文件
annotation2=read.table("GPL96-57554-1.txt",sep="\t",header = T)
head(annotation2)
dim(annotation2) #[1] 22283     2

#用空格拆分字符串
tmp=as.character(annotation2[1,2]);tmp
strsplit(tmp," ")[[1]][1]
#检查是否包含///
#todo

#是否有空基因名
length(which(is.na(annotation2$Symbol))) #0说明没有空基因名字


#看一共多少个uniq gene symbol
uniqSymbol=c()
for(i in 1:nrow(annotation2)){
  if( i%%2000 == 0){  #进度条
    print(i) 
  }
  gname=as.character(annotation2[i,2])
  #gname=annotation2[i,2]
  if(gname %in% uniqSymbol){
    next
  }else{
    uniqSymbol=c(uniqSymbol,gname)
  }
}
length(uniqSymbol) #[1] 13514
head(uniqSymbol)


#对于uniqSymbol
for(gname in uniqSymbol){
  print(i)
}





toDF=function(d){ #转变为数据框
  tmp=data.frame(
    gsm=attr(tmp2,"names"),
    num=as.numeric(tmp2),
    row.names=1
  )
  as.data.frame(t(tmp))
}



i=0
results=NULL
for(gname in uniqSymbol){
  i=i+1
  if( i%%2000 == 0){  #进度条
    print(i) 
  }
  #begin
  #gname#="ALDOB"
  # grep("ALDOB",dif$symbols)
  # [1]  4231  4232 10773 13802 13803 15970 16605
  rows=which(annotation2$Symbol==gname)
  rowCount=length(rows) #求该gene symbol对应的探针个数
  tmp2=exp[rows,]
  
  if(rowCount>1){
    #则计算平均值
    #annotation2$Symbol[rows]
    #exp[10773,1:3]
    tmp2=apply(tmp2[,],2,mean)
  }
  tmp3=toDF(tmp2)
  rownames(tmp3)=gname
  #合并导数据框
  results=rbind(results,tmp3)
}

results[1:3,1:3]
dim(results)


##########
write.table(results,"afterCombineProbe_ByMean.txt")



#通过模糊的基因名字，查找基因行名
gname="ALDOB"
rs=grep(gname,annotation2$Symbol);rs
annotation2[rs,]

#取出某一个基因的一行
exp.ALDOB=results["ALDOB",]
dim(exp.ALDOB)
exp.ALDOB[,1:3]


#按照肿瘤样本分类
type=c()
for(gsm2 in colnames(exp.ALDOB)){
  if(gsm2 %in% LM){ 
    type=c(type,"LM") 
  }else if(gsm2 %in% NC) type=c(type,"NC")
  else if(gsm2 %in% NL) type=c(type,"NL")
  else if(gsm2 %in% PT) type=c(type,"PT")
  else type=c(type,"")
}
length(type) #390

texp.ALDOB=as.data.frame(t(exp.ALDOB))
texp.ALDOB$type=type
head(texp.ALDOB)
dim(texp.ALDOB)#390 2

#删除type为空的行
texp.ALDOB2=texp.ALDOB[-which(texp.ALDOB$type==""),]
dim(texp.ALDOB2) #300 2
head(texp.ALDOB2)

#画图 boxplot
boxplot(ALDOB~type,texp.ALDOB2,xlab="Tumor type",ylab="log2[expression]",main=gname)

########
# 用GPL文件为GSE注释出gene symbol
# v0.1 for 陈春霞
# jimmymall at 163 dot com
########


#先用shell做预处理
# 去掉前61行
# $ sed '1,61d' GSE37175_series_matrix.txt > GSE37175_series_matrix.2.txt
# 删除最后一行
# $ sed '$d' GSE37175_series_matrix.2.txt > GSE37175_series_matrix.3.txt
# 
# 去掉前30行
# $ sed '1,30d' GPL6947-13512.txt >GPL6947-13512.2.txt
# 
# 只保留两列ID、Symbol
# $ awk -F"\t" '{print $1"\t"$14}' GPL6947-13512.2.txt >GPL6947-13512.3.txt
# $ head GPL6947-13512.3.txt
# ID      Symbol
# ILMN_1725881    LOC23117
# ILMN_1910180
# ILMN_1804174    FCGR2B
# ILMN_1796063    TRIM44


# 用R注释出symbol
## 设置工作目录
setwd("C:\\Users\\admin\\Downloads\\GSE37175")
getwd()

#1.read file1 GSE
gse=read.table("GSE37175_series_matrix.3.txt",sep="\t",header=T,row.names=1)
#dim(gse)
#head(gse[,1:5])
#获取id列
gse_id=row.names(gse)
head(gse_id)
length(gse_id) #[1] 48803

#2. read GPL
gpl=read.table("GPL6947-13512.3.txt",header=T,sep="\t",row.names=1)
#dim(gpl)
#head(gpl)

#3. annotate
sb=c()
for(j in 1:length(gse_id) ){
  id=gse_id[j]
  if(j%%3000==0) print(j)
  tmp=as.character(gpl[id,1])
  sb=c(sb, tmp);
}
print( length(sb) ) #[1] 48803

#
tmp=gse
dim(tmp) #[1] 48803    88

tmp2=cbind(symbol=sb, tmp[,1:ncol(tmp)])
dim(tmp2) #[1] 48803    89 多了一列
tmp2[1:10,1:5]


#4. 检测
#symbol有很多空的、重复的
#4.1空的行有12646个
table(sb=="")
#FALSE  TRUE 
#36157 12646 
#4.2 重复的怎么检测
t1=table(sb)

tb=data.frame(
  symbol=attr(t1,"dimnames")[[1]],
  count=as.numeric(t1)
)
head(tb)
dim(tb2) #[1] 25160     2 剩余25160个uniq gene symbol
tb2=tb[order(-tb$count),]
head(tb2,n=20) #重复的基因symbol和重复的次数，按重复次数倒序排列
#
tb3=tb2[tb2$count==1,]
dim(tb3) #[1] 18160     2 剩下18160个 gene symbol只出现1次

#5. 仅保留 symbol 出现1次的行，并保存到文件
tmp3=tmp2[tmp2$symbol %in% tb3$symbol,]
dim(tmp3) #[1] 18160    89
tmp3[1:10,1:5]
#5.1第一列当做行名
row.names(tmp3)=tmp3$symbol
tmp3=tmp3[,-1] 
#5.2 save
write.csv(tmp3,"GSE_with-symbol.csv")
#


# 这样注释信息损失很大：48803行剩下18160行。
#1. 以上代码，一个基因多个探针的，被全部删除了。
#2. 有些软件是合并一个基因的多个探针，再下游处理。
#3. 还有软件用探针为单位做的，有显著的id再注释出symbol，不能直接用GPL注释的用blast看能注释成什么基因
# 

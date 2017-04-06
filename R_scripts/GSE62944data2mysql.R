###########################
# from: http://www.bio-info-trainee.com/2179.html
# 1.需要从ncbi下载数据：https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSE62944
# 2.然后解压  gzip -d xx.gz
# 3.下载安装MySQL数据库，并新建数据库gse62944。
# 4.
##########################


rm(list = ls())
#install.packages('RMySQL');
library(RMySQL)
con <- dbConnect(MySQL(), host="127.0.0.1", port=3306, user="root", password="") 
dbSendQuery(con, "USE gse62944")
dbListTables(con)
setwd('D:\\R_code\\GSE62944')

## 写入cancer类型到db
tumorCancerType2amples=read.table('GSE62944_06_01_15_TCGA_24_CancerType_Samples.txt',sep = '\t',stringsAsFactors = F)
colnames(tumorCancerType2amples)=c('sampleID','CancerType')
dbWriteTable(con, 'tumorCancerType2amples', tumorCancerType2amples, append=F,row.names=F)  #写入数据库
#
# 关于R操作db的细节参考博客 NGS->3.1 R语言基础
#

##写入normal类型到db
normalCancerType2amples=read.table('GSE62944_06_01_15_TCGA_24_Normal_CancerType_Samples.txt',sep = '\t',stringsAsFactors = F)
colnames(normalCancerType2amples)=c('sampleID','CancerType')
dbWriteTable(con, 'normalCancerType2amples', normalCancerType2amples, append=F,row.names=F)

## 写入
Clinical_Variables=read.table('GSE62944_06_01_15_TCGA_24_548_Clinical_Variables_9264_Samples.txt',sep = '\t',stringsAsFactors = F)

## 需要点开GSM后才能找到下载地址
normalRPKM=read.table('GSM1697009_06_01_15_TCGA_24.normal_Rsubread_FPKM.txt.gz',sep = '\t',stringsAsFactors = F,header = T)




# http://www.bio-info-trainee.com/2179.html
# https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSE62944

colnames(normalRPKM)[1]='geneSymbol'
rownames(normalRPKM)=normalRPKM$geneSymbol
normalRPKM=normalRPKM[,-1]
normalRPKM=round( as.matrix(normalRPKM),3)  
normalRPKM=as.data.frame(normalRPKM)
normalRPKM$geneSymbol = rownames(normalRPKM)
dbWriteTable(con, 'normalRPKM', normalRPKM, append=F,row.names=F)


tumorRPKM=read.table('GSM1536837_06_01_15_TCGA_24.tumor_Rsubread_FPKM.txt.gz',sep = '\t',stringsAsFactors = F,header = T)
colnames(tumorRPKM)[1]='geneSymbol'
rownames(tumorRPKM)=tumorRPKM$geneSymbol
tumorRPKM=tumorRPKM[,-1]
tumorRPKM=round( as.matrix(tumorRPKM),3)  
tumorRPKM=as.data.frame(tumorRPKM)
tumorRPKM$geneSymbol = rownames(tumorRPKM)
#load(file = 'tumorRPKM.rData')
lapply(unique((tumorCancerType2amples$CancerType)), function(x){
  #x='PRAD';
  sampleList=tumorCancerType2amples[tumorCancerType2amples$CancerType==x,1]
  sampleList=gsub("-",".", sampleList)
  tmpMatrix=tumorRPKM[,c('geneSymbol',sampleList)]
  dbWriteTable(con, paste('tumor',x,'RPKM',sep='_'), tmpMatrix, append=F,row.names=F)
  
})
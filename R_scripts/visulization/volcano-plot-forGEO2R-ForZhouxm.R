#http://agetouch.blog.163.com/blog/static/22853509020161194123526/
#  Using ggplot2 for volcano plots 使用ggplot2画火山图
library(ggplot2)

#读取数据 #data download from GEO2R result
setwd("C:\\Users\\Administrator\\Desktop")
dif=read.table(file="Primary Tumor_Normal Colon.txt",header=T,row.names=1)
dif[1:3,1:4]

#添加显著与否标签
no_of_genes=nrow(dif);no_of_genes #4653
dif$threshold = as.factor(abs(dif$logFC) > 2 & dif$P.Value < 0.05/no_of_genes)

#画火山图
g = ggplot(data=dif, aes(x=logFC, y=-log10(P.Value), colour=threshold)) +
  geom_point(alpha=0.4, size=1.75) +
  #opts(legend.position = "none") + 
  theme(legend.title=element_blank()) +
  scale_colour_hue(labels=c("Not sig.","Sig."))+
  #xlim(c(-10, 10)) + ylim(c(0, 15)) +
  xlab("log2[fold change]") + ylab("-log10[p-value]") +
  labs(title="Volcano plot")
g

#只标注显著基因的基因名
# 选出一部分基因：FC大且p小的基因
dd_text = dif[(abs(dif$logFC) > 2) & (dif$P.Value < 0.05/no_of_genes),]
head(dd_text)

#添加文字-基因名
g + geom_text(data=dd_text, aes(x=logFC, y=-log10(P.Value), label=dd_text$Gene.symbol), colour="black")

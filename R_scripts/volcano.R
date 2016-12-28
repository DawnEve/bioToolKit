#

data=read.table("D://R_code/volcano.txt",header = TRUE)
selected=as.matrix(data)  #转换矩阵
head(selected)

##
plot(data$logfc, -log10(data$pvalue),
     xlim=c(-5, 5), ylim=c(0, 15), #Set limits
     xlab="log2 fold change", ylab="-log10 p-value")#Set axis labels



##ggplot2
library(ggplot2)
##Highlight genes that have an absolute fold change > 2 and a p-value < Bonferroni cut-off
no_of_genes=nrow(data)
#data$threshold = as.factor(abs(data$logfc) > 2 & data$pValue < 0.05/no_of_genes)

##Construct the plot object
#g = ggplot(data=data, aes(x=logfc, y=-log10(pValue), colour=threshold)) +
g = ggplot(data=data, aes(x=logfc, y=-log10(pvalue))) +
  geom_point(alpha=0.4, size=1.75) +
  # opts(legend.position = "none") + 
  xlim(c(-3, 3)) + ylim(c(0, 26)) +
  xlab("log2 fold change") + ylab("-log10 p-value")
g


data.symbols=row.names(data)
#添加文字-基因名
g + geom_text(data=data, aes(x=logfc, y=-log10(pvalue), label=data.symbols),
              colour="black")


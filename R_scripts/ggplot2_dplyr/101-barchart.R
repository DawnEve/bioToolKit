#画堆叠图

#本文数据纯属虚构。
aa=data.frame(
  A=c( 6305, 37610, 15507, 27069, 13302, 31306 ),
  B=c(159214,  36565,  49019,  73803,  84465, 110251),
  C=c(44724, 19901, 27441, 39047, 41661, 48235),
  geneSymbol=c("gene1", "gene2", "gene3", "gene4", "gene5", "gene6")
)
aa
#######
#1.用R基本绘图语句
#######
aa1=aa[,-4]
row.names(aa1)=aa$geneSymbol
aa1
#      A B C
#gene1    6305  159214   44724
#gene2   37610   36565   19901
#gene3   15507   49019   27441
#gene4   27069   73803   39047
#gene5   13302   84465   41661
#gene6   31306  110251   48235
barplot(t(aa1),col=c("coral", "grey", "white" ),
 width=0.2, beside <- FALSE,
 main="Fig1. barplot",
 las=3,#坐标竖着写
 cex.names=0.8,
 xlab="geneSymbol", ylab="Expression"
)
legend(0.4,200000, title="Sample", 
 #legend("top", title="type", 
 legend= c("A","B","C"), 
 text.font = 10,
 fill =c("coral", "grey", "white" ), box.lty=0)


#######
#2.如果想按照A进行排序呢？
#######
#使用sort函数对数据框进行排序
aa1=aa1[order(aa1$A),]
#回到上一步画图步骤，画图(略)  

#######
#3.用ggplot2包画图
#######
#听说ggplot2画图漂亮，我们就试试
#不过ggplot2只能输入一列数据，一列分组，我们就需要先融合数据
library(reshape2)
d1=melt(aa, id.vars = "geneSymbol",
        measure.vars=c("C","B","A"),
        variable.name = "sample",
        value.name = "expression")
dim(d1)#[1] 18  3
head(d1)
#  geneSymbol sample expression
#1      gene1      C      44724
#2      gene2      C      19901
#3      gene3      C      27441
#4      gene4      C      39047
#5      gene5      C      41661
#6      gene6      C      48235

library(ggplot2)
p <- ggplot(d1, aes(x=geneSymbol, y=expression,fill=sample) ) + #第一版，无序
  geom_bar(stat = "identity")
#’identity’，即对原始数据集不作任何统计变换，
#而该参数的默认值为’count’，即观测数量。

p <- p + xlab("geneSymbol") + 
  ylab("expression")+
  ggtitle("Fig3. expression")+ # Adds title and labels
  #theme(axis.text.x=element_text(face="bold",size=5,angle=90,color="red"))
  theme(axis.text.x=element_text(angle=90))
p #fig3


#######
#4.ggplot2并按A排序
#######
#可以用reorder函数，第一个参数是分类，第二个参数是排序的，第三个可选参数是函数
p <- ggplot(d1, aes(x=reorder(geneSymbol,expression), y=expression,fill=sample) ) + 
  geom_bar(stat = "identity") 
p <- p + xlab("geneSymbol") + 
  ylab("expression")+
  ggtitle("Fig4. expression")+
  theme(axis.text.x=element_text(angle=90))
p 
#这一次按照A+B+C总和排序了，不是我们想要的。

#######
#5.ggplot2并按A排序2nd
#######
#reorder第三个可选参数，返回要排序的列的值即可。
p <- ggplot(d1, aes(x=reorder(geneSymbol,expression,function(x){
  #print(x)
  x[3]
}), y=expression,fill=sample) ) + 
  geom_bar(stat = "identity") 
p <- p + xlab("geneSymbol") + 
  ylab("expression")+
  ggtitle("Fig5. expression")+
  theme(axis.text.x=element_text(angle=90))
p 
#fig5 is same as fig2.


#######
#6.ggplot2并按B排序
#######
#用心的读者已经看到，在3中melt数据的时候，刻意把A放到了最底下
#measure.vars=c("C","B","A"),
#如果想按照B排序呢？仅仅更改返回值可以吗？
#不行，我们其实是想让B显示在最底下的

#目前想到的只能是重新melt数据
d2=melt(aa, id.vars = "geneSymbol",
        measure.vars=c("C","A","B"),
        variable.name = "sample",
        value.name = "expression")
#画图
p <- ggplot(d2, aes(x=reorder(geneSymbol,expression,function(x){
  #print(x)
  x[3]
}), y=expression,fill=sample) ) + 
  geom_bar(stat = "identity") 
p <- p + xlab("geneSymbol") + 
  ylab("expression")+
  ggtitle("Fig6. expression")+
  theme(axis.text.x=element_text(angle=90))
p 



#######
#7.ggplot2并按照A排序,每列标准化为100%
#######
#按照A排序，并做标准化
p <- ggplot(d1, aes(x=reorder(geneSymbol,expression,
  function(x){ x[3] }), y=expression,fill=sample)) + 
  geom_bar(stat = "identity", position = "fill")#position
p <- p + xlab("geneSymbol") + 
  ylab("expression")+
  ggtitle("Fig7. expression")+
  theme(axis.text.x=element_text(angle=90))
p 


#######
#8.ggplot2并按照A排序，给A指定红色
#######
#https://blog.csdn.net/chang349276/article/details/77476848
#scale_fill_manual() for box plot, bar plot, violin plot, etc 
#scale_color_manual() for lines and points
p <- ggplot(d1, aes(x=reorder(geneSymbol,expression,
  function(x){ x[3] }), y=expression,fill=sample)) + 
  geom_bar(stat = "identity")
p <- p + xlab("geneSymbol") + 
  ylab("expression")+
  ggtitle("Fig8. expression")+
  theme(axis.text.x=element_text(angle=90))+
  scale_fill_manual(values=c("#619CFF","#00BA38", "#F8766D"))
p


#######
#9.ggplot2并按总表达量排序，标数值
#######
p <- ggplot(d1, aes(x=reorder(geneSymbol,expression), y=expression,fill=sample)) + 
  geom_bar(stat = "identity")
p <- p + xlab("Gene Symbol") + ylab("Expression")+
  ggtitle("Fig9. Expression")+
  theme(axis.text.x=element_text(angle=90))
#geom_text(aes(label=percent(round(per,3)),y=pos))
p = p+geom_text(aes(label=paste( round(expression/1e3),"k",sep="") ),colour = "white",
  position=position_stack(.9), vjust=0.8)  
p


#######
#10.ggplot2并坐标交换
#######
p <- ggplot(d1, aes(x=reorder(geneSymbol,expression), y=expression,fill=sample)) + 
  geom_bar(stat = "identity")
p <- p + xlab("GeneSymbol") + 
  ylab("Expression")+
  ggtitle("Fig10. Expression")+
  theme(axis.text.x=element_text(angle=90))+
  coord_flip() #坐标交换
p




#ggplot2 https://www.cnblogs.com/nxld/p/6059603.html
#color http://blog.sina.com.cn/s/blog_54f07aba0101s3qu.html

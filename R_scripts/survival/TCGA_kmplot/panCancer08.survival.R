# 绘制kmplot和 卡方检验获取p值。


#install.packages("survival")
#install.packages("survminer")

library(survival)
library(survminer)


rt=read.table("expTime.txt",header=T,sep="\t",check.names=F,row.names=1)       #读取输入文件
rt$futime=rt$futime/365
gene=colnames(rt)[3]
pFilter=0.05            #km方法pvalue过滤条件

#对肿瘤类型进行循环
for(i in levels(rt[,"CancerType"])){
  rt1=rt[(rt[,"CancerType"]==i),]
  group=ifelse(rt1[,gene]>median(rt1[,gene]),"high","low")
  diff=survdiff(Surv(futime, fustat) ~group,data = rt1)
  pValue=1-pchisq(diff$chisq,df=1)
  
  # 只有p值显著的才画图
  if(pValue<pFilter){
  
	# 我感觉p值格式可以不用处理
    if(pValue<0.001){
      pValue="p<0.001"
    }else{
      pValue=paste0("p=",sprintf("%.03f",pValue))
    }
    
	fit <- survfit(Surv(futime, fustat) ~ group, data = rt1)
    #绘制生存曲线
    surPlot=ggsurvplot(fit, 
                       data=rt1,
                       title=paste0("Cancer: ",i),
                       pval=pValue,
                       pval.size=6,
					   
                       legend.labs=c("high","low"),
                       legend.title=paste0(gene," levels"),
                       font.legend=12,
                       
					   xlab="Time(years)",
                       ylab="Overall survival",
                       
					   break.time.by = 1,
                       palette=c("red","blue"),
                       conf.int=F,
                       fontsize=4,
                       
					   risk.table=TRUE,
                       risk.table.title="",
                       risk.table.height=.25)
	
	# 保存图片为pdf格式
    pdf(file=paste0("survival.",i,".pdf"),onefile = FALSE,
        width = 6,             #图片的宽度
        height =5)             #图片的高度
    print(surPlot)
    dev.off()
  }
}




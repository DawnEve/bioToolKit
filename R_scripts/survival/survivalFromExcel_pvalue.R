
###########################################
## input: 三列 time PDL1 status
###########################################
data_all2=read.csv('clipboard',sep="\t")
data_all3=data_all2[which(data_all2$time<36),]
#draw(data_all3,148)

cutoff=148 ##-----------由xtile求出临界值
tx=c()
for(i in 1:dim(data_all3)[1]){
  if(data_all3$PDL1[i]>cutoff){
    tx=c(tx,1)
  }else{
    tx=c(tx,0)
  }
}

#cancer="ESCC"
cancer="stomach"
data_all3$tx=tx
data_need=data_all3

#############################
#计算p值：
#http://stats.stackexchange.com/questions/114304/log-rank-test-in-r
# install.packages("survival")
library("survival")
sdf=survdiff(Surv(time, as.numeric(status))~tx, data=data_need)
sdf
pvalue=1-pchisq(sdf$chisq, df=1)
pvalue=signif(pvalue,2) #保留几位有效数字的 http://www.dataguru.cn/thread-439-1-1.html
#########################

# 按照tx分组对time和statuss拟合生存曲线，
km=survfit(Surv(time,as.numeric(status))~tx,data=data_need,se.fit=FALSE, conf.int=.95)
km
# 画出生存曲线
plot(km,lty=1,col=c("blue","red"),
     xlab="OS MONTHS",ylab="Percent Survival",main=paste("PD-L1 expression in ",cancer, "",sep=""), #生存曲线
     mark.time=T  #生存分析显示截尾数据点
)

#加上图例
legend(1, 0.35,  legend=c(paste("low(n=",km$n[1],")",sep=""), paste("high(n=",km$n[2],")",sep="")), col = c("blue","red"),
       text.font=12,
       text.col = c("blue","red"), lty = c(2, 1), title = paste("logrank p = ",pvalue))
# merge = FALSE, bg ="#ffffff"


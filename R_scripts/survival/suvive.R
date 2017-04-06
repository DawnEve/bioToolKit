# 载入包
library('survival')

# 读取数据
setwd('D:/R_code')
my=read.csv('survive2016.csv',header=T);my

# 按照tx分组对time和statuss拟合生存曲线，
km=survfit(Surv(time,as.numeric(status))~tx,data=my,se.fit=FALSE, conf.int=.95)

summary(km)
km

# 画出生存曲线
plot(km,lty=1,col=c("red","purple"),
     xlab="OS MONTHS",ylab="Percent Survival",main="survival", #生存曲线
) 
#加上图例
legend(130, 1, c(paste("WT(n=",km$n[1],")"), paste("R132H(n=",km$n[2],")")), col = c("red","purple"),
       text.col = c("red","purple"), lty = c(1, 1),
       merge = TRUE, bg ="#efeeef" )
#pch = c(1, 2), //图例线形
#rgb(0.99,0.99,0.99) grey


#p值怎么算？
# http://bbs.pinggu.org/thread-2178930-1-1.html

#请使用survdiff函数做log rank检验或建立Cox模型(coxph)来比较两条生存曲线, 
#KM曲线只是一种可视化手段，不是正经的统计推断分析工具。
# 应该用 suvdiff 函数做 log-rank test


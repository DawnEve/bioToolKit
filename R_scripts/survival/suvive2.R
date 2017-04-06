#

# 读取数据
setwd('D:/R_code/')
my=read.csv('survive2016.csv',header=T);my


#############################
#计算p值：
#http://stats.stackexchange.com/questions/114304/log-rank-test-in-r
# install.packages("survival")
library("survival")
sdf=survdiff(Surv(time, as.numeric(status))~tx, data=my)
sdf
pvalue=1-pchisq(sdf$chisq, df=1)
#pvalue=round(pvalue,2)
# There is also an option for ‘rho’. Rho = 0 (default)
# gives the log-rank test, rho=1 gives the Wilcoxon test.


#install.packages("coin")
#library("coin")
#st=logrank_test(Surv(time, as.numeric(status)) ~ tx, data=my, distribution = "exact")
#st
#########################




# 按照tx分组对time和statuss拟合生存曲线，
km=survfit(Surv(time,as.numeric(status))~tx,data=my,se.fit=FALSE, conf.int=.95)
km

# 画出生存曲线
plot(km,lty=1,col=c("red","purple"), 
     xlab="OS MONTHS",ylab="Percent Survival",main="survival", #生存曲线
) 
#加上图例
legend(100, 1,  legend=c(paste("WT(n=",km$n[1],")"), paste("R132H(n=",km$n[2],")")), col = c("red","purple"),
       text.col = c("red","purple"), lty = c(1, 1), title = paste("logrank p = ",pvalue) )
#       merge = FALSE, bg ="#ffffff"


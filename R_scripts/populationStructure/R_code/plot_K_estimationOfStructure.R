###############
# plot K estimation of Structure
###############
#refer
#http://blog.163.com/imnoqiao@126/blog/static/35265851201611633153720/
#http://blog.sina.com.cn/s/blog_670445240102uwo3.html
#axis(1, lab=(t(as.matrix(tbl2))[1,]), cex.axis = 1.2)
#0.098 0.072 0.109 0.135 0.115 0.103 0.103 0.101 0.103 0.061
par(mfrow=c(1,2))

data=read.table('clipboard', sep="\t")
plot(data,type="o",xlab="K",ylab="Ln P(D)")

data=read.table('clipboard', sep="\t")
plot(data,type="o",xlab="K",ylab="delta K")


#########
#with Errorbar
#########
par(mfrow=c(1,2))

# 数据格式
#N	len	sd
#1	-65843.8	81.4
#2	-61454.7	584.9
#3	-59690.7	754.4
#4	-58326.3	1212
#5	-57695.8	1523.1

data=read.table('clipboard', sep="\t",header=T)
library(ggplot2)

ggplot(data,aes(x=N,y=len))+
  geom_errorbar(aes(ymin=len-sd, ymax=len+sd),width=.1)+
  geom_line()+
  geom_point()
####










#http://www.cookbook-r.com/Graphs/Plotting_means_and_error_bars_(ggplot2)/
par(mfrow=c(2,2)) #分割画布无效？
# Standard error of the mean
ggplot(tgc, aes(x=dose, y=len, colour=supp)) + 
  geom_errorbar(aes(ymin=len-se, ymax=len+se), width=.1) +
  geom_line() +
  geom_point()


#errorbar重叠了，可以移位以便看得更清楚。
# The errorbars overlapped, so use position_dodge to move them horizontally
pd <- position_dodge(0.1) # move them .05 to the left and right
ggplot(tgc, aes(x=dose, y=len, colour=supp)) + 
  geom_errorbar(aes(ymin=len-se, ymax=len+se), width=.1, position=pd) +
  geom_line(position=pd) +
  geom_point(position=pd)


# Use 95% confidence interval instead of SEM 使用95%置信区间，而不是SEM
ggplot(tgc, aes(x=dose, y=len, colour=supp)) + 
  geom_errorbar(aes(ymin=len-ci, ymax=len+ci), width=.1, position=pd) +
  geom_line(position=pd) +
  geom_point(position=pd)


# Black error bars - notice the mapping of 'group=supp' -- without it, the error
# bars won't be dodged!
ggplot(tgc, aes(x=dose, y=len, colour=supp, group=supp)) + 
  geom_errorbar(aes(ymin=len-ci, ymax=len+ci), colour="black", width=.1, position=pd) +
  geom_line(position=pd) +
  geom_point(position=pd, size=3)


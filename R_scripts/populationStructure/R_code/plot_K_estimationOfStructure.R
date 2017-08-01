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
plot(data,type="o",xlab="K",ylab="delta[Ln P(D)]")

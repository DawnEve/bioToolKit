library("lattice")
# 示例数据
# CD103	stage
# 10	1
# 23	1
# 12	1
# 25	2
# 32	2
# 34	2
# 43	2
# 45	3
# 46	3
# 76	3
# 2	4
# 3	4

data=read.csv('clipboard',sep="\t",header=T)
xyplot(CD103~stage,data)

par(cex = 0.6);
par(mar = c(3,3,2,1))
par(mfrow=c(1,2)) 


#http://r.789695.n4.nabble.com/overlap-dot-plots-with-box-plots-td2134530.html
boxplot(CD103 ~ stage, data, outpch = NA,par(lwd=1)) 
# (Setting 'outpch = NA' avoids plotting outliers.) 
stripchart(CD103 ~ stage, data, 
           vertical = TRUE, method = "jitter", 
           pch = 21, col = c("red","green","blue","orange"), bg = "bisque", #col="orange" maroon
           add = TRUE) 

#


#############
Depth <- equal.count(quakes$depth, number=8, overlap=.1)
xyplot(lat ~ long | Depth, data = quakes)
update(trellis.last.object(),
       strip = strip.custom(strip.names = TRUE, strip.levels = TRUE),
       par.strip.text = list(cex = 0.75),
       aspect = "iso")
#refer
# https://www.programiz.com/r-programming/strip-chart


#PCA分析： http://www.sthda.com/english/wiki/ade4-and-factoextra-principal-component-analysis-r-software-and-data-mining#at_pco=smlre-1.0&at_si=598968acaced47ae&at_ab=per-2&at_pos=3&at_tot=4



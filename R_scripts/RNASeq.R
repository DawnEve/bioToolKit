
#0.连接到bioC
source("http://bioconductor.org/biocLite.R")

GSEName=""
setwd(paste("D:/R_code/",GSEName,sep=""))
getwd()

#####################

biocLite("Rsamtools")
biocLite("DESeq")
biocLite("edgeR")

install.packages("DESeq")
install.packages("edgeR")

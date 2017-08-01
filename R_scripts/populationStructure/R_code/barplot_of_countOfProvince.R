#barplot for 每省份病人数

ori=read.table('clipboard',header=T)
head(ori)
ori2=ori$locationID
head(ori2)
table(ori2)
barplot(table(ori2), xlab="Province ID", ylab="Sample Numbers",
        main="Lineage2 Samples from each Province")

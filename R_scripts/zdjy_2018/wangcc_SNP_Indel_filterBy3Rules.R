###########
# v0.2
# snp filter script
#1.by Func; 2. by p value, 3. by GeneName
#v0.2 correct filter2 by adding as.character();
##########


#settings
setwd("D://zzu_Exon") # set working directory
fname="test01.csv" #set file name
project_name="xxx_snp_" #set output file prefix name: xxx_snp_



#read data
snp=read.csv(fname,na.strings = "NA") #用npp转为utf-8无bom头编码
dim(snp) #[1] 174077     55

head(snp[,1:5]) #


#filter 1: by Func.
# levels(snp$Func) #check values in Func
snp=snp[snp$Func %in% c("exonic","exonic;splicing","splicing"),]
dim(snp) #[1] 22264    55



#filter 2: retain 6 columns where p<0.01 or Na
#[25] "X1000g2015aug_Chinese" "X1000g2015aug_eas"     "X1000g2015aug_all"    
#[28] "esp6500siv2_all"       "ExAC_ALL"              "ExAC_EAS" 
pCols=c("X1000g2015aug_Chinese", "X1000g2015aug_eas","X1000g2015aug_all", "esp6500siv2_all", "ExAC_ALL", "ExAC_EAS")

badRows=c()
for(i in 1:nrow(snp)){
  for(j in pCols){
    v=as.character(snp[i,j])
    if(v==".") next
    if(as.numeric(v)>0.01){
      badRows <- c(badRows,i)
    }
  }
}
length(unique(badRows))
snp2=snp[-unique(badRows),]

#check
dim(snp2) #[1] 672  55
snp2[1:10,25:30]

#output to files
write.csv(snp2,paste0(project_name,'beforeFilterByGeneList.csv'),row.names = F)



#filter 3: retain rows which GeneName in list1 and list2 only
HCM <- readLines("HCM.txt", encoding = "UTF-8")
#HCM.txt is a txt file with one gene a line, like this
#MYBPC3
#MYH7
#TNNT2
#TNNI3
snp_sub1=snp2[snp2$GeneName %in% HCM,]
dim(snp_sub1) #[1]  5 55

BPCM <- readLines("BPCM.txt", encoding = "UTF-8")
snp_sub2=snp2[snp2$GeneName %in% BPCM,]
dim(snp_sub2) #[1] 10 55

#output to files
write.csv(snp_sub1,paste0(project_name,'HCM.csv'),row.names = F)
write.csv(snp_sub2,paste0(project_name,'BPCM.csv'),row.names = F)

#end
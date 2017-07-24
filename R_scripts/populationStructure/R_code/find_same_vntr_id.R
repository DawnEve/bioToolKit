############
#1.��ȡ����
# ID	Lineage	Qub.11b	Mtub.21	QuB.26	MIRu.26	Mtub.04	MIRu.10	MIRu.31	MIRu.40	QuB.4156c	ETR.A	MTub.30	Mtub.39	MIRu.16	MIRu.04	ETR.C
# 22155	Lineage2	6	5	8	7	4	3	5	3	2	4	4	3	3	2	4
# 23109	Lineage2	6	5	8	7	4	3	5	3	2	4	4	3	3	2	4
# 23264	Lineage2	6	5	8	7	4	3	5	3	2	4	4	3	3	2	4
# 23509	Lineage2	6	5	8	7	4	3	5	3	2	4	4	3	3	2	4
# 24141	Lineage2	6	5	8	7	4	3	5	3	2	4	4	3	3	2	4
# 24158	Lineage2	6	5	8	7	4	3	5	3	2	4	4	3	3	2	4
# 24160	Lineage2	6	5	8	7	4	3	5	3	2	4	4	3	3	2	4
# ...
# 5110	Lineage2	6	5	9	8	5	3	5	3	3	4	4	3	3	3	4
# 7101	Lineage2	6	5	9	8	4	3	5	3	3	4	4	3	3	3	4

data=read.table('clipboard',header=T,sep="\t")
head(data)
dims=dim(data);dims
#x=dim[1];y=dim[2];


###�����бȽ�
compareByRow=function(x,y){#dim(x)[2]
  for(i in 3:17){ #һ��15��λ��
    #����п�ȱֵ��ֱ�ӱȽ���һλ
    if(x[,i]<=0) next;
    if(y[,i]<=0) next;
    #һ���в���ȣ�����false
      #print(paste(i,x[,i]))
    if(x[,i]!=y[,i]){
      return(FALSE);
    }
  }
  #��ȫ��ȣ��ŷ���true
  return(TRUE)
}
##debug
debug=function(x,y="",z="",a="",b=""){
  print(paste(x,y,z,a,b,sep=", "))
}

#ͳ�����ַ������ֵĴ�������ȱ�ݣ���������
countSubStr=function(substr,str){
  arr <- strsplit(as.character(str),substr)  
  length(arr[[1]]) - 1  ##���ַ���"ag"�ĳ��ָ���  
}

###�����бȽ�
data$same="";
data$count=1;
for(i in 1:dims[1]){
  sameAsI=c();
  
  for(j in 1:dims[1]){
    if(i==j) next;#���ú��Լ���
    if(compareByRow(data[i,],data[j,])){
      sameAsI=c(sameAsI,data[j,][,1])
    }
    #print(paste(i,j,sep="-",result))
  }
  
  #debug(data[i,][,1],sameAsI)
  if(length(sameAsI)>0){
    data[i,]$same=paste("A",paste(sameAsI,sep="", collapse=","),sep=",")
    data[i,]$count=1+countSubStr(',',data[i,]$same);#,�ַ�����
    ##array to string
    #https://stackoverflow.com/questions/2098368/how-do-i-concatenate-a-vector-of-strings-character-in-r
  }
  
  if(i%%20==0) print(paste(i,Sys.time(),sep=" "));#ÿ����20����ӡ��ţ�����鿴����
}



#���������ļ�
write.csv(data,file="vntr_repeat_finding.csv")
############
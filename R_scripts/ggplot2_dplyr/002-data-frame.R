# review data frame manipulating
# 20180530 v0.1 for wechat

#R语言中的数据框data.frame
#数据框(data.frame)，R中使用十分最广泛。只要你用read.table输入数据，基本都是data.frame类别的数据。

# http://www.cnblogs.com/studyzy/p/4316118.html
# https://cos.name/cn/topic/12365/


####################
#1. 创建数据框
#(1)使用已有向量建立数据框
patientID <- c(1:4)
age <- c(25,31,42,57)
diabetes <- c("Type1","Type2","Type3","Type4")
status <- c("Poor","Improved","Excellent","Poor")
patientdata <- data.frame(patientID,age,'diabetesType'=diabetes,status) #可以修改列名
patientdata

#(2)使用向量直接建立数据框
student<-data.frame(ID=c(11,12,13),Name=c("Devin","Edward","Wenli"),
  Gender=c("M","M","F"),Birthdate=c("1984-12-29","1983-5-6","1986-8-8"))
student


#用row.names参数直接为行命名
my_df1 <- data.frame(
  num = 1:3, 
  letter = LETTERS[1:3], 
  logic = c(T,F,T), 
  row.names = paste('row',1:3)
)
my_df1

#(3)另外也可以使用read.table()或read.csv()读取一个文本文件，返回的也是一个Data Frame对象。
text1=read.table('001.txt') #其中文本文件001.txt最后一行是空行，否则会报错
text2=read.table('001.txt',header=F)  #如果没有标题，用header设置
text3=read.table('001.txt',header=F,sep=",") #如果是逗号分隔的，则用sep设置（默认是tab分隔的）


#(4)如果是从excel、txt中复制到内存的，可以直接读取内存。
text4=read.table('clipboard',header=T) #设置有标题




####################
#2.行名列名
#(1)使用names函数可以查看列名
names(student)
colnames(student)

colnames(student)[2]="Mingzi"#修改列名
student
colnames(student)[2]="Name"
student

#(2)如果要查看行名，需要用到row.names函数。
row.names(student)
# [1] "1" "2" "3"
rownames(student)
# [1] "1" "2" "3"

student

Student


dimnames(student)

#(3)获取行列维度的函数
nrow(student)
#[1] 3
dim(student)
#[1] 3 4
ncol(student)
#[1] 4

#(4)获取数据框的结构信息
str(student)


#(5)显示数据框前几行信息
head(student,n=2)
tail(student)







###########################
#3.获取元素
#(1)访问某行，从1开始计数
student[1,]

student[,2]
student[[2]]
student$Name
student[['Name']]

#第一行用户的名字
student[1,]$Name


#返回子列数据框
student[2]
student[1:3]
student[c('ID','Gender')]
student[,c(1,3)]
student[c(1,3)]

#返回子行数据框
ss=student[2:3,]
student[c(1,3),]

rownames(student)=student$Name
student['Devin',]


attach(student)
print(Name)
print(Devin)
detach(student)


#局部变量
with(student, {print(Gender)})


##查询与子集
student
boys=student[which(student$Gender=="M")]
boys

#先添加一个新列Age，就是现在的时间减去生日的年。下文会讲解该语法。
student<-within(student,{
  #as.integer(format(Sys.Date(),"%Y"))
  Age=2005-as.integer(format.Date(Birthdate,"%Y"))
})
student


student[which(student$Gender=="F"),"Age"]
student[which(student$Gender=="F"),c("Age",'Name')]

student[which(student$Gender=="M" & student$Age>21),c("Age",'Name')]

student[which(student$Gender=="M" | student$Age<21),c("Age",'Name')]

#年龄是21或22岁的
student[which(student$Age==21 | student$Age==22),]

subset(student,Gender=="F" & Age<20 ,select=c("Name","Age"))
subset(student,Name!='Devin' | Age>21)


#使用sql查询数据框
library(sqldf)
result<-sqldf("select Name,Age from student where Gender='F' and Age>18")
result

result<-sqldf("select Name,Age from student where Gender='M' and Age>20")
result
result[1,][1]


#(9)遍历数据框
student
dim(student)


nrow(student)
#[1] 3
dim(student)
#[1] 3 4
ncol(student)
#[1] 4


#获取data frame的维度：
x=dim(student)[1]
y=dim(student)[2]

#遍历每个元素
for(i in 1:x){
  for (j in 1:y)
    print(student[i,j])
}

#对每行进行遍历，找出4-9月出生的学生
for(i in 1:x){
  birthday=student[i,4]
  print(birthday)
}


as.integer("2")
#[1] 2
as.integer("2a")##原来能把"2a"转成数字2，现在直接报警告。
#Warning message:
#  NAs introduced by coercion 



#strsplit('1983-5-6','-')[[1]][2]
student
tmp=c()
for(i in 1:x){
  birthday=student[i,4]
  birthday=as.character(birthday)
  month=strsplit(birthday,'-')[[1]][2]
  #month=as.integer(substr(birthday,6,7))
  if(month>=4 && month<=9){
    tmp=c(tmp,i)
  }
}
tmp
print(student[tmp,])




#使用apply函数避免循环
rs=apply(student,1,function(x){
  #print("结果")
  birthday=x["Birthdate"]
  month=strsplit(birthday,'-')[[1]][2]
  if(month>=4 && month<=9){
    return(x[["Name"]])
  }
})
rs2=unlist(rs)
rs3=as.character(rs2)
rs3
student[rs3,]

#(11)使用table函数获得列联表
table(student$Gender,student$Age)





#################
# 4.修改
str(student)

student$Name<-as.character(student$Name)
student$Birthdate<-as.character(student$Birthdate)

str(student) 
student$Birthdate<-as.Date(student$Birthdate)
str(student) 
#

df=data.frame

df<- lapply(df,as.numeric)


#增加年龄行
#写法1
student$Age=as.Date(Sys.Date())-student$Birthdate
str(student)
student
student$Age=as.integer(student$Age/365) #这处理的不好，应该获取年，减去当前年
str(student)
student


# 写法2
student$Age2<-as.integer(format(Sys.Date(),"%Y")) - as.integer(format(student$Birthdate,"%Y"))
str(student)
student


# 写法3
student<-within(student,{
  Age3=as.integer(format(Sys.Date(),"%Y"))-as.integer(format(Birthdate,"%Y"))
})
str(student)
student

#写法4
cbind(student, Age4=c(1,2,3) )



# 删除行
student2=student[-1,]
student2


#(4)增加列
student$class=c("art","math","law")
str(student)
student
#

#(5)删除列
student2 <- subset(student, select = -Age )
student2 #已经删除了不靠谱的age列
student3=student2[,-7] #减去第7列
colNum=dim(student2)[2]
student4=student2[,-colNum] #减去最后一列
student4

#(6)行列转置
data1=data.frame(id=c(1,2,3,4),weight=c(10,20,30,40))
rownames(data1)=c("a",'b','c','d') #设置标题
data1

data2=t(data1) #转置
data3=as.data.frame(data2) #转化为数据框格式
class(data2)#[1] "matrix"
class(data3)#[1] "data.frame"
data3


rm(data1,data2,data3)


#(7)melt函数重组数据：把多个列合并成，而信息量不变
detach("package:reshape") #必须移除reshape包。它和reshape2语法不一致。
(.packages()) #查看当前加载的包

library(reshape2)

sales<-data.frame(
  Name = c("苹果","谷歌","脸书","亚马逊","腾讯"),
  Company = c("Apple","Google","Facebook","Amozon","Tencent"),
  Sale2013 = c(5000,3500,2300,2100,3100),
  Sale2014 = c(5050,3800,2900,2500,3300),
  Sale2015 = c(5050,4000,3200,2800,3700),
  Sale2016 = c(6000,4800,4500,3500,4300)
)
sales
sales2<-melt(sales,
  id.vars=c("Name","Company"),#保留变量，如果为空，则使用所有非数字变量。
  variable.name="Year", #新变量的列名
  value.name="Sale" #值的列名
)
dim(sales2)
str(sales2)
head(sales2)


#数据透视表就是用cast函数
library("reshape") #要使用reshape包的cast函数。
sales3=cast(sales2, Company~Year, value="Sale")
str(sales3)
sales3

sales4=as.data.frame(sales3)
str(sales4)
sales4

##






names(airquality) <- tolower(names(airquality))
head(airquality)
melt(airquality, id=c("month", "day"))
names(ChickWeight) <- tolower(names(ChickWeight))
melt(ChickWeight, id=2:4)





################
# 5. 连接数据框、拆分数据框
score<-data.frame(
  SID=c(11,11,12,12,13),
  Course=c("Math","English","Math","Chinese","Math"),
  Score=c(90,80,80,95,96)
)
#通过merge进行连接
rs=merge(student, score, by.x="ID",by.y="SID")
rs



#(2)使用cbind横向连接
rs2=cbind(student,score[1:3,])
rs2


#rbind
student2<-data.frame(ID=c(21,22),Gender=c("F","M"),Name=c("Yan","Peng"),Birthdate=c("1982-2-9","1983-1-16"),Age=c(32,31))
student3<-data.frame(ID=c(11,12,13),Name=c("Devin","Edward","Wenli"),Gender=c("M","M","F"),Birthdate=c("1984-12-29","1983-5-6","1986-8-8"),Age=c(32,31,30))
student2
student3
stuAll=rbind(student2,student3)
stuAll
#

#(4)按照性别把student拆成两个数据框
#方法1
df=student
df
df_M=df[df$Gender=="M",]
df_F=df[df$Gender=="F",]

#方法2
df_sub=split(df, df$Gender)
df_sub
#可以按照Gender的种类把数据分成几个不同的data.frame




###################
#6. 数据框的计算
student<-data.frame(ID=c(11,12,13),Name=c("Devin","Edward","Wenli"),Gender=c("M","M","F"),Birthdate=c("1984-12-29","1983-5-6","1986-8-8"))
score<-data.frame(SID=c(11,11,12,12,13,13),Course=c("Math","English","Math","Chinese","Math","Chinese"),Score=c(90,80,80,95,96,85))
student
score
result<-merge(student,score,by.x="ID",by.y="SID")
result


#(1)求各科平均分
courseMean=data.frame(course=c(),avg=c(),sum=c(),count=c())
for(i in unique(score$Course)){
  subgrp=score[which(score$Course==i),][['Score']] #分组
  #求行的平均数
  count=length(subgrp);#计数
  sum=sum(subgrp) #总分
  avg=mean(subgrp) #平均分
  #合并到科目平均数df
  courseMean=rbind(courseMean,data.frame(course=c(i),avg=c(avg),sum=c(sum),count=c(count)))
}
courseMean


#每人的平均分。
stuMean=data.frame(course=c(),avg=c(),sum=c(),count=c())
for(i in unique(result$Name)){ #循环(modify)
  subgrp=score[which(result$Name==i),][['Score']] #分组(modify)
  #求行的平均数
  count=length(subgrp);#计数
  sum=sum(subgrp) #总分
  avg=mean(subgrp) #平均分
  
  #合并到科目平均数df
  stuMean=rbind(stuMean,data.frame(course=c(i),avg=c(avg),sum=c(sum),count=c(count)))
  
}

stuMean


#使用tapply函数
result
tapply(result[,6],result[,5],mean)

tapply(result[,6],result[,5],sum) #总数
tapply(result[,6],result[,c(2,5)],sum) #两个维度的数据透视表

#数据透视表
dat1=data.frame(host=c("A","A","A","E","E","G"),
                guest=c("C","B","D","Q","F","W"),
                num=c(2,1,2,3,0,2))
dat1

tapply(dat1[,3],dat1[,c(1,2)],mean)



#或者使用reshape包
library(reshape)
dat2=cast(dat1,host~guest,value="num")
dat2

#colMeans
colMeans(result[,c(1,6)])


#4)使用sql生成数据透视表
#https://www.douban.com/note/609129045/
head(sales2,n=10)

library(sqldf)
#求均值，R中是mean函数，SQL是avg。
sqldf("select Name, avg(Sale) as avg_Sales from sales2 group by Name")

#求总销售额，并按销售总额倒序排列
sqldf("select Name, sum(Sale) as sum_Sales from sales2 group by Name order by sum_Sales DESC")
#其中，order by 是排序，desc是排倒序，结果为





#数据框的排序
table_1=data.frame(
	x=c(1,4,3,3,4,9,5,5),
	y=c(100,44,32,35,450,96,58,51)
)


table_1$y
#[1] 100  44  32  35 450  96  58  51
#order返回的是排序编号
order(-table_1$y)
#[1] 5 1 6 7 8 2 4 3

table_1[order(-table_1$y),]
#  x   y
#5 4 450
#1 1 100
#6 9  96
#7 5  58
#8 5  51
#2 4  44
#4 3  35
#3 3  32

table_1[c(5, 1, 6, 7, 8, 2, 4, 3),]
#  x   y
#5 4 450
#1 1 100
#6 9  96
#7 5  58
#8 5  51
#2 4  44
#4 3  35
#3 3  32



table_1[order(-table_1$x, table_1$y), ] #X desc, Y asc
#   x   y
# 6 9  96
# 8 5  51
# 7 5  58
# 2 4  44
# 5 4 450
# 3 3  32
# 4 3  35
# 1 1 100

table_1[order(-table_1$x, -table_1$y), ] #X desc, Y desc
#   x   y
# 6 9  96
# 7 5  58
# 8 5  51
# 5 4 450
# 2 4  44
# 4 3  35
# 3 3  32
# 1 1 100




#查看当前加载的包
(.packages())



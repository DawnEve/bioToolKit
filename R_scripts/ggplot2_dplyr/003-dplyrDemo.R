#############
# 学习dplyr包
# version: v0.2
#
# 特别提示：
# help: 光标在关键字上，使用f1查询帮助文件。
# docs: https://dplyr.tidyverse.org/
#
# dplyr basics: http://r4ds.had.co.nz/transform.html
# local docs: http://127.0.0.1:27228/library/dplyr/doc/dplyr.html
#############

#单表操作函数
# mutate (变形/计算函数)添加新的变量 adds new variables that are functions of existing variables
# select 使用列名选出列 picks variables based on their names.
# filter 保留满足条件的行 picks cases based on their values.
# summarise 分类汇总 reduces multiple values down to a single summary.
# arange 行排序 changes the ordering of the rows.

# group_by 分组函数
# 随机抽样函数 sample_n, sample_frac
# pipe operator 管道操作 / 多步操作连接符 %>%


library('dplyr')
vignette("dplyr")

#1.数据集类型转换？不知道为啥要做这一步
class(mtcars)
ds=as_tibble(mtcars)
class(ds)
head(ds)


#
#2. 筛选: filter() picks cases based on their values.
#过滤出cyl=8的行
rs1=filter(mtcars,cyl==8)
rs1

#过滤出cyl<6且vs==1的行
filter(mtcars,cyl<6 & vs==1)
#或
filter(mtcars,cyl<6,vs==1)

#过滤出cyl<6或者vs==1的行
filter(mtcars, cyl<6 | vs==1)

#过滤出cyl为4或者6的行
filter(mtcars,cyl %in% c(4,6))



#
# slice() 函数通过行号选取数据
# 缺点是：会丢失行号
#选取第2行
slice(mtcars,2)
head(mtcars)
slice(mtcars,2L) #为什么小数点位数比原来少？//todo
filter(mtcars,row_number()==2L) #filter小数点位数和原始一致
#选取最后一行数据
x=dim(mtcars)[1]; mtcars[x,]; #我的解
slice(mtcars,n())
filter(mtcars,row_number()==n())
#选取第5行到最后一行的数据
slice(mtcars, 5:n())
rs=filter(mtcars, between(row_number(),5,n()))
class(rs) #[1] "data.frame"


#
# 3.排列: arrange() changes the ordering of the rows.
#arrange()按给定的列名依次对行进行排序，类似于base::order()函数。
#默认是按照升序排序，对列名加 desc() 可实现倒序排序。原数据集行名称会被过滤掉。
#以cyl和disp联合升序排序
arrange(mtcars,cyl,disp)
#dim(mtcars)
arrange(mtcars,cyl,desc(disp))


#
# 4.选择: select() picks variables based on their names.
#select()用列名作参数来选择子数据集。
#dplyr包中提供了些特殊功能的函数与select函数结合使用， 用于筛选变量，
#包括starts_with，ends_with，contains，matches，one_of，num_range和everything等。
#用于重命名时，select()只保留参数中给定的列，rename()保留所有的列，只对给定的列重新命名。
#原数据集行名称会被过滤掉。
class(iris)
head(iris)
iris2=iris[1:10,] #用前十行举例
#选取变量名前缀包含Petal的列
select(iris2,starts_with("Petal"))
#选取变量名前缀不高含Petal的列
select(iris2,-starts_with("Petal"))
#选取变量名后缀不包含Width的列
select(iris2, -ends_with("Width"))
#选取变量名包含etal的列
select(iris2,contains("etal"))
#使用正则表达式，返回变量名中包含en的列
select(iris2,matches(".en."))
#使用正则表达式，返回变量名结尾不是h的列
#select(iris2,matches(".+h$"))
select(iris2, -matches(".+h$"))
select(iris2,matches(".+[^h]$"))
#直接选取列
select(iris2,Petal.Length,Petal.Width)
select(iris2,'Petal.Length','Petal.Width') 
#直接选取其余列
select(iris2,-Petal.Length,-Petal.Width)#变量名加''后报错
#select(iris2,-"Petal.Length",-"Petal.Width")
#Error in -"Petal.Length" : invalid argument to unary operator

#直接使用冒号连接列名，选择连续的多个列
select(iris2, Sepal.Width:Species)

#选择字符向量中的列，select中不能直接使用字符向量筛选，需要使用one_of函数
vars=c("Sepal.Length","Petal.Width",'Species')
select(iris2,one_of(vars))
#反向选择
select(iris2, -one_of(vars))
#返回所有列，一般调整数据集中变量顺序时使用
select(iris2,everything())
#调整列顺序，把Species列放到最前面
select(iris2,Species,everything())



# 举例2
df=as.data.frame(matrix(runif(100),nrow=10))
df
dim(df)
#选择V4，V5，V6三列
select(df,V4:V6)
select(df, num_range("V", 4:6))


# 举例3
#重命名列名字
#重命名Petal.Length，返回子数据集只包含重命名的列
select(iris2,petal_length=Petal.Length)
#重命名所有以Peatl为前缀的列，返回子数据集只包含重命名的列
select(iris2, petal=starts_with("Petal"))
#重命名Petal.Length，返回全部咧
rename(iris2,petal_length=Petal.Length)



#
# 5.变形:mutate() adds new variables that are functions of existing variables
# mutate()和transmute()函数对已有列进行数据运算并添加为新列，类似于base::transform() 函数, 
#不同的是可以在同一语句中对刚增添加的列进行操作。
#mutate()返回的结果集会保留原有变量，transmute()只返回扩展的新变量。原数据集行名称会被过滤掉。
# 添加新列wt_kg和wt_t，在同一语句中可以使用刚添加的列。
mtcars2=mtcars[1:10,]
mutate(mtcars2, wt_kg=wt*453, wt_t=wt_kg/1000)
# 使用 transmute时，只返回新添加的列
transmute(mtcars2, wt_kg=wt*453, wt_t=wt_kg/1000)


#
# 6.去重 distinct
# distinct()用于对输入的tbl进行去重，返回无重复的行，类似于 base::unique() 函数，但是处理速度更快。
#原数据集行名称会被过滤掉

df=data.frame(
  x=sample(10,100,rep=T),
  y=sample(10,100,rep=T)
)
# 以全部两个变量去重，返回去重后的行数
nrow(distinct(df))
nrow(distinct(df,x,y))
# 以变量x去重，只返回去重后的x值
distinct(df,x)
# 以变量x去重，返回所有变量
distinct(df, x, .keep_all=TRUE)
#对变量运算后的结果进行去重
distinct(df, diff=abs(x-y))
distinct(df, diff=abs(x-y), .keep_all = T)
distinct(df, diff=x-y, .keep_all = T) #不加abs结果中行会更多


#
# 7.概括: summarise() reduces multiple values down to a single summary.
#对数据框调用函数进行汇总操作, 返回一维的结果。返回多维结果时会报如下错误：
#Error: expecting result of length one, got : 2
#原数据集行名称会被过滤掉。

#返回数据框中变量disp的均值
summarise(mtcars,mean(disp))
#返回数据框中变量disp的标准差
summarise(mtcars, sd(disp))
sd(mtcars$disp)
#返回最大和最小值
summarise(mtcars, max(disp), min(disp))
#返回行数
summarise(mtcars, n())
dim(mtcars)[1];nrow(mtcars)
#返回unique的gear数
summarise(mtcars, n_distinct(gear))
factor(mtcars$gear) #从factor的水平个数看

#返回disp的第一个值
summarise(mtcars, first(disp))
#返回disp的最后一个值
summarise(mtcars, last(disp))



#
# 8.抽样 sample
#抽样函数，sample_n()随机抽取指定数目的样本，sample_frac()随机抽取指定百分比的样本，
#默认都为不放回抽样，通过设置replacement = TRUE可改为放回抽样，可以用于实现Bootstrap抽样。

# 语法 ：sample_n(tbl, size, replace = FALSE, weight = NULL, .env = parent.frame())
#随机无重复的取10行数据
sample_n(mtcars,10)
#随机有重复的取5行数据
sample_n(mtcars, 5, replace=T)
#随机无重复的以mpg值做权重取10行数据
sample_n(mtcars, 10, weight=mpg) #不懂权重怎么影响抽样 //todo

#语法 ：sample_frac(tbl, size = 1, replace = FALSE, weight = NULL,.env = parent.frame())
# 默认size=1，相当于对全部数据无重复重新抽样
sample_frac(mtcars)
#随机无重复的取10%的数据
sample_frac(mtcars, 0.1)
#随机有重复的取总行数的1.5倍的数据
sample_frac(mtcars, 1.5, replace=TRUE)
#随机无重复的以1/mpg值做权重取10%的数据
sample_frac(mtcars,0.1,weight=1/mpg)

#
# 9.分组 group_by()
#group_by()用于对数据集按照给定变量分组，返回分组后的数据集。
#对返回后的数据集使用以上介绍的函数时，会自动的对分组数据操作。
#使用变量cyl对mtcars分组，返回分组后的数据集
by_cyl=group_by(mtcars,cyl)
by_cyl #不懂发生了什么变化 //todo
class(by_cyl)
#返回每个分组中最大disp所在的行
filter(by_cyl, disp==max(disp))
#返回每个分组中变量名包含d的列，始终返回分组列cyl
select(by_cyl, contains("d"))
#使用mpg对每个分组排序
tmp=arrange(by_cyl, mpg)
View(tmp)
#对每个分组无重复的取2行记录
sample_n(by_cyl,2)

#例子2 分组后使用聚合函数
# 返回每个分组的记录数
summarise(by_cyl, n())
#求每个分组中disp和hp的均值
summarise(by_cyl, mean(disp), mean(hp))
#返回每个分组中唯一的gear值
summarise(by_cyl, n_distinct(gear))
#返回每组第一个和最后一个disp值
summarise(by_cyl, first(disp))
summarise(by_cyl, last(disp))
#返回每个分组中最小的disp值
summarise(by_cyl, min(disp))
summarise(arrange(by_cyl,disp), min(disp))
#返回每个分组中最大的disp值
summarize(by_cyl, max(disp))
summarize(arrange(by_cyl,disp), max(disp))
#返回每个分组中disp第二个disp值
summarise(by_cyl, nth(disp,2))


#例子3 
#获取分组数据集使用的分组变量
groups(by_cyl)
#从数据集中移除分组信息，因此返回的分组变量为NULL
groups(ungroup(by_cyl))



#例子4 返回每条记录所在分组id组成的向量
group_indices(mtcars, cyl)
#[1] 2 2 1 2 3 2 3 1 1 2 2 3 3 3 3 3 3 1 1 1 1 3 3 3 3 1 1 1 3 2 3 1



#例子5 返回每个分组记录数组成的向量
group_size(by_cyl)
summarise(by_cyl, n())
table(mtcars$cyl)
#返回所分的组数
n_groups(by_cyl)
length(group_size(by_cyl))

# 
# 对数据集的每个分组计数，类似于base::table()函数。
#其中count已经group_by分组，而tally需要对数据集调用group_by后对分组数据计数。
#使用count对分组计数，数据已按变量分组
count(mtcars, cyl)
#设置sort=TRUE，对分组计数按降序排列
count(mtcars, cyl, sort=TRUE)
#使用tally对分组计数，需要使用group_by分组
tally(group_by(mtcars, cyl))
# 使用summarise对分组计数
summarise(group_by(mtcars, cyl),n())

#按cyl分组，并对分组数据计算变量gear的和
tally(group_by(mtcars,cyl), wt=gear)


#
# 10.数据关联 join
#数据框中经常需要将多个表进行连接操作，如左连接、右连接、内连接等，
#dplyr包也提供了数据集的连接操作，类似于base::merge()函数。

df1=data.frame(
  CustomerId=c(1:6),
  sex=c('f','m','f','f','m','m'),
  Product=c(rep('Toaster',3), rep('Radio',3))
)
df2=data.frame(
  CustomerId=c(2,4,6,7),
  sex=c('m','f','m','f'),
  State=c(rep('Alabama',3), rep('Ohio',1))
)

#内连接，合并数据仅保留匹配的记录
#inner_join(x,y, by = NULL, copy = FALSE, suffix = c(".x", ".y"), ...) 
#内连接，默认使用Customer和sex连接
inner_join(df1,df2) #仅保留匹配的

#左连接，向数据集x中加入匹配的数据集y记录
#left_join(x,y, by = NULL, copy = FALSE, suffix = c(".x", ".y"), ...)
#左连接，默认使用"CustomerId"和"sex"连接  
left_join(df1,df2) #保留左侧全部行

#同理，右连接以右边为主，补充信息到右边。
right_join(df1,df2)  #保留右侧全部行

#全连接，合并数据保留所有记录，所有行
# full_join(x,y, by = NULL, copy = FALSE, suffix = c(".x", ".y"), ...)
full_join(df1,df2) #全连接和内连接有啥区别？全连接是保留全部信息，内连接是仅保留匹配的

#内连接，使用CustomerId连接，则同名字段sex会被加上后缀
inner_join(df1,df2,by=c('CustomerId'="CustomerId"))

#返回能够与y表匹配的x表所有记录 
#semi_join(x,y, by = NULL, copy = FALSE, ...)
semi_join(df1,df2,by=c('CustomerId'='CustomerId'))
df1
#以CustomerId和sex连接，返回df1中与df2不匹配的记录  
anti_join(df1, df2)
df2

#
# 11. 集合操作 set。dplyr也提供了集合操作函数，实际上是对base包中的集合操作的重写，
# 但是对数据框和其它表格形式的数据操作更加高效。
mtcars$model=rownames(mtcars)
g1=mtcars[1:20,]
g2=mtcars[10:32,]
#取两个集合的交集，丢失行名字
intersect(g1,g2)
#取并集，并去重
union(g1,g2)
#取差集，返回g1中有但g2中没有的记录
setdiff(g1,g2)

setdiff(g2,g1) #这个是g2-g1

#取两个集合的交集，不去重
union_all(g1,g2)
#判断两个集合是否相等
setequal(g1,g1[20:1,]) #TRUE
setequal(g1,mtcars[1:20,]) #TRUE
setequal(g1,g2) #FALSE: Different number of rows
setequal(g1,g2[1:20,]) #FALSE: Rows in x but not y...


#
# 12.数据合并 bind
#对数据框按照行/列合并。
one=mtcars[1:4,]; one
two=mtcars[11:14,]; two
#按行合并数据框one和two
bind_rows(one, two)
# 按行合并元素为数据框的列表
bind_rows(list(one,two))
#按行合并数据框，生成id列指明数据来自的数据源数据框
bind_rows(list(one, two), .id='id') # id列为数字代替
bind_rows(list(a=one, b=two), .id="id") #id 列的值为数据框名

# 合并数据框，列名不匹配，因此使用NA替代，使用rbind直接报错
bind_rows(data.frame(x=1:3), data.frame(y=1:4))

# 合并因子
f1=factor('a')
f2=factor('b')
c(f1,f2)
unlist(list(f1,f2))
#因子level不同，强制转换为字符型
combine(f1,f2) #报Warning
combine(list(f1,f2)) #报Warning



#
# 13.条件语句 ifelse
# dplyr包也提供了更加严格的条件操作语句，fi_else函数类似于base::ifelse(),
#不同的是true和false对应的值必须要有相同的类型，这样使得输出类型更容易预测，执行效率更高。
x=c(-5:5, NA);x
if_else(x<0, NA_integer_, x)
#使用字符串missing替换原数据中的NA元素
if_else(x<0, 'negetive', 'positive','missing')
#if_else不支持类型不一致，但是ifelse可以
if_else(x<0, 'negative', 1) #Error: `false` must be type character, not double
ifelse(x<0, 'negative', 1) #1被强制转换为字符了

#例2
set.seed(100)
x <- factor(sample(letters[1:5], 10, replace=TRUE));x
#if_else会保留原有数据类型
if_else(x %in% c('a','b','c'), x, factor(NA))
ifelse(x %in% c('a','b','c'), x, factor(NA))
ifelse(x %in% c('a','b','c'), as.character(x), factor(NA)) #输出强制字符串x


#################
# 管道操作 %>% 或 %.%
#将上一个函数的输出作为下一个函数的输入， %.%已废弃。
mtcars %>%
  group_by(cyl) %>%
  summarise(total = sum(gear)) %>%
  arrange(desc(total))

#写法2（嵌套太深，不好排错）
head(
  arrange(
    summarise(
        group_by(mtcars, cyl), total=sum(gear)
    ), desc(total)
  ), 5
)


#################
# dplyr连接mysql数据框(windows连接失败)
#如果需要获取MySQL数据库中的数据时,可以直接使用dplyr包中的src_mysql()函数：
#src_mysql(dbname,host = NULL,port = 0L,user = “root”,password = “password”,…) 

library(dplyr)
#dplyr连接mysql数据库
my_db <- src_mysql(dbname = "mysql",
                   host = 'localhost',
                   port = 3306,
                   user = "root",
                   password = "")
#Error: Condition message must be a string

#获取指定表中的数据
#tbl(src, from = 'diff')
my_tbl <- tbl(my_db,from = "user") #my_table为数据库中的表
my_tbl


##############
#refer:
# 
# http://blog.csdn.net/achuo/article/details/54693211



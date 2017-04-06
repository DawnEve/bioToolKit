
##############
GEO表达谱数据怎么按照临床指标汇总成平均数？  
##############


条件：
1.表达谱数据中有基因 - 样本矩阵。csv格式。
[assembly] GEO表达谱数据怎么按照临床指标汇总成平均数？ - 胡小叶 - AgeTouch
 
 
2.临床资料是样本 - 性状矩阵。csv格式。
[assembly] GEO表达谱数据怎么按照临床指标汇总成平均数？ - 胡小叶 - AgeTouch

Excel打开文件如果有问题，请用notepad++打开，再导入到excel查看。


问题：
需要求各个基因按照临床分期（T1,T2,T3,T4）的平均表达量。
尽量用R语言实现。（如果不是特别复杂，尽量使用R core部分，尽量少用包。）
输出到excel，类似result.csv的格式。


难点：
难点是dataframe的操作函数：横向合并、纵向合并。
可能tapply更好用。

answer: http://agetouch.blog.163.com/blog/static/2285350902017229111627552/


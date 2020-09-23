# ggpubr
# ref: https://www.jianshu.com/p/f53a05da7745
# docs: http://rpkgs.datanovia.com/ggpubr/reference/index.html#section-make-programming-easy-with-ggplot-


# install.packages("ggpubr")
library(ggpubr)

setwd('D://Temp//ggpubr_fig//')
getwd()

#
head(iris)

###########
# 01. 绘制密度图
set.seed(202007)
ggdensity(iris, x="Sepal.Length", add = "mean", 
          rug = TRUE, color = "Species", fill = "Species",
          palette = c("#00AFBB", "#E7B800", '#DD7F7F')) 
#rug参数添加地毯线，add参数可以添加均值mean和中位数median


# 02. 带有均值线和边际地毯线的直方图
gghistogram(iris, x="Sepal.Length", add = "mean", 
          rug = TRUE, color = "Species", fill = "Species",
          palette = c("#00AFBB", "#E7B800", '#DD7F7F')) 
# 换数据集 iris 效果不好
df=diamonds[sample(nrow(diamonds), 1000),]
head(df)
gghistogram(df, x="carat", add = "mean",
            bins=10,
            rug = TRUE, color = "color", fill = "color"
            #,palette = c("#00AFBB", "#E7B800", '#DD7F7F', '#A180A9', '#FEF392')
            )
#

#箱线/小提琴图绘制(barplot/violinplot)



###########
## 01. 箱线图+分组形状+统计
#加载数据集ToothGrowth
data("ToothGrowth")
df1 <- ToothGrowth
head(df1)
#   len supp dose
# 1  4.2   VC  0.5
# 2 11.5   VC  0.5
tail(df1)
ggboxplot(df1, x="dose", y="len", color = "supp",
          palette = c("#00AFBB", "#E7B800", "#FC4E07"),
          add = "jitter", shape="dose") #增加了jitter点，点shape由dose映射
#
p=ggboxplot(df1, x="dose", y="len", color = "dose",
           palette = c("#00AFBB", "#E7B800", "#FC4E07"),
           add = "jitter", shape="dose")
p
#

# 02. 箱线图+分组形状+统计
# 增加不同组间的p-value值，可以自定义需要标注的组间比较
my_comparisons <- list(c("0.5", "1"), c("1", "2"), c("0.5", "2"))
p+stat_compare_means(comparisons = my_comparisons) + #不同组间的比较
  stat_compare_means(label.y = 50) # 
#


# 03. 内有箱线图的小提琴图+星标记
ggviolin(df1, x="dose", y="len", fill = "dose",
         palette = c("#00AFBB", "#E7B800", "#FC4E07"),
         add = "boxplot", #add = “boxplot”中间再添加箱线图
         add.params = list(fill="white"))+
  stat_compare_means(comparisons = my_comparisons, label = "p.signif")+ #label这里表示选择显著性标记（星号）
  stat_compare_means(label.y = 50)

#



###########
# 条形/柱状图绘制(barplot)
data("mtcars")
df2 <- mtcars
df2$cyl <- factor(df2$cyl)
df2$name <- rownames(df2) #添加一行name
head(df2[, c("name", "wt", "mpg", "cyl")])
ggbarplot(df2, x="name", y="mpg", fill = "cyl", color = "white",
          palette = "npg", #杂志nature的配色
          sort.val = "desc", #下降排序
          sort.by.groups=FALSE, #不按组排序
          x.text.angle=60)
# 也可以桉组排序
ggbarplot(df2, x="name", y="mpg", fill = "cyl", color = "white",
          palette = "aaas", #杂志Science的配色
          sort.val = "asc", #上升排序,区别于desc
          sort.by.groups=T, #按组排序
          x.text.angle=60)




###########
# 偏差图绘制(Deviation graphs)
# 偏差图展示了与参考值之间的偏差
df2$mpg_z <- (df2$mpg-mean(df2$mpg))/sd(df2$mpg) # 相当于Zscore标准化，减均值，除标准差
df2$mpg_grp <- factor(ifelse(df2$mpg_z<0, "low", "high"), levels = c("low", "high"))
head(df2[, c("name", "wt", "mpg", "mpg_grp", "cyl")])
ggbarplot(df2, x="name", y="mpg_z", fill = "mpg_grp", color = "white",#柱状图边框
          palette = "jco", #按jco杂志配色方案
          sort.val = "asc", 
          sort.by.groups = FALSE,
          x.text.angle=60, ylab = "MPG z-score", xlab = FALSE, legend.title="MPG Group")
#
# 坐标轴变换
ggbarplot(df2, x="name", y="mpg_z", fill = "mpg_grp", color = "white",
          palette = "jco", 
          sort.val = "desc", 
          sort.by.groups = FALSE,
          x.text.angle=90, ylab = "MPG z-score", xlab = FALSE,
          legend.title="MPG Group", 
          rotate=TRUE, #翻转坐标轴，柱状图秒变条形图
          ggtheme = theme_minimal()) # rotate设置x/y轴对换
#




############
#棒棒糖图绘制(Lollipop chart)
#棒棒图可以代替条形图展示数据
ggdotchart(df2, x="name", y="mpg", color = "cyl",
           group='cyl',
           palette = c("#00AFBB", "#E7B800", "#FC4E07"),
           sorting = "ascending", #下降 descending
           add = "segments", #添加连线
           ggtheme = theme_pubr())
#柱状图太多了单调，改用棒棒糖图添加多样性
#设置其他参数
ggdotchart(df2, x="name", y="mpg", color = "cyl",
           group='cyl',
           palette = 'npg', #c("#00AFBB", "#E7B800", "#FC4E07"),
           sorting = "descending",
           add = "segments", 
           rotate = TRUE,#旋转坐标轴
           dot.size = 5, #点的大小
           label = round(df2$mpg), #添加糖心中的数值
           font.label = list(color="white",size=9, vjust=0.5),
           ggtheme = theme_pubr())
#
# 棒棒糖偏差图
#用Z-score的值代替原始值绘图。
dfm=df2
dfm$mpg_z=( dfm$mpg-mean(dfm$mpg) )/sd(dfm$mpg)
ggdotchart(dfm, x = "name", y = "mpg_z",
           color = "cyl", # Color by groups
           palette = c("#00AFBB", "#E7B800", "#FC4E07"), # Custom color palette
           sorting = "descending", # Sort value in descending order
           add = "segments", # Add segments from y = 0 to dots
           add.params = list(color = "lightgray", size = 2), # Change segment color and size
           group = "cyl", # Order by groups
           dot.size = 6, # Large dot size
           label = round(dfm$mpg_z,1), # Add mpg values as dot labels，设置一位小数
           font.label = list(color = "white", size = 9, vjust = 0.5), # Adjust label parameters
           ggtheme = theme_pubr() # ggplot2 theme
)+
  theme( axis.text.x=element_text(angle=60,hjust=1) )+
  geom_hline(yintercept = 0, linetype = 2, color = "lightgray")
#
# Cleveland点图绘制
ggdotchart(dfm, x = "name", y = "mpg",
           group='cyl',
           color = "cyl", # Color by groups
           palette = c("#00AFBB", "#E7B800", "#FC4E07"), # Custom color palette
           sorting = "descending", # Sort value in descending order
           rotate = TRUE, # Rotate vertically
           dot.size = 2, # Large dot size
           y.text.col = TRUE, # Color y text by groups
           ggtheme = theme_pubr() # ggplot2 theme
)+
  theme_cleveland() # Add dashed grids
#




















# readMe for R src

# source('base/tool.color.R')


========================
优化的生信分析文件结构

* 探讨见 txtBlog/NGS/最佳实践: 生物信息分析文件夹-目录命名和组织结构：目录结构
* 脚本生成R项目 目录结构: > source("bioToolKit/R_scripts/single_script/init_project.R")


|-projectName 命名不能出现空格、汉字，尽量使用大小写字母、下划线和减号命名文件夹。
	|-ReadMe.txt 对外可见的简介，简介里程碑式的成果。
	|-changeLog.txt 记录每次提交git的日志

	|-docs/ 放文档，写文档
		|-01_map.markdown #记录结果，看怎么方便阅读吧。
	|-scripts/ 放脚本，编号、命名写好。
		|-2020-10-07_simulation_fish_count.Rmd 脚本首行绝对路径: setwd("xxx/xx/results/")
		|-2020-10-15_simulation_fish_count.R 脚本首行绝对路径: setwd("xxx/xx/results/")
	|-R/  函数的定义，后续可以写R包。被引用到script中: source("../src/base/tool.df.R") #这里收集代码还用 src/，表示source code
		|-readMe.txt #记录主要过程。保存在 bioToolKit/R_scripts/src/
		|-base/tool.init.R
		|-base/tool.df.R
		|-base/tool.color.R
	|-src/ 一些R包需要的c++函数
	|-tests/ 测试数据和结果

	|-data/ 原始数据
		|-raw/ 放原始数据，设置为只读。
		|-processed/ 处理后的数据
	|-output/  按项目保存结果
		|-01_map_result/ 图片png,jpg,svg等，及pdf输出, 及数据文件txt,csv等
		|-02_RNA_cor/
#



# 参考基因组的命名
/home/xxx/data/RNA/refs/hg19/hg19.fa
/home/xxx/data/RNA/refs/hg19/hg19_ucsc_genes.gtf 

/home/xxx/data/ref/hg19/index/star/  #看路径就知道是hg19的参考基因组，star的index 



# 后缀名，刻意一点
数据框， xx.df.txt 
基因列表 xx.gene.txt


========================








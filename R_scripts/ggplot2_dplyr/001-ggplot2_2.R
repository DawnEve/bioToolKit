#learn ggplot2
# http://ggplot2.org
#docs: http://ggplot2.tidyverse.org/reference/
#ggplot2作者出的测试题： http://stat405.had.co.nz/drills/ggplot2.html

#R语言数据可视化：R中的三大绘图系统、颜色、探索性数据分析、RMarkdown出报告
#https://www.imooc.com/video/11590

#1.数据科学家需要具备哪些知识与技能？
#计算机+统计学+需要分析的专业背景。
#功夫不负有心人。

#2.完整的数据分析流程
#1)定义研究问题;定义理想的数据集;确定能获取什么数据;获取数据;清理数据;
#2)核心: 探索性分析(数据可视化);统计分析/建模(机器学习)等
#3)解释/交流结果(数据可视化);挑战结果(有没有其他可能?);书写报告(Reproducible原则)

#驱动：假设驱动(核心、主流、困难)、数据驱动(随意、需要补课)

#3.R语言数据基础
数据矩阵
观测：一行
变量：一列

变量类型：
数值变量：连续(身高)、离散(学生个数)
分类变量：无序(颜色)、有序(年级)


数值变量的特征和可视化：
数据集中趋势的测量:均值(mean)、中位数(median)、众数(mode)
分散趋势:值域(range:max-min)、方差(variance)、标准差(standard variance)、

========================================
ggplot2画errorbar
----------------------------------------





========================================
ggplot2画 DotPlot 点图
----------------------------------------
####replot markergenes
CairoPDF( paste0(file_out,"plot_genes/marker_genes_v5/BcellMarker.pdf") , width = 16, height = 10)
marker_dot_plot <- DotPlot(object = dataForPlot, genes.plot = BcellMarker, plot.legend = TRUE,
                           cols.use = c("black","red"), x.lab.rot = T,dot.scale = 10, do.return=T)
marker_dot_plot <- marker_dot_plot + theme(axis.text.x = element_text(angle = 45, vjust = 1, hjust = 1))
print(marker_dot_plot)
dev.off()



其中该函数的定义如下：
function (object, genes.plot, cols.use = c("lightgrey", "blue"), 
  col.min = -2.5, col.max = 2.5, dot.min = 0, dot.scale = 6, 
  group.by, plot.legend = FALSE, do.return = FALSE, x.lab.rot = FALSE) 
{
  if (!missing(x = group.by)) {
    object <- SetAllIdent(object = object, id = group.by)
  }
  data.to.plot <- data.frame(FetchData(object = object, vars.all = genes.plot))
  data.to.plot$cell <- rownames(x = data.to.plot)
  data.to.plot$id <- object@ident
  data.to.plot <- data.to.plot %>% gather(key = genes.plot, 
    value = expression, -c(cell, id))
  data.to.plot <- data.to.plot %>% group_by(id, genes.plot) %>% 
    summarize(avg.exp = mean(expm1(x = expression)), pct.exp = PercentAbove(x = expression, 
      threshold = 0))
  data.to.plot <- data.to.plot %>% ungroup() %>% group_by(genes.plot) %>% 
    mutate(avg.exp.scale = scale(x = avg.exp)) %>% mutate(avg.exp.scale = MinMax(data = avg.exp.scale, 
    max = col.max, min = col.min))
  data.to.plot$genes.plot <- factor(x = data.to.plot$genes.plot, 
    levels = rev(x = sub(pattern = "-", replacement = ".", 
      x = genes.plot)))
  data.to.plot$pct.exp[data.to.plot$pct.exp < dot.min] <- NA
  p <- ggplot(data = data.to.plot, mapping = aes(x = genes.plot, 
    y = id)) + geom_point(mapping = aes(size = pct.exp, 
    color = avg.exp.scale)) + scale_radius(range = c(0, 
    dot.scale)) + scale_color_gradient(low = cols.use[1], 
    high = cols.use[2]) + theme(axis.title.x = element_blank(), 
    axis.title.y = element_blank())
  if (!plot.legend) {
    p <- p + theme(legend.position = "none")
  }
  if (x.lab.rot) {
    p <- p + theme(axis.text.x = element_text(angle = 90, 
      vjust = 0.5))
  }
  suppressWarnings(print(p))
  if (do.return) {
    return(p)
  }
}






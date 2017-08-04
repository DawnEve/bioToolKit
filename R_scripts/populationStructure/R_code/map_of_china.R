#ggplot2绘制中国地图从国家基础地理信息中心下载中国地图的GIS数据。

setwd("D:\\bioToolKit\\R_scripts\\populationStructure")

#加载maptools包，读取空间文件
library("maptools")
#data: https://github.com/ronnyKJ/ShapeFile/tree/master/map
china_map = readShapePoly("map\\bou2_4p.shp")
plot(china_map)

library(ggplot2)
ggplot(china_map,aes(x=long,y=lat,group=group))+
  geom_polygon(fill="white",colour="grey")+
  coord_map("polyconic")
# Error in bioLite("mapproj") : could not find function "bioLite"

# 




#
#refer:
# https://cosx.org/2009/07/drawing-china-map-using-r
# https://www.zhihu.com/question/41230152
# http://www.mamicode.com/info-detail-896335.html
# http://bbs.pinggu.org/forum.php?mod=viewthread&tid=4182165&page=1

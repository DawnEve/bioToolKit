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
# could not find function "mapproj"
# biocLite("mapproj")
# 



# 现在地图是可用的了，但还需要加载和拼接行政信息，以便能与业务数据映射。
x <- china_map@data           #读取行政信息
xs <- data.frame(x,id=seq(1:924)-1)          #含岛屿共925个形状

library(ggplot2)
china_map1 <- fortify(china_map)           #转化为数据框

library(plyr)
china_map_data <- join(china_map1, xs, type = "full")#合并两个数据框.提示：Joining by: id


###############
#添加各省数据，

#按以下格式准备好指标数据，并存为csv格式文件。
#不直接读取xlsx文件是因为需要装的包比较麻烦。

#注意第1列的字段名为NAME，
#各省名称也是要固定一致的，是为了和地图数据框里的省名一致，便于合并。
#后面一列是指标数据，我命名的表头是clazz，下面填充时要一致

#各省名称是用以下命令查看并记下的。
unique(china_map@data$NAME)


#下面读取业务指标数据，并与地图数据合并：
mydata <- read.csv("R_data\\province_group.txt",sep="\t",header=T) #读取指标数据，csv格式
china_data <- join(china_map_data, mydata, type="full") #合并两个数据框
#提示：Joining by: NAME

ggplot(china_data, aes(x = long, y = lat, group = group, fill = clazz)) +
  geom_polygon(colour="grey40") +
  scale_fill_gradient(low="white",high="steelblue") +  #指定渐变填充色，可使用RGB
  coord_map("polyconic")  +      #指定投影方式为polyconic，获得常见视角中国地图
  #图中的背景色、坐标轴、经纬线都是不需要的，图例也可以放到左下角，用theme命令清除：
  theme(               #清除不需要的元素
    panel.grid = element_blank(),
    panel.background = element_blank(),
    axis.text = element_blank(),
    axis.ticks = element_blank(),
    axis.title = element_blank(),
    legend.position = c(0.2,0.3)
  )



###############
# 有时候需要显示省名标签，特别是给老领导看。
# 使用省会城市的经纬度数据标注省名。
province_city <- read.csv("R_data\\province_label_site.txt",sep="\t",header=T)  #读取省会城市坐标
#经纬度换算 http://www.gzhatu.com/du2dfm.html
#province_city


ggplot(china_data,aes(long,lat))+
  geom_polygon(aes(group=group,fill=clazz),colour="grey60")+
  scale_fill_gradient(low="white",high="steelblue") +
  coord_map("polyconic") +
  geom_text(aes(x = long,y = lat,label = en_name), data =province_city,size=2)+
  theme(
    panel.grid = element_blank(),
    panel.background = element_blank(),
    axis.text = element_blank(),
    axis.ticks = element_blank(),
    axis.title = element_blank()
  )

#
#refer:
# https://cosx.org/2009/07/drawing-china-map-using-r
# [推荐]https://www.zhihu.com/question/41230152
# http://www.mamicode.com/info-detail-896335.html
# http://bbs.pinggu.org/forum.php?mod=viewthread&tid=4182165&page=1

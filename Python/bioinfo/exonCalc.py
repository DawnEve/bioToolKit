import re
import os
from  collections import OrderedDict
import time
time1 = time.time()

fileName="D:\coding\Java\CCDS.20160908.txt";

#获取染色体列表
def getChrList():
    chrs=[];
    with open(fileName,'rt') as f:
         for line in f:
             if line.startswith('#'):
                continue
             line=line.rstrip()
             lst=line.split('\t')
             if lst[-2] == '-':
                 continue
             if lst[0] not in chrs:
                 chrs.append(lst[0])
    return chrs;


#按照染色体计算独特位点个数
def calcByChr(chrName):
    lineNumber=0;#总行数
    counter=0;#行数计数器
    exonLength=0
    overlapExons=OrderedDict()
    with open(fileName,'rt') as f:
         for line in f:
             lineNumber+=1 #总行数
             if line.startswith('#'):
                continue
             line=line.rstrip()
             lst=line.split('\t')
             if lst[0] != chrName:
                 continue
             counter += 1 #进入计数的染色体总数
             if lst[-2] == '-':
                 continue
             lst[-2] = re.sub('\[|\]',' ',lst[-2])
             exons=lst[-2].split(', ')
             for exon in exons:
                 start = exon.split("-")[0] 
                 end = exon.split("-")[1]
                 for coordinate in range(int(start),int(end)+1):
                     #coordinate = lst[0] + ':'+str(i)
                     #coordinate=i
                     if coordinate not in overlapExons.keys():
                        overlapExons[coordinate] = 1
                        exonLength += 1
                        #exonLength += int(end) - int(start)
    print("chr",chrName,"共",counter,"行/",lineNumber,"行，特异位点共",exonLength,"个");
    return exonLength;



#1.获取总染色体列表
chrs=getChrList(); 
#chrs=["1"] #debug use only

#2.统计每个染色体的cds长度。累加获得总cds长度。
totalLength=0;
for chr in chrs:
    totalLength += calcByChr(chr);

print("总长度",totalLength,"bp");

time2 = time.time()
print("总耗时：",time2-time1,'s');
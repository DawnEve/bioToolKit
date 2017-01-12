#rm(list=ls())

fileName="D:/coding/Java/CCDS.20160908.txt";


calcByChr=function(currentChr){
  overlapExons=c();#保存已经存在的位点
  
  #函数1：由"925941-926012"  "930154-930335" 字符串按行计算总长度
  getLengthFromArrs=function(arr){
    innerLen=0;
    for (str in arr) {
      limits <- strsplit(str,'-')[[1]]# "925941-926012"
      start=as.numeric(limits[1]);
      end=as.numeric(limits[2]);
      for (i in c(start:end)) {
        #if(is.logical(which(overlapExons==i))){print("有") }else{print("无")}
        if(length(overlapExons[overlapExons==i])==0){ #判断变量i是否在数组overlapExons中
          #print("无") 
          overlapExons <<- c(overlapExons,i);
          innerLen=innerLen+1;
        }
      }
    }
    return(innerLen)
  }
  
  
  
  lineNumber=0;#文件总行数
  counter=0;#当前染色体总行数
  totalLength=0;
  
  #=====================================
  #逐行读取文件
  con <- file(fileName, "r")
  on.exit(close(con))
  line=readLines(con,n=1) #读取第一行
  
  while( length(line) != 0 ) {
    lineNumber=lineNumber+1;
    #print(paste(lineNumber,">>",line))

    lineDice=strsplit(line,"\t")[[1]];
    chr=lineDice[1];
    
    if(chr==currentChr){
      cds=lineDice[10];
      counter=counter+1;
      if(cds!="-"){
        cds=sub('\\[','',cds);
        cds=sub('\\]','',cds); # 这个时候得到的对象还是像这样的“880073-880179, 880436-880525……”
        arrStartEnd <- strsplit(as.character(cds),', ')[[1]]# 我们先从逗号开始分割成小块
        totalLength=totalLength+getLengthFromArrs(arrStartEnd);
      }
    }
    
    if(lineNumber%%200==0) print(paste(lineNumber,",",length(overlapExons)));#进程监控
    if(lineNumber>5000) break;#性能测试
    
    line=readLines(con,n=1);#读取下一行
  }
  #close(con) #关闭文件
  #=====================================
  
  msg=paste("chr",currentChr,":",counter,"/",lineNumber,"行, 独特位点len=",totalLength);
  print(msg)
}

################################

# 如何加快R代码运行速度http://www.biotrainee.com/thread-3-6-1.html
#R里避免用for对非常大的向量历遍（小向量可以），改用apply系列的函数和避免多个数据追加等这些小细节


time1=Sys.time();
calcByChr("1")

time2=Sys.time();
print(paste("消耗时间",time2-time1,'min'))

################################


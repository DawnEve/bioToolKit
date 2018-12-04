################
# on linux only.
################ 

## 任务：从文件读取一行小分子 id，作为参数传给下载进程们。
# 多线程下载 多文件
## 一个进程记录数据，一个进程池 众多线程下载和保存数据。
## 读、写进程之间用queue通信。

#问题： 为什么不能在子进程中完整保存呢？因为没有flush文件。

import os
import re
import requests


############################
##part 1 配置文件:
############################
os.chdir('/home/wangjl/Download/py/') #设置项目目录
print(os.getcwd())

#需要新建文件夹，并在文件夹同级放id文件
pname="molport" 
#"molportnp";
#"fda"  #"specsnp" #项目名字project name

# 示例文件 $ wc molport.id_all_uniq 
# 303558  303558 5160486 molport.id_all_uniq
#wangjl@sustc-HG:~/Download/py$ head molport.id_all_uniq 
#ZINC000000000010
#ZINC000000000092
#ZINC000000000102



############################
#part 2 工作函数
############################
#fun: 根据id下载文件
def download(id):
    #发出请求
    # "http://zinc15.docking.org/substances/ZINC000000000018.sdf"
    rs=requests.get("http://zinc15.docking.org/substances/"+id+".sdf")
    #写入二进制文件
    with open(pname+"/"+id+'.sdf','wb') as f:
        f.write(rs.content)
    return id;
#download("ZINC000000001368")



############################
#part 3 多线程
############################
import time,multiprocessing,os,random,re,sys
from multiprocessing import Queue
from multiprocessing import Process

#start time
start=time.time()
print('='*10, "Begin of main process", os.getpid(), "[child pid by parent ppid]")

# 读和处理数据
def worker(id):
    #一个很耗时的计算
    rs=download(id) #该函数在上一个cell定义的
    q.put(rs) #结果输出到管道
    #print(id+" done.")

#保存的线程1个
def worker_out():
    i=0
    with open(pname+'.done', 'w') as f:
        while True:
            i+=1
            if i%200==0: #进度条
                #pass 
                print(str(i)+" files have been done.  Elapse = "+ str(time.time()-start) +'s' )
            
            rs=q.get() #waite while q is empty
            #print(rs)
            f.write(rs+"\n") #写入文件
            f.flush() #刷新缓存，一次性输出到文件


# 主进程
if __name__ == '__main__':
    q=Queue(100) #会超标，但是不会超出太多
    
    # 声明进程池对象
    pool = multiprocessing.Pool(processes = 50)

    #文件读取，分配任务给进程
    fr=open(pname+".id",'r')

    # 向进程池中提交任务
    i=0
    for lineR in fr.readlines():
        i+=1
        if i>1000:
            pass;
            #break; #测试用语句

        line=lineR.strip()
        #print('>>>>>>to worker:',line)
        #arr=re.split(' ',line)
        #print("start new process", line) #任务是一次发送完的
        pool.apply_async( worker,args=(line,) )
    fr.close() #关闭文件

    #分完任务，开始启动保存进程
    pOut = Process(target=worker_out)
    pOut.start()

    #等待读进程结束
    pool.close()
    pool.join()

    #主线程查看队列，决定是否关掉写循环
    while not q.empty():
        time.sleep(1)#每一秒检查一次队列是否为空

    pOut.terminate(); #终止死循环

print(time.time()-start,'s', '='*10, "End of main process", os.getpid())



#concurrence 并发处理执行linux命令
# v0.1

################
# on linux only.
################ 
## 任务：从文件读取一行cell id，作为参数传给处理进程们。
## 一个进程写数据，一个进程池 众多线程读和处理数据。
## 读、写进程之间用queue通信。
#遇到过的问题：
#Q: 为什么不能在子进程中完整保存呢？ A: 因为没有flush文件。
#Q: 为什么把main中的包装成函数，就阻塞了？ A: 没解决


################################
#part 1 定义路径
################################
import os
#os.chdir('/home/wangjl/data/c1_2019APA/sc/combine/sc_fq') #定义工作目录，仅对python有效。对linux命令建议都使用绝对路径。
os.getcwd()


################################
#part 2 定义linux命令
################################
import subprocess

#目的：需要平行处理的linux命令。if the function can run on one id, it can run on the batch of ids.
#要点： 使用id拼接linux命令。建议都用绝对路径。
def doLinuxCMD(id):
    #构建命令
    fpath="/home/wangjl/data/c1_2019APA/sc/combine/sc_fq/R2_left/"
    cmd="ls -lth "+fpath+id+"_R2.fastq"

    #samtools 语句示例
    #cmd="samtools view -bS "+fpath+"R2_left_human/"+id+"_Aligned.out.sam >"+fpath+"bamR2Lh/"+id+".bam"
    #cmd="samtools sort -o "+fpath+"bamR2Lh/"+id+".sorted.bam "+fpath+"bamR2Lh/"+id+".bam"
    #cmd="samtools index "+fpath+"bamR2Lh/"+id+".sorted.bam"

    #print(cmd) #查看命令拼接效果

    #执行linux命令
    (status, output)=subprocess.getstatusoutput(cmd)
    #print(output) #查看linux命令输出到屏幕上的文字
    return status #返回状态码，0表示命令正常执行，其他表示异常，需要查看output推测具体原因

#test 测试
#doLinuxCMD('c2_ROW01') #传入一个关键词


################################
#part 3 并行执行
################################
import time,multiprocessing,os,re #random
from multiprocessing import Queue
from multiprocessing import Process

#读和处理数据，并行
def worker(cb):
    #一个很耗时的计算
    rs=cb+"\t"+str( doLinuxCMD(cb) ) #part2 中定义的
    q.put(rs)   #结果输出到管道

#保存的线程1个
def writer(log_file_name,ID_total,hint_n=20):
    breaks=int(ID_total/hint_n) #显示20次进度提示
    i=0
    with open(log_file_name, 'w') as f: #这里不能是变量名？
        while True:
            i+=1
            if i%breaks==0: #进度条
                print(i," items processed in ", time.time()-start," seconds",sep="")
            rs=q.get() #waite while q is empty
            f.write(rs+"\n") #写入文件
            f.flush() #刷新缓存，一次性输出到文件

#=====================
#settings
id_list="left.ID" #输入文件名关键词列表，一个id一行，用于在doLinuxCMD命令中构建linux命令。表示本脚本要多线程处理这么多文件。
#一下采用默认值即可
core=10 #使用的CPU逻辑核心数。该数字 x linux命令使用的线程数 要小于硬件CPU逻辑核心数
hint_n=10 #默认给出20个进度提示
log_file_name='py2.log' #输出日志的文件名，内容是： id号 运行状态(0表示正常，否则表示异常) 
#=====================
#start time
start=time.time()
print('='*10, ">Begin of main process[", os.getpid(), "][child pid by parent ppid]", sep="")

# 主进程
if __name__ == '__main__': 
    q=Queue(core+10) #创建队列
    pool = multiprocessing.Pool(processes = core)# 声明进程池对象

    # 向进程池中提交任务，交给并行的worker()来处理
    fr=open(id_list,'r')#读取id_list文件，分配任务给进程
    i=0
    for lineR in fr.readlines():
        i+=1
        #if i>10:
        #    pass;
        #    #break; #测试用语句

        line=lineR.strip()
        arr=re.split(' ',line) ##print("start new process", line) #任务是一次发送完的
        pool.apply_async( worker,args=(arr[0],) )
    fr.close() #关闭文件

    #分完任务，开始启动保存进程，由writer()函数来处理
    pOut = Process(target=writer, args=(log_file_name,i,hint_n,)) # args：元组参数，如果参数就一个，记得加逗号’，’
    pOut.start()

    #等待读进程worker()全部结束
    pool.close()
    pool.join()

    #主线程查看队列，决定是否关掉写writer()循环
    ##todo 这里有风险，会不会执行不完就被关掉了呢？虽然目前还没有遇到过
    while not q.empty():
        time.sleep(1)#每一秒检查一次队列是否为空
    pOut.terminate(); #终止死循环

print(time.time()-start,'s <', '='*10, "End of main process[", os.getpid(),']', sep="")
print("#"*40,"\nLog file: "+ os.getcwd()+"/"+log_file_name)

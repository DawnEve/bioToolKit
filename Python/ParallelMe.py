# define a class: ParallelMe[Run on Linux only!]
# version: 0.2.1
import subprocess
import time,multiprocessing,os,re,random,datetime

class ParallelMe(object):    
    #初始化属性
    def __init__(self, doLinuxCMD_fn, id_list_file, core=3, hint_n=5,log_file_name='logs.txt',uniqLogName=False):
        """
        待批量处理的函数 doLinuxCMD_fn 仅仅依赖一个id，然后id的list在文件 id_list_file 中提供。
        if hint_n定义几次，就出几次进度提示，默认提示5次,最小是1次;
        uniqLogName==True时，会对log文件加时间戳后缀，默认不加时间戳;
        """
        # 必选值
        self.doLinuxCMD=doLinuxCMD_fn
        self.id_list_file=id_list_file
        #默认值
        self.core=core #使用的CPU逻辑核心数。该数字 x linux命令使用的线程数 要小于硬件CPU逻辑核心数
        self.hint_n=hint_n;
        self.log_file_name=log_file_name; #输出日志的文件名，内容是： id号 运行状态(0表示正常，否则表示异常) 
        #需要处理
        #self.uniqLogName=uniqLogName;#这个文件名要加上时间戳，防止忘了修改日志文件名而被覆盖掉
        if uniqLogName:
            timsString=time.strftime("%Y%m%d-%H%M%S", time.localtime()) 
            self.log_file_name=log_file_name + timsString
        #
        #self.q=Queue(core+5) #创建队列
        self.queue=multiprocessing.Manager().Queue(core+5);
    
    #定义worker: 读和处理数据，并行
    def worker(self, cb):
        #print("worker===> ",cb, os.getpid() );
        #一个很耗时的计算
        rs=str(cb)+"\t"+str( self.doLinuxCMD(cb) ) #part2 中定义的
        self.queue.put(rs)   #结果输出到管道
    
    #保存的线程1个
    def writer(self,log_file_name,ID_total,hint_n=10):
        hit_n=int(hint_n);
        if hint_n<1:
            hint_n=1;
        breaks=int(ID_total/hint_n) #显示hint_n次进度提示
        i=0
        with open(log_file_name, 'w') as f: #这里不能是变量名？
            while True:
                if i%breaks==0 or i==ID_total: #进度条
                    print(i," items processed in ", round(time.time()-self.start, 2)," seconds",sep="")
                # 如果所有条目都保存过了，则退出死循环                
                if(i==ID_total):
                    break;
                i+=1
                rs=self.queue.get() #waite while queue is empty
                f.write(rs+"\n") #写入文件
                f.flush() #刷新缓存，一次性输出到文件
    
    #主进程: 向进程池中提交任务，交给并行的worker()来处理
    def main(self):
        #1. 声明进程池对象
        pool=multiprocessing.Pool(self.core)
        #2. 读取id_list_file文件，分配任务给进程
        fr=open(self.id_list_file,'r')
        lines=fr.readlines();
        ID_total=len(lines);
        for lineR in lines:
            line=lineR.strip()
            arr=re.split(' ',line) ##print("start new process", line) #任务是一次发送完的
            pool.apply_async( self.worker, args=(arr[0],) )
        fr.close() #关闭文件

        #3. 分完任务，开始启动保存进程，由writer()函数来处理
        pOut = multiprocessing.Process(target=self.writer, args=(self.log_file_name,ID_total,self.hint_n,)) # args：元组参数，如果参数就一个，记得加逗号’，’
        pOut.start()

        #4. 等待读进程worker()全部结束
        pool.close()
        pool.join()
        #5. 等待写循环结束
        pOut.join()
    
    #运行
    def run(self):
        #输出运行参数
        self.start=time.time();#启动时的时间
        print("function name:", self.doLinuxCMD);
        print("id list file:", self.id_list_file);
        print('CPU core number:', self.core);
        print('hint number:', self.hint_n);
        print('log_file_name:', self.log_file_name);
        #
        print("#"*40,'\n',datetime.datetime.now(),"\n","#"*40, sep="")
        print('='*10, ">Begin of main process[", os.getpid(), "][child pid by parent ppid]", sep="")
        self.main(); #开启多进程
        print(time.time()-self.start,'s <', '='*10, "End of main process[", os.getpid(),']', sep="")
        print("#"*40,"\nLog file: "+ os.getcwd()+"/"+self.log_file_name,"\n","#"*40, sep="")
# end of class
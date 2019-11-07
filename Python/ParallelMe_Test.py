##ParallelMe_Test.py
#其他目录，需要添加工作目录，再引入包。
#import sys
#sys.path.append("/home/wangjl/test/")

from ParallelMe import ParallelMe
################################
#使用三部曲
################################
import os,subprocess,random

##part 1 定义路径
print('Step1> define path: ',os.getcwd())
os.chdir('/home/wangjl/test') #定义工作目录，仅对python有效。对linux命令建议都使用绝对路径。


#part 2 定义linux命令，返回字符串，会被记录到日志文件中。
print("Step2> define the function to be run parallelly: doLinuxCMD(id)")
#目的：需要平行处理的linux命令。if the function can run on one id, it can run on a list of ids.
#要点： 使用id拼接linux命令。建议都用绝对路径。
def doLinuxCMD(id):
    #构建命令，很复杂的linux命令
    cmd="sleep "+str(random.randint(0,4)); #这个linux命令为休眠一段时间。可以是linux脚本，有输入和输出，建议用绝对路径。
    #执行linux命令
    (status, output)=subprocess.getstatusoutput(cmd)
    #print(output) #查看linux命令输出到屏幕上的文字
    rs=str(status)+"\t"+output# +"\t"+str(os.getpid())+"\t"+str(os.getppid());
    return rs #返回状态码status，0表示命令正常执行，其他表示异常，需要查看output推测具体原因
#test
#doLinuxCMD(1) #status output pid ppid


#part 3 批量运行该linux命令
print("Step3> run the function parallelly");
#doLinuxCMD为函数，要有str返回值
#id_list为id列表文本文件名，一个id一行。建议用绝对路径
#core为并行个数(默认是3)，要小于CPU个数，但是超过id总个数也没有意义;
id_list="/home/wangjl/test/a.txt"
myTasks=ParallelMe(doLinuxCMD, id_list, core=55);
myTasks.run()

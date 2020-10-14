## 倒计时护眼程序
# version 0.1
import time,sys,random
import tkinter.messagebox #必须要引用子模块
from tkinter import *
from PIL import ImageTk, Image

################
# settings
################
mode="run" #debug or run

interval=3 #弹窗间隔时间，单位 秒seconds，测试
sleepTime=1 #休眠时间，期间不检查时间，一般要比间隔小

if mode ==  'run':
    interval=60*10 #45min
    sleepTime=60 # check once per min.
# get para from cmd
if len(sys.argv)>1:
    interval=int(sys.argv[1])
# adjust sleepTime
if sleepTime > interval/5:
    sleepTime=interval/5
#

# picture path array
img_paths=[r"C:\Users\admin\Desktop\blog_pics\机器学习ML\Tree\image-20150907-22253-rnp0iv.jpg",
    r"C:\Users\admin\Pictures\cow.jpg"
    ]


################
# main scripts
################
start=time.time(); i=0
while True:
    img_path=img_paths[ int(random.random()*len(img_paths)) ]
    i=i+1
    if i>10:break;
    time.sleep(sleepTime)
    print(i*sleepTime, 'seconds elapsed.')
    if time.time()-start>interval:
        root=Tk()
        root.title("EyeDefender.py")
        root.wm_attributes('-topmost',1) #实现root窗口的置顶显示

        root.wm_attributes('-fullscreen',True) #全屏
        # full screen
        #root.overrideredirect(True)
        #root.geometry("{0}x{1}+0+0".format(root.winfo_screenwidth(), root.winfo_screenheight()))
        #root.geometry("1600x800+100+100") #宽高

        # add pic
        img = ImageTk.PhotoImage(Image.open(img_path))
        panel = Label(root, image = img)
        panel.pack(side = "bottom", fill = "both", expand = "yes")

        # pop choice box
        result=messagebox.askquestion('Notify',"Let your eyes to have a rest!\n\nDo you want to start timer again?")
        #root.mainloop()
        if result=='yes':
            root.destroy()
            start=time.time()
            i=0
            continue;
        else:
            sys.exit(0)
print('==end==')
# ref
# 强制顶层弹窗 https://www.cnblogs.com/shuchengxiang/p/6632140.html
# 添加图片 https://stackoverflow.com/questions/10133856/how-to-add-an-image-in-tkinter
# 全屏 https://stackoverflow.com/questions/7966119/display-fullscreen-mode-on-tkinter

def test():
    for i in range(1,10):
        print(i);#有头无尾
        
def test2(): 
    list=[];
    list.append(1)
    list.append(1)
    list.append(1)
    
    print(list)
def test3():
    li=['1', '2', '3', '4']
    for i in li:
        print(i)
# http://www.runoob.com/python/python-variable-types.html

def test4():
    import time
    time1 = time.time()
    time.sleep(2)
    time2 = time.time()
    print(time2 - time1)
    #http://www.cnblogs.com/kaituorensheng/archive/2012/11/06/2757865.html
    
test4() 
    
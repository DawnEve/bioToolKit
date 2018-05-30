#  learn S3 and S4 class 
# version 0.2.0
#
# refer: https://adv-r.hadley.nz/s4.html
# https://uploads.cosx.org/2012/11/ChinaR2012_SH_Nov04_07_WYC.pdf
#

# OOP 是一种编程范式，将方法（函数）和数据封装起来，提高软件的重用性、灵活性和扩展性。
# R强项是统计计算和绘图（数据可视化）。
# R虽然被认为是一种函数式语言，但同样支持面向对象编程。
# R及其扩展：多以OOP方式实现了统计模型和算法。

########
# OOP的核心是class和method。
# class定义了对象共同拥有的某些属性及其类的关系。
# 如果一个对象属于某各类，则称该对象是这个类的实例（instance）
# 方法是一种与特定的对象关联的函数。

# R的OOP系统：S3和S4及其他。


######################
# S3 类 https://uploads.cosx.org/2012/11/ChinaR2012_SH_Nov04_07_WYC.pdf
######################

# S3实现了一种基于泛型函数的面向对象方式。
# 泛型函数式一种特殊的函数，其根据传入对象的类型决定调用哪个具体的方法。
# 比如函数print(),summary(),plot()等方法使用同一个泛型函数名，就能根据一个对象的不同类型来显示它。

x=rep(0:1,c(10,20))
summary(x)
## Min. 1st Qu. Median Mean 3rd Qu. Max.
## 0.000 0.000 1.000 0.667 1.000 1.000

y=as.factor(x)
summary(y)
## 0 1
## 10 20


#
# S3对象往往是一个list并有一个名为class的属性。
x <- 1
attr(x, "class") <- "foo"
x
## [1] 1
## attr(,"class")
## [1] "foo"
class(x)
## [1] "foo"

y=structure(2,class='foo')
y
## [1] 2
## attr(,"class")
## [1] "foo"
class(y)
## [1] "foo"


#
# S3没有正式的类间关系的定义。一个对象可以有多个类型，其class属性是一个向量。
class(x)=c('foo','bar')
class(x)
## [1] "foo" "bar"



#
# 泛型——方法分派(method dispatch)
#使用UseMethod()来决定为对象分派哪个方法。
# 找不到x对应的类型的泛型函数，则使用default。
#myfn=function(x) "myfn" #这个非泛型模式
myfn=function(x) UseMethod("myfn",x)
myfn.default=function(x) "default"
myfn.numeric=function(x) "numeric"
myfn.data.frame=function(x) "data.frame"
myfn.matrix=function(x) "matrix"
myfn.foo=function(x) "foo"
myfn.bar=function(x) "bar"

myfn(10) 
##[1] "numeric"
myfn(data.frame(name=c('Jim','Robin'),age=c(14,41)))
##[1] "data.frame"

z=2
class(z)=c('foo2','bar')
class(z)
myfn(z)
## [1] "bar" 按类在list中顺序查找，找到停止。
#找不到，使用default
myfn(mean) #传入函数
## [1] "default"

#我们还可以自定义打印print方法。
print.bar=function(x){
  cat('This is a bar print:',"\n")
  cat("the value is:",x)
}
print(z)
##This is a bar print: 
##the value is: 2


# 
#实例2
Robin=list(name="Robin",salary=10000,union=T)
class(Robin) #[1] "list"
class(Robin)="employer"
class(Robin)#[1] "employer"
str(Robin)
Robin #这个打印方式太不个性
#自定义打印方式
print.employer=function(man_){
  cat(man_$name,"\n")
  cat('salary:',man_$salary,"\n")
  cat('union member:',man_$union,"\n")
}
Robin #自动调用上述定义的个性打印方式
##Robin 
##salary: 10000 
##union member: TRUE




#
# 继承Inheritance
# 由于class属性可以是向量，所以S3中的继承关系自然的表现为class属性的前一个分量是后一个的子集。
# NextMethod()函数可以使一系列的方法可以被依次应用到对象上。

myfn.father=function(x)'father fn.'
myfn.son=function(x){
  print("I am a son fn")
  NextMethod();#保证继续执行下一个类对应的方法
}
t=structure(1,class=c("son","father"))
myfn(t)
##[1] "I am a son fn"
##[1] "father fn."


# 实例2
BG=list(name="BG",salary=20000,union=F,ratio=0.12)
class(BG)=c("investor")
BG #原始打印格式

class(BG)=c("invester","employer")
BG #自定义打印格式
##BG 
##salary: 20000 
##union member: FALSE 


#
# S3类对象的缺点
# S3对象系统与其称作为OOP系统，不如说是一系列命名规则。
# .class属性, generic.class等的命名方式决定了其行为。所以，使用不当时会引发一些问题，
#问题1.比如方法被直接调用，而绕过了泛型函数的检查。
print.bar(1)  #失去了包装的意义。
##This is a bar print: 
##the value is: 1

#问题2. class属性可以被直接修改而不管是否正确。表示对象类型的属性，但不叫class，就不会被class()函数发现。
x=1
attr(x,'my_cool_class')='foo'
x
##[1] 1
##attr(,"my_cool_class")
##[1] "foo
class(x)
##[1] "numeric"

#问题3: class属性多值时，依次检查每个值是否有合适的方法并分派。
#所以，class属性的顺序决定了被分派的方法。
y=2
class(y)=c('foo','bar')
myfn(y)
##[1] "foo"
class(y)=c('foo2','bar')
myfn(y) #[1] "bar"
class(y)=c('matrix','bar')
myfn(y)
## [1] "matrix" #是不是很不可思议？瞒天过海了。


##########
# 有效利用S3类

## todo

# 
# 可以用methods()函数查找S3类和方法。
# 如 methods(generic.function=predict)或methods(class=lm)
methods(generic.function=predict)
methods(class=lm)

methods(generic.function=myfn)
methods(class='employer')

# 显示泛型函数对特定对象方法的实现
# getS3method(f,class)
getS3method("print",'employer')

#对于不可见的函数，可以试试
getAnywhere('print')
getAnywhere('myfn')















############################################
# S4 类 
############################################
# 定义一个S4对象
setClass("Man",slots=list(name="character",age="numeric"))
# 实例化一个Person对象
father<-new("Man",name="Xq",age=44)
# 查看father对象，有两个属性name和age
father



#我们可以使用setClass(Class,slots=c())函数来定义新的S4类。
# 如会议参与者类Person
# representation参数用于定义类的属性(slot)及其类型
Person = setClass(Class = "Person", 
                  slots=c(name = "character",age = "numeric"))

#实例化用ClassName(属性名字和值)
p1=Person(name="Tom",age=25)
p1
##An object of class "Person"
##Slot "name":
##  [1] "Tom"
##
##Slot "age":
##  [1] 25


#从R语言的根本上来看（不涉及任何OOP概念），slots和CLASS一样，都是数据的属性而已，只是换了个名称
str(attributes(p1))
#List of 3
#$ name : chr "Tom"
#$ age  : num 26
#$ class: atomic [1:1] Person
#..- attr(*, "package")= chr ".GlobalEnv"



#修改对象的属性值用@符号
p1@age=26
p1

#且属性名字拼写错误会提示,在S3类中则不会报错，直接添加一个新属性。
p1@ag=30 #‘ag’ is not a slot in class “Person”


#或者简写??失败，不能简写
p2=Person("Jim",20)
#用new也不行
p2=new("Person","jim",20)



#S4对象支持从一个已经实例化的类中创建新对象，创建时可以覆盖旧对象的值。
p1
p2
p2=initialize(p1,name="Tomson")
p2



#
# 继承关系：
# S4比S3更为严格的继承关系，用contains参数表示。
# 比如,新建会议演讲者，比一般参会者多一个演讲标题属性。
Reporter=setClass(Class="Reporter",slots=c(title="character"),
                  contains="Person")

# r1=Reporter(name="Lily",age="28",title="The S4 in R")
#有自动检查每个属性的类型。报错说age应该是数字，不能使字符串。

r1=Reporter(name="Lily",age=28,title="The S4 in R")
r1
##An object of class "Reporter"
##Slot "title":
##[1] "The S4 in R"
##
##Slot "name":
##[1] "Lily"
##
##Slot "age":
##[1] 28

#或者，使用new(ClassName,)也能实例化出对象
r2=new("Reporter",name="Lucy",age=30,title="R and OOP after R3.0")
r2


# 访问对象属性
#在S3中我们通常使用$来访问一个对象的属性。但是S4中使用@。
p1@name
#或者使用slot()来查看
slot(p1,'name')

# 设置属性的默认值
#当我们实例化时不设置某个属性时，其默认值时默认属性类型的默认值。
# numeric属性默认值为numeric(0)。显然我们可以设置的更有意义。
#prototype=list()必须用list，用c()不报错，但是设置默认失败。
Host=setClass(Class="Host",slots=c(duty="character"), contains="Person",
             prototype=list(name=NA_character_, age=18) )
h1=new("Host",duty="guidance") #年龄默认18岁。
h1@age
h1@name

#检验属性的合法性,也可以放到类内部去定义成匿名函数。
# 比如未成年学生不能参加会议
checkAge=function(object){
  if(object@age<18){
    stop("Age is under 18")
  }
  return(TRUE)
}

Student=setClass(Class="Student",slots=c(school="character"), contains="Person",
            validity = checkAge,  prototype=list(name=NA_character_, age=18) )
s1=new("Student",name="George",age=17)
## Error in validityMethod(object) : Age is under 18
s1=new("Student",name="George",age=19)
s1


#第二种设定检查方式，更灵活，不在类中定义。通过匿名函数实现。
Student2=setClass(Class="Student2",
                  slots=list(name="character",
                             age="numeric",
                             school="character"), 
                  prototype=list(name=NA_character_, 
                                 age=18,
                                 school=NA_character_))

setValidity("Student2",function(object){
  if(object@age<18){
    stop("Age 不能低于18")
  }
})
new("Student2",age=17)
new("Student2",age=170)



#查看类信息/获取S4泛型函数
showClass('Person') #显示slots和已知子类。
showClass('Student')  #还显示父类名字
getClass("Person") #结果和上面一样。









################# 
#todo 不懂啥意思？？差不多懂了
# 接口和函数是分开的，先通过setGeneric设定函数接口，再通过setMethod设定泛化函数。

#1.定义接口：普通准备
# 使用setGeneric()函数定义泛型函数（相当于接口，没有实现或部分实现）。
#该函数的第二个参数是一个定义了所有需要参数的函数，且内部必须调用standardGeneric()函数。
setGeneric('prepare', function(obj){ 
  standardGeneric('prepare') #这一句必须。
  #剩下的句子可以省略
  #cat("[optional line]This is a Generic function named prepare. age:",obj@age)
})

#2. 定义默认方法（对父类添加方法，当子类没有定义时，调用这个父类的方法）
#使用setMethod()定义方法，使用signature()定义其所面向的类型。
# 输入：第一个参数是generic function name，
setMethod('prepare',signature("Person"),function(obj){#传递的参数名要和generic定义的一模一样。
  cat("[Person] Got obj:",obj@name,"\n")
})

#用Person的子类调用时，也能正确显示。
prepare(new("Student",name="Smith"))
##Got obj: Smith 
##I am a function named prepare, age: 18




#
#定义一个（内置函数的）泛型方法
setMethod('plot',signature("Person","missing"),function(x){
  #plot(x@age)
  print('A plot for Person. We do not plot now:')
  print(x)
})

plot(new("Person",age=100))
plot(new("Student",age=20)) #子类也能用，起到泛型的效果。





# 如何对S4的属性名进行遍历?
class(p1)
class(p1)[1]
tmp1=getClass(class(p1)[1])

attributes(tmp1)
str(tmp1)



#
# [难度：***] 
# 1.功能： 输入对象，输出其属性列表

#其实，用slotNames就可以实现该功能。
# https://adv-r.hadley.nz/s4.html
slotNames(p1)

#我自己的实现slotnames()函数功能
getAttributesByObj=function(o){
  if(mode(o)=="S4"){
    #输入是一个S4对象
    myclassname=class(o)[1]
  }else{
    stop("Input is not a S4 object.")
  }
  tmp=getClass(myclassname)@slots
  
  mylen=length(tmp)
  mylist=c()
  for(i in 1:mylen){
    mylist=c(mylist,names(tmp[i]))
  }
  mylist
}
print(getAttributesByObj(s1))
print(getAttributesByObj(r1))
print(getAttributesByObj('Person')) #参数不是S4报错

# 2.为Person类定制化print方法
print(s1) #打印方法不好看，重新定义打印方法
setMethod('print',signature("Person"),function(x,...){
  # 容易报错：传递的参数名要和generic定义的一模一样。getGeneric(print)查找定义的参数名
  #use getGeneric("rbind") and showMethods("rbind") after your setGeneric;
  # http://r.789695.n4.nabble.com/S4-methods-for-rbind-td3013477.html
  .list=getAttributesByObj(x)
  
  for(i in .list){
    cat(i,":", slot(x,i), "\n",sep="")
  }
})
print(s1)
print(r1)
showMethods(print)


# 3. 为自己的Person类做一个save方法。保存数据到（文本/二进制）文件。当然还要配套读取文件的方法。
# todo http://r.789695.n4.nabble.com/save-method-for-S4-class-td4671826.html

















#
# 继承
#2.2 使用 callNextMethod()来为拥有继承关系的对象寻找合适的方法
setMethod("prepare",signature("Reporter"),function(obj){
  callNextMethod() #只能出现在方法定义中。在当前方法结束后调用父类方法。
  cat("[Reporter]Slides are ready. \n")
})

prepare(new("Reporter",name="Bush"))


#
# 实例2：定义一个计算出生天数功能
# 定义接口：
setGeneric("daysAfterBirth",
           function(object){
             standardGeneric("daysAfterBirth")
           })
# 为Person类具体化该方法：
setMethod("daysAfterBirth","Person",
          function(object){
            return(object@age*365)
          })
# 在Person子类上调用该方法
daysAfterBirth(new("Reporter",age=10))
## [1] 3650





#
# 查看S4对象的类型
is(p1) #查看对象类型
class(p1) #查看对象类型

# 查看S4类定义的属性
getSlots('Person')
getSlots("Student")

# showMethods()查看泛型函数已经定义的方法
showMethods("plot")
showMethods("prepare")

# 查看Reporter对象的prepare函数现实
getMethod("prepare","Reporter")
selectMethod("prepare","Reporter")

# 检查Person对象有没有prepare函数
existsMethod("prepare","Person")
hasMethod("prepare","Person")















#
#######################
# S3和S4的比较
#######################
#1.在定义S3类的时候，没有显式的定义过程，而定义S4类的时候需要调用函数setClass；
#2.在初始化S3对象的时候，只是建立了一个list，然后设置其class属性，而初始化S4对象时需要使用函数new；
#3.提取变量的符号不同，S3为$，而S4为@；
#4.在应用泛型函数时，S3需要定义f.classname，而S4需要使用setMethod函数；
#5.在声明泛型函数时，S3使用UseMethod()， 而S4使用setGeneric()。

#
# S4和S3一样是R语言中基于泛型函数的面向函数编程方式。其他的R语言中还有RC、R6的面向对象的编程方法。
# 一个经典S4的游戏例子：http://blog.csdn.net/qq_27755195/article/details/54836509
# S4的几何形状面积计算的例子：https://www.cnblogs.com/awishfullyway/p/6485240.html

# Bioconductor和Matrix包都基于S4对象且遵循良好的编程方式，可以作为进一步研究的材料。











##########################
# RC和R6是R OOP的未来
##########################
# R6是一个包（http://blog.fens.me/r-class-r6/）。
# https://adv-r.hadley.nz/r6.html 权威作者推荐使用R6.
#
# Reference Class也叫RC或者R5，是2.12版本后新出现的对象系统，是R语言最新一代的面向对象系统。
#RC不同于原来的S3和S4对象系统，RC对象系统的方法是在类中自定的，而不是泛型函数。
#RC是完全用R实现的，行为更类似于其他的编程语言（Java和C#），实例化对象的语法也有所改变。
#但由于RC对象系统还是依赖于S4对象系统，我们可以简单地理解为RC是对S4的更进一步的面向对象封装。
?ReferenceClasses

# 和基于函数的S4、S3使用泛型函数不同。R5方法被包含到类定义内部。
# 第三方包提供的对象系统：R.oo, proto和mutatr

# 1.定义
Account <- setRefClass("Account") #在S4中使用setClass()
Account$new()
##Reference class object of class "Account"

#2.设置属性,修改属性(定义：RC用fields，而S4用slots。使用：RC用$,而S4用@)
Account <- setRefClass("Account",
                       fields = list(balance = "numeric"))

a <- Account$new(balance = 100)
a$balance
mode(a)
##[1] "S4"

a$balance <- 200
a$balance

# 2.1.注意对象复制是引用的
b=a
b$balance
## 200

b$balance=0
a$balance
## 0

# 2.2 如果想复制一个与原来对象无关的心对象，使用copy()方法
c=a$copy()
c$balance
##0
a$balance=30
c$balance
##0


# 3. 添加方法（RC用methods-包含到类定义内部，S4用泛型函数-在类定义外部）
Account <- setRefClass("Account",
   fields = list(balance = "numeric"),
   methods = list(
     withdraw = function(x) {
       balance <<- balance - x #<<-和<-作用一样，都是=的作用。=不是更输入更快吗？
     },
     deposit = function(x) {
       balance <<- balance + x
     }
   )
)

a <- Account$new(balance = 100)
a$deposit(100)
a$balance
##[1] 200


# 4.继承 （使用contains参数）
#定义一个不能透支的账号
NoOverdraft <- setRefClass("NoOverdraft",
   contains = "Account",
   fields = list(validity="character"),
   methods = list(
     withdraw = function(x) {
       if (balance < x) stop("Not enough money")
       balance <<- balance - x
     }
   )
)
accountJohn <- NoOverdraft$new(balance = 100,validity="2020-10-01")
accountJohn$deposit(50)
accountJohn$balance
##[1] 150
accountJohn$withdraw(151)
## Error in accountJohn$withdraw(151) : Not enough money

#所有RC类都继承自envRefClass，后者提供很有用的方法：
# copy() ,上面提到过。
#callSuper() (to call the parent field), 调用父类域
#field() (to get the value of a field given its name), 获取给定域的值 
#export() (equivalent to as()), 等同于as()
#and show() (overridden to control printing). 重写控制打印效果 
# 更多细节看帮助 
?setRefClass



#
# RC 实例：完整的动物模型
#http://blog.csdn.net/sanqima/article/details/50407705
#http://blog.fens.me/r-class-rc/
# 定义一个Animal类，Cat、Dog、Duck继承于Animal，
#Animal有2个属性：name、limbs，
#2个方法：bark()、action()

##定义Animal类，
Animal <- setRefClass("Animal",
  fields = list(name="character",limbs='numeric'),
  methods = list(
    initialize = function(name){ #初始值
      name <<- 'Animal'
      limbs <<- 4
    },
    bark = function() print("Animal::bark"),
    action = function() print("I can walk on the foot")
  )
)

##定义Cat类，继承Animal
Cat <- setRefClass("Cat",contains = "Animal",
   methods = list(
     initialize = function(name){
       callSuper() #调用父类方法
       name <<- 'cat'
     },
     ##重写父类方法
     bark = function() print(paste(name,"is miao miao")),
     action = function(){
       callSuper()
       print("I can Climb a tree")
     }
     
   )
)

##定义Dog类，继承Animal
Dog <- setRefClass("Dog",contains = "Animal",
   methods = list(
     initialize = function(name){
       callSuper()
       name <<- 'dog'
     },
     ##重写父类方法
     bark = function() print(paste(name,"is wang wang")),
     action = function(){
       callSuper()
       print("I can Swim")
     }
     
   )
)


##定义Duck类
Duck <- setRefClass("Duck",contains = "Animal",
    fields = list(wing='numeric'),
    methods = list(
      initialize = function(name){
        name <<- 'duck'
        limbs <<- 2
        wing <<- 2
      },
      ##重写父类方法
      bark = function() print(paste(name,"is ga ga")),
      action = function(){
        callSuper()
        print("I can swim.")
        print("I also can fly a short way.")
      }
    )
)


##实例化cat
cat <- Cat$new()
cat$action()

##实例化dog
dog <- Dog$new()
dog$action()

##实例化duck
duck <- Duck$new()
duck$action()









##########################
# R6
##########################
# R6 is much simpler. Both R6 and RC are built on top of environments, but while R6 uses S3, RC uses S4. 
# R6 is only ~500 lines of R code (and ~1700 lines of tests!). 
library(R6)
browseVignettes(package = "R6")



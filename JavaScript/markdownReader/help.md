# Contents

Rendered by **markedJS**.

You can write a file in markdown, and render it with this app locally.

Below is a simple guide for how to write .md or .markdown file.

## How to use this Markdown Reader?

- Put a .md file under the root directory of this system, which is specified on top of this page;
- Use http://ip:80/?file=xx.md to overview the rendered markdown file.
- default, http://ip:80/ is the same as http://ip/index.html?file=help.md 
- After updating the .md file, please use shift+F5 to reload the .md file on your browser side.


## Chapter 1 list1

- 分类1
- [分类2](?file=aa2.md)
- 分类3
- 分类4


## Chapter 2 list2

some description here.

### level 3 headers
#### level 4 headers
##### level 5 headers
###### level 6 headers

1. item1
2. item2
2. item2


## Chapter 3 Code

```
dim(mtcars)
mtcars[1:4,1:4]
```


## Chapter 4 links and Pictures

### 链接
```
[必应](http://cn.bing.com)
```
这是一个链接: 点击打开[必应](http://cn.bing.com)。


### 图片
```
![二维码](../images/erweima.png)
```

![二维码](../images/erweima.png)


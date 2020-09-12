# aim: 单文件简易单markdown阅读器，基于mistunes

# 使用方法: 
# 1. 指定index()函数内第一个参数filePath 为markdown文件的绝对地址
# 2. 然后运行该脚本 python markdownReader.py，命令行就会出现可访问的地址
# 3. 在浏览器中打开即可查看 http://127.0.0.1:8008/

# v0.2 基本可用
# v0.3 顶部使用js添加目录


#########
# 1. 设置md文件的绝对路径
# 如果是windows系统，则需要使用把路径使用双斜线分割，比如 "G:\\English\\wordStudy.md"
#filePath="G:\\xampp\\htdocs\\txtBlog\\data\\English\\wordStudy.md"
filePath="G:\\ML_MachineLearning\\ReadMe.md"



from flask import Flask
import mistune

app = Flask(__name__)

@app.route('/') #2个参数时
def index():
	md="No file"
	if filePath!='':
		# 2. 获取文件内容
		fr=open(filePath, 'r', encoding='utf8')
		text=fr.read()
		fr.close()
		#
		# 3. markdown to html
		md=mistune.markdown(text, escape=False, hard_wrap=True) #'I am using **mistune markdown parser**'
	md="<div class=markdown>\n"+md+"</div>\n"
	# 4. add css: 
	css='<link rel="stylesheet" type="text/css" href="http://blog.dawneve.cc/public/css/MarkDown3.css">'
	css2 = '''
<style>
body,h1{ margin:0; padding:0;}
h1.title{background:white; color:#ddd; font-size:15px;margin-bottom:10px; text-align: center;}
h1.title p{color:#ff9600; background:#FFECD0; margin:0 auto; width:250px; 
	border-bottom-left-radius:5px;
	border-bottom-right-radius:5px;
}
.content,
.markdown{ width:80%; margin:10px auto; padding:10px 20px; border-radius:20px; background:#fff;}
body{background:#eee;}
.footer{ width:100%; height:20px; background:black; color:white; text-align:center;
	padding:20px 0; margin-top:10px; overflow:hidden;}
.footer a{color:#ff9600;}

.content {
    font-size: 14px;
    color: #333;
    line-height: 1.75;

    font-family: "MicroSoft YaHei","Courier New","Andale Mono",monospace;
}
.content a .text_menu {
    color: #eee;
}
.content a .text_menu span {
    color: #009a61 /*#009a61 DB784D */;
}
.content a {
    color: #0593d3;
    text-decoration: none;
}
/* 段落前空几格 */
.indent_1{text-indent: 0em;}
.indent_2{text-indent: 2em;}
.indent_3{text-indent: 4em;}
.indent_4{text-indent: 6em;}
.indent_5{text-indent: 8em;}
.indent_6{text-indent: 10em;}

</style>
'''
	footer='''
<div class=footer> End of this file | 
	<a target="_blank" href="https://github.com/DawnEve/bioToolKit">Repo</a>
</div>
'''
	js='''
<script>
//通过id获取dom
function $(o){
	if(typeof o=="object") return o;
	return document.getElementById(o);
}


//给obj增加事件的自定义函数：兼容IE/chrome/ff
function addEvent(obj,ev,fn){
	if(obj.addEventListener){
		//ff:addEventListener
		obj.addEventListener(ev,fn,false);
	}else{
		//IE:attachEvent
		obj.attachEvent('on'+ev,fn);
	}
}


/** 返回创建的dom元素
* 只有第一个参数是必须的。
* 其余2个参数可选。
*/
function createElement(tag, json, innerHTML){
	var json=json||{};
	var dom=document.createElement(tag);
	
	if(json!=undefined){
		for(var key in json){
			dom.setAttribute(key,json[key]);
		}
	}
	
	if(innerHTML!=undefined){
		dom.innerHTML=innerHTML;
	}
	return dom;
}


/* 使用的异步，使url中的锚点能在页面中(使用带name的a空标签)正确定位，而不是向下偏移。
* 测试：刷新和输入url都能准确定位，上面有js生成的长度不定的dom，依旧能准确定位。
* version 0.2 抽象成函数，在onload中调用; 要在js生成dom后调用;
*/
function locateURLAnchor(){
	var url = window.location.toString();//获取url
    var id = url.split("#")[1];//获取url#后的部分
	//如果链接含有锚点，则定位；否则啥也不做；
    if(id){
		//定位锚点所在的a标签，遍历获得该dom对象
        var aA=document.querySelectorAll("a[name]");
		for(var i=0;i<aA.length;i++){
			if(id==aA[i].name)
				break;
		}
		//console.log("id=",id,"; i=",i)
		if(i<aA.length){
			//aA[i].scrollIntoView(true)//放这里就不行
			//console.log("01 before setTimeout i=",i, aA[i].offsetTop)
			setTimeout(function(){
				//console.log("02 after setTimeout offsetTop", aA[i].offsetTop)
				//异步的代码总是最后才执行
				wjl=aA[i]
				//aA[i].scrollIntoView(true)//放这里就好使，可能会闪一下
				window.scroll(0, aA[i].offsetTop);//换更兼容的方法
			}, 0)
		}
    }
}

//======================
/**
* name: 为顶部生成目录
* version: 0.1
* version: 0.2 修正点击锚点错位一行的问题
* version: 0.3 修正目录计数，都从1开始；准确定位URL中锚点位置；
*
*/
function addContents(){
	var oMd=document.getElementsByClassName("markdown")[0],
		aH=oMd.querySelectorAll("h1,h2,h3,h4,h5,h6"),
		oUl=createElement('ol');

	//创建content
	oContent=createElement('div',{'class':"content"},"")
	oMd.parentElement.insertBefore(oContent, oMd) //加入文档流

	//1. add "目录"
	oContent.append(createElement('h2',{},'Contents' ))
		
	for(var i=0;i<aH.length;i++){
		var j=i+1;
		var oH=aH[i],
			text=oH.innerText,  //"5.启动nginx"
			tagName=oH.tagName;  //"H3"
		var indentNum='indent_'+ tagName.replace("H",''); //标题缩进行数
		
		if(text.trim()!=""){
			// if h tag is empty, do nothing
			//1. add anchor
			//console.log(i,tagName, text,  aH[i])
			//oH.parentNode.insertBefore( createElement('p',{}, ''), oH);//占位置
			oH.parentNode.insertBefore( createElement('a',{'name':j,
				'my-data':'anchor',
				'style':"margin-top:-1px; padding-top:1px; border:1px solid rgba(0,0,0,0.0);"
			},), oH ); //h前添加锚点,无显示
			
			//2. show in the contents
			var innerSpan = createElement('span',{},text );
			var innerLi = createElement('li',{'class':'text_menu '+indentNum} );
			// 添加点击锚点
			var innerA = createElement('a',{'href':'#'+j, 'title':tagName+": "+text}); //鼠标悬停提示文字
			// 装载锚点 
			innerLi.appendChild(innerSpan);
			innerA.appendChild(innerLi);
			oUl.appendChild( innerA );
		}
	}
	//2. add contents
	oContent.append( oUl); //加入文档流
	
	//3.加入左下角菜单中
	//$("f_content").getElementsByTagName("div")[0].append( oUl.cloneNode(true) );
	// 复制节点 https://blog.csdn.net/LLL_liuhui/article/details/79978487
	
	//3. add "正文"
	//oContent.append( createElement('h2',{},'正文' )); //加入文档流
}

// 挂载函数到load事件
addEvent(window, 'load', function(){
	addContents();
	locateURLAnchor();//定位URL中的锚点
});



</script>
'''
	return '<body><title>Markdown Viewer(simple) v0.2</title>'+\
		css+css2+'<h1 class=title><p>Markdown Viewer(simple)</p> file path: '+filePath+'</h1>'+\
		md+	footer+"</body>"+js
#

# run the app
if __name__ == '__main__':
	app.debug = True # 设置调试模式，生产模式的时候要关掉debug
	#app.run(host="127.0.0.1",port=8000) #default, private
	app.run(host="0.0.0.0",port=8008) #public
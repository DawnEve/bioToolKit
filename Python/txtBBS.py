import time,os,re
from flask import Flask, redirect, request, url_for

app = Flask(__name__)

######################
# aim: txtBBS.py, is a very simple BBS board based on a txt file and python3 flask;
# version: 0.0.1
# version: 0.0.2 美化界面
# version: 0.0.3 添加外部ip地址
######################

jsCode="""
<script>
function ajax(options){
    //创建一个ajax对象
    var xhr = new XMLHttpRequest() || new ActiveXObject("Microsoft,XMLHTTP");
    //数据的处理 {a:1,b:2} a=1&b=2;
    var str = "";
    for(var key in options.data){
        str+="&"+key+"="+options.data[key];
    }
    str = str.slice(1)
    if(options.method == "get"){
        var url = options.url+"?"+str;
        xhr.open("get",url);
        xhr.send();
    }else if(options.method == "post"){
        xhr.open("post",options.url);
        xhr.setRequestHeader("content-type","application/x-www-form-urlencoded");
        xhr.send(str)
    }
    //监听
    xhr.onreadystatechange = function(){
        //当请求成功的时候
        if(xhr.readyState == 4 && xhr.status == 200){
            var text = xhr.responseText;
			if(options.type=="json"){
				text=JSON.parse(text);
			}
            //将请求的数据传递给成功回调函数
            options.success&&options.success(text)
        }else if(xhr.status != 200){
            //当失败的时候将服务器的状态传递给失败的回调函数
            options.error&&options.error(xhr.status);
        }
    }
}


ajax({
    method:"get",
    url:"https://api.ipify.org/?format=json",
    data:{},
    success:function(text){
        //console.log(text)
        document.getElementById('ip').value=text
    },
	error: function(num){
		//
	},
	type: "text"
})

</script>
"""



html1 = '''
<html>
<head>
    <title>txtBBS.py - message board</title>
<style>
/*CSS*/
body{background:#eee;}
html,body,h1{margin:0; padding:0;}
.wrap{background:white; width:80%; min-width:300px; margin:10px auto; padding:10px 20px;}
.footer{background:black;}
.footer p{width:600px; margin:0 auto; padding:5px; color:#AAA;}
.footer a.highlight{color:#E44D26;}
.footer a{color:white;}
.footer a:hover{color:white;}
.tips{background:#FFE9DE; color:#F68041; border-radius:8px;}
h1{background:white;   padding-left:10px; border-left:5px solid #E44D26;}
h2{background:#EFEFEF; border-left:5px solid #E44D26; padding-left:10px;}
.small{font-size:x-small; color:#ccc;}

textarea{width:90%; height:200px; padding:5px;}
pre{word-wrap: break-word!important; white-space: pre-wrap;}
</style>

</head>
<body>
    <h1>txtBBS.py <span class=small>
v0.0.3
    </span></h1>
    <p class='wrap tips'>Tips: Simple message board based on a txt file, powered by Python3 flask.</p>
    <div class=wrap>
<pre>
'''

html2='''
</pre>
    <form action="/" method="post">
        <h2>Leave a message: </h2>
        <textarea type="text" name="message"></textarea> <br><br>
        <input type="hidden" name="ip" id="ip" value="192.168.0.110"/>
        <input type="submit" value="Submit">
    </form>
    </div>
    <div class=footer><p> &copy; 2020 <a href="http://www.biomooc.com">Biomooc.com</a> | 
        <a class=highlight href="https://github.com/DawnEve/bioToolKit">Github</a> | 
        File path: {FilePath}</p></div>
</body>
</html>
'''


@app.route('/', methods=['GET', 'POST'])
def hello_world():
    path='dustbin';
    fileName=path+'/message.txt'
    # if dir exists?
    if not os.path.exists(path):
        os.makedirs(path)
    # if file exists?
    if not os.path.exists(fileName):
        fw=open(fileName, 'w')
        fw.close()
    if request.method == 'POST':
        # get info
        message = request.form['message']
        if message=="":
            return redirect(url_for('hello_world'))
        
        ip = request.form['ip']
        postTime=time.strftime("%Y-%m-%d %H:%M:%S", time.localtime())
        ip2 = request.remote_addr
        
        
        # write to file
        with open(fileName, 'a') as f:
            # html标签替换
            message=re.sub('>', "&gt;", message)
            message=re.sub('<', "&lt;", message)
            message=re.sub('\r', "", message)
            f.write(message + "\n===postTime: "+postTime+  ' \t IP:' +ip+ '\n' + "=*"*20 +'\n')
        # redirect to get 
        return redirect(url_for('hello_world'))

    # read file
    fr=open(fileName, 'r')
    message=""
    for lineR in fr.readlines():
        line=lineR.strip()
        if line=="=*"*20:
            lineR="<hr> \n" #分割线
        if line.startswith('===postTime:'):
            lineR="<span class=small>"+lineR[3:]+"</span>"; #发帖时间
        message += lineR;
    fr.close()
    #
    # inject {FilePath} to html2 
    html2_=re.sub("\{FilePath\}", os.getcwd(), html2)
    return html1+message+html2_+jsCode
#



# test use only
@app.route('/index')
def index():
    return 'Index Page'


@app.route('/hello')
def hello_world2():
    return 'Hello World!'

if __name__ == '__main__':
    #app.run(debug = True)
    app.run(host="0.0.0.0",port=5000, debug=True) #public

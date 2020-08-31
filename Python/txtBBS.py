import time,os,re
from flask import Flask, redirect, request, url_for

app = Flask(__name__)

######################
# aim: txtBBS.py, is a very simple BBS board based on a txt file and python3 flask;
# version: 0.0.1
# version: 0.0.2 美化界面
######################


html1 = '''
<html>
<head>
    <title>message board</title>
<style>
/*CSS*/
body{background:#eee;}
html,body,h1{margin:0; padding:0;}
.wrap{background:white; width:800px; margin:10px auto; padding:10px 20px;}
.footer{background:black;}
.footer p{width:600px; margin:0 auto; padding:5px; color:#AAA;}
.footer a.highlight{color:#E44D26;}
.footer a{color:white;}
.footer a:hover{color:white;}
.tips{background:#FFE1D1; color:#F68041; padding:5px;}
h1{background:white;   padding-left:10px; border-left:5px solid #E44D26;}
h2{background:#EFEFEF; border-left:5px solid #E44D26; padding-left:10px;}
.small{font-size:x-small; color:#ccc;}

textarea{width:500px; height:200px;}
</style>

</head>
<body>
    <h1>txtBBS.py <span class=small>v0.0.1</span></h1>
    <div class=wrap>
    <p class=tips>Tips: Simple message board based on a txt file, powered by Python3 flask.</p>

<pre>
'''

html2=''' 
</pre>
    <form action="/" method="post">
        <h2>Leave a message: </h2>
        <textarea type="text" name="message"></textarea> <br><br>
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
        postTime=time.strftime("%Y-%m-%d %H:%M:%S", time.localtime())
        ip = request.remote_addr
        
        
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
    return html1+message+html2_
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
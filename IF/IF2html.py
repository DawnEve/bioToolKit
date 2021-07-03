# Aim: 根据IF 生成 html 格式
# v0.1 can use now.

import re, os

# 预处理
# excel 保存为 tab分割的txt
# 去掉首尾，只留表格部分作为输入 IF_2020.txt。


output="G:/xampp/htdocs/163/"

fr=open( os.path.join(output, "IF_2020.txt") )
fw=open( os.path.join(output, "IF_2020.html"), 'w')


fw.write("""<title>IF of 2020</title>
<style>
body, div, table, tr, td,th{margin:0;padding:0;}
.wrapper{width:1360px; margin:0 auto;}

.light{color:#aaa;}
table { border-collapse:collapse; margin-top:30px; font-size:12px;}
th{background:black;color:white; height:30px;}
th,td{width:150px; text-align:center;}
tr:hover{background:#eee; color:red;}
.abs{position:fixed; top:0px;}
</style>
<div class=wrapper>
<table border='1'>
	"""+"\n")
i=0
for lineR in fr.readlines():
	i+=1
	line=lineR.strip()
	arr=line.split("\t")
	if i>5:
		#break;
		pass
	if i==1:
		str1="<tr class=abs><th>" + "</th><th>".join(arr) +"</th></tr>\n"
	else:
		arr[3]=re.sub('"','',arr[3])
		arr[4]=re.sub('"','',arr[4])
		str1="<tr><td>" + "</td><td>".join(arr) +"</td></tr>"
	

	
	#print(i, len(arr), str1)
	fw.write(str1+"\n")

fw.write("</table>\n <br><span class=light>The end; Update on 2021.7.3</span> </div>"+"\n")
fr.close()
fw.close()
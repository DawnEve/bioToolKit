# Aim: 根据IF 生成 html 格式
# v0.1 can use now.
# v0.2 for 2019

import re, os
# 预处理
# excel 保存为 tab分割的txt
# 去掉首尾，只留表格部分作为输入 IF_2020.txt。

# settings
output='./' #"G:/xampp/htdocs/bioToolKit/IF/"
year="2020"

# begein
fr=open( os.path.join(output, "IF_"+year+".txt") )
fw=open( os.path.join(output, "IF_"+year+".html"), 'w')
#
fw.write("""<title>IF %s</title>
<style>
body, div, table, tr, td,th{margin:0;padding:0;}
.wrapper{margin:0 auto; font-size:12px;}

.wrapper, table tr{width:1360px;}

.light{color:#aaa;}
table { border-collapse:collapse; margin-top:30px;}
th{background:black;color:white; height:30px; font-size:7px;}
th,td{max-width:500px; min-width:100px; text-align:center; padding:0 10px;}
tr:hover{background:#eee; color:red;}
.fixed{position:fixed; top:0px;}
</style>
<div class=wrapper>
<table border='1'>\n
	""" % year)
i=0
for lineR in fr.readlines():
	i+=1
	line=lineR.strip()
	arr=line.split("\t")
	for j in range(len(arr)-1,0,-1):
		if arr[j]=="":
			arr.pop(j)

	# only keep 7k rows.
	if i>5000:
		break;
		#pass
	# only keep 7 columns
	arr=arr[0:5]

	if i==1:
		str1="<tr class=fixed><th>" + "</th><th>".join(arr) +"</th></tr>\n"
	else:
		arr[2]=re.sub('"','',arr[2])
		arr[3]=re.sub('"','',arr[3])
		arr[4]=re.sub('"','',arr[4])
		str1="<tr><td>" + "</td><td>".join(arr) +"</td></tr>"
	fw.write(str1+"\n")

fw.write("</table>\n <br><span class=light>The end; Update on 2021.7.3</span> </div>"+"\n")
fr.close()
fw.close()
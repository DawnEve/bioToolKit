csvtxt = '''\
序号,姓名,工号,职称,移动电话,邮箱
1,张三,001,副教授,137xxx,xx@xx.edu.cn
2,李四,002,博后,135xxx,xx@xx.edu.cn
'''

from cgi import escape
 
def _row2tr(row, attr=None):
    cols = escape(row).split(',')
    return ('<TR>'
            + ''.join('<TD>%s</TD>' % data for data in cols)
            + '</TR>')
 
def csv2html(txt):
    pre='<meta http-equiv=Content-Type content="text/html;charset=utf-8">\n<style>table { border-collapse:collapse; } </style>\n'
    htmltxt = pre+'<TABLE summary="csv2html program output" border="1">\n'
    for rownum, row in enumerate(txt.split('\n')):
        htmlrow = _row2tr(row)
        #htmlrow = '  <TBODY>%s</TBODY>\n' % htmlrow
        htmltxt += htmlrow
    htmltxt += '</TABLE>\n'
    return htmltxt
 
htmltxt = csv2html(csvtxt)
print(htmltxt)
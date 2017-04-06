$str="this is a cat";
#$str="this is a cat\n";
#$str="this is a cat\n\n";

$str2=chop($str);#去掉最后一个字符
#$str2=chomp($str); #去掉最后一个换行字符\n。成功返回1，失败返回0

print("1:",$str,"\n"); #this is a ca
print("2:",$str2); #t
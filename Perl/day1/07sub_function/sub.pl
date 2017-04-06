#子程序

$c=add(2,3);
print(add($c,100));

#函数可以先定义再使用
sub add{
	my($a,$b)=@_; # 接收2个参数
	return($a+$b); #返回结果
}

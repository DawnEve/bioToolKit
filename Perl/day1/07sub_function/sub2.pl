#子程序

#普通传递参数
$c=add(2,3,4);
print($c);

#可以传递很多参数
sub add{
	my $i; #加my是局部变量
	for($i=0; $i<=$#_;$i++){
		print($_[$i],"\n");
	}
}

print("\$i的值是：",$i);

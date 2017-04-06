#定义一个hash数组
%fruit=("apples"=>17,"bananas"=>9,"oranges"=>"none");
#添加一个元素。注意用$开头！
$fruit{"nut"}=5;

#遍历该hash数组
foreach $keys (keys(%fruit)){
	$price = $fruit{$keys};
	print $keys,":",$price. "\n";
}

#输出
print "\n\n";
print %fruit{"apples"},"\n"; #输出key,value数组
print $fruit{"apples"},"\n"; #输出value

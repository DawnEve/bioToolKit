%fruit=("apples"=>"17","bananas"=>"9","oranges"=>"none");#生成一个哈希
print $fruit{"bananas"},"\n\n";
$fruit{"watermelon"}="15";#给关联数组添加新的元素
foreach $record (keys(%fruit)){ 
	$price = $fruit{$record};
	print $record,"价格：",$price,"\n";
} 

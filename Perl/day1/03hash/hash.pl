%fruit=("apples"=>"17","bananas"=>"9","oranges"=>"none");#����һ����ϣ
print $fruit{"bananas"},"\n\n";
$fruit{"watermelon"}="15";#��������������µ�Ԫ��
foreach $record (keys(%fruit)){ 
	$price = $fruit{$record};
	print $record,"�۸�",$price,"\n";
} 

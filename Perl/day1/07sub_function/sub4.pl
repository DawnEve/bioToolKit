#分割一行中的每个字符。
$line="this is a cat";

my @charArr=split("",$line);
foreach my $char (@charArr){
	print $char."\n";
}

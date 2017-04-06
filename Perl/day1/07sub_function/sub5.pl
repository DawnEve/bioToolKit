my @arr=(0..9);
my @oneCharArr=('a'..'z');
my @twoCharArr=('aa'..'zz');

print2(@arr."\n");
print2(@oneCharArr."\n");
print2(@twoCharArr."\n");

sub print2{
	print(@_[0]);
	
	for(my $i=0;$i<$#_;$i++){
		print(@_[$i], ', ');
	}
	print("\n");
}

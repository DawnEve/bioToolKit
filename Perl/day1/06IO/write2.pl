open(FILE1,">>test.txt") or die $!;
print FILE1 "3TEST TEST2\n";
print FILE1 "3line2 123";
close FILE1;
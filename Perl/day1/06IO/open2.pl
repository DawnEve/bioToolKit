#file read
#open(FILE1, "D:/R_code/bioToolKit/Perl/test.txt") or die $!;
open(FILE1, "test.txt") or die $!;
while($line=<FILE1>){
	print $line;
}
close FILE1;
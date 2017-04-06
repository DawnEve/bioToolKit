$string = "0abc1";
$string =~ s/[a-zA-Z]+/$& x 2/e;  #匹配字符，并加倍
# now $string = "0abcabc1“
print $string."\n";

$string = "0abc1";
$string =~ s/[0-9]+/$& x 2/ge;  #匹配数字，并加倍
print $string."\n"; #00abc11

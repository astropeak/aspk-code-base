# Print all file names in a dir and the file total size in that dir
# How to run this if parent dir of Aspk not in search path?
# cd to the parent dir, then 'perl Aspk/dir_example.pl DIR'

use Aspk::dir qw(dirWalk);

sub printName{
	my ($f)=@_;
    print "  $f\n";
	my $s=-s $f;
	if ($s > 1000000) {
		print "Large file. $f, size:$s\n";
	}
	return $s;
}

sub printDir{
	my ($d,@rst)=@_;
	my $c= -s $d;
    my $n=0;
	my $largest = 0;
	foreach my $v (@rst){
        ++$n;
		$c+=$v;
		$largest=$v if $v>$largest;
	}

	#print "Empty dir: $d\n" if ($c == 0) ;
	$emptyDirCount++ if ($c==0);
	print "dir: $d, file count: $n, file total size: $c\n";

	if ($c>1000000 && $largest<=1000000){
		print "Large dir. $d, size:$c\n";
	}
	return $c;
}

if ($ARGV[0]) {
    dirWalk($ARGV[0],\&printName,\&printDir);
    print "empty dir count: $emptyDirCount\n";
} else {
    print "Print all file names in a dir.\nUsage: perl dir_example.pl DIR\n";
}

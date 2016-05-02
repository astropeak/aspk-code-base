package Aspk::dir;
use Exporter;

@ISA=qw(Exporter);
@EXPORT_OK=qw(dirWalk);

sub dirWalk{
	my ($top,$filefunc,$dirfunc)=@_;
	my $dir;
	if (-d $top){
		unless (opendir $dir, $top){
			print "Can't open directory $dir, skipping\n";
			return;
		}
		my @result;
		while (my $f=readdir($dir)) {
			next if $f eq "." || $f eq "..";
			push @result, dirWalk($top."/".$f,$filefunc,$dirfunc);
		}
		closedir $dir;
		return $dirfunc->($top,@result);
	} else {
		return $filefunc->($top);
	}
}

1;
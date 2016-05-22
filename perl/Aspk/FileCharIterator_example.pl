use Aspk::FileCharIterator;
use Aspk::Debug;


$file='Debug.pm';
open my $fh, "<", $file or die "can't open file $file";

my $fciter=Aspk::FileCharIterator->new('Debug.pm');

print $fciter->get('package.*')."\n";
while(++$i < 20) {
    print $fciter->get()."\n";
}



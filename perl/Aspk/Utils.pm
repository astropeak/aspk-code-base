package Aspk::Utils;
use Exporter;

@ISA=qw(Exporter);
@EXPORT_OK=qw(reduce);

sub reduce {
    my $r;
    foreach (@_){
        $r+=$_;
    }
    return $r;
}


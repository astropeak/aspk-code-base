package Aspk::Debug;
use Exporter;

use Scalar::Util qw(reftype);

@ISA=qw(Exporter);
@EXPORT_OK=qw(print_obj);

# first parameter is a references to a hash
# TODO should be renamed to print_obj
my $objs = {};
sub print_obj {
	my $h = $_[0];
	my $header = $_[1];
	unless ($header) {
        print "Root: $h\n";
        $header="    ";
        $objs = {};
    };
    if (exists $objs->{$h}) {
        print "$header Already printed\n";
        return;
    }

    $objs->{$h} = 1 if (reftype($h) eq 'HASH' || reftype($h) eq 'ARRAY');

	if (reftype($h) eq 'HASH') {
        for my $k (keys %{$h}) {
            my $t = $h->{$k};
            print "$header $k: $t\n";
            # if ($k ne "_parent"){ #TODO: this is only a workaround for Tree.pm. should be removed.
                print_obj($h->{$k}, $header."    ");
            # }
		}
    } elsif (reftype($h) eq 'ARRAY'){
        # my $t = join( ", " , @{$h});
		# print "$header $t\n";
        for(my $i=0; $i<scalar(@{$h});$i++) {
            print($header." [$i]:".$h->[$i]."\n");
            print_obj($h->[$i], $header."    ");
        }
    }
    else {
        # print "$header $h\n";
    }
}

1;
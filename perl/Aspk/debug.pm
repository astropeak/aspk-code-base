package Aspk::debug;

# first parameter is a references to a hash
sub printHash {
	my $h = $_[0];
	my $header = $_[1];
	unless ($header) {$header="";};

	if (ref($h) eq 'HASH') {
        for my $k (keys %{$h}) {
            my $t = $h->{$k};
            print "$header $k: $t\n";
            printHash($h->{$k}, $header."    ");
		}
    } elsif (ref($h) eq 'ARRAY'){
        my $t = join( ", " , @{$h});
		print "$header $t\n";
    }
    else {
        # print "$header $h\n";
    }
}

1;
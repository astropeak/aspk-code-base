package Aspk::Debug;
use Filter::Simple;
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

my $dbg_current_level= 8;

sub _aa {
    my $str = shift;
    # print "Input: $str\n";
    my @a = grep {$_ ne ""} split /[, )(]/, $str;
    # print_obj(\@a);
    my $b = join(".', '.", map {"'$_='.".$_} @a);
    $b.='."\n";';
    # print $b."\n";
    return $b

}

# split '$a $b $c', '($a,$b,$c)', '$a,$b,$c' to a list of '($a,$b,$c)'
sub split_arg_list{
    my $str = shift;
    my @a = grep {$_ ne ""} split /[, )(]/, $str;
    return @a;
}


FILTER {
    # print "####### Enter FILTER: $_\n";
    # print "####### Enter FILTER\n\n";
    # print "seperator:".$\."\n";
    my @all_lines = grep {$_->{content} ne ""} map {{linenum=>++$aaaa, content=>$_}}split /\n/, $_;
    # print_obj \@all_lines;
    # my $file_name = $0;
    # my ($package, $filename, $line) = caller;

    if ($dbg_current_level > 5) {
        foreach (@all_lines) {
            if ($_->{content} =~ /^\s*dbgd([^;]*)/) {
                $_->{content} = "print '[', __PACKAGE__, '::', __SUB__, ':', __LINE__, ']', "."' '."._aa($1);
            }
        }

        $_ = join("\n", map{$_->{content}} @all_lines);
        $_ = "\nuse feature 'current_sub';\n".$_;
    } else {
        s/dbgd(.*)//g;
    }


    # print_obj \@all_lines;

    # s/BANG\s+BANG/die 'die in filter: BANG' if 1/g;
    # if ($dbg_current_level > 5) {
    #     if (/dbg.([^;]*)/) {

    #         # s/dbgd/print "$b\n";/g;

    #     }
    #     s/dbgd\s*(.*)/print '\1='._aa($1).'\n';/g;
    # } else {
    #     s/dbgd(.*)//;
    # }

    # print "####### Exit FILTER: $_\n";
    # print "####### Exit FILTER\n";
    # $_ = "print EEEEFFF\n';";
};

sub get_current_line {
    my ($package, $filename, $line, $subroutine, $hasargs,
        $wantarray, $evaltext, $is_require, $hints, $bitmask, $hinthash) = caller(0);
    return $line;
}
sub get_parent_sub {
    my ($package, $filename, $line, $subroutine, $hasargs,
        $wantarray, $evaltext, $is_require, $hints, $bitmask, $hinthash) = caller(1);
    return $subroutine;
}



1;
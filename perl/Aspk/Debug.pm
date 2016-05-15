package Aspk::Debug;
use Filter::Simple;
use File::Basename;
use Exporter;

use Scalar::Util qw(reftype);

@ISA=qw(Exporter);
@EXPORT_OK=qw(print_obj);

my $dbg_current_level= 3;

# first parameter is a references to a hash
# TODO should be renamed to print_obj
my $objs = {};
sub print_call_stack {
    my $i = 2;
    my @rst;
    my ($package, $filename, $line, $subroutine, $hasargs,
        $wantarray, $evaltext, $is_require, $hints, $bitmask, $hinthash) = caller($i++);

    $filename = my_basename($filename, 2);
    unshift @rst, [$filename, $line, $subroutine];
    while ($subroutine ne "") {
        ($package, $filename, $line, $subroutine, $hasargs,
         $wantarray, $evaltext, $is_require, $hints, $bitmask, $hinthash) = caller($i++);

        $filename = my_basename($filename, 2);
        unshift @rst, [$filename, $line, $subroutine];
    }
    print "call stack: ".join("\n", map {"  ".$_->[0].':'.$_->[1].', '.$_->[2]}@rst)."\n";
}

sub my_basename {
    my ($name, $path, $suffix, $depth);
    ($path, $depth) = @_;
    my @t;
    while ($depth-- && $path) {
        $name = basename($path);
        unshift @t, $name;
        $path = dirname($path);
    }
    return join("/", @t);
}

sub my_caller{
    my $i = shift;
    ++$i;

    my ($package, $filename, $line, $subroutine, $hasargs,
        $wantarray, $evaltext, $is_require, $hints, $bitmask, $hinthash) = caller($i+1);
    $line = (caller($i))[2];
    $filename = (caller($i))[1];
    $subroutine = (caller($i))[0]."::noname" if $subroutine eq "";

    return ($filename, $line, $subroutine);
}
sub format_header {
    my ($filename, $line, $subroutine) = my_caller(1);
    $filename = my_basename($filename, 2);
    return "[$filename:$line, $subroutine]";
}

# print result of format_array_hash
sub print_vars {
    my @varhash = @_;
    print format_header()." ".
        join(", ",
             map {my $v=$_->{value};
                  if (defined($v)) {
                      if ($v eq "") {
                          $v = "EMPTY_STR";
                      }
                  } else {
                      $v = 'UNDEF';
                  };
                  $v = scalar2str($v);
                  chomp $v unless $v =~ /\n.*\n$/;
                  $_->{name}."=".$v;
             } @varhash)."\n";
}

# convert a scalar to a string. scalar can be a ref, number, string
# there will always be a newline in the end of the result
sub scalar2str {
	my $h = $_[0];
	my $header = $_[1];
    my ($var, $header) = @_;
    my $rst = "";

	unless ($header) {
        $rst .= "$var\n";
        $header="    ";
        $objs = {};
    };
    if (exists $objs->{$var}) {
        $rst .= "$header Already printed\n";
        return $rst;
    }

    $objs->{$var} = 1 if (reftype($var) eq 'HASH' || reftype($var) eq 'ARRAY');

	if (reftype($var) eq 'HASH') {
        for my $k (keys %{$var}) {
            my $t = $var->{$k};
            $rst .= "$header $k: $t\n";
            # if ($k ne "_parent"){ #TODO: this is only a workaround for Tree.pm. should be removed.
            $rst .= scalar2str($var->{$k}, $header."    ");
            # }
		}
    } elsif (reftype($var) eq 'ARRAY'){
        # my $t = join( ", " , @{$var});
		# $rst .= "$header $t\n";
        for(my $i=0; $i<scalar(@{$var});$i++) {
            $rst .=($header." [$i]:".$var->[$i]."\n");
            $rst .= scalar2str($var->[$i], $header."    ");
        }
    }
    else {
        # print "$header $var\n";
    }

    return $rst;
}

sub print_obj {
    print scalar2str(@_);
}


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

# given a list of variable string name, format a hash table
# eg: input:string list, '("$a", "$b")'; output:string, "{'$a'=>$a, '$b'=$b}"
sub format_hash{
    return '{'.(join(',', map {"'$_'=>".$_} @_))
        .'}';
}

# given a list of variable string name, format an array of  hash table
# eg: input:string list, '("$a", "$b")'; output:string, "({name=>'$a',value=>$a}, {name=>'$b',value=>$b})"
sub format_array_hash{
    return '('.(join(',', map {"{name=>'$_', value=>".$_."}"} @_))
        .')';
}

FILTER {
    # print "####### Enter FILTER: $_\n";
    # print "####### Enter FILTER\n\n";
    # print "seperator:".$\."\n";
    my @all_lines = grep {$_->{content} ne ""} map {{linenum=>++$aaaa, content=>$_}}split /\n/, $_;
    # print_obj \@all_lines;
    # my $file_name = $0;
    # my ($package, $filename, $line) = caller;

    foreach (@all_lines) {
        if ($_->{content} =~ /^\s*(dbg[ewhml])([^;]*)/) {
            # $_->{content} = "print '[', __PACKAGE__, '::', __SUB__, ':', __LINE__, ']', "."' '."._aa($2);
            # print "arg_list: $2\n";
            my $level_table = {"dbge"=>1,
                               "dbgw"=>2,
                               "dbgh"=>3,
                               "dbgm"=>4,
                               "dbgl"=>5
            };

            my $func=$1;
            # my $real_level = $level_table->{$func};

            if ($dbg_current_level >= $level_table->{$func}) {
                my @a = split_arg_list($2);
                # print "split_arg_list: @a\n";
                my @b = format_array_hash(@a);
                # print "format_hash: @b\n";
                $_->{content} = "print \"[$func]\";Aspk::Debug::print_vars(@b);";
            } else {
                $_->{content} = "";
            }
        }
    }

    $_ = join("\n", map{$_->{content}} @all_lines);
    # $_ = "\nuse feature 'current_sub';\n".$_;
    # s/dbgd(.*)//g;

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
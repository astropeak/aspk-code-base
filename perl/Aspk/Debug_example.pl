use Aspk::Debug qw(print_obj);

my %h = ("name"=>"Tom", "gender"=>"male");
my $h1 = {"aa"=>"BB",
          "cc"=>"dd",
          "AA"=>\%h,
          "BB"=>[1,2,\%h,4]};

# print_obj($h1);




sub aaa{
    #  0         1          2      3            4
    my ($package, $filename, $line, $subroutine, $hasargs,
        #  5          6          7            8       9         10
        $wantarray, $evaltext, $is_require, $hints, $bitmask, $hinthash) = caller(1);

    print "aaa: ",$package, $filename, $line, $subroutine, $hasargs, "\n";
    print_obj($hinthash);
    print "subroutine: $subroutine\n";
}
sub bbb{
    aaa(1,2,3);
}
sub ccc{
    bbb(4,5,7);
}
# ccc();

# print __FILE__, ":", __LINE__, ":", __FUNCTION__, ": BBBB\n";

# print __PACKAGE__, ": FFFF\n";

my $str="AAAABBBB";
my $num=33333;

dbgl $str $num;

sub ddd {
    my $str="XXXXX";
    my $num=5555;

    print "\n\n##########\n\n";
    $str="";
    dbgl $str $num;
}

$dbg_current_level = 5;

# ddd();
# $h1 = "AAA";
dbgh $h1 $num;
dbge "BBB", $num;

# print_obj($h1);
# print_obj $h1 ,$num;

# print "scalar2str test:\n".Aspk::Debug::scalar2str($h1);
# print "scalar2str test:\n".Aspk::Debug::scalar2str("AAAA");
use Aspk::Tree;
use Aspk::debug qw(printHash);

my $n = Aspk::Tree->new({data=>"aaaa"});
my $cn = Aspk::Tree->new({data=>"bbbb", parent=>$n});
my $cn1 = Aspk::Tree->new({data=>"cccc", parent=>$n});
my $cn11 = Aspk::Tree->new({data=>"dddd", parent=>$cn1});
my $cn12 = Aspk::Tree->new({data=>"eeee"});
$cn1->add_child($cn12);

print "Hash of $n. data:".$n->{_data}."\n";
my @a = (keys(%{$n}));
print "keys: @a\n";
@a = @{$n->{_children}};
print "child: @a\n";
printHash($n);

sub printDiv{
    my $para = shift;
    my $pad = " "x($para->{depth}*4);
    my $pad1= " "x(($para->{depth}+1)*4);
    print $pad."<div>\n";
    print $pad1.$para->{data}."\n";
}
sub printDivPost{
    my $para = shift;
    my $pad= " "x($para->{depth}*4);
    print $pad."</div>\n";
}

print "\nTraverse result of tree:\n";
$n->traverse({prefunc=>\&printDiv, postfunc=>\&printDivPost});

print "\nPre order traverse result:\n";
$n->traverse({prefunc=>
                  sub{
                      my $para = shift;
                      print $para->{data}."\n";
              }});

print "\nMiddle order traverse result:\n";
$n->traverse({midfunc=>
                  sub{
                      my $para = shift;
                      print $para->{data}."\n";
              }});

print "\nPost order traverse result:\n";
$n->traverse({postfunc=>
                  sub{
                      my $para = shift;
                      print $para->{data}."\n";
              }});

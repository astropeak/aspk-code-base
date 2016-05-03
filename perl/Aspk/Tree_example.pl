use Aspk::Tree qw(createNode traverse);

my $n = createNode({data=>"aaaa"});
my $cn = createNode({data=>"bbbb", parent=>$n});
my $cn1 = createNode({data=>"cccc", parent=>$n});
my $cn11 = createNode({data=>"dddd", parent=>$cn1});
# appendChild({node=>$n, child=>$cn});
# appendChild({node=>$n, child=>$cn1});

print "data: ".$n->{data}."\n";
print "parent: ".$n->{parent}."\n";
print "child: ".$n->{children}[0]->{data}."\n";
print "child 1: ".$n->{children}[1]->{data}."\n";
# print "child 2: ".$n->{children}[2]->{data}."\n";

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
traverse({node=>$n, prefunc=>\&printDiv, postfunc=>\&printDivPost});

print "\nMiddle traverse result:\n";
traverse({node=>$n, midfunc=>
              sub{
                  my $para = shift;
                  print $para->{data}."\n";
          }});

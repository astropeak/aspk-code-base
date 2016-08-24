use Aspk::ProcessFiles;
use Aspk::Debug;

my $pf = new Aspk::ProcessFiles("a.txt", "b.txt", "c.doc");
# $pf->process();
$pf->register(pre_all, sub {
    my (@file_list) = @_;
    print "in pre_all. Files: ".(join " ",@file_list)."\n";
    0;}, "checking");

$pf->register(pre, sub {
    my ($file) = @_;
    print "in pre. Files: ".$file."\n";
    0;});

$pf->process1();

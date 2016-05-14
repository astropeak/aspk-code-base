use Aspk::debug qw(printHash);

my %h = ("name"=>"Tom", "gender"=>"male");
my $h1 = {"aa"=>"bb",
          "cc"=>"dd",
          "AA"=>\%h,
          "BB"=>[1,2,\%h,4]};

printHash($h1);
use Aspk::debug;

my %h = ("name"=>"Tom", "gender"=>"male");
my $h1 = {"aa"=>"bb",
          "cc"=>"dd",
"AA"=>\%h,
"BB"=>[1,2,3,4]};
Aspk::debug::printHash($h1);
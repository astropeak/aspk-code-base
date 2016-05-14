use Aspk::Debug qw(print_obj);

my %h = ("name"=>"Tom", "gender"=>"male");
my $h1 = {"aa"=>"bb",
          "cc"=>"dd",
          "AA"=>\%h,
          "BB"=>[1,2,\%h,4]};

print_obj($h1);
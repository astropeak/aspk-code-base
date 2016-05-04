use Aspk::HtmlElement;

my $e=Aspk::HtmlElement->new({tag=>"div", prop=>{class=>"active;aab",id=>"myDiv",href=>"http://112233aaa"}});
my $ee=Aspk::HtmlElement->new({tag=>"a", prop=>{class=>"active;aab",id=>"myDiv 2",href=>"http://112233aaa"}});
my $eee=Aspk::HtmlElement->new({tag=>"div", prop=>{class=>"active;aab",id=>"myDiv 3",href=>"http://112233aaa"}});
$e->add_child($ee);
$ee->add_child($eee);

$e->add_class("foo");
$e->rm_class("active");
$e->html_prop("type", "text");
$e->rm_prop("href");
$e->rm_prop("Not_exist");

# my $ss=$e->format_html();
# print $ss;

$e->print();
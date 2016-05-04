use Aspk::HtmlElement;

my $e=Aspk::HtmlElement->new({tag=>"div", prop=>{class=>"active;aab",id=>"myDiv",href=>"http://112233aaa"}});

$e->add_class("foo");
$e->rm_class("active");
$e->prop("type", "text");
$e->rm_prop("href");
$e->rm_prop("Not_exist");
my $ss=$e->format_html();
print $ss;
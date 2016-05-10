use Aspk::HtmlElement;
use Aspk::debug qw(printHash);

print $Aspk::HtmlElement::PropFormatTable->{class}(["aa", "bb"])."\n";
print $Aspk::HtmlElement::PropFormatTable->{style}({height=>10, width=>30})."\n";

my $e=Aspk::HtmlElement->new({tag=>"div", prop=>{class=>["active", "aab"],id=>"myDiv",href=>"http://112233aaa"}});

my $ee=Aspk::HtmlElement->new({tag=>"a", prop=>{class=>["active", "aab"],id=>"myDiv 2",href=>"http://112233aaa"}, parent=>$e});
my $eec=Aspk::HtmlElement->new({tag=>"text", prop=>{content=>"I am a connect"}, parent=>$ee});
my $eee=Aspk::HtmlElement->new({tag=>"div", prop=>{class=>["active", "aab"],id=>"myDiv 3",href=>"http://112233aaa"}});

# $ee->add_child($eec);
$ee->add_child($eee);

$e->add_class("foo");
$e->rm_class("active");

$e->style("height", 10);
$ee->style("height", 20);
$ee->style("z-index", 999);
print $ee->style(height)."\n";

$e->html_prop("type", "text");
$e->rm_prop("href");
$e->rm_prop("Not_exist");

# my $ss=$e->format_html();
# print $ss;

print "Html:\n".$e->format();

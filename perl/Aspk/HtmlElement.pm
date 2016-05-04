package Aspk::HtmlElement;
use parent Aspk::Tree;

sub new {
    # print "Enter HtmlElement new\n";
    my ($class, $spec)= @_;
    my $self;
    $self = $class->SUPER::new();
    # $self->prop(data, {tag=>$spec->{tag},
    # prop=>$spec->{prop}});

    $self->prop(tag, $spec->{tag});
    $self->prop(prop, $spec->{prop});
    $self->prop(parent, $spec->{parent});
    # print "In HtmlElement new. tag: ".$spec->{tag}."\n";
    # print "In HtmlElement new. tag: ".$self->prop(tag)."\n";

    bless $self, $class;
    return $self;
}

sub html_prop {
    my ($self, $name, $value)=@_;
    # print "self:$self, name: $name, value: $value\n";
    if (defined($value)){
        $self->prop(prop)->{$name} = $value;
        return $self;
    } else {
        return $self->prop(prop)->{$name};
    }
}

sub rm_prop{
    my ($self, $name)=@_;
    delete $self->prop(prop)->{$name};
    return $self;
}

sub add_class{
    my ($self, $class)=@_;
    my $orig_class = $self->html_prop("class");
    $self->html_prop("class", $orig_class.";".$class);

    return $self;
}

sub rm_class{
    my ($self, $class)=@_;
    my $orig_class = $self->html_prop("class");
    $orig_class=~s/(;?)$class;?/\1/;
    $self->html_prop("class",$orig_class);

    return $self;
}

sub format_html{
    # my ($self)=@_;
    # my ($data, $depth, $self)=@_;
    my $para = shift;
    my $self = $para->{node};

    # print "tag: ".$self->prop(tag).".\n";
    my $pad = " "x($para->{depth}*4);
    my $p=$self->prop(prop);
    my $rst=$pad."<".$self->prop(tag);
    my @ak = keys(%{$p});
    foreach my $k (@ak) {
        $rst .= " ".$k."=\"".$p->{$k}."\"";
    }
    $rst.=">\n";
    print $rst;
    return $rst;
}

sub print {
    my ($self)=@_;
    $self->traverse({prefunc=>\&format_html,
                     postfunc=>sub {
                         my $para=shift;
                         my $self=$para->{node};
                         my $pad = " "x($para->{depth}*4);
                         print "$pad</".$self->prop(tag).">\n";
                     }})
}

sub height {
    my ($self, $value)=@_;
    my $style = $self->html_prop(style);

}
1;
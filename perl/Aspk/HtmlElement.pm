package Aspk::HtmlElement;

sub new {
    my ($class, $para)= @_;
    my $self =  {tag=>$para->{tag},
                 prop=>$para->{prop},
                 content=>$para->{content}};
    bless $self, $class;
    return $self;
}

sub prop{
    my ($self, $name, $value)=@_;
    # print "self:$self, name: $name, value: $value\n";
    if (defined($value)){
        $self->{prop}->{$name} = $value;
        return $self;
    } else {
        return $self->{prop}->{$name};
    }
}

sub rm_prop{
    my ($self, $name)=@_;
    delete $self->{prop}->{$name};
    return $self;
}

sub add_class{
    my ($self, $class)=@_;
    my $orig_class = $self->prop("class");
    $self->prop("class", $orig_class.";".$class);

    return $self;
}

sub rm_class{
    my ($self, $class)=@_;
    my $orig_class = $self->prop("class");
    $orig_class=~s/(;?)$class;?/\1/;
    $self->prop("class",$orig_class);

    return $self;
}

sub format_html{
    my ($self)=@_;
    my $rst="";
    my $p=$self->{prop};
    $rst="<".$self->{tag};
    my @ak = keys(%{$p});
    foreach my $k (@ak) {
        $rst .= " ".$k."=\"".$p->{$k}."\"";
    }
    $rst.=">";
    return $rst;
}

1;
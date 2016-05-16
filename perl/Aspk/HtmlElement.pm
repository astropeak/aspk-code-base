package Aspk::HtmlElement;
use parent Aspk::Tree;
use Aspk::Debug;

sub new {
    # print "Enter HtmlElement new\n";
    my ($class, $spec)= @_;
    my $self;
    $self = $class->SUPER::new();
    # $self->prop(data, {tag=>$spec->{tag},
    # prop=>$spec->{prop}});

    $spec->{prop} = {} if not exists($spec->{prop});

    $self->prop(tag, $spec->{tag});
    $self->prop(prop, $spec->{prop});
    $spec->{parent}->add_child($self) if defined $spec->{parent};

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
    $self->html_prop("class", []) if not defined($self->html_prop("class"));
    my $orig_class = $self->html_prop("class");
    push(@{$orig_class}, $class);
    # $self->html_prop("class", $orig_class.";".$class);

    return $self;
}
sub style{
    my ($self, $name, $value)=@_;
    dbgl $name, $value;
    $self->html_prop("style", {}) if not defined($self->html_prop("style"));
    my $orig_style = $self->html_prop("style");

    if (defined($value)) {
        $orig_style->{$name} = $value;
        return $self;
    } else {
        return $orig_style->{$name};
    }
}

sub rm_style{
    my ($self, $name)=@_;
    my $orig_style = $self->html_prop("style");
    delete $orig_class->{$name};
    return $self;
}

sub rm_class{
    my ($self, $class)=@_;
    my $orig_class = $self->html_prop("class");
    my @class_array = grep {$_ ne $class} @{$orig_class};
    $self->html_prop("class", \@class_array);

    return $self;
}

our $PropFormatTable = {
    class=>sub{
        my $class_array=shift;
        return join(";", @{$class_array});
    },
    style=>sub{
        my $style_hash=shift;
        return join(";", map {$_.":".$style_hash->{$_}} keys(%{$style_hash}));
    }
};

sub _format_prop {
    my ($name, $value) = @_;
    # print "in _format_prop. name: $name, value: $value\n";
    if (exists($PropFormatTable->{$name})) {
        return $PropFormatTable->{$name}($value);
    } else {
        return $value;
    }
}

sub format_html{
    # my ($self)=@_;
    # my ($data, $depth, $self)=@_;
    my $para = shift;
    my $self = $para->{node};

    # print "tag: ".$self->prop(tag).".\n";
    my $pad = " "x($para->{depth}*4);
    my $rst = "";

    if ($self->prop(tag) eq "text"){
        $rst=$pad.$self->html_prop(content)."\n";
    } else {
        my $p=$self->prop(prop);
        $rst=$pad."<".$self->prop(tag);
        my @ak = keys(%{$p});
        foreach my $k (@ak) {
            $rst .= " ".$k."=\""._format_prop($k, $p->{$k})."\"";
        }
        $rst.=">\n";
    }
    # print $rst;
    return $rst;
}

sub format {
    my ($self)=@_;
    return $self->traverse({prefunc=>\&format_html,
                            postfunc=>sub {
                                my $para=shift;
                                my $self=$para->{node};
                                if ($self->prop(tag) eq "text") {
                                    return "";
                                } else {
                                    my $pad = " "x($para->{depth}*4);
                                    # print "$pad</".$self->prop(tag).">\n";
                                    return "$pad</".$self->prop(tag).">\n";
                                }
                            }})
}

sub height {
    my ($self, $value)=@_;
    my $style = $self->html_prop(style);

}
1;
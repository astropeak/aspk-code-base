package Aspk::FileCharIterator;
use Aspk::Debug;

sub new {
    my ($class, $file)= @_;
    dbgm $class $file;

    my $self={};
    bless $self, $class;

    open my $fh, "<", $file or die "can't open file $file";
    local $/;
    binmode $fh;

    $self->prop(content, <$fh>);
    # $self->prop(index) = 0;
    return $self;
}

sub get {
    my ($self, $pattern) = @_;
    # dbgm $pattern;
    my $len=0;
    my $str=$self->prop(content);
    if (defined($pattern)){
        if ($str =~ /^($pattern)/) {
            $len = length($1);
        }
    } else {
        $len=1;
    }

    $self->prop(content, substr($str, $len));
    return substr($str,0,$len);
}

# Get or set a property of the object
sub prop {
    my ($self, $name, $value) = @_;
    # print "In prop. name: $name, value: $value\n";
    # dbgl $name $value;

    if (defined($value)) {
        $self->{"_$name"} = $value;
        return $self;
    } else {
        return $self->{"_$name"};
    }
}

1;
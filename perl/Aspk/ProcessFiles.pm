package Aspk::ProcessFiles;
use Aspk::Debug qw(print_obj);
use Cwd;

sub new {
    my ($class, @file_list)= @_;
    my $self={};
    bless $self, $class;

    @file_list = map {Cwd::abs_path($_)} @file_list;
    dbgh \@file_list;
    $self->prop(file_list, \@file_list);
    $self->prop(action_table, {});
    return $self;
}

# Get or set a property of the object
sub prop {
    my ($self, $name, $value) = @_;
    # print "In prop. name: $name, value: $value\n";
    dbgl $name $value;

    if (defined($value)) {
        $self->{"_$name"} = $value;
        return $self;
    } else {
        return $self->{"_$name"};
    }
}

sub process {
    my ($self) = @_;
    my @file_list = @{$self->prop(file_list)};
    $self->pre_all(@file_list);
    foreach my $file (@file_list) {
        $self->pre($file);
        $self->action($file);
        $self->post($file);
    }

    $self->post_all(@file_list);
    return $self;
}

sub process1 {
    my ($self) = @_;
    my %action_table=%{$self->prop(action_table)};
    my @file_list = @{$self->prop(file_list)};
    dbgl \@file_list;
    sub run {
        my ($action, @para) = @_;
        if (exists $action_table{$action}) {
            my $msg = $action_table{$action}{description};
            print "run $msg\n";
            my $rst = $action_table{$action}{callback}(@para);
            die "Step error" if $rst != 0;
        }
    }

    run("pre_all", @file_list);
    foreach my $file (@file_list) {
        run("pre", $file);
        run("action", $file);
        run("post", $file);
    }

    run("post_all", @file_list);
    return $self;
}

sub iterate {
    my ($self, $func)=@_;
    foreach my $file (@{$self->prop(file_list)}) {
        $func->($file);
    }
}

sub register {
    my ($self, $action, $callback, $description) = @_;
    $self->prop(action_table)->{$action}{callback} = $callback;
    $self->prop(action_table)->{$action}{description} = $description;
    return $self;
}

sub pre_all {
    my ($self, @file_list) = @_;
    print "pre_all\n";
    return $self;
}

sub post_all {
    my ($self, @file_list) = @_;
    print "post_all\n";
    return $self;
}

sub pre {
    my ($self, $file) = @_;
    print "pre. file: $file\n";
    return $self;
}

sub post {
    my ($self, $file) = @_;
    print "post. file: $file\n";
    return $self;
}

sub action {
    my ($self, $file) = @_;
    print "action. file: $file\n";
    return $self;
}

1;
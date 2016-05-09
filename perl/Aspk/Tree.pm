# A very simple tree implementation. Currenttly only little functions implemented.
# Definition of a tree: a tree has a data, some child trees, and a parent tree.

package Aspk::Tree;

sub new {
    my ($class, $spec)= @_;
    $spec = {} if !defined($spec);
    my $self={};
    bless $self, $class;

    $self->prop(data, $spec->{data});
    $self->prop(parent, undef);
    $spec->{parent}->add_child($self) if defined($spec->{parent});
    $self->prop(children, []);
    return $self;
}

# Get or set a property of the object
sub prop {
    my ($self, $name, $value) = @_;
    # print "In prop. name: $name, value: $value\n";
    if (defined($value)) {
        $self->{"_$name"} = $value;
        return $self;
    } else {
        return $self->{"_$name"};
    }
}

sub _add_child {
    my ($self, $child) = @_;
    push(@{$self->prop(children)}, $child);
    return $self;
}

sub add_child {
    my ($self, $child) = @_;
    $self->_add_child($child);
    $child->prop(parent, $self);
    return $self;
}


# internal function
sub createNode1{
    my $para=shift;
    my $cn = {data=> $para->{data},
              parent=> undef,
              children=>[]
    };
    return $cn;
}

# create a new node and return that node.
# parameter:
# hash->{data}: data to be save in this node, can be any data
# hash->{parent}: the parent node. Must be one returned by createNode. If ommited, parent node of returned node will be set to undef.
sub createNode{
    my $para=shift;
    my $n = createNode1({data=>$para->{data}});
    if ($para->{parent}){
        appendChild({node=>$para->{parent}, child=>$n});
    }

    return $n;
}

# internal function
# set parent node of a node
# parameter
# hash->{node}: the node
# hash->{parent}: the parent node
sub setParent{
    my $para=shift;
    $para->{node}->{parent} = $para->{parent};
    return $para->{node};
}

# internal function
# set child node of a node
# parameter
# hash->{node}: the node
# hash->{child}: the child node
sub appendChild1{
    my $para=shift;
    push(@{$para->{node}->{children}}, $para->{child});
    return $para->{node};
}

# add a child node to another node
# parameter
# hash->{node}: the node
# hash->{child}: the child node to be added.
sub appendChild{
    my $para=shift;
    setParent({node=>$para->{child}, parent=>$pare->{node}});
    appendChild1({node=>$para->{node}, child=>$para->{child}});

    return $para->{node};
}

# traverse the tree
# parameter
# hash->{depth}: the depth of current tree node. Optional
# hash->{prefunc}: the prefunc callback, called before traverse its subtree. Optional
# hash->{midfunc}: the midfunc callback, called between every child tree. Optional
# hash->{postfunc}: the postfunc callback, called after traversed its subtree. Optional
#
# Parameter to the callback
# hash->{data}: the data saved in current node
# hash->{depth}: current node depth(same as tree height)
# hash->{node}: the current node itself
#
# For midfunc, there is another parameter:
# hash->{traversedChildCount}: child count that already be traversed.
#
# So to pre-order, just provide prefunc. to post-order, just provide post func. to middle order, just provide midfunc.
#
# return value
# all result of funcs concat as string
sub traverse {
    my ($self, $para)=@_;
    $para->{depth} || ($para->{depth}=0);
    my $depth = $para->{depth};
    my $data = $self->prop(data);
    my @children = @{$self->prop(children)};
    my $rst;

    # if ($para->{node}) {
    if (1) {
        if ($para->{prefunc}) {
            $rst .= $para->{prefunc}({data=>$data,
                              depth=>$depth,
                              node=>$self});
        }

        my $len = scalar(@children);
        for (my $i=0;$i<$len;$i++){
            $rst .= @children[$i]->traverse({depth=>$depth+1,
                                     prefunc=>$para->{prefunc},
                                     postfunc=>$para->{postfunc},
                                     midfunc=>$para->{midfunc}});
            if ($para->{midfunc} && $i < ($len-1)) {
                $rst.=$para->{midfunc}({data=>$data,
                                  depth=>$depth,
                                  node=>$self,
                                  traversedChildCount=>($i+1)});
            }
        }

        if ($len<=1){
            if ($para->{midfunc}) {
                $rst.=$para->{midfunc}({data=>$data,
                                  depth=>$depth,
                                  node=>$self,
                                  traversedChildCount=>0});
            }
        }

        if ($para->{postfunc}) {
            $rst.=$para->{postfunc}({data=>$data,
                               depth=>$depth,
                               node=>$self});
        }

    }
    return $rst;
}

# getter function. Get data of a node
# Parameter:
# node: the node
sub get_data (){
    my ($self) = @_;
    return $self->prop(data);
}

# getter function. Get children as an array of a node
# Parameter:
# node: the node
sub get_childeren(){
    my ($self) = @_;
    return $self->prop(children);
}

1;
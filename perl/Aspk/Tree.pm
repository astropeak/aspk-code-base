# A very simple tree implementation. Currenttly only little functions implemented.

package Aspk::Tree;
use Exporter;

@ISA=qw(Exporter);
@EXPORT_OK=qw(createNode appendChild traverse);

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
# hash->{node}: the node
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
sub traverse{
    my $para=shift;
    $para->{depth} || ($para->{depth}=0);
    my $depth = $para->{depth};
    my $node=$para->{node};

    if ($para->{node}) {
        if ($para->{prefunc}) {
            $para->{prefunc}({data=>$node->{data},
                              depth=>$depth,
                              node=>$node});
        }

        my $len = scalar(@{$node->{children}});
        for (my $i=0;$i<$len;$i++){
            traverse({node=>${node}->{children}[$i], depth=>$depth+1,
                      prefunc=>$para->{prefunc}, postfunc=>$para->{postfunc},
                      midfunc=>$para->{midfunc}});
            if ($para->{midfunc} && $i < ($len-1)) {
                $para->{midfunc}({data=>$node->{data},
                                  depth=>$depth,
                                  node=>$node,
                                  traversedChildCount=>($i+1)});
            }
        }

        if ($len<=1){
            if ($para->{midfunc}) {
                $para->{midfunc}({data=>$node->{data},
                                  depth=>$depth,
                                  node=>$node,
                                  traversedChildCount=>0});
            }
        }

        if ($para->{postfunc}) {
            $para->{postfunc}({data=>$node->{data},
                               depth=>$depth,
                               node=>$node});
        }

    }
}

# getter function. Get data of a node
# Parameter:
# node: the node
sub getData (){
    return @_[0]->{data};
}

# getter function. Get children as an array of a node
# Parameter:
# node: the node
sub getChilderen(){
    return @_[0]->{children};
}

1;
class DirectedGraph:
    def __init__(self, nodes, next):
        '''
        nodes: list of node
        next: function, given an node, return a list of nodes that is the descendant of the given node. Can be empty node.
        A graph can be defined by those two thing
        '''
        self.nodes = nodes
        self.next = next

    def heads(self):
        '''return the head nodes of this graph as a list.
        If a node don't exist in any node's next node, then it is a head node
        '''
        all = set(self.nodes)
        nexts = set()
        for node in self.nodes:
            nexts.update(self.next(node))

        return list(all.difference(nexts))

    def paths(self):
        '''Return all paths of this graph'''
        start_nodes = self.heads()
        if len(start_nodes) == 0:
            # all nodes are in a circle, so we just push the first node
            start_nodes.append(self.nodes[0])

        for node in start_nodes:
            # print("\nin paths. node: ", node)
            yield from self._paths(node, []) # don't know why we need to provide the second parameter

    def circular_paths(self):
        '''Return all circular paths'''
        for path in self.paths():
            if path['is_circular']:
                pp = path['data'][path['circular_index']:]
                # yield pp+pp[0:1]
                yield pp

    def _paths(self, node, current_path=[]):
        '''
        Iterate all pathes that start with 'node'.
        current_path is a list of node that previous the 'node'

        One benifet of generator: if I want to stop when I detected one circle, then I can stop easily.
        '''
        # print("enter _paths.", node, current_path, self.next(node))
        current_path.append(node)

        if len(self.next(node)) == 0:
            yield {'is_circular':False,
                   'data': current_path,
            }

        for n in self.next(node):
            if n in current_path:
                # '''There is circle'''
                idx = current_path.index(n)
                # print("Circular dependency: ", current_path[idx:])
                yield {'is_circular':True,
                       'data': current_path,
                       'circular_index': idx,
                }
            else:
                yield from self._paths(n, current_path.copy())


def test_graph():
    nodes = ['a', 'b', 'c', 'd', 'e', 'f']
    # nodes = ['a', 'b', 'c']
    nexts = {'a':['b'],
             'b':['c'],
             'c':['a'],
             'd':['a', 'e'],
             'e':['e'],
    }

    def next(node):
        '''return a list of node that depends on the given node'''
        return nexts.get(node, [])

    graph = DirectedGraph(nodes, next)

    # print("heads", graph.heads())
    print('All paths:')
    for p in graph.paths():
        print(p)

    print('\nCircular paths:')
    for p in graph.circular_paths():
        print(p)

if __name__ == '__main__':
    test_graph()
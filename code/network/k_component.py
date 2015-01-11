""" Approximations for k-components

A k-component is a maximal subgraph in which all pairs of nodes are connected 
by at least k node-independent paths which each run entirely within the 
subgraph. An exact solution (Moody & White, 2003) is computationally very hard.
This approximation is based on the proposal of White and Newman (2001). It 
allows us to compute the approximate value of group cohesion for moderately 
large networks, along with all the hierarchy structure of connectivity levels,
in a reasonable time frame.

The algorithm consists in 4 steps:

1. Compute the k-core structure of the network. This is a fast computation and
gives us a baseline for the computation of the k-component structure because 
all k-components are k-cores but not all k-cores are k-components. 

2. For each core level (k) we compute the connected component of the k-core 
(note that the k-core could be disconnected) and then compute the approximation
of the pairwise vertex connectivity proposed by White and Newman (2001) for 
each connected part of each k-core. Implemented in ticket #538. 

3. Build the complement graph of a graph with all nodes in the connected part 
of the k-core and edges between two nodes if the pairwise vertex connectivity 
(ie number of node independent paths between them) is greater or equal than 
the level k of the k-core analyzed.

4. Compute the anti k-core structure on the complement graph (eg the equivalent
of the k-core structure of the dense graph) and extract the core of level k 
that correspond to the level of the k-core in step 1. Each connected component 
of this k-core is a good approximation for k-components of level k. 

References

    White, Douglas R., and Mark Newman. 2001 
    A Fast Algorithm for Node-Independent Paths. 
    Santa Fe Institute Working Paper 01-07-035  
    http://eclectic.ss.uci.edu/~drwhite/working.pdf

    Moody, James and Douglas R. White. 2003. 
    Social Cohesion and Embeddedness. American Sociological Review. 68:103-127
    http://www2.asanet.org/journals/ASRFeb03MoodyWhite.pdf

"""
import math
import itertools
import networkx
# Code in ticket #538
from node_independent_paths import all_pairs_vertex_connectivity, pairwise_vertex_connectivity
# Dan's version of Anticore number
from anticore import anticore_number
#    Copyright (C) 2011 by 
#    Jordi Torrents <jtorrents@milnou.net>
#    Dan Schult (dschult@colgate.edu)
#    Aric Hagberg (hagberg@lanl.gov)
#    All rights reserved.
#    BSD license.
__author__ = """\n""".join(['Jordi Torrents <jtorrents@milnou.net>',
                            'Dan Schult (dschult@colgate.edu)',
                            'Aric Hagberg (hagberg@lanl.gov)'])

def approximation_k_components(G, max_k=None):
    # Compute only until max k
    if max_k is None:
        max_k = float('infinity')
    # Dictionary with connectivity level (k) as keys and a list of
    # sets of nodes that form a k-component as values
    k_components = {}
    # Dictionary with nodes as keys and maximum k of the deepest 
    # k-component in which they are embedded
    k_number = dict(((n,0) for n in G.nodes()))
    # We deal first with k = 1
    k_components[1] = []
    for cc in networkx.connected_components(G):
        for node in cc:
            k_number[node] = 1
        if len(cc) > 2:
            k_components[1].append(set(cc))
    # Start from k_cores: all k-components are also k-cores
    # but not all k-cores are k-components
    core_number = networkx.core_number(G)
    for k in range(2, min(max(core_number.values())+1, max_k + 1)):
        k_components[k] = []
        # Build k-core subgraph
        C = G.subgraph((n for n, cnum in core_number.items() if cnum >= k))
        for candidates in networkx.connected_components(C):
            # Compute pairwise vertex connectivity for each connected part
            # of this k-core using White and Newman (2001) algorithm and build 
            # the complement graph of a graph where two nodes are linked if 
            # they have at least k node independent paths between them.
            SG = G.subgraph(candidates)
            H = networkx.Graph()
            for u,v in itertools.combinations(SG, 2):
                K = pairwise_vertex_connectivity(SG, u, v, max_paths=k, 
                                                    strict=True)
                if K < k or math.isnan(K):
                    H.add_edge(u,v)
            # Compute complement k-core (anticore) of H and assume that the 
            # core of level k is a good approximation for a component of level k
            acore_number = anticore_number(H)
            A = H.subgraph((n for n, cnum in acore_number.items() if cnum >= k))
            for k_component in networkx.connected_components(A):
                if len(k_component) >= k:
                    k_components[k].append(set(k_component))
                    for node in k_component:
                        k_number[node] = k
    
    return k_components, k_number


# Dense version of the algorithm (it was the first implementation)
def approximation_k_components_dense(G, max_k=None):
    # Compute only until max k
    if max_k is None:
        max_k = float('infinity')
    # Dictionary with connectivity level (k) as keys and a list of
    # sets of nodes that form a k-component as values
    k_components = {}
    # Dictionary with nodes as keys and maximum k of the deepest 
    # k-component in which they are embedded
    k_number = dict(((n,0) for n in G.nodes()))
    # We deal first with k = 1
    k_components[1] = []
    for cc in networkx.connected_components(G):
        for node in cc:
            k_number[node] = 1
        if len(cc) > 2:
            k_components[1].append(set(cc))
    # Start from k_cores: all k-components are also k-cores
    # but not all k-cores are k-components
    core_number = networkx.core_number(G)
    for k in range(2, min(max(core_number.values())+1, max_k + 1)):
        k_components[k] = []
        # Build k-core subgraph
        C = G.subgraph((n for n, cnum in core_number.items() if cnum >= k))
        for candidates in networkx.connected_components(C):
            # Compute pairwise vertex connectivity for each connected part
            # of this k-core using White and Newman 2001 algorithm.
            K = all_pairs_vertex_connectivity(G.subgraph(candidates), 
                                                    max_paths=k,
                                                    strict=True)
            # Build a graph where two nodes are linked if they have at least k
            # node independent paths between them. Suggested in 
            # White & Newman, 2001 (This is a very dense graph, almost complete 
            # in many cases)
            H = networkx.Graph()
            # Too slow because we add every edge twice
            #H.add_edges_from(((u,v) for u in K \
            #                    for (v,w) in K[u].iteritems() if w >= k))
            seen = set()
            for u, nbrs in K.items():
                for v, ni_paths in nbrs.iteritems():
                    if v not in seen and ni_paths >= k:
                        H.add_edge(u,v)
                seen.add(u)
            # Compute k-core of H and assume that the core of level k is a good
            # approximation for a component of level k
            core_number_2 = networkx.core_number(H)
            C2 = H.subgraph((n for n, cnum in core_number_2.items() if cnum >= k))
            for k_component in networkx.connected_components(C2):
                if len(k_component) >= k:
                    k_components[k].append(set(k_component))
                    for node in k_component:
                        k_number[node] = k
    
    return k_components, k_number

##
## Functions to test approximation accuracy. We use igraph to compute bicomponents
## 

def networkx_to_igraph(G, directed=False):
    nodes = dict(G.nodes(data=True))
    graph = igraph.Graph(len(nodes), directed=directed)
    ids = dict(zip(nodes.keys(),range(len(nodes))))
    rids = dict((v, k) for k, v in ids.items())
    for vertex in graph.vs:
        node = rids[vertex.index]
        for k, v in nodes[node].items():
            vertex[k] = v
        vertex['id'] = node
    for i, (source, target, data) in enumerate(G.edges(data=True)):
        graph.add_edges((ids[source], ids[target]))
        for k, v in data.items():
            graph.es[i][k] = v
    return graph

def check_bicomponent(G, result):
    gbc = networkx_to_igraph(G).biconnected_components().giant()
    bnodes = set([v['id'] for v in gbc.vs])
    if 2 not in result or not result[2]:
        print('Error: no bicomponent detected for %s'%G.name)
        print
    elif bnodes == result[2][0]:
        print('%s correctly detected bicomponent'%G.name)
        print('%d nodes in the bicomponent'%(len(bnodes)))
        print
    else:
        print('Error in bicomponent:')
        print('%d actual; %d estimated'%(len(bnodes),len(result[2][0])))
        print('%d nodes correct; %d nodes incorrect'%(\
                            len([v for v in result[2][0] if v in bnodes]),
                            len([v for v in result[2][0] if v not in bnodes])))
        print

if __name__ == '__main__':
    import time
    try:
        import igraph
    except ImportError:
        # it would be nice to implement biconnected_components in NetworkX
        # it is in my TODO list
        raise Exception('Unable to import igraph (used only to test accuracy)')
    Gnp = networkx.gnp_random_graph(100, 0.03)
    Gba = networkx.barabasi_albert_graph(100, 2)
    Gpc = networkx.powerlaw_cluster_graph(100, 2, 0.1)
    constructor=[(20,40,0.8),(80,140,0.6)]
    Gshell = networkx.random_shell_graph(constructor)
    Gshell.name = 'Shell graph'
    deg_seq = networkx.create_degree_sequence(100, networkx.utils.powerlaw_sequence)
    Gconf = networkx.Graph(networkx.configuration_model(deg_seq))
    Gconf.remove_edges_from(Gconf.selfloop_edges())
    Gconf.name = 'Conf model'
    Gdeb_2m = networkx.read_adjlist('test_2m.adj') # file in ticket #589
    Gdeb_2m.name = "Debian 2-mode"
    Gdeb_1m = networkx.read_adjlist('test_1m.adj') # file in ticket #589
    Gdeb_1m.name = "Debian 1-mode"
    graph_list = [Gnp, Gba, Gpc, Gshell, Gconf, Gdeb_1m, Gdeb_2m]
    for G in graph_list:
        print("Testing with %s"%G.name)
        print(networkx.info(G))
        print('Running analysis ...')
        print
        print("New version using the complement graph in step 3")
        start = time.time()
        result, _ = approximation_k_components(G, max_k=2)
        print("Approximation (computed only up to 2-component): %.3f secs"%(time.time()-start))
        print('Testing results')
        check_bicomponent(G, result)
        print("Version using dense graph in step 3")
        start = time.time()
        result, _ = approximation_k_components_dense(G, max_k=2)
        print("Approximation (computed only up to 2-component): %.3f secs"%(time.time()-start))
        print('Testing results')
        check_bicomponent(G, result)
        print

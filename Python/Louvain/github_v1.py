# 测试: 大小样本都通过; 不支持分辨率
# https://github.com/tzyl/louvain-communities
# 貌似 delta Q 公式差别很大 delta_Q = 2 * k_i_in - sigma_tot * k_i / m

import time

class CommunityTracker:
    """Class to keep track of network statistics of the network as the
    algorithm progresses and nodes move communities.
    """

    def __init__(self):
        self.node_to_community_map = None
        self.m = 0.0
        self.degrees = None
        self.self_loops = None
        self.community_degrees = None
        self.community_self_loops = None

    def initialize_network_statistics(self, G):
        self.node_to_community_map = {}
        self.m = G.size(weight="weight")
        self.degrees = {}
        self.self_loops = {}
        # Sum of the weights of the edges incident to nodes in C.
        self.community_degrees = {}
        # Sum of the weights of the internal edges in C.
        self.community_self_loops = {}
        # Initialize all nodes in separate communities.
        for community, node in enumerate(G):
            self.node_to_community_map[node] = community
            degree = G.degree(node, weight="weight")
            self.degrees[node] = self.community_degrees[community] = degree
            self_loop = 0
            if G.has_edge(node, node):
                self_loop = G[node][node].get("weight", 1)
            self.community_self_loops[community] = self.self_loops[node] = self_loop

    def remove(self, node, community, incident_weight):
        """Removes node from community and updates statistics given the
        incident weight of edges from node to other nodes in community.
        """
        self.community_degrees[community] -= self.degrees[node]
        self.community_self_loops[community] -= incident_weight + self.self_loops[node]
        self.node_to_community_map[node] = None

    def insert(self, node, community, incident_weight):
        """Inserts isolated node into community and updates statistics given
        the incident weight of edges from node to other nodes in community.
        """
        self.community_degrees[community] += self.degrees[node]
        self.community_self_loops[community] += incident_weight + self.self_loops[node]
        self.node_to_community_map[node] = community


from itertools import product


def modularity(G, partition):
    """Returns the modularity of the partition of an undirected graph G.
    Definition as given in:
        M. E. J. Newman. Networks: An Introduction, page 224.
    Oxford University Press, 2011.
    """
    m = G.size(weight="weight")
    degrees = dict(G.degree(weight="weight"))
    Q = 0
    for community in partition:
        for u, v in product(community, repeat=2):
            try:
                w = G[u][v].get("weight", 1)
            except KeyError:
                w = 0
            if u == v:
                # Double count self-loop weight.
                w *= 2
            Q += w - degrees[u] * degrees[v] / (2 * m)
    return Q / (2 * m)


import networkx as nx

from collections import defaultdict
import random


class Louvain:

    def __init__(self, G, verbose=False, randomized=False):
        # SETTINGS
        self.verbose = verbose
        self.randomized = randomized
        # Create helper to track network statistics.
        # We use the coarse_grain_graph in the iterations.
        self.tracker = CommunityTracker()
        self.original_graph = G
        self.coarse_grain_graph = G
        # self.community_history keeps track of the community maps
        # from each iteration.
        self.community_history = []
        self.iteration_count = 0
        self.finished = False
        # Final community map and list of communities created at end.
        self.community_map = None
        self.communities = None

    def run(self):
        """Runs the iterations of the Louvain method until finished then
        generates the final community map.
        """
        while not self.finished:
            self.iterate()
        if self.verbose:
            print("Finished in {} iterations".format(self.iteration_count))
        self.community_map = self.generate_community_map(
            self.community_history)
        self.communities = self.invert_community_map(self.community_map)

    def iterate(self):
        """Performs one iteration of the Louvain method on the current graph G.
        For each node we move it to a neighbouring community which causes the
        greatest increase in modularity (if there is no such positive change we
        leave it where it is). We continue this until no more moves can be done
        so we have reached a local modularity optimum.
        We then create a new coarse grained graph where each node represents a
        community for the next iteration.
        """
        self.iteration_count += 1
        if self.verbose:
            print("Iteration: ", self.iteration_count)
        # modified if we have made at least one change overall.
        # improved if we have made at least one change in the current pass.
        modified = False
        improved = True
        G = self.coarse_grain_graph
        self.tracker.initialize_network_statistics(G)
        community_map = self.tracker.node_to_community_map

        while improved:
            improved = False

            nodes = G.nodes()
            if self.randomized:
                nodes = list(G.nodes())
                random.seed()
                random.shuffle(nodes)

            for node in nodes:
                best_delta_Q = 0.0
                old_community = community_map[node]
                new_community = old_community
                neighbour_communities = self.get_neighbour_communities(
                    G, node, community_map)
                # Isolate the current node and find the best neighbouring
                # community (including checking the original).
                old_incident_weight = neighbour_communities.get(
                    old_community, 0)
                self.tracker.remove(node, old_community, old_incident_weight)
                for community, incident_wt in neighbour_communities.items():
                    delta_Q = self.calculate_delta_Q(
                        G, node, community, incident_wt)
                    if delta_Q > best_delta_Q:
                        best_delta_Q = delta_Q
                        new_community = community

                # Move to the best community and check if we actually improved.
                new_incident_weight = neighbour_communities[new_community]
                self.tracker.insert(node, new_community, new_incident_weight)
                if self.verbose:
                    message = "Moved node {} from community {} to community {}"
                    print(message.format(node, old_community, new_community))

                if new_community != old_community:
                    improved = True
                    modified = True

        if modified:
            self.relabel_community_map(community_map)
            self.community_history.append(community_map)
            self.coarse_grain_graph = self.generate_coarse_grain_graph(
                G, community_map)
        else:
            # We didn't modify any nodes so we are finished.
            self.finished = True

    def get_neighbour_communities(self, G, node, community_map):
        """Returns a dictionary with the neighbouring communities as keys and
        incident edge weights between node and the community as values.
        """
        neighbour_communities = defaultdict(int)
        for neighbour in G[node]:
            if neighbour != node:
                neighbour_community = community_map[neighbour]
                w = G[node][neighbour].get("weight", 1)
                neighbour_communities[neighbour_community] += w
        return neighbour_communities

    def calculate_delta_Q(self, G, node, community, incident_weight):
        """Calculate change in modularity from adding isolated node to
        community."""
        # Sum of the weights of the links incident to nodes in C.
        sigma_tot = self.tracker.community_degrees[community]
        # Sum of the weights of the links incident to node i.
        k_i = self.tracker.degrees[node]
        # Sum of the weights of the links from i to nodes in C.
        k_i_in = incident_weight
        # Sum of the weights of all the links in the network.
        m = self.tracker.m

        delta_Q = 2 * k_i_in - sigma_tot * k_i / m
        return delta_Q

    def generate_coarse_grain_graph(self, G, community_map):
        """Generates new coarse grain graph with each community as a single
        node.
        Weights between nodes are the sum of all weights between respective
        communities and self loops are added for the weights of he internal
        edges.
        """
        new_graph = nx.Graph()
        # Create nodes for each community.
        for community in set(community_map.values()):
            new_graph.add_node(community)
        # Create the combined edges from the individual old edges.

        # debug: https://www.codeleading.com/article/60802402906/
        #for u, v, w in G.edges_iter(data="weight", default=1):
        for u, v, w in G.edges(data="weight", default=1):
            c1 = community_map[u]
            c2 = community_map[v]
            new_weight = w
            if new_graph.has_edge(c1, c2):
                new_weight += new_graph[c1][c2].get("weight", 1)
            new_graph.add_edge(c1, c2, weight=new_weight)
        return new_graph

    def relabel_community_map(self, community_map):
        """Relabels communities to be from 0 to n."""
        community_labels = set(community_map.values())
        relabelled_communities = {j: i for i, j in enumerate(community_labels)}
        for node in community_map:
            community_map[node] = relabelled_communities[community_map[node]]

    def invert_community_map(self, community_map):
        """Inverts a community map from nodes to communities to a list of
        lists of nodes where each list of nodes represents one community.
        """
        inverted_community_map = defaultdict(list)
        for node in community_map:
            inverted_community_map[community_map[node]].append(node)
        return list(inverted_community_map.values())

    def generate_community_map(self, community_history):
        """Builds the final community map using the history of iterations."""
        community_map = {node: node for node in self.original_graph}
        for node in community_map:
            for iteration in community_history:
                # Follow iterations to find final community of node.
                community_map[node] = iteration[community_map[node]]
        return community_map


def detect_communities(G, verbose=False, randomized=False):
    """Returns the detected communities as a list of lists of nodes
    representing each community.
    Uses the Louvain heuristic from:
        Blondel, V.D. et al. Fast unfolding of communities in
    large networks. J. Stat. Mech 10008, 1 - 12(2008).
    """
    louvain = Louvain(G, verbose=verbose, randomized=randomized)
    louvain.run()
    return louvain.communities


import networkx as nx
#from louvain import detect_communities

# 这个包的输入要求顶点列表、边列表。
def load_graph(path):
    nodes=set()
    edges=[]
    with open(path) as text:
        for line in text:
            vertices = line.strip().split() #去掉换行符，按空格切分
            v_i = int(vertices[0])
            v_j = int(vertices[1])
            w = 1.0
            # 数据集有权重的话则读取数据集中的权重
            if len(vertices) > 2:
                w = float(vertices[2])
            nodes.add(v_i)
            nodes.add(v_j)
            # weighted edge
            edges.append([v_i,v_j, w])
    return nodes,edges


if __name__ == '__main__':
    nodes,edges=load_graph("data/OpenFlights.txt")
    #nodes,edges=load_graph("backup/snn_df.txt")

    # prepare the input of Louvain py
    G=nx.Graph()
    G.add_nodes_from( list(nodes) )
    #G.add_edges_from( edges )
    G.add_weighted_edges_from( edges )

    start_time = time.time()
    partition = detect_communities(G, randomized=False)
    end_time = time.time()

    # 按照社区大小从大到小排序输出
    communities = sorted(partition, key=lambda b: -len(b))  # 按社区大小排序
    count = 0
    for communitie in communities:
        count += 1
        if count>10:
            break;
        print("Community", count, ":", communitie)
    print("====>>>>Total clusters:", len(communities))

    # 输出到文件: 顶点id 社区id
    cid=-1;
    output_file="backup/result.txt"
    fw=open(output_file, "w")
    for arr in communities:
        cid+=1;
        for v in arr:
            fw.write(f"{v}\t{cid}"+"\n")
    fw.close()
    print("output_file:", output_file)

    print(f'Exec time: { round(end_time - start_time, 2)} seconds')
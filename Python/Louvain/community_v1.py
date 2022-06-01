import time
import community
import networkx as nx

# https://github.com/taynaud/python-louvain

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

#data,edges=load_graph("data/OpenFlights.txt")
nodes,edges=load_graph("backup/snn_df.txt")
#print(list(data.keys()))
#print(edges)

# prepare the input of Louvain py
G=nx.Graph()
G.add_nodes_from( list(nodes) )
#G.add_edges_from( edges )
G.add_weighted_edges_from( edges )

# begin community detection
start_time = time.time()
partition=community.best_partition(G, resolution=0.7)
end_time = time.time()
#print("partition:", partition)


# save to file: 顶点id 社区id
output_file="backup/result.txt";
fw=open(output_file, "w")
for k,v in partition.items():
	fw.write(f"{k}\t{v}"+"\n")
fw.close()

print( set( partition.values() ) )

print("saved to file:", output_file)
print(f'Exec time: { round(end_time - start_time, 2)} seconds')
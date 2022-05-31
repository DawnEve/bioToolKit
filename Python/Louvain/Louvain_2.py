# aim: 注释 phaseI
import collections
import random
import time


# 载入文件: 前两列是数字（顶点编号），中间用空格隔开。
# 第三列可选，是权重，默认是1。
def load_graph(path):
    G = collections.defaultdict(dict)
    with open(path) as text:
        for line in text:
            vertices = line.strip().split() #去掉换行符，按空格切分
            v_i = int(vertices[0])
            v_j = int(vertices[1])
            w = 1.0
            # 数据集有权重的话则读取数据集中的权重
            if len(vertices) > 2:
                w = float(vertices[2])
            G[v_i][v_j] = w
            G[v_j][v_i] = w
    return G



# 节点类 存储社区与节点编号信息
class Vertex:
    def __init__(self, vid, cid, nodes, k_in=0):
        # 节点编号
        self._vid = vid
        # 社区编号
        self._cid = cid
        self._nodes = nodes
        self._kin = k_in  # 结点内部的边的权重
    def __str__(self):
        return f"class Vertex:[vid:{self._vid},cid:{self._cid}, nodes:{self._nodes}, kin:{self._kin}]"
    __repr__ = __str__

class Louvain:
    def __init__(self, G):
        self._G = G
        self._m = 0  # 边数量 图会凝聚动态变化
        self._cid_vertices = {}  # 需维护的关于社区的信息(社区编号,其中包含的结点编号的集合)
        self._vid_vertex = {}  # 需维护的关于结点的信息(结点编号，相应的Vertex实例)
        # 遍历每个顶点
        for vid in self._G.keys():
            # 刚开始每个点作为一个社区
            self._cid_vertices[vid] = {vid}
            # 刚开始社区编号就是节点编号
            self._vid_vertex[vid] = Vertex(vid, vid, {vid})
            # 计算边数  每两个点维护一条边
            # 和该点连接的顶点中，比该序号大的点的边数。为了保证只计算一次。
            self._m += sum([1 for neighbor in self._G[vid].keys() if neighbor > vid])

    # 模块度优化阶段
    def first_stage(self):
        mod_inc = False  # 用于判断算法是否可终止

        # 这样写不会随机化
        #visit_sequence = self._G.keys() #所有顶点
        #random.shuffle(list(visit_sequence)) # 随机访问

        # 先list才能随机化
        visit_sequence = list(self._G.keys()) #所有顶点
        # random.shuffle(visit_sequence) # 随机访问 ========================> //todo 为了调试方便，先不打乱了。
        print(">>> visit_sequence in PhaseI:", visit_sequence)
        print("G:", self._G)
        n_times=0; #phageI 迭代次数

        while True:
            n_times+=1;
            print(f"0=> phaseI iter:{n_times} (max:10)" )
            if n_times>10: #如果大型网络不收敛，则超过规定次数自动停止
                break;

            can_stop = True  # 第一阶段是否可终止
            # 遍历所有节点
            for v_vid in visit_sequence:
                # 获得节点的社区编号
                v_cid = self._vid_vertex[v_vid]._cid
                # k_v节点的权重(度数): 外部边权重之和 + 内部边权重(第一轮没有内部边，为0)
                k_v = sum(self._G[v_vid].values()) + self._vid_vertex[v_vid]._kin
                # 存储模块度增益大于0的社区编号
                cid_Q = {}
                # 遍历节点的邻居节点
                for w_vid in self._G[v_vid].keys():
                    # 获得该邻居的社区编号
                    w_cid = self._vid_vertex[w_vid]._cid
                    if w_cid in cid_Q:
                        continue
                    else:
                        # tot是关联到社区C中的节点的链路上的权重的总和
                        # k 是 该邻居节点(w_vid)所在社区(w_cid)的内部点的编号
                        #   k 点 外部权重和 + k点内部权重
                        tot = sum(
                            [ sum(self._G[k].values()) + self._vid_vertex[k]._kin  for k in self._cid_vertices[w_cid]])
                        # 如果该邻居的 社区编号 w_cid 和 顶点的社区编号 v_cid 一致，减去 该顶点的权重
                        # 不是应该跳过吗？ //todo
                        if w_cid == v_cid:
                            #print("1==>", v_cid, w_cid, tot, k_v)
                            tot -= k_v
                        # k_v_in是从节点i连接到C中的节点的链路的总和
                        k_v_in = sum([v for k, v in self._G[v_vid].items() if k in self._cid_vertices[w_cid]])
                        delta_Q = k_v_in - k_v * tot / self._m  # 由于只需要知道delta_Q的正负，所以少乘了1/(2*self._m)
                        # print("==>", v_cid, w_cid, delta_Q)
                        cid_Q[w_cid] = delta_Q
                        #print("2====>", v_cid, w_cid, "cid_Q=",cid_Q)

                # 取得最大增益的编号
                cid, max_delta_Q = sorted(cid_Q.items(), key=lambda item: item[1], reverse=True)[0]

                #需要好几个循环才能调整到 deltaQ<=0
                #print("\t3====>","v_vid=",v_vid,  "v_cid=",v_cid, "cid=", cid, "max_delta_Q=",max_delta_Q) 
                
                # 如果 deltaQ>0 且 该点的调整后 communiti id 变了，则调整且 社区编号
                if max_delta_Q > 0.0 and cid != v_cid:
                    #print("\t4=====>")
                    # 让该节点的社区编号变为取得最大增益邻居节点的编号
                    self._vid_vertex[v_vid]._cid = cid
                    # 在该社区编号下添加该节点
                    self._cid_vertices[cid].add(v_vid)
                    # 以前的社区中去除该节点
                    self._cid_vertices[v_cid].remove(v_vid)
                    
                    # 模块度还能增加 继续迭代  ======================================>//todo#这里是否可以添加分辨率？
                    can_stop = False #只有有一个点的社区号调整过，这里就是F，就可以下一轮循环。
                    
                    mod_inc = True
            if can_stop: #while 死循环什么时候结束？对每个点遍历，没有可以调整标签的点时，结束 PhaseI.
                print("-- break PhaseI --")
                break
        print("status after phaseI:")
        print("\t {cid: vid arr}::", [item for item in self._cid_vertices.items() if len(item[1])>0])
        print("\t {vid: vertex object}::", self._vid_vertex)
        return mod_inc

    # 网络凝聚阶段: 每个社区 合并为 超级节点
    def second_stage(self):
        cid_vertices = {}
        vid_vertex = {}

        # 遍历社区和社区内的节点
        for cid, vertices in self._cid_vertices.items():
            if len(vertices) == 0:
                continue
            new_vertex = Vertex(cid, cid, set())
            # 将该社区内的所有点看做一个点
            for vid in vertices:
                new_vertex._nodes.update(self._vid_vertex[vid]._nodes)
                new_vertex._kin += self._vid_vertex[vid]._kin
                # k,v为邻居和它们之间边的权重 计算kin社区内部总权重 这里遍历vid的每一个在社区内的邻居   因为边被两点共享后面还会计算  所以权重/2
                for k, v in self._G[vid].items():
                    if k in vertices:
                        new_vertex._kin += v / 2.0
            # 新的社区与节点编号
            cid_vertices[cid] = {cid}
            vid_vertex[cid] = new_vertex

        G = collections.defaultdict(dict)
        # 遍历现在不为空的社区编号 求社区之间边的权重
        for cid1, vertices1 in self._cid_vertices.items():
            if len(vertices1) == 0:
                continue
            for cid2, vertices2 in self._cid_vertices.items():
                # 找到cid后另一个不为空的社区
                if cid2 <= cid1 or len(vertices2) == 0:
                    continue
                edge_weight = 0.0
                # 遍历 cid1社区中的点
                for vid in vertices1:
                    # 遍历该点在社区2的邻居已经之间边的权重(即两个社区之间边的总权重  将多条边看做一条边)
                    for k, v in self._G[vid].items():
                        if k in vertices2:
                            edge_weight += v
                if edge_weight != 0:
                    G[cid1][cid2] = edge_weight
                    G[cid2][cid1] = edge_weight
        # 更新社区和点 每个社区看做一个点
        self._cid_vertices = cid_vertices
        self._vid_vertex = vid_vertex
        self._G = G

    def get_communities(self):
        communities = []
        for vertices in self._cid_vertices.values():
            if len(vertices) != 0:
                c = set()
                for vid in vertices:
                    c.update(self._vid_vertex[vid]._nodes)
                communities.append(list(c))
        return communities

    def execute(self):
        iter_time = 0
        while True:
            iter_time += 1
            print(">>> iter_time:", iter_time)
            # 反复迭代，直到网络中任何节点的移动都不能再改善总的 modularity 值为止
            mod_inc = self.first_stage()
            if mod_inc:
                self.second_stage()
            else:
                break
        return self.get_communities()



if __name__ == '__main__':    
    # G = load_graph('data/club.txt')
    input_filename='data/OpenFlights.txt'
    G = load_graph(input_filename)
    
    # 开始检查社群    
    start_time = time.time()
    algorithm = Louvain(G)
    communities = algorithm.execute()
    end_time = time.time()
    # 按照社区大小从大到小排序输出
    communities = sorted(communities, key=lambda b: -len(b))  # 按社区大小排序
    count = 0
    for communitie in communities:
        count += 1
        print("Community", count, ":", communitie)
    
    print(f'Exec time: { round(end_time - start_time, 2)} seconds')

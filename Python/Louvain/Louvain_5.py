# Aim: 测试 10x 数据: 输入SNN稀疏矩阵，输出2列，和 Seurat 结果作比较。 每个cell一类，失败。
#  修订版 v2.0, pbmc 3k 数据集可用，虽然不好；但是 10 点小数据集不行;
# v2.1 继续修改，看 delta Q 公式是否正确： 大小数据都ok; 不支持分辨率;(没有考虑deltaQ(D->i))
import collections
import random
import time


# Settings
MAX_PHASE_I=10
MAX_PASSS=10
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
            # 一行是 1 2 则读入时 2个方向都读入了，分别是 1:{2:1} 和 2:{1:1} 
            G[v_i][v_j] = w
            G[v_j][v_i] = w
    print(">> total edges:", len(G))
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
    # 方便打印顶点类
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
            # 这里是不是应该考虑 权重？
            #self._m += sum([1 for neighbor in self._G[vid].keys() if neighbor > vid])
            self._m += sum([value for neighbor,value in self._G[vid].items() if neighbor > vid])
        print("====> m:", self._m)

    # phaseI 模块度优化阶段
    def first_stage(self):
        mod_inc = False  # 用于判断算法是否可终止

        # 这样写不会随机化
        #visit_sequence = self._G.keys() #所有顶点
        #random.shuffle(list(visit_sequence)) # 随机访问

        # 先list才能随机化
        visit_sequence = list(self._G.keys()) #所有顶点
        random.shuffle(visit_sequence) # 随机访问 ========================> //todo 为了固定，调试时先不打乱
        #print(">>> visit_sequence in PhaseI:", visit_sequence)
        #print("G:", self._G)
        iter_times_phaseI=0; #phageI 迭代次数

        while True:
            # 监视最大 deltaQ 值
            log_max_deltaQ=0

            iter_times_phaseI+=1;
            # 当前 cluster 总数
            cluster_num = len([k for k,v in self._cid_vertices.items() if len(v)>0])
            print(f"0=> phaseI iter:{iter_times_phaseI} (max:{MAX_PHASE_I}) | cluster_num:{cluster_num}" )

            can_stop = True  # 第一阶段是否可终止

            
            # 遍历所有节点v
            for v_vid in visit_sequence:
                

                # 获得节点的社区编号
                v_cid = self._vid_vertex[v_vid]._cid
                # k_v节点的权重(度数): 外部边权重之和 + 内部边权重(第一轮没有内部边，为0)
                k_v = sum(self._G[v_vid].values()) + self._vid_vertex[v_vid]._kin
                
                # 存储模块度增益大于0的社区编号
                cid_Q = {}
                # 遍历节点的邻居节点w
                for w_vid in self._G[v_vid].keys():
                    # 获得该邻居的社区编号
                    w_cid = self._vid_vertex[w_vid]._cid
                    # 如果该邻居的 社区编号 w_cid 和 顶点的社区编号 v_cid 一致，应该跳过
                    if w_cid == v_cid:
                        # print("1==>", v_cid, w_cid, tot, k_v)
                        #tot -= k_v
                        continue;
                    # 如果 v 顶点已经加入过 w 所在的社区，则跳过
                    if w_cid in cid_Q:
                        continue
                    else:
                        # 计算 deltaQ = deltaQ(D->i) + deltaQ(i->C)
                        # tot是关联到社区C中的节点的链路上的权重的总和
                        # k 是 该邻居节点(w_vid)所在社区(w_cid)的内部点的编号
                        #   k 点 外部权重和 + k点内部权重
                        tot = sum(
                            [ sum(self._G[k].values()) + self._vid_vertex[k]._kin  for k in self._cid_vertices[w_cid]] )
                        
                        # k_v_in是从节点i连接到C中的节点的链路的总和
                        k_v_in = sum([v for k, v in self._G[v_vid].items() if k in self._cid_vertices[w_cid]])
                        delta_Q1 = k_v_in - k_v * tot / self._m  # 由于只需要知道delta_Q的正负，所以少乘了1/(2*self._m)
                        # above is deltaQ(i->C)



                        # below is deltaQ(D->i)
                        # 这一部分公式是不是推导错了？ //todo
                        k_v_in2=sum([v for k, v in self._G[v_vid].items() if k in self._cid_vertices[v_cid]])
                        tot2 = sum(
                            [ sum(self._G[k].values()) + self._vid_vertex[k]._kin  for k in self._cid_vertices[v_cid]] )
                        delta_Q2 = -k_v_in2 - (k_v*k_v - 2*k_v*tot2)/ (2*self._m)



                        # add the 2 deltas.
                        delta_Q = delta_Q1 #+ delta_Q2 #加上 delta_Q2 后结果不稳定
                        
                        #delta_Q = 2 * k_v_in - tot * k_v / self._m
                        #print(f"============>{round(delta_Q1,3)}+{round(delta_Q2,3)}={round(delta_Q,3)}")
                        #print("==>", v_cid, w_cid, delta_Q)
                        cid_Q[w_cid] = delta_Q
                        #print("2====>", v_cid, w_cid, "cid_Q=",cid_Q)

                # 如果没有可以调整的社区编号，则跳出循环。
                if len(cid_Q)==0:
                    #print("len(cid_Q)==0")
                    cid, max_delta_Q=0,-1
                else:
                    # 取得最大增益的编号
                    cid, max_delta_Q = sorted(cid_Q.items(), key=lambda item: item[1], reverse=True)[0]
                
                if log_max_deltaQ<= max_delta_Q:
                    log_max_deltaQ = max_delta_Q
                else:
                    #print(max_delta_Q)
                    pass


                #需要好几个循环才能调整到 deltaQ<=0
                #print("\t3====>","v_vid=",v_vid,  "v_cid=",v_cid, "cid=", cid, "max_delta_Q=",max_delta_Q) 
                
                # 如果 deltaQ>0 且 该点的调整后 communiti id 变了，则调整该 社区编号
                if max_delta_Q > 0.0 and cid != v_cid:
                    #print("\t4=====>")
                    # 让该节点的社区编号变为取得最大增益邻居节点的编号
                    self._vid_vertex[v_vid]._cid = cid
                    # 在该社区编号下添加该节点
                    self._cid_vertices[cid].add(v_vid)
                    # 以前的社区中去除该节点
                    self._cid_vertices[v_cid].remove(v_vid)
                    
                    # 模块度还能增加 继续迭代  ======================================>//todo#这里是否可以添加分辨率？
                    can_stop = False #只要有一个点的社区号调整过，这里就是F，就可以下一轮循环。
                    
                    mod_inc = True

            if iter_times_phaseI >= MAX_PHASE_I: #如果大型网络不收敛，则超过规定次数自动停止
                can_stop=True;
            if can_stop: #while 死循环什么时候结束？对每个点遍历，没有可以调整标签的点时，结束 PhaseI.
                #print("-- break PhaseI -- | mod_inc:",mod_inc)
                break
            print(f"\tmax_dleta_Q:{log_max_deltaQ}")

        #print("status after phaseI:")
        #print("\t {cid: vid arr}::", [item for item in self._cid_vertices.items() if len(item[1])>0])
        #print("\t {vid: vertex object}::", self._vid_vertex)

        return mod_inc #只要在所有的 while 中，又一次调整，返回值就是T。一个都不调整，则返回F。




    # phase II 网络凝聚阶段: 每个社区 合并为 超级节点
    def second_stage(self):
        print("== Phase II begin ==")
        cid_vertices = {}
        vid_vertex = {}

        # 遍历社区和社区内的节点
        for cid, vertices in self._cid_vertices.items():
            # 如果该 社区 没有节点，则跳过
            if len(vertices) == 0:
                continue
            # 新节点：顶点编号 cid, 社区编号 cid，其中的 nodes 先空集，内部权重 默认0
            new_vertex = Vertex(cid, cid, set())

            # 将该社区内的所有点看做一个点
            for vid in vertices:  # 遍历 社区内的每个顶点 v
                new_vertex._nodes.update(self._vid_vertex[vid]._nodes) #节点编号 加进来。
                new_vertex._kin += self._vid_vertex[vid]._kin
                # k,v为邻居和它们之间边的权重 计算kin社区内部总权重 这里遍历vid的每一个在社区内的邻居   
                #   因为边被两点共享后面还会计算  所以权重/2
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

        print("=====> cluster:", len(self._G))



    # 获取社区构成，就是 cid_vertices 中的键值对们的值: {社区编号: [节点编号arr]}
    def get_communities(self):
        communities = []
        # 键值对的value是 节点编号arr
        for vertices in self._cid_vertices.values():
            if len(vertices) != 0:
                c = set()
                for vid in vertices:
                    c.update(self._vid_vertex[vid]._nodes)
                communities.append(list(c))
        #print("communities:", communities)
        return communities


    # 执行函数
    def execute(self):
        iter_time = 0 #pass 次数，一个 pass 包括2个 phase.
        while True:
            iter_time += 1
            if iter_time>10:
                break;
            print(F"\n>>>Pass iter_time:{iter_time} (max:{MAX_PASSS})")
            # 反复迭代，直到网络中任何节点的移动都不能再改善总的 modularity 值为止
            mod_inc = self.first_stage()

            if mod_inc:
                self.second_stage()
            else: # 什么时候整个优化过程结束呢？ mod_inc=F时，就是整个 phaseI  没有调整一个社区标签。
                print("-------Stop Phase II-----")
                break
        return self.get_communities()



if __name__ == '__main__':    
    # G = load_graph('data/club.txt')
    input_file='data/OpenFlights.txt'
    #input_file='data/t3.txt'

    # input SNN_sparse_pbmc3k
    input_file='data/snn_df.txt'
    G = load_graph(input_file)
    
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

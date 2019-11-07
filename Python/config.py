#v0.2

import pymysql
db = pymysql.connect(host='y.biomooc.com',port=7070,user='root', password='123456', database='wang',charset='utf8')


#插入语句，返回插入id，如果失败，返回None
#v0.2
#sql='insert into cell_c1(cid) values("'+cid+'");'
#print('rs=',insert(sql))
def insert(sql):
    #2. 使用cursor()方法获取操作游标 
    cursor = db.cursor()

    #3. SQL 语句
    #sql = "select * from goods;"
    # 执行sql语句
    try:
        rs=cursor.execute(sql) #成功了总是1
        # 最后插入行的主键id
        #print('cursor.lastrowid=', cursor.lastrowid) #10
        rs= cursor.lastrowid

        # 最新插入行的主键id
        #print('db.insert_id()=', db.insert_id()) #10
        db.commit()
        #print('==1 rs=',rs)
        return rs
    except(TypeError, IndexError):
        db.rollback()
        #print('==2 rs=', rs) #None
        print('TypeError=', TypeError, 'IndexError=',IndexError) #None
    finally:
        # 关闭数据库连接
        cursor.close()
        #db.close()
        # (('Mac', 'Mohan', 20, 'M', 2000.0),)
    return False
#

import pymysql
# 单例模式 https://blog.csdn.net/qq_32539403/article/details/83343581
# 方法很好 https://blog.csdn.net/qy20115549/article/details/82972993
# 更多方法 https://www.cnblogs.com/ddjl/p/8670545.html
class DBUtil():
    _db=None
    #在这里配置自己的SQL服务器
    _config = {
        'host':"y.biomooc.com",
        'port':7070,
        'username':"root",
        'password':'123456',
        'database':"wang",
        'charset':"utf8"
    }
    #单例模式
    def __connect(self):
        if(self._db == None):
            try:
                self._db = pymysql.connect(
                    host = self._config['host'],
                    port = self._config['port'],
                    user = self._config['username'],
                    passwd = self._config['password'],
                    db = self._config['database'],
                    charset = self._config['charset']
                )
                self._cur=self._db.cursor()
            except Exception as e:
                print(e)
                raise BaseException("DataBase connect error,please check the db config.")
    #初始化
    def __init__(self):
        self.__connect()
    #结束销毁连接
    def close(self):
        '''结束查询和关闭连接'''
        if self._cur is not None:
            self._cur.close()
        if self._db is not None:
            self._db.close()
    #创建表
    def create_table(self,sql_str):
        '''创建数据表'''
        try:
            self._cur.execute(sql_str)
        except Exception as e:
            print(e)
    #
    def query(self,sql):
        '''查询数据并返回 tuple
             cursor 为连接光标
             sql为查询语句
        '''
        try:
            self._cur.execute(sql)
            rows = self._cur.fetchall()
            return rows
        except Exception as e:
            print(e)
            return False
    #
    def execute(self,sql):
        '''
        插入或更新记录 成功返回最后的id
        '''
        try:
            self._cur.execute(sql) #成功了总是1
            rs= self._cur.lastrowid  # 最新插入行的主键id
            self._db.commit()
            return rs
        except Exception as e:
            print(e)
            self._db.rollback()
        return False
        #
    def executeMany(self,sqlArr): #对比试验显示，这比着单独执行sql语句速度更慢了。可能是保证都执行，就要牺牲性能。
        '''
        更新多个记录，成功返回最后的id
        '''
        try:
            for sql in sqlArr:
                self._cur.execute(sql) #成功了总是1
            rs= self._cur.lastrowid  # 最新插入行的主键id
            self._db.commit()
            return rs
        except Exception as e:
            print(e)
            self._db.rollback()
        return False
    #删除列
    def delCol(self, tableName, colName):
        sql="alter table %s drop %s;"
        rs1=self.execute(sql %(tableName, colName)) #3 如果重复，会报错
        print('删除%s表中的 %s列, rs1=%s' % (tableName, colName, rs1) )
#

















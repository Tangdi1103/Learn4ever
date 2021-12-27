[toc]

## 一、Redis 持久化

![image-20211220234025727](images/image-20211220234025727.png)

- RDB：存储二进制快照，可能丢数据

  ![image-20211220235809271](images/image-20211220235809271.png)

- AOF：存命令

  ![image-20211227153432524](images/image-20211227153432524.png)







## 二、Redis 底层数据结构

Redis 实例对象

RedisObject 对象

底层数据数据结构

- 动态字符串SDS
- 跳跃表skiplist
- hash表
- 快速列表quiklist
  - 压缩列表ziplist
  - 整数集合
- 流对象





## 三、Redis 缓存过期及淘汰策略

maxmemery

删除策略



## 四、Redis 通讯协议及时间处理机制

Redis 请求协议及命令处理流程

Redis 多路复用模式以及实现方式

Redis 时间事件处理机制、文件事件处理机制

![image-20211227153504075](images/image-20211227153504075.png)

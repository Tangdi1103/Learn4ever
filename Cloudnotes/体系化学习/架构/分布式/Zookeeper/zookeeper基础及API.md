[toc]

### zookeeper简介

zookeeper是开源的分布式协调服务，通过共享存储（信息共享）保证分布式系统信息的一致性，实现对分布式系统的协调，基于网络通信。

zookeeper是分布式数据一致性的解决方案

类似于一个项目组中，leader ——上传任务——> SVN ——发送事件——>邮箱——发送邮件——>组员————>从SVN获取任务

zookeeper其实就是一个类文件系统。。。

##### 集群角色

leader：发起投票

follower：提供读服务；参与投票；参与leader选举；

observer：提供读服务

**保证数据一致性**

当follower和observer接收到客户端写请求时，转发给leader，leader发起投票过半写成功策略，follower参与投票，observer不参与。根据投票结果，所有服务器（包括leader、follower和observer）进行写操作

![image-20210808223854368](images/image-20210808223854368.png)

##### 会话

zookeeper服务端的端口为2181，当应用程序依赖了zookeeper，在启动的时候就建立了与zookeeper的TCP连接，这就开始了客户端会话的生命周期。

客户端通过定期心跳检测，保持与zk服务端的TCP连接

##### 数据节点

**具有强一致性**

znode类型：持久、持久顺序、临时、临时顺序

持久节点不随会话结束而消失

临时节点随会话结束而消失

顺序节点后缀由zk自动生成一串序号，所以前缀的名称可以重复

非顺序节点名称不可以重复

##### Watcher（事件监听/通知）

Watcher事件通知机制时zk核心，数据发布/订阅、命名服务、集群管理、Master选择、分布式锁和分布式队列都基于此实现

Watcher数据变更通知，客户端向服务端注册一个Watcher，然后通过回调获得消息

事件通知类型：Event.xxxxxx

##### ACL（访问权限控制）

权限模式：ip、Digest、world、Super

授权对象：ip:xxx.xxx.x.1/24、username:password、world:anyOne（常用）、super

权限、create（针对子节点）、delete（针对子节点）、read（ls2/get）、write（set）、admin



### zookeepe基本使用

##### 启动服务端集群

##### 启动客户端

##### 客户端命令行操作

创建会话建立（TCP连接）、创建节点、删除节点、获取子节点列表、获取节点数据、修改节点数据

create（针对子节点）、delete（针对子节点）、read（ls2/get）、write（set）、admin

##### 客户端原生API操作

创建会话建立（TCP连接）、创建节点、删除节点、获取子节点列表（getChildren）、获取节点数据（getData）、修改节点数据

##### 客户端GitHUb-API操作（推荐）

##### 客户端Curator-API操作

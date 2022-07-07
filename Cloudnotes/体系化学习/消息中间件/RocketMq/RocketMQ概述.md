[toc]

## 一、RocketMQ概述

### 应用场景

#### 1. 异步

将同步操作异步话，提升系统性能。

#### 2. 解耦

系统耦合性越低，容错性就越高。例如电商系统的下单、支付、库存扣减、优惠券扣减、短信发送等操作，一旦哪个系统暂时不可用都会影响整个流程。

#### 3. 削峰

当业务系统遇上流量洪峰，超出了系统的处理能力，可以将请求以消息的形式保存到MQ服务器中，由消费者服务器慢慢的根据自身处理能力来消费。当然消费者可以设置每个批次接受的Message，也可是设置处理的线程数。

#### 4. 分发

通过消息队列可以让数据在多个系统之间进行流通。数据的产生方不需要关心谁来使用数据，只需要将数据发送到消息队列，数据使用方直接在消息队列中直接获取数据即可

#### 5. 分布式事务

[分布式事务](../../架构/分布式架构设计/分布式理论、事务、一致性算法)

 

### 角色及部署架构

#### 1. 角色

- **Producer**：消息的发送者，比喻为发信者
- **Consumer**：消息的接收者，比喻为收信者
- **Broker**：存储及传输者，比喻为邮局
- **NameServer**：Broker、Producer、Consumer的注册及管理中心，记录每个broker状态、有哪些topic、有哪些messagequeue、ip、port。比喻为各邮局的管理机构
- **Topic**：消息主题，区分消息的类型。一个发送者可以发消息给一个或多个Topic；一个接收者可以订阅一个或多个Topic。
- **Message Queue**：Topic分区，用于并行发送、接收消息。**等同于Kafka的 Partition分区**。

#### 2. 部署架构

![image-20220517000814645](images/image-20220517000814645.png)

##### 各节点职责

- NameServer是一个几乎无状态节点，可集群部署，节点之间无任何信息同步。

- Broker部署相对复杂，Broker分为Master与Slave。Master与Slave 的对应**关系通过指定相同的BrokerName，不同的BrokerId来定义**，BrokerId为**0表示Master**，非0表示Slave，**一组BrokerName的Master和Slaver构成一个Broker组**，每个Broker组只有一个Master，一个或多个Slaver。**每个Broker与NameServer集群中的所有节点建立长连接**，定时**注册Topic信息到所有NameServer**。 注意：当前RocketMQ版本在部署架构上支持一Master多Slave，但**只有BrokerId=1的从服务器才会参与消息的读负载**。

- Producer**与NameServer**集群中的其中一个节点（随机选择）**建立长连接**，**定期从NameServer获取Topic路由信息**，并向提供Topic 服务的**Master Broker建立长连接**，且**定时向Master Broker发送心跳**。Producer完全无状态，可集群部署。

- Consumer**与NameServer**集群中的其中一个节点（随机选择）**建立长连接**，**定期从NameServer获取Topic路由信息**，并向提供Topic服务的**Master、Slave建立长连接**，且定时向Master、Slave发送心跳。**Consumer既可以从Master订阅消息，也可以从Slave订阅消息**，消费者在向Master拉取消息时，Master服务器会根据拉取偏移量与最大偏移量的距离（判断是否读老消息，产生读I/O），以及从服务器是否可读等因素建议下一次是从Master还 是Slave拉取。



### 了解特性

#### 1. 发布与订阅

- 发布：某个生产者向某个Topic发送消息，可打上Tag；
- 订阅：某个消费者订阅了某个Topic中带有某些Tag的消息；**RocketMQ使用长轮询Pull机制来模拟Push效果**。

#### 2. 消息顺序

- 全局顺序：只用一个队列（分区），并开发重试有序的设置；
- 局部顺序：通过某个具有全局唯一的业务标识，将消息发到同个队列，保证这部分业务顺序，并开启重试有序设置。如某个订单创建、付款、库存，保证发往同一个队列即可。

#### 3. 消息过滤

- 消费者可以根据Tag来进行消息过滤消费。支持自定义属性过滤。消息过滤在Broker端实现，减少了对Consumer无用消息的网络传输，但增加了Broker的负担。

#### 4. 高性能

在Linux操作系统层级进行调优，推荐使用EXT4文件系统，IO调度算法使用deadline算法。

#### 5. 至少一次

At least Once，每个消息必须投递一次。Consumer先Pull到本地，消费完成后再返回服务器ACK，如果没有消费则不会ACK。

#### 6. 回溯消息

Broker在向Consumer投递成功消息后，消息仍然需要保留。并且重新消费一般是按照时间维度，例如由于Consumer系统故障，恢复后需要重新消费1小时前的数据，那么Broker要提供一种机制，可以按照时间维度来回退消费进度。RocketMQ支持按照时间回溯消费，时间维度精确到毫秒

#### 7. 事务消息

Transactional Message事务消息**将本地数据库事务**和**发送消息的操作**绑定到**一个全局事务中**。

#### 8. 定时消息（延时队列）

Broker有配置项 **`messageDelayLevel`**，默认值为“1s 5s 10s 30s 1m 2m 3m 4m 5m 6m 7m 8m 9m 10m 20m 30m 1h 2h”，**18个level**。

定时消息被暂存再名为  **`SCHEDULE_TOPIC_XXXX`**  的topic中，**每个Level都对应一个Message Queue，队列中存放相同延迟消息，保证顺序消费**

使用：**`msg.setDelayLevel(level)`**，level有以下三种情况：

- level = 0，立即发送消息
- 1<= level <= maxLevel，指定延时时间
- level > maxLevel，则level = maxLevel，例如level = 20，则还是2h

#### 9. 消息重投

可能重发消息的场景：

- 同步消息到从Slaver失败
- 异步消息有重试
- Oneway没有任何保证

重投可设置的策略：

- **`retryTimesWhenSendFailed`**：**同步发送消息失败重投**，默认次数为**2次**，超过则抛异常**。注意：为了保证消息不丢失，由业务端创建消息表，并在后续补偿重投**。
- **`retryTimesWhenSendAsyncFailed`**：异步发送消息失败重投，默认为2次。
- **`retryAnotherBrokerWhenNotStoreOK`**：消息刷盘并同步到Slaver

#### 10. 消息重试

#### 11. 流量控制

- 生产者流控：
  - commitLog文件被锁时间超过osPageCacheBusyTimeOutMills时，参数默认为1000ms，发生流控
  - 如果开启transientStorePoolEnable = true，且broker为异步刷盘的主机，且transientStorePool中资源不足，拒绝当前send请求，发生流控。
  - broker每隔10ms检查send请求队列头部请求的等待时间，如果超过waitTimeMillsInSendQueue，默认200ms，拒绝当前send请求，发生流控。
  - broker通过拒绝send 请求方式实现流量控制。
- 消费者流控：
  - 消费者本地缓存消息数超过pullThresholdForQueue时，默认1000。
  - 消费者本地缓存消息大小超过pullThresholdSizeForQueue时，默认100MB。
  - 消费者本地缓存消息跨度超过consumeConcurrentlyMaxSpan时，默认2000。
  - 消费者流控的结果是降低拉取频率。

#### 12. 死信队列

当消费者消息重试达到最大次数后，消息队列会将该消息发到一个特殊队列中-死信队列。



## 二、环境搭建

### 1. 下载RocketMQ:4.5.1

[官网下载地址](https://www.apache.org/dyn/closer.cgi?path=rocketmq/4.5.1/rocketmq-all-4.5.1-bin-release.zip)

```sh
#下载
wget https://archive.apache.org/dist/rocketmq/4.5.1/rocketmq-all-4.5.1-bin-release.zip
```



### 2. 安装及环境配置

- 修改脚本(**JDK8可忽略**，若JDK为11则需要修改一些JVM配置)

  ```
  bin/runserver.sh
  bin/runbroker.sh
  bin/tools.sh
  ```

- 启动NameServer

  ```sh
  # 1.启动NameServer 
  mqnamesrv 
  # 2.查看启动日志 
  tail -f ~/logs/rocketmqlogs/namesrv.log
  ```

- 启动Broker

  ```sh
  # 1.启动Broker 
  mqbroker -n localhost:9876 
  # 2.查看启动日志
  tail -f ~/logs/rocketmqlogs/broker.log
  ```

### 3. 环境测试

- 发送消息

  ```sh
  # 1.设置环境变量 
  export NAMESRV_ADDR=localhost:9876 
  # 2.使用安装包的Demo发送消息 
  sh bin/tools.sh org.apache.rocketmq.example.quickstart.Producer
  ```

- 接收消息

  ```sh
  # 1.设置环境变量 
  export NAMESRV_ADDR=localhost:9876 
  # 2.接收消息 
  sh bin/tools.sh org.apache.rocketmq.example.quickstart.Consumer
  ```

- 关闭RocketMQ

  ```sh
  # 1.关闭NameServer 
  mqshutdown namesrv 
  # 2.关闭Broker 
  mqshutdown broker
  ```


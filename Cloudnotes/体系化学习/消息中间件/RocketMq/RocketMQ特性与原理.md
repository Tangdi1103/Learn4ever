[toc]



## 一、RocketMQ特性详述

### 发送和消费

#### 1. 生产者

##### 1.1 快速入门



##### 1.2 提升发送效率





#### 2. 消费者

##### 2.1 快速入门

- Push模式

  优点实时性高，但是容易造成消费者的消息积压，严重时会压垮客户端。Rocket的Push模式其实就是**封装了不断循环Pull的操作**

- Pull模式

  优点是消费者量力而行，不会出现消息积压。缺点就是如何控制Pull的频率。定时间隔太久担心影响时效性，间隔太短担心做太多“无用功”浪费资源。比较折中的办法就是长轮询。



##### 2.2 防止消息积压/提升消费效率





### 存储机制

消息发送到broker后，**首先将数据存储到commitlog文件**中，然后**异步创建对应的consumequeue**（保存消息索引，例如**消息的offset**、消息大小、**tags值**）。**消费者到对应的consumequeue获取索引信息**（通过**tags**判断是否过滤，根据**offset到对应的commitlog文件**读取具体的消息）

跟kafka很像

- 零拷贝

- 顺序读写：<font style="font-weight:bold;color:red">使用文件系统存储数据</font>，**创建文件直接占用固定的磁盘空间**（**保证连续的磁盘空间**），提高了数据写入性能

![image-20220420215827507](images/image-20220420215827507.png)



![image-20220420215842399](images/image-20220420215842399.png)



![image-20220420215854466](images/image-20220420215854466.png)









### **可靠性（防丢失）、一致性**

#### 1. 零拷贝

​	**[详见零拷贝->](../../Java/基础/网络编程/零拷贝)**

#### 2. 刷盘模式/主从同步

- **同步复制：**指Master写成功后并且成功复制给Slaver，才给客户端（Producer）返回成功。可靠性高，但降低了系统吞吐量。
- **异步复制：**指Master写成功后，就给客户端（Producer）返回成功，后台线程异步将数据写入Slaver。系统吞吐量高，但可靠性不高（Master故障，Slaver没被写入，数据丢失）。



​	**建议：**虽然SYNC_FLUSH同步，由于频繁地触发磁盘写动作，会明显降低性能。通常情况下，应该把Master和Save配置成ASYNC_FLUSH的刷盘 方式，主从之间配置成SYNC_MASTER的复制方式，这样即使有一台机器出故障，仍然能保证数据不丢，是个不错的选择。	

​	可通过Broker配置文件进行配置，文件地址：**`/opt/rocket/conf/broker.conf `**，参数为**brokerRole**

​	![image-20220526083555274](images/image-20220526083555274.png)

#### 3. 刷盘机制（默认异步）



### 高可用

### ==负载均衡==

### 过滤消息

#### 1. 基于 TAGS标签 过滤

#### 2. 基于 SQL92 过滤

### ==死信队列==

### ==延迟消息==

定时消息会暂存在名为**SCHEDULE_TOPIC_XXXX 的 Topic**中，并根据 delayTimeLevel 存入特定的queue，queueId = delayTimeLevel – 1，即一个queue只存相同延迟的消息，保证具有相同发送延迟的消息能够顺序消费。broker会调度地消费SCHEDULE_TOPIC_XXXX，将消息写入真实的topic。

Broker中配置messageDelayLevel，默认值为“1s 5s 10s 30s 1m 2m 3m 4m 5m 6m 7m 8m9m 10m 20m 30m 1h 2h”，18个level。

发消息时，设置delayLevel等级 msg.setDelayLevel(level)。level有以下三种情况：

- level == 0，消息为非延迟消息

- 1<=level<=maxLevel，消息延迟特定时间，例如level==1，延迟1s

- level > maxLevel，则level== maxLevel，例如level==20，延迟2h



### ==消息重投==

消息重投保证消息尽可能发送成功、不丢失，但可能会造成消息重复，消息重复在RocketMQ中是无法避免的问题。出现消息量大、网络抖动，就很有可能出现消息重复（因为成功发送消息后，网络问题导致没收到ACK而重投）。

如下方法可以设置消息重试策略：

1. **retryTimesWhenSendFailed**：**同步发送失败重投次数**，**默认为2**，因此生产者会最多尝试发送retryTimesWhenSendFailed + 1次。不会选择上次失败的broker，尝试向其他broker发送，最大程度保证消息不丢失。**超过重投次数，抛异常**，然后**由生产者客户端保证消息不丢失（例如写消息表）**。当出现RemotingException、MQClientException和部分MQBrokerException时会重投。
2. **retryTimesWhenSendAsyncFailed**：**异步发送失败重试次数**，异步重试不会选择其他broker，仅在同一个broker上做重试，不保证消息不丢。
3. **retryAnotherBrokerWhenNotStoreOK**：消息刷盘（主或备）超时或slave不可用（返回状态非SEND_OK），是否尝试发送到其他broker，默认false。十分重要消息可以开启。**就是说，需要Master分区消息必须落盘，并且与Slaver完成消息同步，才表示消息发送完成**

### ==消息重试（消费消息必须满足幂等性）==

Consumer消费消息失败后，要提供一种重试机制，令消息再消费一次。Consumer消费消息失败通常可以认为有以下几种情况：

1. 由于消息本身的原因，例如反序列化失败，消息数据本身无法处理（例如话费充值，当前消息的手机号被注销，无法充值）等。这种错误通常需要跳过这条消息，再消费其它消息，而这条失败的消息即使立刻重试消费，99%也不成功，所以**最好 10秒后再重试。**
2. 由于依赖的下游应用服务不可用，例如db连接不可用，外系统网络不可达等。遇到这种错误，即使跳过当前失败的消息，消费其他消息同样也会报错。这种情况建议应用sleep 30s，再消费下一条消息，这样可以减轻Broker重试消息的压力。



### ==顺序消息==

### ==事务消息==

### ==流量控制（防止堆积）==



## 二、RocketMQ配置

### 1. 生产者





### 2. 消费者





### 3. 配置

#### 3.1 Broker配置

Broker服务器配置如下：

![image-20220520082244030](images/image-20220520082244030.png)

#### 3.2 系统配置

#### 3.3 客户端配置

客户端也就是消息的生产者和消费者，它们的配置通过**代码Set**或**Spring的注解**或**全局配置文件**来配置。

##### 3.3.1 客户端寻址配置

客户端寻址指的是配置NameServer地址，配置方式优先级**由高到低（高优先级优先生效）**如下：

- 代码中指定NameServer，使用**分号分隔**

  ```java
  producer.setNamesrvAddr("192.168.0.1:9876;192.168.0.2:9876");
  consumer.setNamesrvAddr("192.168.0.1:9876;192.168.0.2:9876");
  ```

- Java启动参数指定NameServer地址

  ```sh
  -Drocketmq.namesrv.addr=192.168.0.1:9876;192.168.0.2:9876
  ```

- 环境变量指定NameServer地址

  ```sh
  export NAMESRV_ADDR=192.168.0.1:9876;192.168.0.2:9876
  ```

- HTTP静态服务器寻址（默认，推荐）

  客户端第一次会10s后调用，然后每个2分钟调用一次，静态HTTP服务器：http://jmenv.tbsite.net:8080/rocketmq/nsaddr。

  因此，只需要修改改/etc/hosts文件：`127.0.0.1 jmenv.tbsite.net`。好处是客户端部署简单，修改NameServer无需重启，只需修改域名解析即可。

  RocketMQ源码在  **`org.apache.rocketmq.common.MixAll.java`**  中：

  ![image-20220520083610691](images/image-20220520083610691.png)

##### 3.3.2 客户端公共配置 

![image-20220522180221185](images/image-20220522180221185.png)

##### 3.3.3 生产者配置

![image-20220522180152303](images/image-20220522180152303.png)

##### 3.3.4 消费者配置

- **PushConsumer**

![image-20220522180014337](images/image-20220522180014337.png)

- **PullConsumer**

![image-20220522175846489](images/image-20220522175846489.png)

##### 3.3.5 Message 结构

![image-20220522175546516](images/image-20220522175546516.png)

[toc]



### 一、问题场景

新服务上线后，服务消费者不能访问到刚上线的新服务，需要过⼀段时间后才能访问？

或是将服务下线后，服务还是会被调⽤到，⼀段时候后才彻底停⽌服务，访问前期会导致频繁报错？这些问题还会让你对Spring Cloud 产⽣严重的怀疑，这难道不是⼀个 Bug?

上线⼀个新的服务实例，但是服务消费者⽆感知，过了⼀段时间才知道

某⼀个服务实例下线了，服务消费者⽆感知，仍然向这个服务实例在发起请求

这其实就是服务发现的⼀个问题，当我们需要调⽤服务实例时，信息是从注册中⼼Eureka获取的，然后通过Ribbon选择⼀个服务实例发起调⽤，如果出现调⽤不到或者下线后还可以调⽤的问题，原因肯定是服务实例的信息更新不及时导致的





### 二、Eureka 服务发现慢的原因

Eureka 服务发现慢的原因主要有两个

- 服务缓存导致的，
- 客户端缓存导致的。

![image-20210830012100937](images/image-20210830012100937.png)

#### 1. 服务端缓存

服务注册到注册中⼼后，服务实例信息是存储在注册表中的，也就是内存中。但Eureka为了提⾼响应速度，在内部做了优化，加⼊了两层的缓存结构，将Client需要的实例信息，直接缓存起来，获取的时候直接从缓存中拿数据然后响应给 Client。

- 第⼀层缓存是readOnlyCacheMap，readOnlyCacheMap是采⽤ConcurrentHashMap来存储数据的，主要负责定时与readWriteCacheMap进⾏数据同步，默认同步时间为 30 秒⼀次。
- 第⼆层缓存是readWriteCacheMap，readWriteCacheMap采⽤Guava来实现缓存。缓存过期时间默认为180秒，当服务下线、过期、注册、状态变更等操作都会清除此缓存中的数据。
- Client获取服务实例数据时，会先从⼀级缓存中获取，如果⼀级缓存中不存在，再从⼆级缓存中获取，如果⼆级缓存也不存在，会触发缓存的加载，从存储层拉取数据到缓存中，然后再返回给 Client。
- Eureka 之所以设计⼆级缓存机制，也是为了提⾼ Eureka Server 的响应速度，缺点是缓存会导致 Client 获取不到最新的服务实例信息，然后导致⽆法快速发现新的服务和已下线的服务。

了解了服务端的实现后，想要解决这个问题就变得很简单了，我们可以缩短只读缓存的更新时间（eureka.server.response-cache-update-interval-ms）让服务发现变得更加及时，或者直接将只读缓存关闭（eureka.server.use-read-onlyresponse-cache=false），多级缓存也导致C层⾯（数据⼀致性）很薄弱。

Eureka Server 中会有定时任务去检测失效的服务，将服务实例信息从注册表中移除，也可以将这个失效检测的时间缩短，这样服务下线后就能够及时从注册表中清除。



#### 2. 客户端缓存 客户端缓存主要分为两块内容，⼀块是 Eureka Client 缓存，⼀块是Ribbon 缓存。

##### 2.1 EurekaClient

EurekaClient负责跟EurekaServer进⾏交互，在EurekaClient中的com.netflflix.discovery.DiscoveryClient.initScheduledTasks() ⽅法中，初始化了⼀个 CacheRefreshThread 定时任务专⻔⽤来拉取 Eureka Server 的实例信息到本地。

所以我们需要缩短这个定时拉取服务信息的时间间隔（eureka.client.registryFetchIntervalSeconds）来快速发现新的服务。

##### 2.2 Ribbon和Hystrix

Ribbon会从EurekaClient中获取服务信息，ServerListUpdater是Ribbon中负责服务实例更新的组件，默认的实现是PollingServerListUpdater，通过线程定时去更新实例信息。定时刷新的时间间隔默认是30秒，当服务停⽌或者上线后，这边最快也需要30秒才能将实例信息更新成最新的。我们可以将这个时间调短⼀点，⽐如 3 秒。

刷新间隔的参数是通过 getRefreshIntervalMs ⽅法来获取的，⽅法中的逻辑也是从Ribbon 的配置中进⾏取值的。⼀般还会开启重试功能，当路由的服务出现问题时，可以重试到另⼀个服务来保证这次请求的成功





### 三、Spring Cloud 各组件超时

##### 1.1 Ribbon

Rbbon的超时可以配置全局的 `ribbon.ReadTimeout` 和 `ribbon.ConnectTimeout`。也可以在前⾯指定服务名，为每个服务单独配置，⽐如user-service.ribbon.ReadTimeout。



##### 1.2 Hystrix

Hystrix的全局超时 `hystrix.command.default.execution.isolation.thread.timeoutInMilliseconds`

Hystrix的特定方法超时`hystrix.command.UserRemoteClient.execution.isolation.thread.timeoutInMilliseconds`

**==Hystrix的超时时间要⼤于Ribbon的超时时间，因为Hystrix将请求包装了起来，特别需要注意的是，如果Ribbon开启了重试机制，⽐如重试3 次，Ribbon 的超时为 1 秒，那么 Hystrix 的超时时间应该⼤于 3 秒，否则就会出现 Ribbon 还在重试中，⽽ Hystrix 已经超时的现象。==**



##### 1.2 Feign

**==若配置了ribbon的时间，以ribbon为主，一般不配置Feign的时间==**

Feign也有连接超时时间（feign.client.config.服务名称.connectTimeout）和读取超时时间（feign.client.config.服务名称.readTimeout）
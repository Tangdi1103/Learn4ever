[toc]

### Spring Cloud简介

**==Spring Cloud是⼀套⽤于构建微服务架构的规范==**（所谓规范就是应该有哪些功能组件，然后组件之间怎么配合，共同完成什么事情），**==采用服务组件化，提供了一站式微服务化的解决方案==**

有组件：**==服务注册发现、配置中⼼、消息总线、负载均衡、熔断器、数据监控等==**，利⽤**==Spring Boot的开发便利性简化了微服务架构的开发（⾃动装配）==**

在这个规范之下第三⽅的Netflflix公司开发了⼀些组件、Spring官⽅开发了⼀些框架/组件，包括第三⽅的阿⾥巴巴开发了⼀套框架/组件集合Spring Cloud Alibaba，这些才是Spring Cloud规范的实现。

- Netflflix搞了⼀套 简称SCN

- Spring Cloud 吸收了Netflflix公司的产品基础之上⾃⼰也搞了⼏个组件

- 阿⾥巴巴在之前的基础上搞出了⼀堆微服务组件，Spring Cloud Alibaba（SCA）



### SPring Cloud架构组件

|                | 第⼀代 SpringCloud                                                                                 （Netflix，SCN） | 第⼆代 Spring Cloud                                                                                                                                                            （主要就是Spring Cloud Alibaba，SCA） |
| -------------- | :----------------------------------------------------------- | ------------------------------------------------------------ |
| 注册中⼼       | Netflix Eureka                                               | 阿⾥巴巴 Nacos                                               |
| 客户端负载均衡 | Netflix Ribbon                                               | 阿⾥巴巴 Dubbo LB、SpringCloud Loadbalancer                  |
| 熔断器         | Netflix Hystrix                                              | 阿⾥巴巴 Sentinel                                            |
| ⽹关           | Netflix Zuul（性能⼀般，未来将退出SpringCloud⽣态圈）、**SpringCloud Gateway** |                                                              |
| 配置中⼼       | SpringCloud Config                                           | 阿⾥巴巴Nacos、携程 Apollo                                   |
| 服务调⽤       | **Netflix Feign（Ribbon+Hystrix）**                          | 阿⾥巴巴 Dubbo RPC                                           |
| 消息驱动       | **Spring Cloud Stream**                                      |                                                              |
| 链路追踪       | **Spring Cloud Sleuth/Zipkin**                               |                                                              |
| 分布式事务     |                                                              | **阿⾥巴巴 seata 分布式事务⽅案**                            |

**==SCN 和 SCA的组件在实际项目使用中，可以任意搭配==**

⽬前来看，SCA开源出来的这些组件，推⼴及普及率不⾼，社区活跃度不⾼，稳定性和体验度上仍需进⼀步提升，根据实际使⽤来看Sentinel的稳定性和体验度要好于Nacos



### Spring Cloud 体系结构（组件协同⼯作机制）

<img src="images/image-20210826172211035.png" alt="image-20210826172211035" style="zoom:150%;" />

- 注册中⼼负责服务的注册与发现，很好将各服务连接起来

- API⽹关负责转发所有外来的请求

- 断路器负责监控服务之间的调⽤情况，连续多次失败进⾏熔断保护。

- 配置中⼼提供了统⼀的配置信息管理服务,可以实时的通知各个服务获取最新的配置信息

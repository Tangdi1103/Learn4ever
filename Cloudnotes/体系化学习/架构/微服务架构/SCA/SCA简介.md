[toc]

## 一、Spring Cloud Alibaba简介

[详见SCN概述](../SCN/SpringCloud概述)

第⼀代 Spring Cloud （主要是 SCN）很多组件已经进⼊停更维护模式

Alibaba 更进⼀步，搞出了Spring Cloud Alibaba（SCA），SCA 是由⼀些阿⾥巴巴的开源组件和云产品组成的，2018年，Spring Cloud Alibaba 正式⼊住了 SpringCloud 官⽅孵化器

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



## 二、主要组件

SCA由于阿里的云原生战略，大部分组件都是收费的，所以这里主要介绍以下几款 SCA 开源的组件

- **Nacos**（服务注册中⼼、配置中⼼）

- **Sentinel哨兵**（服务的熔断、降级、限流等）

- **Dubbo RPC/LB**（远程服务调用）

- **Seata**（分布式事务解决⽅案）


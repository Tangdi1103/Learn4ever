[toc]

## 一、改造父类

注释热部署依赖

```xml
<!--热部署-->
<!--<dependency>
   <groupId>org.springframework.boot</groupId>
   <artifactId>spring-boot-devtools</artifactId>
   <optional>true</optional>
</dependency>-->
```



## 二、服务提供者改造

### 1. 将远程方法的interface接口暴露出来，提取到API工程



### 2. 修改pom.xml

#### 2.1 删除OpenFeign 和 Ribbon（==可不删==），使⽤DubboRPC 和 Dubbo LB

#### 2.2 添加spring cloud + dubbo整合的依赖，同时添加dubbo服务接⼝⼯程依赖

```xml
<!--spring cloud alibaba dubbo 依赖-->
<dependency>
    <groupId>com.alibaba.cloud</groupId>
    <artifactId>spring-cloud-starter-dubbo</artifactId>
</dependency>
<dependency>
    <groupId>com.alibaba.csp</groupId>
    <artifactId>sentinel-apache-dubbo-adapter</artifactId>
</dependency>
```



### 3. 在远程方法的类上添加Dubbo的注解@Service



### 4. 全局配置文件添加以下配置，（==可不删==）并删除Feign、Ribbon、Hystrix配置

```yaml
spring:
  main:
    allow-bean-definition-overriding: true

dubbo:
  scan:
    # dubbo 服务扫描基准包
    base-packages: com.tangdi.service
  protocol:
    # dubbo 协议
    name: dubbo
    # dubbo 协议端⼝（ -1 表示⾃增端⼝，从 20880 开始）
    port: -1
  registry:
    # 挂载到 Spring Cloud 的注册中⼼
    address: spring-cloud://localhost
```



## 三、服务消费者改造

### 1. pom.xml中删除OpenFeign相关内容（==可不删==）



### 2. application.yml配置⽂件中删除和Feign、Ribbon相关的内容（==可不删==）；代码中删除Feign客户端内容



### 3. pom.xml添加内容和服务提供者⼀样



### 4. application.yml配置⽂件中添加以下内容

```yaml
spring:
  main:
    allow-bean-definition-overriding: true

dubbo:
  registry:
    # 挂载到 Spring Cloud 注册中心
    address: spring-cloud://localhost
  cloud:
    # 订阅服务提供方的应用列表，订阅多个服务提供者使用 "," 连接
    subscribed-services: lagou-service-resume
```



### 5. 使用Dubbo的@Refrance调用远程方法（可指定负载均衡策略）

**==负载均衡策略，可选值：random（默认值）,roundrobin,leastactive，分别表示：随机，轮询，最少活跃调用==**

```java
//在服务消费者一方配置负载均衡策略，check启动时检查提供者是否存在，true报错，false忽略
@Reference(check = false,loadbalance = "random")
```


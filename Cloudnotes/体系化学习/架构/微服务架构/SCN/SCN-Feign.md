[toc]

## 一、Feign 基础

### 1. 简介

Feign是由Netflix开发的**==轻量级RestFul风格的HTTP服务客户端==**，用于远程过程调用。

类似于Dubbo，也是**==通过java接口生成代理类，去调用远程服务==**。不同于Dubbo，Feign发起的是**==HTTP请求并且Feign的接口需要配置注解使用==**，底层基于RestTemplate实现远程服务调用

（效果）**==Feign==** = **==RestTemplate==** + **==Ribbon==** + **==Hystrix==**

### 2. 衍生OpenFeign

SpringCloud对Feign进⾏了增强，产生了**==OpenFeign==**，它**==⽀持SpringMVC的注解==**





## 二、Feign 简单应用及注意事项

### 1. 消费者

#### 1.1 pom文件引入openFeign

若引入openFein，则无需额外引入Hystrix的依赖了

```xml
<!--openfeign-->
<dependency>
    <groupId>org.springframework.cloud</groupId>
    <artifactId>spring-cloud-starter-openfeign</artifactId>
</dependency>
```



#### 1.2 在启动类开启Feign

由于Feign内部集成了熔断器Hystrix，所以可省略@EnableCircuitBreaker来开启熔断器

```java
package com.tangdi;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.cloud.client.discovery.EnableDiscoveryClient;
import org.springframework.cloud.openfeign.EnableFeignClients;

/**
 * @program: scn-demo
 * @description:
 * @author: Wangwentao
 * @create: 2021-08-30 17:31
 **/
@SpringBootApplication
@EnableDiscoveryClient // 开启服务发现
@EnableFeignClients // 开启Feign
public class UserServiceApplication {

    public static void main(String[] args) {
        SpringApplication.run(UserServiceApplication.class,args);
    }
}
```



#### 1.3 创建Feign接口

- @FeignClient注解的name属性用于指定调用的服务名，是服务提供者的applicationName
- contextId 作为多FeignClient上下文id，当有多个FeignClient请求到同个微服务（即多个FeignClient的name相同）时，用以区分
- OpenFeign可以使⽤@PathVariable、@RequestParam、@RequestHeader注解进行参数绑定，这也是OpenFeign对SpringMVC注解的⽀持，但是需要注意value必须设置，否则会抛出异常

```java
package com.tangdi.webservice;

import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;

@FeignClient(value = "code-service",contextId = "code")
public interface CodeFeginClient {

    //调⽤的请求路径
    @RequestMapping("/code/fromEmail/validate/{email}/{code}")
    public Integer vaildAuthCode(@PathVariable String email, @PathVariable String code);
}
```



#### 1.4 使用接口调用远程服务

```java
@Autowired
private CodeFeginClient codeFeginClient;

@Test
public void testFeignClient(){
    Integer state = codeFeginClient.vaildAuthCode(2341231@qq.com,321242);
    System.out.println("=======>>>vaildAuthCode state：" + state);
}
```





## 三、Feign 对Ribbon负载均衡的⽀持

Feign内部集成了Ribbon以及自动配置，所以无需额外引入依赖。相关设置只需在全局配置文件配置即可

### 1.Feign关于Ribbon负载均衡的相关配置

Feign默认的请求处理**==超时时⻓为1s==**，Feign⾃⼰有超时设置，**==如果配置Ribbon的超时，则会以Ribbon的为准==**

Ribbon与Hystrix的超时时长比较，取最短的生效

```yaml
#针对的被调用方微服务名称,不加就是全局生效
user-service:
  ribbon:
    #请求连接超时时间
    ConnectTimeout: 2000
    #请求处理超时时间,Feign超时时长设置,默认1秒超时。与Hystrix超时时长比较，取最短的生效
    ReadTimeout: 10000
    #对所有操作都进行重试
    OkToRetryOnAllOperations: true
    ####根据如上配置，当访问到故障请求的时候，它会再尝试访问一次当前实例（次数由MaxAutoRetries配置），
    ####如果不行，就换一个实例进行访问，如果还不行，再换一次实例访问（更换次数由MaxAutoRetriesNextServer配置），
    ####如果依然不行，返回失败信息。
    MaxAutoRetries: 0 #对当前选中实例重试次数，不包括第一次调用
    MaxAutoRetriesNextServer: 0 #切换实例的重试次数
    NFLoadBalancerRuleClassName: com.netflix.loadbalancer.RoundRobinRule #负载策略调整
```





## 四、Feign 对熔断器的⽀持

### 1. Feign开启熔断支持

在消费者工程的全局配置中，开启Feign对熔断器的⽀持

开启Hystrix之后，Feign中的⽅法都会被进⾏⼀个管理，⼀旦出现问题就进⼊对应的回退逻辑处理

```yaml
# 开启Feign的熔断功能
feign:
  hystrix:
   enabled: true
```





### 2. 熔断的相关配置

针对超时这⼀点，当前有两个超时时间设置（Feign/hystrix），熔断是根据最小的超时时间为主，最先熔断进⼊回退降级逻辑

```yaml
hystrix:
  command:
    default:
      circuitBreaker:
        # 强制打开熔断器，如果该属性设置为true，强制断路器进⼊打开状态，将会拒绝所有的请求。 默认false关闭的
        forceOpen: false
        # 触发熔断错误⽐例阈值，默认值50%
        errorThresholdPercentage: 50
        # 熔断后休眠时⻓，默认值5秒
        sleepWindowInMilliseconds: 3000 
        # 熔断触发最⼩请求次数，默认值是20
        requestVolumeThreshold: 2
      execution:
        isolation:
          thread:
            # 熔断超时设置，默认为1秒。与ribbon的超时时长比较，最短的生效
            timeoutInMilliseconds: 10000
```





### 3. Feign熔断的降级处理

#### 3.1 ⾃定义FallBack处理类（需要实现FeignClient接⼝）

```java
import org.springframework.stereotype.Component;

/**
* 降级回退逻辑需要定义⼀个类，实现FeignClient接⼝，实现接⼝中的⽅法
**
*/
@Component // 别忘了这个注解，还应该被扫描到
public class CodeFallback implements CodeFeginClient {
    @Override
    public Integer vaildAuthCode(String email,String code) {
        return 0;
    }
}
```

#### 3.2 FeignClient相关修改

##### @FeignClient注解中添加fallback属性

```java
package com.tangdi.webservice;

import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;

@FeignClient(value = "code-service",contextId = "code",fallback = CodeFallback.class)
public interface CodeFeginClient {

    //调⽤的请求路径
    @RequestMapping("/code/fromEmail/validate/{email}/{code}")
    public Integer vaildAuthCode(@PathVariable String email, @PathVariable String code);
}
```





## 五、Feign 对请求/响应压缩的支持

Feign ⽀持对请求和响应进⾏GZIP压缩，以减少通信过程中的性能损耗。通过下⾯的参数 即可开启请求与响应的压缩功能：

```yaml
feign:
  compression:
    request:
      # 开启请求压缩
      enabled: true 
      # 设置压缩的数据类型，此处也是默认值
      mime-types: text/html,application/xml,application/json 
      # 设置触发压缩的⼤⼩下限，此处也是默认值
      min-request-size: 2048 
    response:
      # 开启响应压缩
      enabled: true 
```



## 六、Feign 的日志配置

Feign是http请求客户端，类似于浏览器，它在请求和接收响应的时候，可以打印出⽐较详细的⼀些⽇志信息（响应头，状态码等等）

### 1. 默认情况下Feign的⽇志没有开启，需要手动配置

```java
import feign.Logger;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;


// Feign的⽇志级别（Feign请求过程信息）
// NONE：默认的，不显示任何⽇志----性能最好
// BASIC：仅记录请求⽅法、URL、响应状态码以及执⾏时间----⽣产问题追踪
// HEADERS：在BASIC级别的基础上，记录请求和响应的header
// FULL：记录请求和响应的header、body和元数据----适⽤于开发及测试环境定位问题
@Configuration
public class FeignLog {
    @Bean
    Logger.Level feignLevel() {
        return Logger.Level.FULL;
    }
}
```



### 2. 配置log⽇志级别为debug

##### 2.1 Feign日志只会对日志级别为debug的做出响应

```yaml
logging:
  level:
    # 设置所有feignClient的日志级别为debug
    # Feign日志只会对日志级别为debug的做出响应
    com.tangdi.webservice: debug
```







## 七、Feign 源码剖析

#### 1. 利用SpringBoot的自动配置原理

源码略。。

#### 2. 利用代理模式，为Feign接口生产代理对象

源码略。。

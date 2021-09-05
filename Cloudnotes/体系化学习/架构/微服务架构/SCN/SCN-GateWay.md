[toc]

## 一、GateWay基础

### 1. 简介

Spring Cloud GateWay由Spring官方开发的网关，目的是替代Netflix Zuul。性能⾼于Zuul，官⽅测试，GateWay是Zuul的1.6倍，旨在为微服务架构提供⼀种简单有效的统⼀的API路由管理⽅式

**==GateWay基于Spring5.X、SpringBoot2.X、WebFlux（基于Netty的异步非阻塞、响应式的表现层框架）==**



### 2. 架构

#### 2.1 网关在微服务中的架构

微服务的网关上游应该是Nginx服务器，**==通过Nginx反向代理对前端隐藏后端服务地址==**，并**==负载均衡实现网关的高可用集群==**

![image-20210829223421360](images/image-20210829223421360.png)





#### 2.2 GateWay的架构图

由以下组成

- 一系列断言Predicates
- 一个路由Route
- 一系列过滤器Filter组成

![image-20210829224454899](images/image-20210829224454899.png)



### 3. 功能

- **==反向代理/路由（Route）==**

  网关最基本的功能，由⼀个ID、⼀个⽬标URL（最终路由到的地址）、⼀系列的断⾔（匹配条件判断）和Filter过滤器（精细化控制）组成。如果断⾔为true，则匹配该路由

- **==断言（Predicates）==**

  参考了Java8中的断⾔java.util.function.Predicate，开发⼈员可以匹配Http请求中的所有内容（包括请求头、请求参数等）（类似于nginx中的location匹配⼀样），如果断⾔与请求相匹配则路由。

- **==过滤器（Filter）==**

  Spring Webflux的过滤器，可以在请求之前或者之后执⾏业务逻辑，可扩展以下功能

  - 黑白名单
  - 限流IP防爆刷
  - 验证登陆IP、登陆设备号
  - 日志监控
  - 熔断
  - 转发



## 二、GateWay工作原理

*GateWay核⼼逻辑：路由转发 + 执⾏过滤器链*

![image-20210829225016884](images/image-20210829225016884.png)

1. GateWay收到请求后，根据请求url在HandlerMapping匹配对应的路由路径，
2. 调用GateWay Web Handler，Handler再通过指定的过滤器执行链
3. 将请求发送到对应的服务，然后返回。



## 三、GateWay 基础应用

GateWay不需要使⽤web模块，它引⼊的是WebFlux（类似于SpringMVC）

### 1. 创建网关工程，pom.xml文件

```xml
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>

    <groupId>com.tangdi</groupId>
    <artifactId>scn-gateway</artifactId>
    <version>1.0-SNAPSHOT</version>

    <!--spring boot 父启动器依赖-->
    <parent>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-parent</artifactId>
        <version>2.1.6.RELEASE</version>
    </parent>

    <dependencies>
        <dependency>
            <groupId>org.springframework.cloud</groupId>
            <artifactId>spring-cloud-commons</artifactId>
        </dependency>

        <!--gateway使用weblux，需要排除spring-boot-starter-web依赖-->
        <dependency>
            <groupId>com.tangdi</groupId>
            <artifactId>api-service</artifactId>
            <version>1.0-SNAPSHOT</version>
            <exclusions>
                <exclusion>
                    <groupId>org.springframework.boot</groupId>
                    <artifactId>spring-boot-starter-web</artifactId>
                </exclusion>
            </exclusions>
        </dependency>

        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-data-jpa</artifactId>
        </dependency>
        <dependency>
            <groupId>mysql</groupId>
            <artifactId>mysql-connector-java</artifactId>
            <scope>runtime</scope>
        </dependency>

        <!--eureka client 客户端依赖引入-->
        <dependency>
            <groupId>org.springframework.cloud</groupId>
            <artifactId>spring-cloud-starter-netflix-eureka-client</artifactId>
        </dependency>

        <!--分布式配置中心config client-->
        <dependency>
            <groupId>org.springframework.cloud</groupId>
            <artifactId>spring-cloud-config-client</artifactId>
        </dependency>

        <!--GateWay 网关-->
        <dependency>
            <groupId>org.springframework.cloud</groupId>
            <artifactId>spring-cloud-starter-gateway</artifactId>
        </dependency>
        <!--引入webflux-->
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-webflux</artifactId>
        </dependency>
        <!--日志依赖-->
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-logging</artifactId>
        </dependency>
        <!--测试依赖-->
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-test</artifactId>
            <scope>test</scope>
        </dependency>
        <!--lombok工具-->
        <dependency>
            <groupId>org.projectlombok</groupId>
            <artifactId>lombok</artifactId>
            <version>1.18.4</version>
            <scope>provided</scope>
        </dependency>

        <!--引入Jaxb，开始-->
        <dependency>
            <groupId>com.sun.xml.bind</groupId>
            <artifactId>jaxb-core</artifactId>
            <version>2.2.11</version>
        </dependency>
        <dependency>
            <groupId>javax.xml.bind</groupId>
            <artifactId>jaxb-api</artifactId>
        </dependency>
        <dependency>
            <groupId>com.sun.xml.bind</groupId>
            <artifactId>jaxb-impl</artifactId>
            <version>2.2.11</version>
        </dependency>
        <dependency>
            <groupId>org.glassfish.jaxb</groupId>
            <artifactId>jaxb-runtime</artifactId>
            <version>2.2.10-b140310.1920</version>
        </dependency>
        <dependency>
            <groupId>javax.activation</groupId>
            <artifactId>activation</artifactId>
            <version>1.1.1</version>
        </dependency>
        <!--引入Jaxb，结束-->

        <!-- Actuator可以帮助你监控和管理Spring Boot应用-->
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-actuator</artifactId>
        </dependency>
        <!--热部署-->
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-devtools</artifactId>
            <optional>true</optional>
        </dependency>

        <!--链路追踪-->
        <!--<dependency>
            <groupId>org.springframework.cloud</groupId>
            <artifactId>spring-cloud-starter-sleuth</artifactId>
        </dependency>-->
    </dependencies>

    <dependencyManagement>
        <!--spring cloud依赖版本管理-->
        <dependencies>
            <dependency>
                <groupId>org.springframework.cloud</groupId>
                <artifactId>spring-cloud-dependencies</artifactId>
                <version>Greenwich.RELEASE</version>
                <type>pom</type>
                <scope>import</scope>
            </dependency>
        </dependencies>
    </dependencyManagement>

    <build>
        <plugins>
            <!--编译插件-->
            <plugin>
                <groupId>org.apache.maven.plugins</groupId>
                <artifactId>maven-compiler-plugin</artifactId>
                <configuration>
                    <source>1.8</source>
                    <target>1.8</target>
                    <encoding>utf-8</encoding>
                </configuration>
            </plugin>
            <!--打包插件-->
            <plugin>
                <groupId>org.springframework.boot</groupId>
                <artifactId>spring-boot-maven-plugin</artifactId>
            </plugin>
        </plugins>
    </build>

</project>
```



### 2. 创建启动类

```java
package com.tangdi;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.cloud.client.discovery.EnableDiscoveryClient;

/**
 * @program: scn-eureka
 * @description:
 * @author: Wangwentao
 * @create: 2021-08-30 15:48
 **/

@SpringBootApplication
@EnableDiscoveryClient
public class ScnGateWayApplication {

    public static void main(String[] args) {
        SpringApplication.run(ScnGateWayApplication.class,args);
    }
}

```



### 3. 全局配置文件及说明

```yaml
server:
  port: 7002
  
##注册到Eureka服务中心
eureka:
  client:
    # 每隔多久拉取⼀次服务列表
    registry-fetch-interval-seconds: 10
    service-url:
      # 注册到集群，就把多个Eurekaserver地址使用逗号连接起来即可
      defaultZone: http://localhost:8761/eureka,http://localhost:8762/eureka
  instance:
    prefer-ip-address: true  #使⽤ip注册，否则会使⽤主机名注册了（此处考虑到对⽼版本的兼容，新版本经过实验都是ip）
    # 实例名称： 192.168.1.103:lagou-service-resume:8080，我们可以自定义它
    instance-id: ${spring.cloud.client.ip-address}:${spring.application.name}:${server.port}
    # 租约续约间隔时间，默认30秒
    lease-renewal-interval-in-seconds: 10
    # 租约到期，服务时效时间，默认值90秒,服务超过90秒没有发⽣⼼跳，EurekaServer会将服务从列表移除
    lease-expiration-duration-in-seconds: 30

spring:
  application:
    name: scn-gateway
  redis:
    database: 0
    password:
    jedis:
      pool:
        max-active: 8
        max-idle: 8
        min-idle: 0
        max-wait: -1
    timeout: 300000
    host: localhost
    port: 6379
  datasource:
    driver-class-name: com.mysql.jdbc.Driver
    url: jdbc:mysql://localhost:3306/demo_jpa?useSSL=false&characterEncoding=utf-8&serverTimezone=GMT
    username: root
    password: 123456
  jpa:
    database: MySQL
    show-sql: true
    hibernate:
      naming:
         #避免将驼峰命名转换为下划线命名
        physical-strategy: org.hibernate.boot.model.naming.PhysicalNamingStrategyStandardImpl 
  cloud:
    gateway:
      # 路由可以有多个
      routes:
        # 我们自定义的路由 ID，保持唯一
        - id: user-service-route
          # gateway网关从服务注册中心获取实例信息然后负载后路由
          uri: lb://user-service
          # 断言：路由条件，Predicate 接受一个输入参数，返回一个布尔值结果。该接口包含多种默 认方法来将 Predicate 组合成其他复杂的逻辑（比如：与，或，非）。
          predicates:
            - Path=/api/user/**
          filters:
            - StripPrefix=1 # 去掉第一个上下文路径
        - id: code-service-route
          uri: lb://code-service
          # 断言：路由条件，Predicate 接受一个输入参数，返回一个布尔值结果。该接口包含多种默 认方法来将 Predicate 组合成其他复杂的逻辑（比如：与，或，非）。
          predicates:
            - Path=/api/code/**
          filters:
            - StripPrefix=1 # 去掉第一个上下文路径
        - id: email-service-route
          uri: lb://email-service
          # 断言：路由条件，Predicate 接受一个输入参数，返回一个布尔值结果。该接口包含多种默 认方法来将 Predicate 组合成其他复杂的逻辑（比如：与，或，非）。
          predicates:
            - Path=/api/email/**
          filters:
            - StripPrefix=1 # 去掉第一个上下文路径
 

#ip防爆刷
antiClimbing:
  timeSlot: 1
  maxCount: 10


logging:
  level:
    # 分布式链路追踪日志
    org.springframework.web.servlet.DispatcherServlet: debug
    org.springframework.cloud.sleuth: debug
```





## 四、GateWay 断言路由规则详解

Spring Cloud GateWay 帮我们内置了很多 Predicates功能，实现了各种路由匹配规则（通过 Header、请求参数等作为条件）匹配到对应的路由

![image-20210829230702123](images/image-20210829230702123.png)

#### 1. 时间点后匹配

```yaml
routes:
  - id: after_route
    uri: https://example.org
    predicates:
    - After=2017-01-20T17:42:47.789-07:00[America/Denver]
```

#### 2. 时间点前匹配

```yaml
spring:
  cloud:
    gateway:
      routes:
        - id: remoteaddr_route
          uri: https://example.org
          predicates:
            - Before=2017-01-20T17:42:47.789-07:00[America/Denver]
```

#### 3. 时间区间匹配

```yaml
spring:
  cloud:
    gateway:
      routes:
        - id: remoteaddr_route
          uri: https://example.org
          predicates:
            - Between=2017-01-20T17:42:47.789-07:00[America/Denver],2017-01-21T17:42:47.789-07:00[America/Denver]
```

#### 4. 指定Cookie正则匹配指定值	

```yaml
spring:
  cloud:
    gateway:
      routes:
        - id: remoteaddr_route
          uri: https://example.org
          predicates:
            - Cookie=chocolate, ch.p
```

#### 5. 指定Header正则匹配指定值

```yaml
spring:
  cloud:
    gateway:
      routes:
        - id: remoteaddr_route
          uri: https://example.org
          predicates:
            - Header=X-Request-Id, \d+
```

#### 6. 请求Host匹配指定值

```yaml
spring:
  cloud:
    gateway:
      routes:
        - id: remoteaddr_route
          uri: https://example.org
          predicates:
            - Host=**.somehost.org,**.anotherhost.org
```

#### 7. 请求Method匹配指定请求⽅式

```yaml
spring:
  cloud:
    gateway:
      routes:
        - id: remoteaddr_route
          uri: https://example.org
          predicates:
            - Method=GET,POST
```

#### 8. 请求路径正则匹配

```yaml
spring:
  cloud:
    gateway:
      routes:
        - id: remoteaddr_route
          uri: https://example.org
          predicates:
            - Path=/red/{segment},/blue/{segment}
```

#### 9. 请求包含某参数

```yaml
spring:
  cloud:
    gateway:
      routes:
        - id: remoteaddr_route
          uri: https://example.org
          predicates:
            - Query=green
```

#### 10. 请求包含某参数并且参数值匹配正则表达式

```yaml
spring:
  cloud:
    gateway:
      routes:
        - id: remoteaddr_route
          uri: https://example.org
          predicates:
            - Query=red, gree.
```

#### 11. 远程地址匹配

```yaml
spring:
  cloud:
    gateway:
      routes:
        - id: remoteaddr_route
          uri: https://example.org
          predicates:
            - RemoteAddr=192.168.1.1/24
```



## 五、GateWay 过滤器

#### 1. 从过滤器⽣命周期（影响时机点）

- pre  

  在被路由到服务之前执行，可扩展黑白名单、日志监控、鉴权、扩展请求头

- post

  服务执行完后响应给前端之前执行，可为响应头扩展

#### 2. 过滤器种类

- GateWayFilter 

  应⽤到单个路由路由上，GateWay有一些默认的GateWayFilter 实现，如StripPrefix：去掉url中N个占位路径然后路由转发

  ```yaml
  predicates:
   - Path=/resume/**
  filters:
    - StripPrefix=1 # 可以去掉resume之后转发
  ```

- GlobalFilter 

  应⽤到所有的路由上

#### 3. GateWay 全局过滤器黑白名单应用

获取客户端ip，判断是否在黑名单中，在的话就拒绝访问，不在的话就放行

```java
import lombok.extern.slf4j.Slf4j;
import org.springframework.cloud.gateway.filter.GatewayFilterChain;
import org.springframework.cloud.gateway.filter.GlobalFilter;
import org.springframework.core.Ordered;
import org.springframework.core.io.buffer.DataBuffer;
import org.springframework.http.HttpStatus;
import org.springframework.http.server.reactive.ServerHttpRequest;
import org.springframework.http.server.reactive.ServerHttpResponse;
import org.springframework.stereotype.Component;
import org.springframework.web.server.ServerWebExchange;
import reactor.core.publisher.Mono;

import java.util.ArrayList;
import java.util.List;

/**
 * 定义全局过滤器，会对所有路由生效
 */
@Slf4j
@Component  // 让容器扫描到，等同于注册了
public class BlackListFilter implements GlobalFilter, Ordered {

    // 模拟黑名单（实际可以去数据库或者redis中查询）
    private static List<String> blackList = new ArrayList<>();

    static {
        blackList.add("0:0:0:0:0:0:0:1");  // 模拟本机地址
    }

    /**
     * 过滤器核心方法
     * @param exchange 封装了request和response对象的上下文
     * @param chain 网关过滤器链（包含全局过滤器和单路由过滤器）
     * @return
     */
    @Override
    public Mono<Void> filter(ServerWebExchange exchange, GatewayFilterChain chain) {
        // 从上下文中取出request和response对象
        ServerHttpRequest request = exchange.getRequest();
        ServerHttpResponse response = exchange.getResponse();

        // 从request对象中获取客户端ip
        // String clientIp = request.getRemoteAddress().getHostString();
        // 从nginx获取客户端真实ip
        String clientIp = request.getHeaders().getFirst("X-Real-IP");
        
        // 拿着clientIp去黑名单中查询，存在的话就决绝访问
        if(blackList.contains(clientIp)) {
            // 决绝访问，返回
            response.setStatusCode(HttpStatus.UNAUTHORIZED); // 状态码
            log.debug("=====>IP:" + clientIp + " 在黑名单中，将被拒绝访问！");
            String data = "Request be denied!";
            DataBuffer wrap = response.bufferFactory().wrap(data.getBytes());
            return response.writeWith(Mono.just(wrap));
        }

        // 合法请求，放行，执行后续的过滤器
        return chain.filter(exchange);
    }


    /**
     * 返回值表示当前过滤器的顺序(优先级)，数值越小，优先级越高
     * @return
     */
    @Override
    public int getOrder() {
        return 0;
    }
}
```

#### 4. 防爬

```java
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.cloud.gateway.filter.GatewayFilterChain;
import org.springframework.cloud.gateway.filter.GlobalFilter;
import org.springframework.core.Ordered;
import org.springframework.core.io.buffer.DataBuffer;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.http.HttpStatus;
import org.springframework.http.server.reactive.ServerHttpRequest;
import org.springframework.http.server.reactive.ServerHttpResponse;
import org.springframework.stereotype.Component;
import org.springframework.web.server.ServerWebExchange;
import reactor.core.publisher.Mono;

import java.util.Set;
import java.util.concurrent.TimeUnit;

/**
 * ip防爆策略请求
 */
@Component
public class IPForceFilter implements GlobalFilter, Ordered {

    @Value("${antiClimbing.timeSlot}")
    private Integer timeSlot;
    @Value("${antiClimbing.maxCount}")
    private Integer maxCount;

    private static final String REGISTER_PATH = "/user/register";

    private static final String KEY_PRE = "antiClimbing_";

    @Autowired
    private RedisTemplate<String, String> redisTemplate;

    @Override
    public Mono<Void> filter(ServerWebExchange exchange, GatewayFilterChain chain) {
        // 从上下文中取出request和response对象
        ServerHttpRequest request = exchange.getRequest();
        ServerHttpResponse response = exchange.getResponse();

        // 从request对象中获取客户端ip 0:0:0:0:0:0:0:1
        String clientIp = request.getRemoteAddress().getHostString();
        // 请求地址 request.getPath()
        String path = request.getPath().toString();
        //注册接口，进行ip防爆策略检查
        if (path.contains(REGISTER_PATH)) {
            String key = KEY_PRE + clientIp + "_";
            Set<String> keys = redisTemplate.keys(key + "*");
            //不允许注册  返回
            if (keys != null && keys.size() >= maxCount) {
                response.setStatusCode(HttpStatus.FORBIDDEN);
                String data = "注册请求过于频繁，请稍后再试！";
                DataBuffer msg = response.bufferFactory().wrap(data.getBytes());
                return response.writeWith(Mono.just(msg));
            }
            // 进行计数，将ip和时间戳作为key
            redisTemplate.opsForValue().set(key + System.currentTimeMillis(), "", timeSlot, TimeUnit.MINUTES);
        }
        return chain.filter(exchange);
    }

    @Override
    public int getOrder() {
        return 0;
    }
}
```





#### 5. 基于令牌漏桶算法的限流过滤器

Spring cloud gateway官方提供了基于令牌桶的限流算法，基于内部的过滤器工厂RequestRateLimiterGatewayFilterFactory实现。

##### 目前RequestRateLimiterGatewayFilterFactory的实现依==赖于 Redis，所以我们还要引入spring-boot-starter-data-redis-reactive==

```xml
<dependency> 
    <groupId>org.springframework.cloud</groupId> 
    <artifactId>spring-cloud-starter-gateway</artifactId>
</dependency> 
<dependency> 
    <groupId>org.springframework.boot</groupId> 
    <artifatId>spring-boot-starter-data-redis- reactive</artifactId> 
</dependency>
```

##### 配置文件

```yaml
server: 
  port: 8080
spring:
  cloud:
    gateway:
      routes:
        - id: limit_route
          uri: http://httpbin.org:80/get
          predicates:
            - After=2019-02-26T00:00:00+08:00[Asia/Shanghai]
          filters:
            - name: RequestRateLimiter
              args:
                key-resolver: '#{@userKeyResolver}' #获取请求用户id作为限流key
                redis-rate-limiter.replenishRate: 50 #令牌桶每秒填充平均速率
                redis-rate-limiter.burstCapacity: 300 #令牌桶总容量
  application:
    name: scn-gateway
  redis:
    host: localhost
    port: 6379 
    database: 0
```

配置了RequestRateLimiter的限流过滤器，该过滤器需要配置三个参数

- redis-rate-limiter.burstCapacity：令牌桶总容量。

- redis-rate-limiter.replenishRate：令牌桶每秒填充平均速率。
- key-resolver：用于限流的键的解析器的 Bean 对象的名字。它使用 SpEL表达式根据#{@beanName}从 Spring 容器中获取 Bean 对象。

##### 限流key解析器bean对象的声明

```java
@Configuration
public class KeyResolverConfiguration {
    /*** 接口限流： * 获取请求地址的uri作为限流key。 */
    @Bean
    public KeyResolver pathKeyResolver() {
        return new KeyResolver() {
            @Override
            public Mono<String> resolve(ServerWebExchange exchange) {
                return Mono.just(exchange.getRequest().getPath().toString());
            }
        };
    }

    /*** 用户限流： * 获取请求用户id作为限流key。 */
    @Bean
    public KeyResolver userKeyResolver() {
        return exchange -> Mono.just(exchange.getRequest().getQueryParams().getFirst("userId"));
    }

    /**
     * IP限流： * 获取请求用户ip作为限流key。
     */
    @Bean
    public KeyResolver hostAddrKeyResolver() {
        return exchange -> Mono.just(exchange.getRequest().getRemoteAddress().getHostName());
    }
}
```




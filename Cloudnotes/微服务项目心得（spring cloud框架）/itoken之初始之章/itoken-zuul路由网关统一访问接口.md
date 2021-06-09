# 使用路由网关统一访问接口
在微服务架构中，需要几个基础的服务治理组件，包括服务注册与发现、服务消费、负载均衡、熔断器、智能路由、配置管理等，由这几个基础组件相互协作，共同组建了一个简单的微服务系统。一个简单的微服务系统如下图：
![image](https://note.youdao.com/yws/public/resource/c5be5802daf0385d18fbdfde57d959e9/xmlnote/24626EE6F9CC4577BD90B0BFA2F5505C/1504)

在 Spring Cloud 微服务系统中，一种常见的负载均衡方式是，客户端的请求首先经过负载均衡（Zuul、Ngnix），再到达服务网关（Zuul 集群），然后再到具体的服。服务统一注册到高可用的服务注册中心集群，服务的所有的配置文件由配置服务管理，配置服务的配置文件放在 GIT 仓库，方便开发人员随时改配置。

---


# Zuul 简介
Zuul 的主要功能是路由转发和过滤器。路由功能是微服务的一部分，比如 /api/user 转发到到 User 服务，/api/shop 转发到到 Shop 服务。Zuul 默认和 Ribbon 结合实现了负载均衡的功能。


---
# 创建路由网关
pom.xml 文件如下：


```
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>

    <parent>
        <groupId>com.tangdi</groupId>
        <artifactId>itoken-dependencies</artifactId>
        <version>1.0.0-SNAPSHOT</version>
        <relativePath>../itoken-dependencies/pom.xml</relativePath>
    </parent>

    <artifactId>itoken-zuul</artifactId>
    <packaging>jar</packaging>

    <dependencies>
        <!-- Spring Boot Begin -->
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-web</artifactId>
        </dependency>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-tomcat</artifactId>
        </dependency>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-actuator</artifactId>
        </dependency>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-test</artifactId>
            <scope>test</scope>
        </dependency>
        <!-- Spring Boot End -->

        <!-- Spring Cloud Begin -->
        <dependency>
            <groupId>org.springframework.cloud</groupId>
            <artifactId>spring-cloud-starter-netflix-eureka-server</artifactId>
        </dependency>
        <dependency>
            <groupId>org.springframework.cloud</groupId>
            <artifactId>spring-cloud-starter-netflix-zuul</artifactId>
        </dependency>
        <dependency>
            <groupId>org.springframework.cloud</groupId>
            <artifactId>spring-cloud-starter-config</artifactId>
        </dependency>
        <!-- Spring Cloud End -->

        <!-- 链路追踪以及服务监控-->
        <dependency>
            <groupId>org.springframework.cloud</groupId>
            <artifactId>spring-cloud-starter-zipkin</artifactId>
        </dependency>
        <dependency>
            <groupId>org.jolokia</groupId>
            <artifactId>jolokia-core</artifactId>
        </dependency>
        <dependency>
            <groupId>de.codecentric</groupId>
            <artifactId>spring-boot-admin-starter-client</artifactId>
        </dependency>
        <!-- 链路追踪以及服务监控-->

    </dependencies>

    <build>
        <plugins>
            <plugin>
                <groupId>org.springframework.boot</groupId>
                <artifactId>spring-boot-maven-plugin</artifactId>
                <configuration>
                    <mainClass>com.tangdi.itoken.zuul.ZuulApplication</mainClass>
                </configuration>
            </plugin>
        </plugins>
    </build>
</project>
```

gradle配置

```
group 'com.tinckay'
version '1.0-SNAPSHOT'

buildscript{
    ext{
        springBootVersion = '2.0.3.RELEASE'
    }
    repositories{
        mavenCentral()
    }
    dependencies{
        classpath("org.springframework.boot:spring-boot-gradle-plugin:${springBootVersion}")
    }
}

apply plugin: 'java'
apply plugin: 'eclipse'
apply plugin: 'idea'
apply plugin: 'org.springframework.boot'
apply plugin: 'io.spring.dependency-management'

bootJar {
    baseName = 'mc-zuul'
    version = '1.0.0'
}

sourceCompatibility = 1.8
targetCompatibility = 1.8

repositories {
    maven { url 'http://maven.aliyun.com/nexus/content/repositories/central' }
    mavenCentral()
}

ext {
    springCloudVersion = 'Finchley.SR1'
}

dependencyManagement {
    imports {
        mavenBom "org.springframework.cloud:spring-cloud-dependencies:${springCloudVersion}"
    }
}

repositories {
    maven {
        url 'https://repo.spring.io/libs-milestone'
    }
}

dependencies {
    //compile("org.springframework:spring-context:4.3.8.RELEASE")

    compile('org.springframework.boot:spring-boot-starter-actuator')
    compile('org.springframework.boot:spring-boot-starter-web')
    compile('org.springframework.cloud:spring-cloud-starter-netflix-zuul')
    compile('org.springframework.cloud:spring-cloud-starter-netflix-ribbon')
    compile('org.springframework.cloud:spring-cloud-starter-netflix-hystrix')
    compile('org.springframework.cloud:spring-cloud-starter-netflix-hystrix-dashboard')
    compile('org.springframework.cloud:spring-cloud-starter-netflix-eureka-client')
    fileTree(dir: 'lib', include: '*.jar')

}


jar {

    String someString = ''
    configurations.runtime.each {someString = someString + " lib\\"+it.name}
    manifest {
        attributes 'Main-Class': 'RunServer'
        attributes 'Class-Path': someString

    }

}

task clearPj(type:Delete){
    delete 'build','target'
}

task copyJar(type:Copy){
    from configurations.runtime
    into ('build/libs/lib')

}


task release(type: Copy,dependsOn: [build,copyJar]) {
//    from  'conf'
    //   into ('build/libs/eachend/conf')
}





task wrapper(type: Wrapper) {
    gradleVersion = '4.7'
}
```



---

# Application
增加 @EnableZuulProxy 注解开启 Zuul 功能

```
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.cloud.netflix.eureka.EnableEurekaClient;
import org.springframework.cloud.netflix.zuul.EnableZuulProxy;

@SpringBootApplication
@EnableEurekaClient
@EnableZuulProxy
public class ZuulApplication {
    public static void main(String[] args) {
        SpringApplication.run(ZuulApplication.class, args);
    }
}
```

---


# bootstrap.yml

```
server:
  port: 24000
#  host01: 112.74.195.125
#  host02: 120.25.218.19
  host01: 192.168.0.21
  host02: 192.168.0.49
  regport: 26000

spring:
  application:
    name: mc-zuul
  security:
    user:
      name: tinckay_dev
      password: x1016wm
#  boot:
#    admin:
#      client:
#        url: http://localhost:23000
#        url: http://${server.host01}:23000，http://${server.host02}:23000

eureka:
  instance:
#    hostname: localhost
    prefer-ip-address: true
    lease-renewal-interval-in-seconds: 5
    lease-expiration-duration-in-seconds: 15
  client:
    registerWithEureka: true
    fetchRegistry: true
#    与服务端连接超时
    eureka-server-connect-timeout-seconds: 20
#    从注册中心获取注册信息的时间
    registry-fetch-interval-seconds: 5
    serviceUrl:
      defaultZone: http://localhost:${server.regport}/eureka
#      defaultZone: http://${server.host01}:${server.regport}/eureka,http://${server.host02}:${server.regport}/eureka
#      defaultZone: http://tinckay_dev:x1016wm@192.168.1.201:26000/eureka,http://tinckay_dev:x1016wm@192.168.1.202:26000/eureka

management:
  endpoint:
    health:
      show-details: always
  endpoints:
    web:
      exposure:
        include: '*'

zuul:
#  请求并发的线程数
  semaphore:
    max-semaphores: 5000
  add-host-header: true
#  敏感头信息
  sensitive-headers:
  host:
    connect-timeout-millis: 60000
    socket-timeout-millis: 60000
#    每个路由的初始连接数
    max-per-route-connections: 1000
#    总连接数
    max-total-connections: 1000
  routes:
    loginSys:
      path: /loginSys/**
      serviceId: loginSys
    onlineEc:
      path: /onlineEc/**
      serviceId: onlineEc
    onlineSys:
      path: /onlineSys/**
      serviceId: onlineSys
    AIR-STATION:
      path: /airStation/**
      serviceId: air-station
    onlineFlow:
      path: /onlineFlow/**
      serviceId: onlineFlow
    section:
      path: /section/**
      serviceId: section
    onlineOffice:
      path: /onlineOffice/**
      serviceId: onlineOffice
    Api:
      path: /demo/**
      serviceId: demo-1



ribbon:
  MaxAutoRetries: 1
  MaxAutoRetriesNextServer: 2
  ConnectTimeout: 60000
  ReadTimeout:  60000
#ribbonTimeout为(ribbonReadTimeout + ribbonConnectTimeout) * (maxAutoRetries + 1) * (maxAutoRetriesNextServer + 1)

hystrix:
  command:
    default:
      execution:
        isolation:
          thread:
            timeoutInMilliseconds:  60000
```


路由说明：

- 以 /api/a 开头的请求都转发给 hello-spring-cloud-web-admin-ribbon 服务
- 以 /api/b 开头的请求都转发给 hello-spring-cloud-web-admin-feign 服务
 

---

# 测试访问
打开浏览器访问：http://localhost:8769/api/a/hi?message=HelloZuul

打开浏览器访问：http://localhost:8769/api/b/hi?message=HelloZuul


---


# 配置网关路由失败时的回调

```
import com.fasterxml.jackson.databind.ObjectMapper;
import org.springframework.cloud.netflix.zuul.filters.route.FallbackProvider;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.client.ClientHttpResponse;
import org.springframework.stereotype.Component;

import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.util.HashMap;
import java.util.Map;

/**
 * 路由 hello-spring-cloud-web-admin-feign 失败时的回调
 * <p>Title: WebAdminFeignFallbackProvider</p>
 * <p>Description: </p>
 *
 * @author Lusifer
 * @version 1.0.0
 * @date 2018/7/27 6:55
 */
@Component
public class WebAdminFeignFallbackProvider implements FallbackProvider {

    @Override
    public String getRoute() {
        // ServiceId，如果需要所有调用都支持回退，则 return "*" 或 return null
        return "hello-spring-cloud-web-admin-feign";
    }

    /**
     * 如果请求服务失败，则返回指定的信息给调用者
     * @param route
     * @param cause
     * @return
     */
    @Override
    public ClientHttpResponse fallbackResponse(String route, Throwable cause) {
        return new ClientHttpResponse() {
            /**
             * 网关向 api 服务请求失败了，但是消费者客户端向网关发起的请求是成功的，
             * 不应该把 api 的 404,500 等问题抛给客户端
             * 网关和 api 服务集群对于客户端来说是黑盒
             * @return
             * @throws IOException
             */
            @Override
            public HttpStatus getStatusCode() throws IOException {
                return HttpStatus.OK;
            }

            @Override
            public int getRawStatusCode() throws IOException {
                return HttpStatus.OK.value();
            }

            @Override
            public String getStatusText() throws IOException {
                return HttpStatus.OK.getReasonPhrase();
            }

            @Override
            public void close() {

            }

            @Override
            public InputStream getBody() throws IOException {
                ObjectMapper objectMapper = new ObjectMapper();
                Map<String, Object> map = new HashMap<>();
                map.put("status", 200);
                map.put("message", "无法连接，请检查您的网络");
                return new ByteArrayInputStream(objectMapper.writeValueAsString(map).getBytes("UTF-8"));
            }

            @Override
            public HttpHeaders getHeaders() {
                HttpHeaders headers = new HttpHeaders();
                // 和 getBody 中的内容编码一致
                headers.setContentType(MediaType.APPLICATION_JSON_UTF8);
                return headers;
            }
        };
    }
}
```

---

# 使用路由网关的服务过滤功能

继承 ==ZuulFilter== 类并在类上增加== @Component== 注解就可以使用服务过滤功能了，非常简单方便


```
package com.funtl.hello.spring.cloud.zuul.filter;

import com.netflix.zuul.ZuulFilter;
import com.netflix.zuul.context.RequestContext;
import com.netflix.zuul.exception.ZuulException;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Component;

import javax.servlet.http.HttpServletRequest;
import java.io.IOException;

/**
 * Zuul 的服务过滤演示
 * <p>Title: LoginFilter</p>
 * <p>Description: </p>
 *
 * @author Lusifer
 * @version 1.0.0
 * @date 2018/5/29 22:02
 */
@Component
public class LoginFilter extends ZuulFilter {

    private static final Logger logger = LoggerFactory.getLogger(LoginFilter.class);

    /**
     * 配置过滤类型，有四种不同生命周期的过滤器类型
     * 1. pre：路由之前
     * 2. routing：路由之时
     * 3. post：路由之后
     * 4. error：发送错误调用
     * @return
     */
    @Override
    public String filterType() {
        return "pre";
    }

    /**
     * 配置过滤的顺序
     * @return
     */
    @Override
    public int filterOrder() {
        return 0;
    }

    /**
     * 配置是否需要过滤：true/需要，false/不需要
     * @return
     */
    @Override
    public boolean shouldFilter() {
        return true;
    }

    /**
     * 过滤器的具体业务代码
     * @return
     * @throws ZuulException
     */
    @Override
    public Object run() throws ZuulException {
        RequestContext context = RequestContext.getCurrentContext();
        HttpServletRequest request = context.getRequest();
        logger.info("{} >>> {}", request.getMethod(), request.getRequestURL().toString());
        String token = request.getParameter("token");
        if (token == null) {
            logger.warn("Token is empty");
            context.setSendZuulResponse(false);
            context.setResponseStatusCode(401);
            try {
                context.getResponse().getWriter().write("Token is empty");
            } catch (IOException e) {
            }
        } else {
            logger.info("OK");
        }
        return null;
    }
}
```
**filterType**

返回一个字符串代表过滤器的类型，在 Zuul 中定义了四种不同生命周期的过滤器类型

- pre：路由之前
- routing：路由之时
- post： 路由之后
- error：发送错误调用
- filterOrder
过滤的顺序

**shouldFilter**

是否需要过滤，这里是 true，需要过滤

**run**

过滤器的具体业务代码

---

# 关于Zuul丢失Cookie


```

@Data
@ConfigurationProperties("zuul")
public class ZuulProperties {
    private Set<String> sensitiveHeaders = new LinkedHashSet<>(
            Arrays.asList("Cookie", "Set-Cookie", "Authorization"));
    ...
}

```
  PreDecorationFilter过滤器会调用ProxyRequestHelper的addIgnoredHeaders方法把敏感信息（ZuulProperties的sensitiveHeaders属性）添加到请求上下文的IGNORED_HEADERS中

sensitiveHeaders的默认值初始值是"Cookie", "Set-Cookie", "Authorization"这三项，可以看到Cookie被列为了敏感信息，所以不会放到新header中

##### 解决方法：配置sensitiveHeaders为空


```
zuul:
  sensitiveHeaders:  
  host:
    socket-timeout-millis: 60000
    connect-timeout-millis: 60000  
```







# 服务监控简介
随着开发周期的推移，项目会不断变大，切分出的服务也会越来越多，这时一个个的微服务构成了错综复杂的系统。对于各个微服务系统的健康状态、会话数量、并发数、服务资源、延迟等度量信息的收集就成为了一个挑战。Spring Boot Admin 应运而生，它正式基于这些需求开发出的一套功能强大的监控管理系统。

Spring Boot Admin 有两个角色组成，一个是 Spring Boot Admin Server，一个是 Spring Boot Admin Client，本章节将带领大家实现 Spring Boot Admin 的搭建。

# 创建一个工程名为 itoken-admin 的项目，pom.xml 文件如下：

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

    <artifactId>itoken-admin</artifactId>
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
            <artifactId>spring-boot-starter-webflux</artifactId>
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

        <dependency>
            <groupId>org.jolokia</groupId>
            <artifactId>jolokia-core</artifactId>
        </dependency>
        <dependency>
            <groupId>de.codecentric</groupId>
            <artifactId>spring-boot-admin-starter-server</artifactId>
        </dependency>
        <!-- Spring Boot End -->

        <!-- Spring Cloud Begin -->
        <!-- 链路追踪 -->
        <dependency>
            <groupId>org.springframework.cloud</groupId>
            <artifactId>spring-cloud-starter-zipkin</artifactId>
        </dependency>
        <!-- 链路追踪 -->
        <dependency>
            <groupId>org.springframework.cloud</groupId>
            <artifactId>spring-cloud-starter-config</artifactId>
        </dependency>
        <dependency>
            <groupId>org.springframework.cloud</groupId>
            <artifactId>spring-cloud-starter-netflix-eureka-server</artifactId>
        </dependency>
        <!-- Spring Cloud End -->
    </dependencies>

    <build>
        <plugins>
            <plugin>
                <groupId>org.springframework.boot</groupId>
                <artifactId>spring-boot-maven-plugin</artifactId>
                <configuration>
                    <mainClass>com.tangdi.itoken.admin.AdminApplication</mainClass>
                </configuration>
            </plugin>
        </plugins>
    </build>
</project>
```

###### ==注意 spring-boot-admin-starter-server 的版本号为：2.0.1，这里没写版本号是因为我已将版本号托管到 dependencies 项目中==


---


# Application
通过 @EnableAdminServer 注解开启 Admin 功能

```
import de.codecentric.boot.admin.server.config.EnableAdminServer;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.cloud.netflix.eureka.EnableEurekaClient;

@SpringBootApplication
@EnableEurekaClient
@EnableAdminServer
public class AdminApplication {
    public static void main(String[] args) {
        SpringApplication.run(AdminApplication.class, args);
    }
}
```

---

# bootstrap.yml

```
spring:
  application:
    name: itoken-admin
  zipkin:
    base-url: http://localhost:9411

server:
  port: 8084

management:
  endpoint:
    health:
      show-details: always
  endpoints:
    web:
      exposure:
        include: health,info

eureka:
  client:
    serviceUrl:
      defaultZone: http://localhost:8761/eureka/
```

#bootstrap-prod.yml

```
spring:
  application:
    name: itoken-admin
  zipkin:
    base-url: http://192.168.243.135:9411

server:
  port: 8084

eureka:
  client:
    serviceUrl:
      defaultZone: http://192.168.243.135:8761/eureka/

management:
  endpoint:
    health:
      show-details: always
  endpoints:
    web:
      exposure:
        include: health,info
```


---


# 测试访问监控中心
打开浏览器访问：http://localhost:8084


---


# 客户端使用admin服务监控方法

### 使用服务监控的客户端增加以下依赖：

```
<dependency>
    <groupId>org.jolokia</groupId>
    <artifactId>jolokia-core</artifactId>
</dependency>
<dependency>
    <groupId>de.codecentric</groupId>
    <artifactId>spring-boot-admin-starter-client</artifactId>
</dependency>
```
###### ==注意 spring-boot-admin-starter-client 的版本号为：2.0.1，这里没写版本号是因为我已将版本号托管到 dependencies 项目中==


### 使用服务监控的客户端增加以下配置：

```
spring:
  boot:
    admin:
      client:
        url: http://localhost:8084
```

---


# 测试服务监控
依次启动两个应用，打开浏览器访问：http://localhost:8084
# 简介
在分布式系统中，由于服务数量巨多，为了方便服务配置文件统一管理，实时更新，所以需要分布式配置中心组件。在 Spring Cloud 中，有分布式配置中心组件 Spring Cloud Config ，它支持配置服务放在配置服务的内存中（即本地），也支持放在远程 Git 仓库中。在 Spring Cloud Config 组件中，分两个角色，一是 Config Server，二是 Config Client。

---

# 创建一个工程名为 itoken-config 的项目，pom.xml 配置文件如下：
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

    <artifactId>itoken-config</artifactId>
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
            <artifactId>spring-cloud-config-server</artifactId>
        </dependency>
        <dependency>
            <groupId>org.springframework.cloud</groupId>
            <artifactId>spring-cloud-starter-netflix-eureka-server</artifactId>
        </dependency>
        <!-- Spring Cloud End -->

        <!-- 链路追踪以及服务监控 -->
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
        <!-- 链路追踪以及服务监控 -->
    </dependencies>

    <build>
        <plugins>
            <plugin>
                <groupId>org.springframework.boot</groupId>
                <artifactId>spring-boot-maven-plugin</artifactId>
                <configuration>
                    <mainClass>com.tangdi.itoken.config.ConfigApplication</mainClass>
                </configuration>
            </plugin>
        </plugins>
    </build>
</project>
```
# Application
通过 @EnableConfigServer 注解，开启配置服务器功能

```
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.cloud.config.server.EnableConfigServer;
import org.springframework.cloud.netflix.eureka.EnableEurekaClient;

@SpringBootApplication
@EnableConfigServer
@EnableEurekaClient
public class ConfigApplication {
    public static void main(String[] args) {
        SpringApplication.run(ConfigApplication.class, args);
    }
}
```
# bootstrap.yml


```
spring:
  application:
    name: itoken-config
  cloud:
    config:
      label: master
      server:
        git:
          uri: http://192.168.243.129:8080/Itoken/itoken-config.git
          search-paths: respo
          username: tangdi1103
          password: wangwentao
  zipkin:
      base-url: http://localhost:9411
  boot:
    admin:
      client:
        url: http://localhost:8084

server:
  port: 8888

eureka:
  client:
    serviceUrl:
      defaultZone: http://localhost:8761/eureka/

management:
  endpoint:
    health:
      show-details: always
  endpoints:
    web:
      exposure:
        include: health,info
```

# bootstrap-prod.yml


```
spring:
  application:
    name: itoken-config
  cloud:
    config:
      label: master
      server:
        git:
          uri: http://192.168.243.129:8080/Itoken/itoken-config.git
          search-paths: respo
          username: tangdi1103
          password: wangwentao
  zipkin:
      base-url: http://192.168.243.135:9411
  boot:
    admin:
      client:
        url: http://192.168.243.135:8084

server:
  port: 8888

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

相关配置说明，如下：

- spring.cloud.config.label：配置仓库的分支
- spring.cloud.config.server.git.uri：配置 Git 仓库地址（GitHub、GitLab、码云 …）
- spring.cloud.config.server.git.search-paths：配置仓库路径（存放配置文件的目录）
- spring.cloud.config.server.git.username：访问 Git 仓库的账号
- spring.cloud.config.server.git.password：访问 Git 仓库的密码


# 测试
浏览器端访问：http://localhost:8888/itoken-XXXXX/dev/master

# 附：HTTP 请求地址和资源文件映射
- http://ip:port/{application}/{profile}[/{label}]
- http://ip:port/{application}-{profile}.yml
- http://ip:port/{label}/{application}-{profile}.yml
- http://ip:port/{application}-{profile}.properties
- http://ip:port/{label}/{application}-{profile}.properties


---


# 使用配置中心的客户端增加以下依赖：

```
<dependency>
    <groupId>org.springframework.cloud</groupId>
    <artifactId>spring-cloud-starter-config</artifactId>
</dependency>
```

# 使用配置中心的客户端yml配置改为：

#### ==开发环境==

```
spring:
  cloud:
      config:
        uri: http://localhost:8888
        name: itoken-xxx
        label: master
        profile: dev
```

#### ==生产环境==


```
spring:
  cloud:
    config:
      uri: http://192.168.243.135:8888
      name: itoken-xxx
      label: master
      profile: prod
```

相关配置说明，如下：

- ==spring.cloud.config.uri==：配置服务中心的网址
- ==spring.cloud.config.name==：配置文件名称的前缀
- ==spring.cloud.config.label==：配置仓库的分支
- ==spring.cloud.config.profile==：配置文件的环境标识
    - dev：表示开发环境
    - test：表示测试环境
    - prod：表示生产环境
    

###### ==注意事项==：

- 配置服务器的默认端口为 ==8888==，如果修改了默认端口，则客户端项目就不能在 ==application.yml== 或 ==application.properties== 中配置 ==spring.cloud.config.uri==，必须在 ==bootstrap.yml== 或是 ==bootstrap.properties== 中配置，原因是 ==bootstrap== 开头的配置文件会被优先加载和配置，切记。


---

# 附：开启 Spring Boot Profile

操作起来很简单，只需要为不同的环境编写专门的配置文件，如：==application-dev.yml==、==application-prod.yml==，
启动项目时只需要增加一个命令参数 ==--spring.profiles.active=环境配置== 即可，启动命令如下：


```
java -jar itoken-xxxx-1.0.0-SNAPSHOT.jar --spring.profiles.active=prod
```

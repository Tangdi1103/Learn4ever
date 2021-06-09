#  创建服务注册中心

用的组件是 Spring Cloud Netflix 的 Eureka，Eureka 是一个服务注册和发现模块

Eureka 是一个高可用的组件，它没有后端缓存，每一个实例注册之后需要向注册中心发送心跳（因此可以在内存中完成），在默认情况下 Erureka Server 也是一个 Eureka Client ,必须要指定一个 Server。

### pom.xml 文件配置如下：

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

    <artifactId>itoken-eureka</artifactId>
    <packaging>jar</packaging>

    <dependencies>
        <!-- Spring Boot Begin -->
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
                    <mainClass>com.tangdi.itoken.eureka.EurekaApplication</mainClass>
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


buildscript {
    ext {
        springBootVersion = '2.0.3.RELEASE'
    }
    repositories {
        mavenCentral()
    }

    dependencies {
        classpath("org.springframework.boot:spring-boot-gradle-plugin:${springBootVersion}")
    }
}


apply plugin: 'java'
apply plugin: 'eclipse'
apply plugin: 'idea'
apply plugin: 'org.springframework.boot'
apply plugin: 'io.spring.dependency-management'

bootJar {
    baseName = 'mc-regcenter'
    version = '1.0.0'
}

sourceCompatibility = 1.8
targetCompatibility = 1.8

repositories {
    maven { url 'http://maven.aliyun.com/nexus/content/repositories/central' }
    mavenCentral()
}


dependencyManagement {
    imports {
        mavenBom 'org.springframework.cloud:spring-cloud-dependencies:Finchley.RELEASE'
    }
}

repositories {
    maven {
        url 'https://repo.spring.io/libs-milestone'
    }
}

dependencies {
    compile('org.springframework.cloud:spring-cloud-starter-netflix-eureka-server')
    compile('org.springframework.boot:spring-boot-starter-security')
    testCompile group: 'junit', name: 'junit', version: '4.12'
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
### Application
启动一个服务注册中心，只需要一个注解 ==@EnableEurekaServer==
package com.funtl.hello.spring.cloud.eureka;


```
server:
  port: 26000
#  host01: 112.74.195.125
#  host02: 120.25.218.19
  host01: 192.168.0.21
  host02: 192.168.243.142

spring:
  application:
    name: mc-regcenter
  zipkin:
      base-url: http://localhost:9411
  boot:
    admin:
      client:
        url: http://localhost:8084
  security:
    user:
      name: 0000000
      password: 0000000

management:
  endpoint:
    health:
      show-details: always
  endpoints:
    web:
      exposure:
        include: health,info


eureka:
  server:
    #eureka server刷新readCacheMap的时间，注意，client读取的是readCacheMap，这个时间决定了多久会把readWriteCacheMap的缓存更新到readCacheMap上
    #默认0
    response-cache-update-interval-ms: 30000
    #eureka server缓存readWriteCacheMap失效时间，这个只有在这个时间过去后缓存才会失效，失效前不会更新，过期后从registry重新读取注册服务信息，registry是一个ConcurrentHashMap。
    #由于启用了eviction其实就用不太上改这个配置了
    #默认180s
    response-cache-auto-expiration-in-seconds: 180
    #启用主动失效，并且每次主动失效检测间隔为30s，默认为60s
    eviction-interval-timer-in-ms: 15000
    enable-self-preservation: false
  instance:
    lease-renewal-interval-in-seconds: 5
    lease-expiration-duration-in-seconds: 15
#    hostname: ${server.host01}
    prefer-ip-address: true
#    instance-id: ${server.host01}:${server.port}
  client:
    registerWithEureka: true
    fetchRegistry: true
    serviceUrl:
#      defaultZone: http://${server.host01}:${server.port}/eureka
      defaultZone: http://${server.host01}:${server.port}/eureka,http://${server.host02}:${server.port}/eureka
#      defaultZone: http://tinckay_dev:x1016wm@192.168.1.201:26000/eureka,http://tinckay_dev:x1016wm@192.168.1.202:26000/eureka



#服务提供者配置
  #服务过期时间配置,超过这个时间没有接收到心跳EurekaServer就会将这个实例剔除
  #注意，EurekaServer一定要设置eureka.server.eviction-interval-timer-in-ms否则这个配置无效，这个配置一般为服务刷新时间配置的三倍
  #默认90s
  #eureka.instance.lease-expiration-duration-in-seconds=15

  #服务刷新时间配置，每隔这个时间会主动心跳一次
  #默认30s
  #eureka.instance.lease-renewal-interval-in-seconds=5

#服务消费者配置
  #eureka client刷新本地缓存时间
  #默认30s
  #eureka.client.registry-fetch-interval-seconds=5

  #eureka客户端ribbon刷新时间
  #默认30s
  #ribbon.ServerListRefreshInterval=5000
```

### bootstrap-prod.yml

```
server:
  port: 26000
#  host01: 112.74.195.125
#  host02: 120.25.218.19
  host01: 192.168.0.21
  host02: 192.168.243.142

spring:
  application:
    name: mc-regcenter
  zipkin:
      base-url: http://localhost:9411
  boot:
    admin:
      client:
        url: http://localhost:8084
  security:
    user:
      name: tinckay_dev
      password: x1016wm

management:
  endpoint:
    health:
      show-details: always
  endpoints:
    web:
      exposure:
        include: health,info

eureka:
  server:
    #eureka server刷新readCacheMap的时间，注意，client读取的是readCacheMap，这个时间决定了多久会把readWriteCacheMap的缓存更新到readCacheMap上
    #默认0
    response-cache-update-interval-ms: 30000
    #eureka server缓存readWriteCacheMap失效时间，这个只有在这个时间过去后缓存才会失效，失效前不会更新，过期后从registry重新读取注册服务信息，registry是一个ConcurrentHashMap。
    #由于启用了eviction其实就用不太上改这个配置了
    #默认180s
    response-cache-auto-expiration-in-seconds: 180
    #启用主动失效，并且每次主动失效检测间隔为30s，默认为60s
    eviction-interval-timer-in-ms: 15000
#    enable-self-preservation: false
  instance:
    lease-renewal-interval-in-seconds: 5
    lease-expiration-duration-in-seconds: 15
#    hostname: ${server.host01}
    prefer-ip-address: true
#    instance-id: ${server.host01}:${server.port}
  client:
    registerWithEureka: true
    fetchRegistry: true
    serviceUrl:
#      defaultZone: http://${server.host01}:${server.port}/eureka
      defaultZone: http://${server.host01}:${server.port}/eureka,http://${server.host02}:${server.port}/eureka
#      defaultZone: http://tinckay_dev:x1016wm@192.168.1.201:26000/eureka,http://tinckay_dev:x1016wm@192.168.1.202:26000/eureka



#服务提供者配置
  #服务过期时间配置,超过这个时间没有接收到心跳EurekaServer就会将这个实例剔除
  #注意，EurekaServer一定要设置eureka.server.eviction-interval-timer-in-ms否则这个配置无效，这个配置一般为服务刷新时间配置的三倍
  #默认90s
  #eureka.instance.lease-expiration-duration-in-seconds=15

  #服务刷新时间配置，每隔这个时间会主动心跳一次
  #默认30s
  #eureka.instance.lease-renewal-interval-in-seconds=5

#服务消费者配置
  #eureka client刷新本地缓存时间
  #默认30s
  #eureka.client.registry-fetch-interval-seconds=5

  #eureka客户端ribbon刷新时间
  #默认30s
  #ribbon.ServerListRefreshInterval=5000
```

### 操作界面
Eureka Server 是有界面的，启动工程，打开浏览器访问：

http://host1:8761
http://host2:8761
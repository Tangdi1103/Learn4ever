[toc]

### 一、SpringBoot概念

**1.什么SpringBoot**

SpringBoot是一个用于快速搭建Spring项目的脚手架，能够尽可能快的跑起来项目并且尽可能的减少配置文件。利用约定优于配置原则省去配置繁杂配置文件、利用依赖启动器简化了pom文件的配置、内嵌Tomcat容器使应用可以直接启动。

**2.什么是约定优于配置**

约定优于配置是一种约定编程，是一种软件设计规范，对系统、框架中的一些东西设定一个大众化的缺省值（默认值）。如SpringBoot中遵循约定优于配置原则，整合的大部分组件及框架都提供了缺省值，约定的配置满足开发者自身需求的话，可不做任何配置，大大简化了配置文件的编写

**3.SpringBoot有哪些特性（核心），分别具有什么优点**

1. 起步依赖（Spring boot starter）

   起步依赖将某功能常用的依赖进行整合，合并到一个依赖中，版本由起步依赖统一管理，简化了繁杂的pom配置以及依赖冲突的管理

2. JavaConfig

   Spring从3.0开始支持JavaConfig，Spring4.0后全面支持JavaConfig，通过Java类的形式进行配置配合注解，大大提供了工作效率

3. 自动配置（详情见源码剖析）

   利用Spring对条件化配置的支持，推测SpringBoot整合的一些框架所需的bean并自动配置他们。通过起步依赖可实现自定义框架bean的自动配置

4. 内嵌Web容器

   SpringBoot内嵌Tomcat、Jetty、undertow三种Web容器，只需一个Java的运行环境，即可直接将SpringBoot项项目跑起来，SpringBoot的项目可打成一个jar包

### 二、关于Spring的一些疑问，以供思考

1. starter是什么？我们如何去使用这些starter？

2. 为什么包扫描只会扫描核心启动类所在的包及其子包

3. 在springBoot启动的过程中，是如何完成自动装配的？

4. 内嵌Tomcat是如何被创建及启动的？

5. 使用了web场景对应的starter，springmvc是如何自动装配？  

### 三、Springboot的热部署

##### **1.添加spring-boot-devtools热部署依赖启动器**

```xml
<!-- 引入热部署依赖 -->
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-devtools</artifactId>
</dependency>
```

##### **2.IDEA设置自动编译**

![image-20210707162350390](images/image-20210707162350390.png)

Ctrl+Alt+Shift+/打开Maintenance  ，选择Registry，找到"compiler.automake.allow.when.app.running"  勾选Value值，允许项目运行时编译

![image-20210707163244443](images/image-20210707163244443.png)

##### **3.排除不触发自动加载资源**

```properties
spring.devtools.restart.exclude=static/**,public/**
```



##### **4.SpringBoot热部署原理**

1. SpringBootDevtools自定义了两个类加载器：restartClassLoader和baseclassloader
2. restartClassLoader加载本项目classpath文件
3. baseclassloader则只加载三方类库
4. restartClassLoader监控classpath文件，若重新编译后classpath发生变化，则重新加载classpath
5. 重新加载classpath时，无需再加载三方类库，使项目无需重启便能代码生效

### 四、Springboot全局配置

正如spring项目有applicationContext.xml，springmvc有springmvc.xml一样，SpringBoot也有配置文件：application.properties，这是一个全局配置文件对项目中所有组件生效。

##### 1.全局配置文件可存放的路径，以及不同路径加载优先级顺序如下

1. **/config**（项目根路径下的config文件夹）

2. **/ **（项目根路径下）

3. **resources/config** （resources目录下的config文件夹）

4. **resources/**（resources目录下）

##### 2.全局配置文件的命名规范及同目录下加载优先级

- application.yml或者application.properties

- springboot-2.4.0之前：properties优先级大于yaml文件；springboot-2.4.0之后：yaml优先级大于properties文件，也可通过配置强制哪个生效

  ```properties
  ## 配置以下属性可优先加载该配置文件
  srping.config.use-legacy-processing=true
  ```

- 若不以application开头命名，则在程序启动时指定全局配置文件，指令如下

  ```sh
  $ java -jar myproject.jar --spring.config.name=myproject
  ```

##### 3.存在多全局配置文件的情况

- 存在多个全局配置文件时，若配置属性冲突，以优先读取的属性为准

- 存在多个全局配置文件时，若配置属性不冲突，则共同生效-形成互补

##### 4.指定外部全局配置文件

```sh
java -jar run-0.0.1-SNAPSHOT.jar --spring.config.location=D:/application.properties
```

##### 5.当使用@ConfigurationProperties自定义配置项时，可通过以下依赖，在配置文件中进行书写提示 

 ```xml
 <dependency>
     <groupId>org.springframework.boot</groupId>
     <artifactId>spring-boot-configuration-processor</artifactId>
     <optional>true</optional>
 </dependency>
 ```

##### 6.properties书写规范

```properties
#数组
person.hobby=吃饭,睡觉

#Map
person.map.k1=v1
person.map.k2=v2

#集合
person.family=爸爸,妈妈

#引用对象
person.pet.type=狗
person.pet.name=旺财
```

##### 7.yaml书写规范

```yaml
#数组
person:
  hobby: [吃饭，睡觉，打豆豆]

#Map
person:
  map: {k1: v1,k2: v2}

person:
  map:
    k1: v1
    k2: v2
#集合
person:
  hobby:
    - play
    - read
    - sleep

person:
  hobby: [play,read,sleep]
#引用对象
person:
  pet: {type: dog,name: 旺财}
```



### 五、属性注入

##### 1.@ConfigurationProperties

每个springboot的jar包META-INF下都会有一个spring.factories文件记录所有的配置类

体现面向对象编程，全局配置中所有默认的配置属性都能一一对应一个Javaconfig。通过在全局配置文件中定义属性值，在springboot启动的时候，读取带**@ConfigurationProperties(prefix = "mq.upp.callback.rocket", ignoreUnknownFields = false)**和**@Component**的配置类，根据注解属性值去全局配置中找对应的属性值，然后通过setter组装到javaconfig中

```java
@ConfigurationProperties(prefix = "mq.upp.callback.rocket", ignoreUnknownFields = false) // 通过setter批量注入属性
@Component //将对象存入IoC容器
public class RocketMqUPPCallBackConfig {
```

若在全局配置文件中配置自定义的属性，可先定义带以上两个注解的javaConfig，然后配置以下依赖，就能在全局配置中自动提醒javaConfig的属性

```xml
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-configuration-processor</artifactId>
    <optional>true</optional>
</dependency>
```

##### 2.@Value

##### 3.松散绑定

### 六、日志系统

1. 抽象层+实现层组合搭建（若只使用抽象层，意味着日志输出到空 > dev/null）
2. 常见日志框架及选型：JCL、Log4j、Logback、JUL
3. spring中使用的日志框架和springboot使用的日志框架
4. 抽象层作为门面，通过门面调用具体的实现。日志配置文件使用的是实现层框架自己的配置
5. 项目开发时，由于maven存在依赖传递，项目中存在多个日志实现层，怎么统一日志框架的使用？

### 七、内嵌web容器

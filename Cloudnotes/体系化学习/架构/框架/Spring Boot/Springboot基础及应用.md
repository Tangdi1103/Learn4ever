### 一、SpringBoot概念

1. 什么SpringBoot
2. 什么是约定由于配置
3. SpringBoot有哪些特性（核心），分别具有什么优点
   1. 什么是起步依赖（Spring boot starter），有哪些优点
   2. 什么是JavaConfig，有哪些优点（说说spring3.0、4.0的servlet规范）
   3. 什么是自动配置，有哪些优点
   4. 为什么不需要配置web容器就可以直接启动？

### 二、Springboot的热部署——DevTools

1. 重新编译更改classpath资源文件
2. 自定义类加载器RestartClassLoader加载自开发项目类
3. 而APPClassLoader则只加载三方类库
4. RestartClassLoader类加载器来监控classpath的变动，若发生变动则重新加载类

​	自定义了一个RestartClassLoader来监控classpath下的变动来重新加载类，而依赖的三方类库还是由APPClassLoader在服务启动的时候加载。再配合自动编译实现了无需重启服务，也能使更改代码实时生效

### 三、Springboot全局配置

1. 全局配置文件可存放的路径，以及其优先级为：/config  >  /  >  resources/config  >  resources/

2. （不同路径）多个全局配置文件时，存在相同属性时，以优先读取的为准

3. （不同路径）多个全局配置文件时，配置的不同属性都可以生效

4. springboot-2.4.0之前：properties优先级大于yaml文件；springboot-2.4.0之后：yaml优先级大于properties文件

   ```properties
   ## 配置以下属性可优先加载该配置文件
   srping.config.use-legacy-processing=true
   ```

   

5. springboot加载全局配置默认匹配application开头的文件并且properties/yml结尾的文件

   ```sh
   // 脚本启动jar包时，可通过--spring.config.name指定非application开头的全局配置文件
   java -jar --spring.config.name=test.properties test.jar
   
   // 脚本启动jar包时，可通过--spring.config.location额外加载一个物理路径下的全局配置，形成配置互补
   java -jar --spring.config.location=D:/xxxx.properties test.jar
   ```

   

### 四、属性注入

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

### 五、日志系统

1. 抽象层+实现层组合搭建（若只使用抽象层，意味着日志输出到空 > dev/null）
2. 常见日志框架及选型：JCL、Log4j、Logback、JUL
3. spring中使用的日志框架和springboot使用的日志框架
4. 抽象层作为门面，通过门面调用具体的实现。日志配置文件使用的是实现层框架自己的配置
5. 项目开发时，由于maven存在依赖传递，项目中存在多个日志实现层，怎么统一日志框架的使用？

### 六、内嵌web容器

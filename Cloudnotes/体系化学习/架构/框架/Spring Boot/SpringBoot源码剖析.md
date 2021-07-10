[toc]

## 一、我们带着以下疑问看源码

1. starter是什么？我们如何去使用这些starter？
2. 为什么包扫描只会扫描核心启动类所在的包及其子包
3. 在springBoot启动的过程中，是如何完成自动装配的？
4. 内嵌Tomcat是如何被创建及启动的？
5. 使用了web场景对应的starter，springmvc是如何自动装配？  

## 二、spring-boot-starter

spring-boot-starter也称依赖起步器，每个功能的starter都封装了所需的所有依赖，并且通过spring-boot-dependencies统一依赖管理项目进行统一的依赖管理。

springboot整合了众多starter，基于Maven的依赖传递原理，比如我们现在进行Web项目开发，只需依赖一个sping-boot-starter-web包并且可以不配置版本号，就能快速进行web项目开发。sping-boot-starter-web包含了spring、springmvc、tomcat、jackson等依赖下所有的jar包。



## 二、SpringBoot启动流程（未作）

## 三、SpringBoot自动配置原理

### 1.SpringBoot的启动配置类往往是由@SpringBootApplication注解所标注的类，通过该类的main方法启动SpringBoot应用

![image-20210706230528670](images/image-20210706230528670.png)

##### 1.1 @SpringBootApplication注解由以下三个注解组合而成

![image-20210706230558354](images/image-20210706230558354.png)

##### 1.2 @SpringBootConfiguration-标识为配置类

![image-20210706230615750](images/image-20210706230615750.png)

##### 1.3 @EnableAutoConfiguration-开启自动配置

![image-20210706230632549](images/image-20210706230632549.png)

##### 1.4 @ComponentScan-注解扫描路径

![image-20210706230825276](images/image-20210706230825276.png)

### 2.@EnableAutoConfiguration是自动配置的核心

由@AutoConfigurationPackage和@Import(AutoConfigurationImportSelector.class)组合成。

##### 2.1 @AutoConfigurationPackage使用@Import向SpringIoC容器注册了一个basePackage，默认是启动配置类的包路径。

![image-20210706230949300](images/image-20210706230949300.png)

##### 2.2 (自动配置核心组件)@Import(AutoConfigurationImportSelector.class)向容器注册了一个Selector组件

### 3.自动配置的核心逻辑在DeferredImportSelectorGrouping#getImports方法中

![image-20210706230426773](images/image-20210706230426773.png)

##### 3.1 调用AutoConfigurationImportSelector.AutoConfigurationGroup#process，再调用AutoConfigurationImportSelector#selectImports

selectImports方法是ImportSelector组件获取自动配置bean信息的核心方法，得到所有的自动配置bean信息后放入Map中

![image-20210710231458941](images/image-20210710231458941.png)

![image-20210711002501568](images/image-20210711002501568.png)

##### 3.2 调用AutoConfigurationMetadataLoader#loadMetadata(java.lang.ClassLoader)读取相关文件

该方法读取所有jar包下的META-INF/spring-autoconfigure-metadata.properties文件，作为后续bean过滤的条件

![image-20210711000023732](images/image-20210711000023732.png)

##### 3.3 调用AutoConfigurationImportSelector#getCandidateConfigurations，再调用SpringFactoriesLoader#loadFactoryNames

该方法读取所有jar包下的META-INF/spring.factories文件，并读取该文件配置属性”EnableAutoConfiguration“的值，得到需要被自动加载bean的全限定类名。

![image-20210711000141694](images/image-20210711000141694.png)

![image-20210711000447016](images/image-20210711000447016.png)

##### 3.4 调用AutoConfigurationImportSelector#filter将不符合条件的bean信息过滤

根据配置中得到的ConditionOnXXX等过滤条件过滤不符合条件的自动配置bean

![image-20210711001510802](images/image-20210711001510802.png)

### 4.具体的逻辑触发时机以及后续beanDefinition注册请查看[SpringIoC源码剖析步骤6.4](../Spring/SpringIoC/源码解析)

## 四、内嵌Web容器原理

![image-20210707005142384](images/image-20210707005142384.png)



### 1.自动配置

通过自动配置注入ServletWebServerFactory的自动配置类，该自动配置类通过@Import注入Tomcat、jetty、undertow组件（根据ConditionOnXXX判断是否注入容器）

### 1.SpringIoC容器执行AbstractApplicationContext#refresh进行容器刷新时，其中有一步调用onRefresh方法进行特殊bean的处理

![image-20210707005500421](images/image-20210707005500421.png)

### 3.org.springframework.boot.web.servlet.context.ServletWebServerApplicationContext#onRefresh负责Servlet容器的创建及启动工作

##### 1.调用createWebServer方法获得嵌入式的Web容器工厂。通过工厂获得Web容器并且启动

![image-20210707000459166](images/image-20210707000459166.png)

##### 2.由于刚启动所以没有servletContext和webServer，先获得工厂，然后创建web服务

![image-20210707000744795](images/image-20210707000744795.png)

##### 3.通过beanFactory获得ServletWebServerFactory的对象

![image-20210707001149454](images/image-20210707001149454.png)

##### 4.执行org.springframework.boot.web.servlet.server.ServletWebServerFactory#getWebServer，根据项目pom的配置默认使用tomcat,执行TomcatServletWebServerFactory#getWebServer实例化tomcat，逻辑如下：

**创建Tomcat实例**

**设置目录、协议等信息**

![image-20210707001540538](images/image-20210707001540538.png)

##### 5.最后一步getTomcatWebServer方法创建一个TomcatWebServer，并进行初始化以及启动Web服务

![image-20210707003015067](images/image-20210707003015067.png)

![image-20210707003534578](images/image-20210707003534578.png)

### 4.SpringIoC容器执行AbstractApplicationContext#refresh进行容器刷新时，最后一步finishRefresh进行Servlet启动以及最终日志打印

![image-20210707005500421](images/image-20210707005500421.png)

##### 1.ServletWebServerApplicationContext#finishRefresh进行内嵌Web容器最终打印及启动需要启动的Servlet

![image-20210707004531563](images/image-20210707004531563.png)

****

![image-20210707004624237](images/image-20210707004624237.png)

##### 2.根据项目pom的配置默认使用tomcat,执行org.springframework.boot.web.embedded.tomcat.TomcatWebServer#start

**启动<load-start-up>大于0的Servlet**

**打印最终日志**

![image-20210707005610821](images/image-20210707005610821.png)

## 五、自动装配SpringMVC（未作）

### 1.SpringBoot是如何在不配置web.xml的情况下将DispatchServlet注册到Web容器的ServletContext中的？

### 2.通过自动配置将DispatchServlet注入IoC

### 3.通过自动配置将DispatchServlet添加到ServletContext

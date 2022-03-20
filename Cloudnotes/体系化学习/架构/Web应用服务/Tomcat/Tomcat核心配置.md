[toc]

## 注意：

- Tomcat 作为服务器的配置，主要是 server.xml 文件的配置；

- server.xml中包含了 Servlet容器的相关配置，即 Catalina 的配置；

- Xml 文件的讲解主要是标签的使用

## 主要标签结构如下：

```xml
<!--Server 根元素，创建⼀个Server实例，⼦标签有 Listener、GlobalNamingResources、Service-->
<Server>
    
 <!--定义监听器-->
 <Listener/>
    
 <!--定义服务器的全局JNDI资源 -->
 <GlobalNamingResources/>
    
 <!--定义⼀个Service服务，⼀个Server标签可以有多个Service服务实例-->
 <Service/>
</Server>
```



## 1. Server 标签详情（1级标签）

```xml
<!--port：关闭服务器的监听端⼝shutdown：关闭服务器的指令字符串-->
<Server port="8005" shutdown="SHUTDOWN">
    
 <!-- 以⽇志形式输出服务器 、操作系统、JVM的版本信息 -->
 <Listener className="org.apache.catalina.startup.VersionLoggerListener" />
    
    
 <!-- Security listener. Documentation at /docs/config/listeners.html
 <Listener className="org.apache.catalina.security.SecurityListener" />
 -->
    
    
 <!--APR library loader. Documentation at /docs/apr.html -->
 <!-- 加载（服务器启动） 和 销毁 （服务器停⽌） APR。 如果找不到APR库， 则会输出⽇志， 并不影响 Tomcat启动 -->
 <Listener className="org.apache.catalina.core.AprLifecycleListener" SSLEngine="on" />
    
    
 <!-- Prevent memory leaks due to use of particular java/javax APIs-->
 <!-- 避免JRE内存泄漏问题 -->
 <Listener className="org.apache.catalina.core.JreMemoryLeakPreventionListener" />
    
    
 <!-- 加载（服务器启动） 和 销毁（服务器停⽌） 全局命名服务 -->
 <Listener className="org.apache.catalina.mbeans.GlobalResourcesLifecycleListener" />
    
    
 <!-- 在Context停⽌时重建 Executor 池中的线程， 以避免ThreadLocal 相关的内存泄漏 -->
 <Listener className="org.apache.catalina.core.ThreadLocalLeakPreventionListener" />
    
    
    <!-- Global JNDI resources Documentation at /docs/jndi-resources-howto.html GlobalNamingResources 中定义了全局命名服务-->
 <GlobalNamingResources>
 <!-- Editable user database that can also be used by UserDatabaseRealm to authenticate users-->
 	<Resource name="UserDatabase"
              auth="Container"
              type="org.apache.catalina.UserDatabase"
              description="User database that can be updated and saved" 
              factory="org.apache.catalina.users.MemoryUserDatabaseFactory" 
              pathname="conf/tomcat-users.xml" />
 </GlobalNamingResources>
    
    <!-- A "Service" is a collection of one or more "Connectors" that share
 a single "Container" Note: A "Service" is not itself a "Container",
 so you may not define subcomponents such as "Valves" at this level.
 Documentation at /docs/config/service.html
 -->
 <Service name="Catalina">
 	...
 </Service>
</Server>
```

### 1.1 Listener（2级标签）

定义监听器，如系统日志监听、资源声明周期监听等



### 1.2 GlobalNamingResources（2级标签）

定义服务器的全局JNDI资源



### 1.3 Service 标签（2级标签）

该标签用于创建 Service 实例，默认使⽤ org.apache.catalina.core.StandardService。默认情况下，Tomcat 仅指定了Service 的名称， 值为 "Catalina"。Service ⼦标签为 ： Listener、Executor、Connector、Engine，

- Listener 用于为Service添加生命周期监听器，
- **Executor** 用于配置Service 共享**线程池**，
- **Connector** 用于配置Service 包含的**连接器**，
- **Engine** 用于配置Service中连接器对应的**Servlet 容器引擎**

```xml
<Service name="Catalina">
 ...
</Service>
```

#### 1.3.1 Executor 标签（3级标签）

Service 共享线程池配置，可手动配置如下

- **name：**线程池名称，⽤于 Connector中指定
- namePrefix：所创建的每个线程的名称前缀，⼀个单独的线程名称为namePrefix+threadNumber
- **minSpareThreads：核心线程数**
-  **prestartminSpareThreads：**线程池启动是否直接初始化核心线程数的线程，默认值为false
- **maxIdleTime：空闲线程存活时间**，默认值为60000（1分钟），单位毫秒
- **maxThreads：**池中**最大线程数**
- **maxQueueSize：任务阻塞队列**，当达到最大线程数并且没有线程空闲时，放入阻塞队列，**大小默认为Integer.MAX_VALUE**
-  threadPriority：线程池中线程优先级，默认值为5，值从1到10
- className：线程池实现类，未指定情况下，默认实现类为 org.apache.catalina.core.StandardThreadExecutor。如果想使⽤⾃定义线程池⾸先需要实现org.apache.catalina.Executor接⼝

```xml
<Executor name="commonThreadPool"
 namePrefix="thread-exec-"
 maxThreads="200"
 minSpareThreads="100"
 maxIdleTime="60000"
 maxQueueSize="Integer.MAX_VALUE"
 prestartminSpareThreads="false"
 threadPriority="5"
 className="org.apache.catalina.core.StandardThreadExecutor"/>
```

#### 1.3.2 Connector 标签（3级标签）

Service 默认配置两个连接器，分别监听8080和8009，8080使用HTTP协议，8009使用AJP协议

- **port：**连接器监听的端口号
- **protocol：**连接器使用的协议，默认为 HTTP/1.1，使用 NIO 方式进行读写
- **connectionTimeOut：**连接器等待超时时间， 单位为 毫秒。 -1 表示不超时。
- **redirectPort：**当前连接器不支持SSL请求，当需要SSL传输，将请求重定向到指定的HTTPS端口
- **executor：**指定共享线程池的名称，**也可以内部自定义线程池**
- URIEncoding：用于指定编码URI的字符编码，Tomcat8.x版本默认的编码为 UTF-8，Tomcat7.x版本默认为ISO-8859-1
- **maxConnections：**最大连接数，CPU密集型程序不建议设置过大（如500） ; 对于IO密集型程序可以设置大些（如2000）
- **acceptCount：连接等待队列长度，默认100**。达到最大连接数时将请求放入等待队列

```xml
<!--org.apache.coyote.http11.Http11NioProtocol，即HTTP1.1协议、NIO非阻塞读写模式-->
<!--<Connector port="8080" protocol="HTTP/1.1" connectionTimeout="20000" redirectPort="8443" />-->

<!--org.apache.coyote.http11.Http11AprProtocol，即HTTP1.1协议、APR异步读写模式-->
<Connector port="8080" protocol="org.apache.coyote.http11.Http11AprProtocol" connectionTimeout="20000" redirectPort="8443" />


<Connector port="8009" protocol="AJP/1.3" redirectPort="8443" />

<!--可以使⽤共享线程池-->
<Connector port="8080" 
 protocol="HTTP/1.1"
 executor="commonThreadPool"
 maxThreads="1000" 
 minSpareThreads="100" 
 acceptCount="1000" 
 maxConnections="1000" 
 connectionTimeout="20000"
 compression="on" 
 compressionMinSize="2048" 
 disableUploadTimeout="true" 
 redirectPort="8443" 
 URIEncoding="UTF-8" />
```

#### 1.3.3 Engine 标签（3级标签）

Engine 表示 Servlet 引擎

- name： 用于指定Engine 的名称， 默认为Catalina
- defaultHost：默认虚拟主机名， 当URL请求无效主机，则使用该默认虚拟主机

```xml
<Engine name="Catalina" defaultHost="localhost">
 ...
</Engine>
```

##### 1.3.3.1 Host 标签（4级标签）及Context 标签

每个Tomcat一般只配置一个Host，**每个虚拟主机的webapps下可以有多个webapp，每个webapp的context默认为webapp的war包名**

- name：虚拟主机地址
- addBase：应用项目存放目录

也可以为每个webapp设置个性化的context，使用Context标签配置

- docBase：应用项目或者War包路径，可以是绝对路径，也可以是相对于 Host appBase的相对路径
- path：应用项目的context

如下Host名为 `www.wangfeng.com` ， pay-server 和 order-server的 context分别为 wf1 和 wf2

```xml
<Host name="localhost" appBase="webapps" unpackWARs="true" autoDeploy="true">
    <!--定义访问日志命名及日志格式-->
    <Valve className="org.apache.catalina.valves.AccessLogValve"
           directory="logs"
           prefix="localhost_access_log" suffix=".txt"
           pattern="%h %l %u %t &quot;%r&quot; %s %b" />
</Host>

<Host name="www.wangfeng.com" appBase="webapps2" unpackWARs="true" autoDeploy="true">
    <Context docBase="pay-server" path="wf1"></Context>
    <Context docBase="order-server" path="/wf2"></Context>
</Host>
```

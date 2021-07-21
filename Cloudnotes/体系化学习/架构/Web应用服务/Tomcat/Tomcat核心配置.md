[toc]

## 注意：

- Tomcat 作为服务器的配置，主要是 server.xml ⽂件的配置；

- server.xml中包含了 Servlet容器的相关配置，即 Catalina 的配置；

- Xml ⽂件的讲解主要是标签的使⽤

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



## Server 标签（1级标签）

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

### Service 标签（2级标签）

```xml
<!--
 该标签⽤于创建 Service 实例，默认使⽤ org.apache.catalina.core.StandardService。
 默认情况下，Tomcat 仅指定了Service 的名称， 值为 "Catalina"。
 Service ⼦标签为 ： Listener、Executor、Connector、Engine，
 其中：
 Listener ⽤于为Service添加⽣命周期监听器，
 Executor ⽤于配置Service 共享线程池，
 Connector ⽤于配置Service 包含的链接器，
 Engine ⽤于配置Service中链接器对应的Servlet 容器引擎
-->
<Service name="Catalina">
 ...
</Service>
```

#### Executor 标签（3级标签）

Service 并未添加共享线程池配置，可手动配置如下

```xml
<!--默认情况下，Service 并未添加共享线程池配置。 如果我们想添加⼀个线程池， 可以在<Service> 下添加如下配置：
 name：线程池名称，⽤于 Connector中指定
 namePrefix：所创建的每个线程的名称前缀，⼀个单独的线程名称为namePrefix+threadNumber
 maxThreads：池中最⼤线程数
 minSpareThreads：活跃线程数，也就是核⼼池线程数，这些线程不会被销毁，会⼀直存在
 maxIdleTime：线程空闲时间，超过该时间后，空闲线程会被销毁，默认值为6000（1分钟），单位毫秒
 maxQueueSize：在被执⾏前最⼤线程排队数⽬，默认为Int的最⼤值，也就是⼴义的⽆限。除⾮特殊情况，这个值 不需要更改，				否则会有请求不会被处理的情况发⽣
 prestartminSpareThreads：启动线程池时是否启动 minSpareThreads部分线程。默认值为false，即不启动
 threadPriority：线程池中线程优先级，默认值为5，值从1到10
 className：线程池实现类，未指定情况下，默认实现类为 org.apache.catalina.core.StandardThreadExecutor。如			果想使⽤⾃定义线程池⾸先需要实现org.apache.catalina.Executor接⼝
-->
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

#### Connector 标签（3级标签）

Connector 标签⽤于创建链接器实例

默认情况下，server.xml 配置了两个链接器，⼀个⽀持HTTP协议，⼀个⽀持AJP协议

⼤多数情况下，我们并不需要新增链接器配置，只是根据需要对已有链接器进⾏优化

```xml
<!--
 port：端⼝号，Connector ⽤于创建服务端Socket 并进⾏监听，以等待客户端请求链接。如果该属性设置为0，Tomcat将会随		机选择⼀个可⽤的端⼝号给当前Connector使⽤
 protocol：当前Connector ⽀持的访问协议。 默认为 HTTP/1.1 ， 并采⽤⾃动切换机制选择⼀个基于 JAVA NIO 的链接			器或者基于本地APR的链接器（根据本地是否含有Tomcat的本地库判定）
 connectionTimeOut：Connector 接收链接后的等待超时时间， 单位为 毫秒。 -1 表示不超时。
 redirectPort：当前Connector不⽀持SSL请求，接收到了⼀个请求，并且也符合security-constraint 约束，需要SSL传				输，Catalina⾃动将请求重定向到指定的端⼝。
 executor：指定共享线程池的名称， 也可以通过maxThreads、minSpareThreads 等属性配置内部线程池。
 URIEncoding：⽤于指定编码URI的字符编码， Tomcat8.x版本默认的编码为 UTF-8 , Tomcat7.x版本默认为ISO-8859-1
 maxConnections：最大连接数，对于CPU要求更⾼(计算密集型)时，建议不要配置过⼤ ; 对于CPU要求不是特别⾼时，建议配				置在2000左右(受服务器性能影响)。 当然这个需要服务器硬件的⽀持
 maxThreads：最大线程数，需要根据服务器的硬件情况，进⾏⼀个合理的设置
 acceptCount：最⼤排队等待数，当最大连接数满时，进入等待队列。⼀台Tomcat的最⼤的请求处理数量，是最大连接数+最大排				队等待数
-->
<!--org.apache.coyote.http11.Http11NioProtocol ， ⾮阻塞式 Java NIO 链接器-->
<Connector port="8080" protocol="HTTP/1.1" connectionTimeout="20000" redirectPort="8443" />

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

#### Engine 标签（3级标签）

Engine 表示 Servlet 引擎

```xml
<!--
name： ⽤于指定Engine 的名称， 默认为Catalina
defaultHost：默认使⽤的虚拟主机名称， 当客户端请求指向的主机⽆效时， 将交由默认的虚拟主机处
理， 默认为localhost
-->
<Engine name="Catalina" defaultHost="localhost">
 ...
</Engine>
```

##### **Host** 标签（4级标签）

Host 标签⽤于配置⼀个虚拟主机，可配置多个Host，根据不同的虚拟主机访问到不同的项目

```xml
<Host name="localhost" appBase="webapps" unpackWARs="true" autoDeploy="true">
 ...
</Host>

<Host name="www.wangfeng.com" appBase="webapps2" unpackWARs="true" autoDeploy="true">
 ...
</Host>
```

###### Context 标签（5级标签）

Context 标签⽤于配置⼀个Web应⽤，如下：

```xml
<Host name="www.abc.com" appBase="webapps" unpackWARs="true" autoDeploy="true">
<!-- docBase：Web应⽤⽬录或者War包的部署路径。可以是绝对路径，也可以是相对于 Host appBase的相对路径。
 	path：Web应⽤的Context 路径。如果我们Host名为localhost， 则该web应⽤访问的根路径：http://localhost:8080/web3。
-->
 <Context docBase="/Users/yingdian/web_demo" path="/web3"></Context> 
 
 <!--定义访问日志命名及日志格式-->
 <Valve className="org.apache.catalina.valves.AccessLogValve"
directory="logs"
 prefix="localhost_access_log" suffix=".txt"
 pattern="%h %l %u %t &quot;%r&quot; %s %b" />
</Host>
```




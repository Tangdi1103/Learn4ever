[toc]



## 一、Dubbo的SPI机制

### 1.Dubbo为什么不直接使用JDK自带的SPI机制？

##### [查看JDK SPI机制 -->](../../../java/基础/SPI机制)

##### JDK SPI的缺点：

1. 所有扩展实现都会被初始化并加载，影响了程序启动的耗时，若有扩展实现加载耗时又没被使用，影响了系统资源
2. 并且任意一个扩展实现加载失败，都会影响所有的扩展实现的使用

##### Dubbo SPI的改善

提供了对扩展点包装的功能(Adaptive)，实现动态加载扩展点，并且还支持通过set的方式对其他的扩展点进行注入



### 2.Dubbo SPI简介

![image-20210815224334650](images/image-20210815224334650.png)

Dubbo项目中大量使用Dubbo SPI ，定义了一些接口服务，如协议，负载均衡。并在**META-INF/dubbo.internal**包下提供了大量扩展实现，除此之外，使用Dubbo的开发者也可通过Dubbo SPI自定义实现扩展服务，

![image-20210815224121635](images/image-20210815224121635.png)



##### dubbo提供的默认负载均衡实现如下图所示：

![image-20210815225011591](images/image-20210815225011591.png)



### 3.使用Dubbo SPI自定义扩展实现

`SPI `自定义的扩展实现中，`SPI`声明文件以 `key-value` 形式存储，**key代表了某个扩展实现的标识**，**value为扩展实现的全限定类名**

##### 创建API工程

1. pom文件添加dubbo依赖

```xml
<dependencies>
    <dependency>
        <groupId>org.apache.dubbo</groupId>
        <artifactId>dubbo</artifactId>
        <version>2.7.5</version>
    </dependency>
</dependencies>
```

2. 定义接口服务，接口使用**@SPI**注解

```java
import org.apache.dubbo.common.URL;
import org.apache.dubbo.common.extension.Adaptive;
import org.apache.dubbo.common.extension.SPI;

@SPI
public interface HelloService {
    String  sayHello();
}
```



##### 创建扩展实现工程

1. 导入API工程的依赖
2. 编写两个扩展实现类

```java
import com.tangdi.service.HelloService;
import org.apache.dubbo.common.URL;

public class DogHelloService implements HelloService{
    @Override
    public String sayHello() {
        return "wang wang";
    }
}
```

```java
import com.tangdi.service.HelloService;
import org.apache.dubbo.common.URL;

public class HumanHelloService implements HelloService{
    @Override
    public String sayHello() {
        return "hello 你好";
    }
}
```

3.编写SPI声明文件，在**resources/META-INF/dubbo** （区别于dubbo默认的spi实现文件）目录下创建一个以“**接口全限定名**”为命名的文件，文件内部配置**两个实现类名称和对应的全限定名**

```
human=com.lagou.service.impl.HumanHelloService
dog=com.lagou.service.impl.DogHelloService
```



##### 创建使用工程

1.  导入API工程和扩展实现工程
2. 编写main函数，与jdk spi不同的是 dubbo spi 使用自己实现的**ExtensionLoader**来加载扩展实现类

```java
import com.tangdi.service.HelloService;
import org.apache.dubbo.common.extension.ExtensionLoader;

import java.util.Set;

public class DubboSpiMain {
    public static void main(String[] args) {
        // 获取扩展加载器
        ExtensionLoader<HelloService>  extensionLoader  = ExtensionLoader.getExtensionLoader(HelloService.class);
        // 遍历所有的支持的扩展点 META-INF.dubbo
        Set<String>  extensions = extensionLoader.getSupportedExtensions();
        for (String extension : extensions){
            String result = extensionLoader.getExtension(extension).sayHello();
            System.out.println(result);
        }

    }
}
```



### 4.Dubbo SPI的Adaptive功能

Dubbo中的Adaptive功能，是动态的选择具体的扩展点。通过getAdaptiveExtension 统一对指定接口对应的所有扩展点进行封装，通过URL的方式对扩展点来进行动态选择。 (dubbo中所有的注册信息都是通过URL的形式进行处理的)这里同样采用相同的方式进行实现

##### 在上面的基础上更改API工程

1. **@SPI 注解**的value值代表该接口默认的实现是什么，对应dubbo.internal文件中的key

2. **@Adaptive 注解**代表可以被动态选择的扩展实现方法

3. 在参数中提供URL参数.注意这里的URL参数的类为 `org.apache.dubbo.common.URL`

```java
import org.apache.dubbo.common.URL;
import org.apache.dubbo.common.extension.Adaptive;
import org.apache.dubbo.common.extension.SPI;

@SPI("human")
public interface HelloService {
    String  sayHello();
    @Adaptive
    String  sayHello(URL  url);
}
```



##### 在上面的基础上更改扩展实现工程

1. 实现类方法增加URL形参即可

```java
@Override
public String sayHello(URL url) {
    return "wang url";
}
```

```java
@Override
public String sayHello(URL url) {
    return "hello 你好";
}
```

2. SPI声明文件以key-value形式编写

```
human=com.lagou.service.impl.HumanHelloService
dog=com.lagou.service.impl.DogHelloService
```



##### 在上面的基础上更改使用工程

main 函数中需要传入URL参数，并且在参数中指定具体的实现类参数

URL的地址不限，关键是 `?` 后面跟上全限定接口名，然后指定扩展实现对应的key

```java
import com.tangdi.service.HelloService;
import org.apache.dubbo.common.URL;
import org.apache.dubbo.common.extension.ExtensionLoader;

public class DubboAdaptiveMain {
    public static void main(String[] args) {
        URL url = URL.valueOf("test://localhost/hello?hello.service=dog");
        // 获取所有扩展实现，封装到AdaptiveExtension
        HelloService adptExt = ExtensionLoader.getExtensionLoader(HelloService.class).getAdaptiveExtension();
        String  msg = adaptiveExtension.sayHello(url);
        System.out.println(msg);
    }
}
```



### 5.基于Dubbo SPI的Dubbo过滤器功能



## 二、负载均衡策略

### [Dubbo官网文档](https://dubbo.apache.org/zh/docs/advanced/loadbalance/)



## 三、异步调用

### [Dubbo官网文档](https://dubbo.apache.org/zh/docs/advanced/async-call/)

从 2.7.0 开始，Dubbo 的所有异步编程接口开始以 [CompletableFuture](https://docs.oracle.com/javase/8/docs/api/java/util/concurrent/CompletableFuture.html) 为基础

基于 NIO 的非阻塞实现并行调用，客户端不需要启动多线程即可完成并行调用多个远程服务，相对多线程开销较小

![image-20210816235737413](images/image-20210816235737413.png)



## 四、线程池

### [Dubbo官方文档 - 线程池配置](https://dubbo.apache.org/zh/docs/references/xml/dubbo-provider/)

### 1 Dubbo提供以下两种方式

##### 1.1 fifix（Dubbo默认）：固定大小线程池，启动时建立线程，不关闭，一直持有，默认创建的执行线程数为200，并且没有任何等待队列

在极端的情况下可能会存在问题，比如某个操作大量执行时，可能存在堵塞的情况。后面也会讲相关的处理办法。

##### 1.2 cache:：缓存线程池，空闲一分钟自动删除，当线程不足时，会自动创建新的线程。

如果突然有高TPS的请求过来，方法没有及时完成，则会造成大量的线程创建，极度消耗系统资源，拖慢系统性能甚至导致OOM

##### 1.3 limit：可伸缩线程池，但池中的线程数只会增长不会收缩。只增长不收缩的目的是为了避免收缩时突然来了大流量引起的性能问题

##### 1.4 eager：优先创建`Worker`线程池。

在任务数量大于`corePoolSize`但是小于`maximumPoolSize`时，优先创建`Worker`来处理任务。当任务数量大于`maximumPoolSize`时，将任务放入阻塞队列中。阻塞队列充满时抛出`RejectedExecutionException`。(相比于`cached`:`cached`在任务数量超过`maximumPoolSize`时直接抛出异常而不是将任务放入阻塞队列)



### 2 自定义Dubbo线程池

由于线程池的使用对于业务开发人员是无感的，只有fix模式的线程池中的线程不够处理请求或者cache模式的线程池创建大量线程导致程序OOM，引起的系统故障，业务开发人员才能得知发生问题了。

##### 现在要实现当线程池数量不够用，或者创建了大量线程超过阈值，发生告警

自定义线程池及实现线程池阈值告警



## 五、路由规则

### 基本路由规则介绍

##### [具体查看Dubbo官网](https://dubbo.apache.org/zh/docs/advanced/routing-rule/)

本质上就是通过在zookeeper中保存一个节点数据，来记录路由规则。消费者会通过监听这个服务的路径，来感知整个服务的路由规则配置，然后进行适配

路由规则在发起一次RPC调用前起到过滤目标服务器地址的作用，过滤后的地址列表，将作为消费端最终发起RPC调用的备选地址。

- 条件路由。支持以服务或 Consumer 应用为粒度配置路由规则。
- 标签路由。以 Provider 应用为粒度配置路由规则。

**2.6.x以上版本**随时在服务治理控制台 [Dubbo-Admin](https://github.com/apache/dubbo-admin) 写入路由规则

### Dubbo在不同场景下使用的路由方案

##### [具体查看Dubbo官网](https://dubbo.apache.org/zh/docs/examples/routing/)

##### [动态路由](https://dubbo.apache.org/zh/docs/examples/routing/dynamic-rule-deployment/)

类groovy脚本动态路由。

##### [权重路由](https://dubbo.apache.org/zh/docs/examples/routing/weight-rule-deployment/)

基于用户自定权重实现路由功能。

##### [使用案例](https://dubbo.apache.org/zh/docs/examples/routing/demo-rule-deployment/)

基于实际情况来制定路由规则。

##### [蓝绿部署](https://dubbo.apache.org/zh/docs/examples/routing/blue-green-deployment/)

在线上的老版本继续运行的前提下，直接部署新版本然后进行测试，当新版本测试通过以后，将流量切到新版本，最后将老版本同时也升级到新版本。

##### [Ab测试](https://dubbo.apache.org/zh/docs/examples/routing/ab-testing-deployment/)

在线上的老版本继续运行的前提下，直接部署新版本然后进行测试，当新版本测试通过以后，将流量切到新版本，最后将老版本同时也升级到新版本。

##### [金丝雀部署](https://dubbo.apache.org/zh/docs/examples/routing/canary-deployment/)

在原有版本可用的情况下，同时部署一个新版本应用作为“金丝雀”，测试新版本的性能和表现，在保障整体系统稳定的前提下，尽早发现、及时调整。



### 路由与上线系统结合

通过路由的规则，把预发布(灰度)的机器进行从机器列表中移除。并且等待一定的时间，让其把现有的请求处理完成之后再进行关闭服务。同时，在启动时，同样需要等待一定的时间，以免因为尚未重启结束，就已经注册上去。等启动到达一定时间之后，再进行开启流量操作

##### 实现主体思路

1. 利用zookeeper的路径感知能力，在服务准备进行重启之前将当前机器的IP地址和应用名写入 zookeeper。 

2. 服务消费者监听该目录，读取其中需要进行关闭的应用名和机器IP列表并且保存到内存中。 

3. 当前请求过来时，判断是否是请求该应用，如果是请求重启应用，则将该提供者从服务列表中移除。

##### 具体实现

1. 引入 Curator 框架，用于方便操作Zookeeper 

2. 编写Zookeeper的操作类，用于方便进行zookeeper处理

3. 编写需要进行预发布的路径管理器，用于缓存和监听所有的待灰度机器信息列表。

4. 编写路由类(实现 org.apache.dubbo.rpc.cluster.Router )，主要目的在于对ReadyRestartInstances 中的数据进行处理，并且移除路由调用列表中正在重启中的服务。

5. 由于 Router 机制比较特殊，所以需要利用一个专门的 RouterFactory 来生成，原因在于并不是所有的都需要添加路由，所以需要利用 @Activate 来锁定具体哪些服务才需要生成使用。

6. 对 RouterFactory 进行注册，同样放入到META-INF/dubbo/org.apache.dubbo.rpc.cluster.RouterFactory 文件中

7. 将dubbo-spi-router项目引入至 consumer 项目的依赖中。

8. 这时直接启动程序，还是利用上面中所写好的 consumer 程序进行执行，确认各个 provider 可以正常执行。

9. 单独写一个 main 函数来进行将某台实例设置为启动中的状态，比如这里我们认定为当前这台机器中的 service-provider 这个提供者需要进行重启操作。

10. 执行完成后，再次进行尝试通过 consumer 进行调用，即可看到当前这台机器没有再发送任何请求

11. 情况下，当机器重启到一定时间后，我们可以再通过 removeRestartingInstance 方法对这个机器设定为既可以继续执行。

12. 调用完成后，我们再次通过 consumer 去调用，即可看到已经再次恢当前机器的请求参数。

## 六、服务降级

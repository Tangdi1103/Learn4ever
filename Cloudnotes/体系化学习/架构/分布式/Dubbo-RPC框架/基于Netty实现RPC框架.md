[toc]

## 一、分布式架构网络通信

在分布式服务框架中，一个最基础的问题就是远程服务是怎么通讯的，在Java领域中有很多可实现远程通讯的技术，例如：RMI、Hessian、SOAP、ESB和JMS等，它们都实现了RPC

### 1. 基本原理

要实现网络机器间的通讯，首先得来看看计算机系统网络通信的基本原理，在底层层面去看，网络通信需要做的就是将流从一台计算机传输到另外一台计算机，基于传输协议和网络IO来实现，其中传输协议比较出名的有tcp、udp等等，tcp、udp都是在基于Socket概念上为某类应用场景而扩展出的传输协议，网络IO，主要有bio、nio、aio三种方式，所有的分布式应用通讯都基于这个原理而实现



### 2. 什么是RPC

RPC全称为remote procedure call，即远程过程调用。借助RPC可以做到像本地调用一样调用远程服务，是一种进程间的通信方式

比如两台服务器A和B，A服务器上部署一个应用，B服务器上部署一个应用，A服务器上的应用想调用B服务器上的应用提供的方法，由于两个应用不在一个内存空间，不能直接调用，所以需要通过网络来表达调用的语义和传达调用的数据。**需要注意的是RPC并不是一个具体的技术，而是指整个网络远程调用过程。**

![image-20210807114634981](images/image-20210807114634981.png)



### 3.RPC架构

 在java中RPC框架比较多，常见的有Hessian、gRPC、Dubbo、Motan等，其实对 于RPC框架而言，核心模块就是**通讯和序列化**

一个完整的RPC架构里面包含了四个核心的组件，分别是**Client**，**Client Stub**，**Server**以及**Server Stub**，这个Stub可以理解为存根

#### 组件结构如下图所示：

![image-20210807115121135](images/image-20210807115121135.png)

- 客户端(Client)，服务的调用方。

- 客户端存根(Client Stub)，存放服务端的地址消息，再将客户端的请求参数打包成网络消息，然后通过网络远程发送给服务方。

- 服务端(Server)，真正的服务提供者。

- 服务端存根(Server Stub)，接收客户端发送过来的消息，将消息解包，并调用本地的方法。



#### 调用时序图如下所示：

![image-20210807114823124](images/image-20210807114823124.png)

1. 客户端（client）以本地调用方式（即以接口的方式）调用服务；

2. **客户端存根（client stub）接收到调用后，负责将方法、参数等组装成能够进行网络传输的消息体（将消息体对象序列化为二进制）；**

3. **客户端通过socket将消息发送到服务端；**

4. **服务端存根( server stub）收到消息后进行解码（将消息对象反序列化）；**

5. **服务端存根( server stub）根据解码结果调用本地的服务；**

6. 服务处理

7. **本地服务执行并将结果返回给服务端存根( server stub）；**

8. **服务端存根( server stub）将返回结果打包成消息（将结果消息对象序列化）；**

9. **服务端（server）通过socket将消息发送到客户端；**

10. **客户端存根（client stub）接收到结果消息，并进行解码（将结果消息发序列化）；**

11. 客户端（client）得到最终结果。

RPC的目标是要把2、3、4、5、7、8、9、10这些步骤都封装起来。只剩下1、6、11



### 4. RMI

 Java RMI，即远程方法调用(Remote Method Invocation)，一种用于实现**远程过程调用**(RPC-Remote procedure call)的Java API， 能直接传输序列化后的Java对象。它的实现依赖于Java虚拟机，因此它仅支持从一个JVM到另一个JVM的调用。

#### 流程图

![image-20210807120208850](images/image-20210807120208850.png)

1. 客户端从远程服务器的注册表中查询并获取远程对象引用。 

2. 桩对象与远程对象具有相同的接口和方法列表，当客户端调用远程对象时，实际上是由相应的桩对象代理完成的。

3. 远程引用层在将桩的本地引用转换为服务器上对象的远程引用后，再将调用传递给传输层(Transport)，由传输层通过TCP协议发送调用； 

4. 在服务器端，传输层监听入站连接，它一旦接收到客户端远程调用后，就将这个引用转发给其上层的远程引用层； 5）服务器端的远程引用层将客户端发送的远程应用转换为本地虚拟机的引用后，再将请求传递给骨架(Skeleton)； 6）骨架读取参数，又将请求传递给服务器，最后由服务器进行实际的方法调用。

5. 如果远程方法调用后有返回值，则服务器将这些结果又沿着“骨架->远程引用层->传输层”向下传递；

6. 客户端的传输层接收到返回值后，又沿着“传输层->远程引用层->桩”向上传递，然后由桩来反序列化这些返回值，并将最终的结果传递给客户端程序。



#### 需求分析

1. 服务端提供根据ID查询用户的方法

2. 客户端调用服务端方法, 并返回用户对象

3. 要求使用RMI进行远程通信

#### 代码实现

##### - 服务端

```java
import com.lagou.rmi.service.IUserService;
import com.lagou.rmi.service.UserServiceImpl;

import java.rmi.RemoteException;
import java.rmi.registry.LocateRegistry;
import java.rmi.registry.Registry;

/**
 * 服务端
 */
public class RMIServer {
    public static void main(String[] args) {
        try {
            //1.注册Registry实例. 绑定端口
            Registry registry = LocateRegistry.createRegistry(9998);
            //2.创建远程对象
            IUserService userService = new UserServiceImpl();
            //3.将远程对象注册到RMI服务器上即(服务端注册表上)
            registry.rebind("userService", userService);
            System.out.println("---RMI服务端启动成功----");
        } catch (RemoteException e) {
            e.printStackTrace();
        }
    }
}
```

##### - 客户端

```java
import com.lagou.rmi.pojo.User;
import com.lagou.rmi.service.IUserService;

import java.rmi.NotBoundException;
import java.rmi.RemoteException;
import java.rmi.registry.LocateRegistry;
import java.rmi.registry.Registry;

/**
 * 客户端
 */
public class RMIClient {
    public static void main(String[] args) throws RemoteException, NotBoundException {
        //1.获取Registry实例
        Registry registry = LocateRegistry.getRegistry("127.0.0.1", 9998);
        //2.通过Registry实例查找远程对象
        IUserService userService = (IUserService) registry.lookup("userService");
        User user = userService.getByUserId(2);
        System.out.println(user.getId() + "----" + user.getName());
    }
}
```

##### - 接口与实现类

```java
import com.lagou.rmi.pojo.User;

import java.rmi.Remote;
import java.rmi.RemoteException;

public interface IUserService extends Remote {

    User getByUserId(int id) throws RemoteException;
}
```

```java
package com.lagou.rmi.service;

import com.lagou.rmi.pojo.User;

import java.rmi.RemoteException;
import java.rmi.server.UnicastRemoteObject;
import java.util.HashMap;
import java.util.Map;

public class UserServiceImpl extends UnicastRemoteObject implements IUserService {
    Map<Object, User> userMap = new HashMap();

    public UserServiceImpl() throws RemoteException {
        super();
        User user1 = new User();
        user1.setId(1);
        user1.setName("张三");
        User user2 = new User();
        user2.setId(2);
        user2.setName("李四");
        userMap.put(user1.getId(), user1);
        userMap.put(user2.getId(), user2);

    }

    @Override
    public User getByUserId(int id) throws RemoteException {
        return userMap.get(id);
    }
}
```



## 二、基于Netty实现RPC框架

### 1. 需求介绍

dubbo 底层使用了 Netty 作为网络通讯框架，要求用 Netty 实现一个简单的 RPC 框架，消费者和提供者约定接口和协议，消费者远程调用提供者的服务, 

1. 创建一个接口，定义抽象方法。用于消费者和提供者之间的约定, 

2. 创建一个提供者，该类需要监听消费者的请求，并按照约定返回数据

3. 创建一个消费者，该类需要透明的调用自己不存在的方法，内部需要使用 Netty 进行数据通信

4. 提供者与消费者数据传输使用json字符串数据格式

5. 提供者使用netty集成spring boot 环境实现

##### 案例: 客户端远程调用服务端提供根据ID查询user对象的方法

![image-20210807134833428](images/image-20210807134833428.png)



### 2. 实现思路

#### 2.1 服务端

- 服务Netty启动类RpcServer：Netty服务端[===>>>](#服务Netty启动类RpcServer)

- 注解RpcService：注解对外暴露的service[===>>>](#注解RpcService)

- 实现类UserServiceImpl：对外提供服务的方法[===>>>](#实现类UserServiceImpl)

- 服务业务处理类RpcServerHandler：服务端具体业务处理类[===>>>](#服务业务处理类RpcServerHandler)

  - 实现ApplicationContextAware接口，当bean对象实例化后通过Aware发现应用上下文，通过`applicationContext.getBeansWithAnnotation`获取**@RpcService**注解的bean并存入ServiceMap

  - 读事件中，将消息对象JSON字符串转换成RpcRequest，通过请求方法元数据从ServiceMap取出对应的实现类并执行方法

  - 通过RpcResponse响应结果

- 启动类ServerBootstrap：SpringBoot启动类[===>>>](#启动类ServerBootstrap)

#### 2.2 客户端

- RPC代理类：创建外部方法的代理对象[===>>>](#RPC代理类)
  - 客户端调用远程方法主要是通过代理对象，创建Netty客户端与服务端建立连接并通信
  - 通信结束后，得到服务器的响应结果，记得关闭Netty客户端资源（通道和线程组连接，即TCP连接）
  
- 客户端Netty启动类RpcClient：Netty客户端[===>>>](#客户端Netty启动类RpcClient)
  - 提供给调用者主动关闭worker线程组和通道的方法
  - 提供消息发送的方法（底层通过线程池执行handler的写），并同步获得响应结果（读）
- 客户端业务处理类RpcClientHandler：客户端具体业务处理类[===>>>](#客户端业务处理类RpcClientHandler)
  - 实现Callbale接口，由NettyClient通过线程池执行此handler，并通过wait()当前线程，等待消息入站然后唤醒线程返回结果
- Rpc配置类及全局配置[===>>>](#Rpc配置类及全局配置)
- 注解RpcRefrence：Controller中依赖注入外部接口[===>>>](#注解RpcRefrence)
- 编写beanPostProcess：后置处理Controller的依赖注入[===>>>](#编写beanPostProcess)
- 客户端启动类ClientBootStrap[===>>>](#客户端启动类ClientBootStrap)



### 3. API公共模块

##### 对外接口

```java
import com.lagou.rpc.pojo.User;

/**
 * 用户服务
 */
public interface IUserService {

    /**
     * 根据ID查询用户
     *
     * @param id
     * @return
     */
    User getById(int id);
}
```

##### RpcRequest

```java
import lombok.Data;

import java.util.Arrays;

/**
 * 封装的请求对象
 */
@Data
public class RpcRequest {

    /**
     * 请求对象的ID
     */
    private String requestId;
    /**
     * 类名
     */
    private String className;
    /**
     * 方法名
     */
    private String methodName;
    /**
     * 参数类型
     */
    private Class<?>[] parameterTypes;
    /**
     * 入参
     */
    private Object[] parameters;

}
```

##### RpcResponse

```java
import lombok.Data;

/**
 * 封装的响应对象
 */
@Data
public class RpcResponse {

    /**
     * 响应ID
     */
    private String requestId;

    /**
     * 错误信息
     */
    private String error;

    /**
     * 返回的结果
     */
    private Object result;

}
```

##### POJO

```java
import lombok.Data;

@Data
public class User {
    private int id;
    private String name;
}
```







### 4. 服务端代码实现

##### 服务Netty启动类RpcServer

实现DisposableBean接口，当Spring容器注销时，关闭boss和work线程组

```java
import com.lagou.rpc.provider.handler.RpcServerHandler;
import io.netty.bootstrap.ServerBootstrap;
import io.netty.channel.ChannelFuture;
import io.netty.channel.ChannelInitializer;
import io.netty.channel.ChannelPipeline;
import io.netty.channel.nio.NioEventLoopGroup;
import io.netty.channel.socket.SocketChannel;
import io.netty.channel.socket.nio.NioServerSocketChannel;
import io.netty.handler.codec.string.StringDecoder;
import io.netty.handler.codec.string.StringEncoder;
import org.springframework.beans.factory.DisposableBean;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

/**
 * 启动类
 */
@Service
public class RpcServer implements DisposableBean {

    private NioEventLoopGroup bossGroup;

    private NioEventLoopGroup workerGroup;

    @Autowired
    RpcServerHandler rpcServerHandler;


    public void startServer(String ip, int port) {
        try {
            //1. 创建线程组
            bossGroup = new NioEventLoopGroup(1);
            workerGroup = new NioEventLoopGroup();
            //2. 创建服务端启动助手
            ServerBootstrap serverBootstrap = new ServerBootstrap();
            //3. 设置参数
            serverBootstrap.group(bossGroup, workerGroup)
                    .channel(NioServerSocketChannel.class)
                    .childHandler(new ChannelInitializer<SocketChannel>() {
                        @Override
                        protected void initChannel(SocketChannel channel) throws Exception {
                            ChannelPipeline pipeline = channel.pipeline();
                            //添加String的编解码器
                            pipeline.addLast(new StringDecoder());
                            pipeline.addLast(new StringEncoder());
                            //业务处理类
                            pipeline.addLast(rpcServerHandler);
                        }
                    });
            //4.绑定端口
            ChannelFuture sync = serverBootstrap.bind(ip, port).sync();
            System.out.println("==========服务端启动成功，端口：=========="+port);
            sync.channel().closeFuture().sync();
        } catch (InterruptedException e) {
            e.printStackTrace();
        } finally {
            if (bossGroup != null) {
                bossGroup.shutdownGracefully();
            }

            if (workerGroup != null) {
                workerGroup.shutdownGracefully();
            }
        }
    }


    @Override
    public void destroy() throws Exception {
        if (bossGroup != null) {
            bossGroup.shutdownGracefully();
        }

        if (workerGroup != null) {
            workerGroup.shutdownGracefully();
        }
    }
}
```

##### 注解RpcService

注解对外暴露服务方法，将该注解的bean缓存起来

```java
import java.lang.annotation.ElementType;
import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;
import java.lang.annotation.Target;

/**
 * 对外暴露服务接口
 */
@Target(ElementType.TYPE) // 用于接口和类上
@Retention(RetentionPolicy.RUNTIME)// 在运行时可以获取到
public @interface RpcService {
}
```

##### 实现类UserServiceImpl

对外服务方法

```java
import com.lagou.rpc.api.IUserService;
import com.lagou.rpc.pojo.User;
import com.lagou.rpc.provider.anno.RpcService;
import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.Map;

@RpcService
@Service
public class UserServiceImpl implements IUserService {
    Map<Object, User> userMap = new HashMap();

    @Override
    public User getById(int id) {
        if (userMap.size() == 0) {
            User user1 = new User();
            user1.setId(1);
            user1.setName("张三");
            User user2 = new User();
            user2.setId(2);
            user2.setName("李四");
            userMap.put(user1.getId(), user1);
            userMap.put(user2.getId(), user2);
        }
        User user = userMap.get(id);
        System.out.println("查询结果========>"+user);
        return user;
    }
}
```

##### 服务业务处理类RpcServerHandler

实现ApplicationContextAware接口，当bean对象实例化后通过Aware发现应用上下文，通过`applicationContext.getBeansWithAnnotation`获取**@RpcService**注解的bean并存入ServiceMap

读事件中，将消息对象JSON字符串转换成RpcRequest，通过请求方法元数据从ServiceMap取出对应的实现类并执行方法

通过RpcResponse响应结果

```java
import com.alibaba.fastjson.JSON;
import com.lagou.rpc.common.RpcRequest;
import com.lagou.rpc.common.RpcResponse;
import com.lagou.rpc.provider.anno.RpcService;
import io.netty.channel.ChannelHandler;
import io.netty.channel.ChannelHandlerContext;
import io.netty.channel.SimpleChannelInboundHandler;
import org.springframework.beans.BeansException;
import org.springframework.cglib.reflect.FastClass;
import org.springframework.cglib.reflect.FastMethod;
import org.springframework.context.ApplicationContext;
import org.springframework.context.ApplicationContextAware;
import org.springframework.stereotype.Component;

import java.lang.reflect.InvocationTargetException;
import java.util.Map;
import java.util.Set;
import java.util.concurrent.ConcurrentHashMap;

/**
 * 服务端业务处理类
 * 1.将标有@RpcService注解的bean缓存
 * 2.接收客户端请求
 * 3.根据传递过来的beanName从缓存中查找到对应的bean
 * 4.解析请求中的方法名称. 参数类型 参数信息
 * 5.反射调用bean的方法
 * 6.给客户端进行响应
 */
@Component
@ChannelHandler.Sharable
public class RpcServerHandler extends SimpleChannelInboundHandler<String> implements ApplicationContextAware {

    private static final Map SERVICE_INSTANCE_MAP = new ConcurrentHashMap();

    /**
     * 1.将标有@RpcService注解的bean缓存
     *
     * @param applicationContext
     * @throws BeansException
     */
    @Override
    public void setApplicationContext(ApplicationContext applicationContext) throws BeansException {
        Map<String, Object> serviceMap = applicationContext.getBeansWithAnnotation(RpcService.class);
        if (serviceMap != null && serviceMap.size() > 0) {
            Set<Map.Entry<String, Object>> entries = serviceMap.entrySet();
            for (Map.Entry<String, Object> item : entries) {
                Object serviceBean = item.getValue();
                if (serviceBean.getClass().getInterfaces().length == 0) {
                    throw new RuntimeException("服务必须实现接口");
                }
                //默认取第一个接口作为缓存bean的名称
                String name = serviceBean.getClass().getInterfaces()[0].getName();
                SERVICE_INSTANCE_MAP.put(name, serviceBean);
            }
        }
    }

    /**
     * 通道读取就绪事件
     *
     * @param channelHandlerContext
     * @param msg
     * @throws Exception
     */
    @Override
    protected void channelRead0(ChannelHandlerContext channelHandlerContext, String msg) throws Exception {
        //1.接收客户端请求- 将msg转化RpcRequest对象
        RpcRequest rpcRequest = JSON.parseObject(msg, RpcRequest.class);
        RpcResponse rpcResponse = new RpcResponse();
        rpcResponse.setRequestId(rpcRequest.getRequestId());
        try {
            //业务处理
            rpcResponse.setResult(handler(rpcRequest));
        } catch (Exception exception) {
            exception.printStackTrace();
            rpcResponse.setError(exception.getMessage());
        }
        //6.给客户端进行响应
        channelHandlerContext.writeAndFlush(JSON.toJSONString(rpcResponse));

    }

    /**
     * 业务处理逻辑
     *
     * @return
     */
    public Object handler(RpcRequest rpcRequest) throws InvocationTargetException {
        // 3.根据传递过来的beanName从缓存中查找到对应的bean
        Object serviceBean = SERVICE_INSTANCE_MAP.get(rpcRequest.getClassName());
        if (serviceBean == null) {
            throw new RuntimeException("根据beanName找不到服务,beanName:" + rpcRequest.getClassName());
        }
        //4.解析请求中的方法名称. 参数类型 参数信息
        Class<?> serviceBeanClass = serviceBean.getClass();
        String methodName = rpcRequest.getMethodName();
        Class<?>[] parameterTypes = rpcRequest.getParameterTypes();
        Object[] parameters = rpcRequest.getParameters();
        //5.反射调用bean的方法- CGLIB反射调用
        FastClass fastClass = FastClass.create(serviceBeanClass);
        FastMethod method = fastClass.getMethod(methodName, parameterTypes);
        return method.invoke(serviceBean, parameters);
    }
}
```

##### 启动类ServerBootstrap

```java
import com.lagou.rpc.provider.server.RpcServer;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.CommandLineRunner;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
public class ServerBootstrapApplication implements CommandLineRunner {


    @Autowired
    RpcServer rpcServer;

    public static void main(String[] args) {
        SpringApplication.run(ServerBootstrapApplication.class, args);
    }

    @Override
    public void run(String... args) throws Exception {
        new Thread(new Runnable() {
            @Override
            public void run() {
                rpcServer.startServer("127.0.0.1", 8899);
            }
        }).start();
    }
}
```



### 5. 客户端代码实现

##### 客户端Netty启动类RpcClient

提供给调用者主动关闭worker线程组和通道的方法

提供消息发送的方法（底层通过线程池执行handler的写），并同步获得响应结果（读）

```java
import com.lagou.rpc.consumer.handler.RpcClientHandler;
import io.netty.bootstrap.Bootstrap;
import io.netty.channel.*;
import io.netty.channel.nio.NioEventLoopGroup;
import io.netty.channel.socket.SocketChannel;
import io.netty.channel.socket.nio.NioSocketChannel;
import io.netty.handler.codec.string.StringDecoder;
import io.netty.handler.codec.string.StringEncoder;

import java.util.concurrent.ExecutionException;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.Future;

/**
 * 客户端
 * 1.连接Netty服务端
 * 2.提供给调用者主动关闭资源的方法
 * 3.提供消息发送的方法
 */
public class RpcClient {

    private EventLoopGroup group;

    private Channel channel;

    private String ip;

    private int port;

    private RpcClientHandler rpcClientHandler = new RpcClientHandler();

    private ExecutorService executorService = Executors.newCachedThreadPool();

    public RpcClient(String ip, int port) {
        this.ip = ip;
        this.port = port;
        initClient();
    }

    /**
     * 初始化方法-连接Netty服务端
     */
    public void initClient() {
        try {
            //1.创建线程组
            group = new NioEventLoopGroup();
            //2.创建启动助手
            Bootstrap bootstrap = new Bootstrap();
            //3.设置参数
            bootstrap.group(group)
                    .channel(NioSocketChannel.class)
                    .option(ChannelOption.SO_KEEPALIVE, Boolean.TRUE)
                    .option(ChannelOption.CONNECT_TIMEOUT_MILLIS, 3000)
                    .handler(new ChannelInitializer<SocketChannel>() {
                        @Override
                        protected void initChannel(SocketChannel channel) throws Exception {
                            ChannelPipeline pipeline = channel.pipeline();
                            //String类型编解码器
                            pipeline.addLast(new StringDecoder());
                            pipeline.addLast(new StringEncoder());
                            //添加客户端处理类
                            pipeline.addLast(rpcClientHandler);
                        }
                    });
            //4.连接Netty服务端
            channel = bootstrap.connect(ip, port).sync().channel();
        } catch (Exception exception) {
            exception.printStackTrace();
            if (channel != null) {
                channel.close();
            }
            if (group != null) {
                group.shutdownGracefully();
            }
        }
    }

    /**
     * 提供给调用者主动关闭资源的方法
     */
    public void close() {
        if (channel != null) {
            channel.close();
        }
        if (group != null) {
            group.shutdownGracefully();
        }
    }

    /**
     * 提供消息发送的方法
     */
    public Object send(String msg) throws ExecutionException, InterruptedException {
        rpcClientHandler.setRequestMsg(msg);
        Future submit = executorService.submit(rpcClientHandler);
        return submit.get();
    }
}
```

##### 客户端业务处理类RpcClientHandler

实现Callbale接口，由NettyClient通过线程池执行此handler，并通过wait()当前线程，等待消息入站然后唤醒线程返回结果

```java
import io.netty.channel.ChannelHandlerContext;
import io.netty.channel.SimpleChannelInboundHandler;

import java.util.concurrent.Callable;

/**
 * 客户端处理类
 * 1.发送消息
 * 2.接收消息
 */
public class RpcClientHandler extends SimpleChannelInboundHandler<String> implements Callable {

    ChannelHandlerContext context;
    //发送的消息
    String requestMsg;

    //服务端的消息
    String responseMsg;

    public void setRequestMsg(String requestMsg) {
        this.requestMsg = requestMsg;
    }

    /**
     * 通道连接就绪事件
     *
     * @param ctx
     * @throws Exception
     */
    @Override
    public void channelActive(ChannelHandlerContext ctx) throws Exception {
        context = ctx;
    }

    /**
     * 通道读取就绪事件
     *
     * @param channelHandlerContext
     * @param msg
     * @throws Exception
     */
    @Override
    protected synchronized void channelRead0(ChannelHandlerContext channelHandlerContext, String msg) throws Exception {
        responseMsg = msg;
        //唤醒等待的线程
        notify();
    }

    /**
     * 发送消息到服务端
     *
     * @return
     * @throws Exception
     */
    @Override
    public synchronized Object call() throws Exception {
        //消息发送
        context.writeAndFlush(requestMsg);
        //线程等待
        wait();
        return responseMsg;
    }
}
```

##### Rpc配置类及全局配置

```java
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.stereotype.Component;

import java.util.List;

@Component
@ConfigurationProperties(prefix = "rpc",ignoreUnknownFields = false)
public class RpcConfig {
    private List<String> server;

    public List<String> getServer() {
        return server;
    }

    public void setServer(List<String> server) {
        this.server = server;
    }
}
```

```yaml
server:
  port: 8080

rpc:
  server:
    - 127.0.0.1:8899
    - 127.0.0.1:9999
```

##### 注解RpcRefrence

Controller中依赖注入外部接口

```java
import java.lang.annotation.*;

/**
 * @program: lg-rpc
 * @description:
 * @author: Wangwt
 * @create: 23:31 2021/8/3
 */
@Retention(RetentionPolicy.RUNTIME)
@Target(ElementType.FIELD)
@Documented
public @interface RpcRefrence {

    String value() default "";
}
```

##### 编写beanPostProcess

后置处理Controller的依赖注入

```java
import com.lagou.rpc.consumer.anno.RpcRefrence;
import com.lagou.rpc.consumer.proxy.RpcClientProxy;
import org.springframework.beans.BeansException;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.config.BeanPostProcessor;
import org.springframework.stereotype.Component;

import java.lang.reflect.Field;

@Component
public class RpcServicePostProcessor implements BeanPostProcessor {

    @Autowired
    RpcClientProxy rpcClientProxy;

    @Override
    public Object postProcessBeforeInitialization(Object bean, String beanName) throws BeansException {
        return bean;
    }

    @Override
    public Object postProcessAfterInitialization(Object bean, String beanName) throws BeansException {
        try {
            Class<?> aClass = bean.getClass();
            Field[] fields = aClass.getDeclaredFields();
            for (Field field : fields) {
                if (field.isAnnotationPresent(RpcRefrence.class)) {
                    Class<?> type = field.getType();
                    if (type.isInterface()) {
                        Object ob = rpcClientProxy.createProxy(type);
                        field.setAccessible(true);
                        field.set(bean,ob);
                    }
                }
            }
        } catch (IllegalAccessException e) {
            e.printStackTrace();
        }

        return bean;
    }
}
```

##### RPC代理类

客户端调用远程方法主要是通过代理对象，创建Netty客户端与服务端建立连接并通信

```java
import com.alibaba.fastjson.JSON;
import com.lagou.rpc.common.RpcRequest;
import com.lagou.rpc.common.RpcResponse;
import com.lagou.rpc.consumer.client.RpcClient;
import com.lagou.rpc.consumer.config.RpcConfig;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import java.lang.reflect.InvocationHandler;
import java.lang.reflect.Method;
import java.lang.reflect.Proxy;
import java.util.List;
import java.util.UUID;

/**
 * 客户端代理类-创建代理对象
 * 1.封装request请求对象
 * 2.创建RpcClient对象
 * 3.发送消息
 * 4.返回结果
 */
@Component
public class RpcClientProxy {

    @Autowired
    RpcConfig rpcConfig;

    public Object createProxy(Class serviceClass) {
        return Proxy.newProxyInstance(Thread.currentThread().getContextClassLoader(),
                new Class[]{serviceClass}, new InvocationHandler() {
                    @Override
                    public Object invoke(Object proxy, Method method, Object[] args) throws Throwable {
                        // 根据时间戳负载均衡
                        List<String> server = rpcConfig.getServer();
                        int size = server.size();
                        int index = Integer.parseInt(String.valueOf(System.currentTimeMillis()/1000 % size));
                        String host = server.get(index).split(":")[0];
                        int port = Integer.parseInt(server.get(index).split(":")[1]);


                        //1.封装request请求对象
                        RpcRequest rpcRequest = new RpcRequest();
                        rpcRequest.setRequestId(UUID.randomUUID().toString());
                        rpcRequest.setClassName(method.getDeclaringClass().getName());
                        rpcRequest.setMethodName(method.getName());
                        rpcRequest.setParameterTypes(method.getParameterTypes());
                        rpcRequest.setParameters(args);
                        //2.创建RpcClient对象
                        RpcClient rpcClient = new RpcClient(host, port);
                        try {
                            //3.发送消息
                            Object responseMsg = rpcClient.send(JSON.toJSONString(rpcRequest));
                            RpcResponse rpcResponse = JSON.parseObject(responseMsg.toString(), RpcResponse.class);
                            if (rpcResponse.getError() != null) {
                                throw new RuntimeException(rpcResponse.getError());
                            }
                            //4.返回结果
                            Object result = rpcResponse.getResult();
                            return JSON.parseObject(result.toString(), method.getReturnType());
                        } catch (Exception e) {
                            throw e;
                        } finally {
                            rpcClient.close();
                        }

                    }
                });
    }
}
```

##### 客户端启动类ClientBootStrap

```java
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
public class ClientBootStrap {

    public static void main(String[] args) {
        SpringApplication.run(ClientBootStrap.class,args);
    }
}

```

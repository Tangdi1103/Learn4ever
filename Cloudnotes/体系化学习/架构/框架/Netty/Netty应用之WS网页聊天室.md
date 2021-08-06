[toc]

## 基于Netty的WebSocket开发网页版聊天室

###  一、WebSocket简介

WebSocket是一种在单个TCP连接上进行全双工通信的协议。WebSocket使得客户端和服务器之间的数据交换变得更加简单，**允许服务端主动向客户端推送数据**。在WebSocket API中，客户端和服务器只需要完成一次握手，两者之间就直接可以创建持久性的连接，并进行双向数据传输。

##### WebSockt应用场景

1. 社交订阅
2. 协同编辑/编程
3. 股票基金报价
4. 体育实况更新
5. 多媒体聊天
6. 在线教育



### 二、为什么需要WebSocket？

HTTP 协议是一种无状态的、无连接的、单向的应用层协议。它采用了请求/响应模型。通信请求只能由客户端发起，服务端对请求做出应答处理。

这种通信模型有一个弊端：HTTP 协议无法实现服务器主动向客户端发起消息。

这种单向请求的特点，注定了如果服务器有连续的状态变化，客户端要获知就非常麻烦。大多数 Web 应用程序将通过频繁的异步JavaScript和XML（AJAX）请求实现长轮询。轮询的效率低，非常浪费资源（因为必须不停连接，或者 HTTP 连接始终打开）。

WebSocket 就是这样发明的。WebSocket 连接允许客户端和服务器之间进行全双工通信，以便任一方都可以通过建立的连接将数据推送到另一端。WebSocket 只需要建立一次连接，就可以一直保持连接状态。这相比于轮询方式的不停建立连接显然效率要大大提高。



### 三、WebSocket和HTTP的区别

#### HTTP

http协议是用在应用层的协议，他是基于tcp协议的，http协议建立连接也必须要有三次握手才能发送信息。 

http连接分为短连接和长连接，

短连接是每次请求都要三次握手才能发送自己的信息，即每一个request对应一个response。

长连接是在一定的期限内保持TCP连接不断开。

客户端与服务器通信，必须要有客户端先发起, 然后服务器返回结果。客户端是主动的，服务器是被动的。 **客户端要想实时获取服务端消息就得不断发送长连接到服务端。**



#### WebSocket

WebSocket实现了多路复用，他是全双工通信。

在webSocket协议下服务端和客户端可以同时发送信息。 

建立了WebSocket连接之后, 服务端可以主动发送信息到客户端。而且信息当中不必在带有head的部分信息了与http的长链接通信来说，这种方式，**不仅能降低服务器的压力。而且信息当中也减少了部分多余的信息。**



### 四、与HTTP协议的比较

#### 同：

- 建立在TCP之上，同http一样通过TCP来传输数据

#### 不同：

- HTTP协议为单向协议，即浏览器只能向服务器请求资源，服务器才能将数据传送给浏览器，而服务器不能主动向浏览器传递数据。分为长连接和短连接，短连接是每次http请求时都需要三次握手才能发送自己的请求，每个request对应一个response；长连接是短时间内保持连接，保持TCP不断开，指的是TCP连接。

- WebSocket一种双向通信协议，在建立连接后，WebSocket服务器和Browser/UA都能主动的向对方发送或接收数据，就像Socket一样，不同的是WebSocket是一种建立在Web基础上的一种简单模拟Socket的协议；

- WebSocket需要通过握手连接，类似于TCP它也需要客户端和服务器端进行握手连接，连接成功后才能相互通信。

- WebSocket在建立握手连接时，数据是通过http协议传输的，“GET/chat HTTP/1.1”，这里面用到的只是http协议一些简单的字段。但是在建立连接之后，真正的数据传输阶段是不需要http协议参与的。

### 五、导入基础环境

#### 依赖SpringBoot

```xml
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter</artifactId>
</dependency>
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-test</artifactId>
    <scope>test</scope>
</dependency>

<!--整合web模块-->
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-web</artifactId>
</dependency>
<!--整合模板引擎 -->
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-thymeleaf</artifactId>
</dependency>
<dependency>
    <groupId>org.projectlombok</groupId>
    <artifactId>lombok</artifactId>
</dependency>

<!--引入netty依赖 -->
<dependency>
    <groupId>io.netty</groupId>
    <artifactId>netty-all</artifactId>
</dependency>
```

#### 全局配置文件

```yaml
server:
  port: 8080
netty:
  port: 8081
  path: /chat
resources:
  static-locations:
    - classpath:/static/
spring:
  thymeleaf:
    cache: false
    checktemplatelocation: true
    enabled: true
    encoding: UTF-8
    mode: HTML5
    prefix: classpath:/templates/
    suffix: .html
```



### 六、服务端开发

#### Netty配置类

```java
import lombok.Data;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.stereotype.Component;

@Component
@ConfigurationProperties(prefix = "netty")
@Data
public class NettyConfig {

    private int port;//netty监听的端口

    private String path;//websocket访问路径
}
```



#### NettyWebSocketServer开发

```java
import com.lagou.config.NettyConfig;
import io.netty.bootstrap.ServerBootstrap;
import io.netty.channel.ChannelFuture;
import io.netty.channel.EventLoopGroup;
import io.netty.channel.nio.NioEventLoopGroup;
import io.netty.channel.socket.nio.NioServerSocketChannel;
import io.netty.handler.logging.LogLevel;
import io.netty.handler.logging.LoggingHandler;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import javax.annotation.PreDestroy;

/**
 * Netty服务器
 */
@Component
public class NettyWebSocketServer implements Runnable {

    @Autowired
    NettyConfig nettyConfig;

    @Autowired
    WebSocketChannelInit webSocketChannelInit;


    private EventLoopGroup bossGroup = new NioEventLoopGroup(1);

    private EventLoopGroup workerGroup = new NioEventLoopGroup();

    /**
     * 资源关闭--在容器销毁是关闭
     */
    @PreDestroy
    public void close() {
        bossGroup.shutdownGracefully();
        workerGroup.shutdownGracefully();
    }

    @Override
    public void run() {
        try {
            //1.创建服务端启动助手
            ServerBootstrap serverBootstrap = new ServerBootstrap();
            //2.设置线程组
            serverBootstrap.group(bossGroup, workerGroup);
            //3.设置参数
            serverBootstrap.channel(NioServerSocketChannel.class)
                    .handler(new LoggingHandler(LogLevel.DEBUG))
                    .childHandler(webSocketChannelInit);
            //4.启动
            ChannelFuture channelFuture = serverBootstrap.bind(nettyConfig.getPort()).sync();
            System.out.println("--Netty服务端启动成功---");
            channelFuture.channel().closeFuture().sync();
        } catch (Exception e) {
            e.printStackTrace();
            bossGroup.shutdownGracefully();
            workerGroup.shutdownGracefully();
        } finally {
            bossGroup.shutdownGracefully();
            workerGroup.shutdownGracefully();
        }
    }
}
```



#### 通道初始化对象

```java
import com.lagou.config.NettyConfig;
import io.netty.channel.Channel;
import io.netty.channel.ChannelInitializer;
import io.netty.channel.ChannelPipeline;
import io.netty.handler.codec.http.HttpObjectAggregator;
import io.netty.handler.codec.http.HttpServerCodec;
import io.netty.handler.codec.http.websocketx.WebSocketServerProtocolHandler;
import io.netty.handler.stream.ChunkedWriteHandler;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

/**
 * 通道初始化对象
 */
@Component
public class WebSocketChannelInit extends ChannelInitializer {

    @Autowired
    NettyConfig nettyConfig;

    @Autowired
    WebSocketHandler webSocketHandler;

    @Override
    protected void initChannel(Channel channel) throws Exception {
        ChannelPipeline pipeline = channel.pipeline();
        //对http协议的支持.
        pipeline.addLast(new HttpServerCodec());
        // 对大数据流的支持
        pipeline.addLast(new ChunkedWriteHandler());
        //post请求分三部分. request line / request header / message body
        // HttpObjectAggregator将多个信息转化成单一的request或者response对象
        pipeline.addLast(new HttpObjectAggregator(8000));
        // 将http协议升级为ws协议. websocket的支持
        pipeline.addLast(new WebSocketServerProtocolHandler(nettyConfig.getPath()));
        // 自定义处理handler
        pipeline.addLast(webSocketHandler);

    }
}
```



#### 处理对象

```java
import io.netty.channel.Channel;
import io.netty.channel.ChannelHandler;
import io.netty.channel.ChannelHandlerContext;
import io.netty.channel.SimpleChannelInboundHandler;
import io.netty.handler.codec.http.websocketx.TextWebSocketFrame;
import org.springframework.stereotype.Component;

import java.util.ArrayList;
import java.util.List;

/**
 * 自定义处理类
 * TextWebSocketFrame: websocket数据是帧的形式处理
 */
@Component
@ChannelHandler.Sharable //设置通道共享
public class WebSocketHandler extends SimpleChannelInboundHandler<TextWebSocketFrame> {

    public static List<Channel> channelList = new ArrayList<>();

    /**
     * 通道就绪事件
     *
     * @param ctx
     * @throws Exception
     */
    @Override
    public void channelActive(ChannelHandlerContext ctx) throws Exception {
        Channel channel = ctx.channel();
        //当有新的客户端连接的时候, 将通道放入集合
        channelList.add(channel);
        System.out.println("有新的连接.");
    }


    /**
     * 通道未就绪--channel下线
     *
     * @param ctx
     * @throws Exception
     */
    @Override
    public void channelInactive(ChannelHandlerContext ctx) throws Exception {
        Channel channel = ctx.channel();
        //当有客户端断开连接的时候,就移除对应的通道
        channelList.remove(channel);
    }

    /**
     * 读就绪事件
     *
     * @param ctx
     * @param textWebSocketFrame
     * @throws Exception
     */
    @Override
    protected void channelRead0(ChannelHandlerContext ctx, TextWebSocketFrame textWebSocketFrame) throws Exception {
        String msg = textWebSocketFrame.text();
        System.out.println("msg:" + msg);
        //当前发送消息的通道, 当前发送的客户端连接
        Channel channel = ctx.channel();
        for (Channel channel1 : channelList) {
            //排除自身通道
            if (channel != channel1) {
                channel1.writeAndFlush(new TextWebSocketFrame(msg));
            }
        }
    }


    /**
     * 异常处理事件
     *
     * @param ctx
     * @param cause
     * @throws Exception
     */
    @Override
    public void exceptionCaught(ChannelHandlerContext ctx, Throwable cause) throws Exception {
        cause.printStackTrace();
        Channel channel = ctx.channel();
        //移除集合
        channelList.remove(channel);
    }
}
```



#### Controller

```java
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;

@Controller
public class ChatController {

    @RequestMapping("/")
    public String chat() {
        return "chat";
    }
}
```



#### SpringBoot启动类

```java
import com.lagou.netty.NettyWebSocketServer;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.CommandLineRunner;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
public class NettySpringbootApplication implements CommandLineRunner {

    @Autowired
    NettyWebSocketServer nettyWebSocketServer;

    public static void main(String[] args) {
        SpringApplication.run(NettySpringbootApplication.class, args);
    }

    @Override
    public void run(String... args) throws Exception {
        new Thread(nettyWebSocketServer).start();
    }
}
```



### 七、前端资源开发（测试用）

从github取

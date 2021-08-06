[toc]

## 基于Netty的群聊天室

### 一、案例要求

1. 编写一个 Netty 群聊系统，实现服务器端和客户端之间的数据简单通讯

2. 实现多人群聊

3. 服务器端：可以监测用户上线，离线，并实现消息转发功能

4. 客户端：可以发送消息给其它所有用户，同时可以接受其它用户发送的消息



### 二、聊天室服务端编写

##### NettyChatServer

```java
import com.lagou.demo.NettyServerHandler;
import io.netty.bootstrap.ServerBootstrap;
import io.netty.channel.*;
import io.netty.channel.nio.NioEventLoopGroup;
import io.netty.channel.socket.SocketChannel;
import io.netty.channel.socket.nio.NioServerSocketChannel;
import io.netty.handler.codec.string.StringDecoder;
import io.netty.handler.codec.string.StringEncoder;

/**
 * 聊天室服务端
 */
public class NettyChatServer {
    //端口号
    private int port;

    public NettyChatServer(int port) {
        this.port = port;
    }

    public void run() throws InterruptedException {
        //1. 创建bossGroup线程组: 处理网络事件--连接事件
        EventLoopGroup bossGroup = null;
        //2. 创建workerGroup线程组: 处理网络事件--读写事件 2*处理器线程数
        EventLoopGroup workerGroup = null;
        try {
            bossGroup = new NioEventLoopGroup(1);
            workerGroup = new NioEventLoopGroup();
            //3. 创建服务端启动助手
            ServerBootstrap serverBootstrap = new ServerBootstrap();
            //4. 设置bossGroup线程组和workerGroup线程组
            serverBootstrap.group(bossGroup, workerGroup)
                    .channel(NioServerSocketChannel.class) //5. 设置服务端通道实现为NIO
                    .option(ChannelOption.SO_BACKLOG, 128)//6. 参数设置
                    .childOption(ChannelOption.SO_KEEPALIVE, Boolean.TRUE)//6. 参数设置
                    .childHandler(new ChannelInitializer<SocketChannel>() { //7. 创建一个通道初始化对象
                        @Override
                        protected void initChannel(SocketChannel ch) throws Exception {
                            //8. 向pipeline中添加自定义业务处理handler
                            //添加编解码器
                            ch.pipeline().addLast(new StringDecoder());
                            ch.pipeline().addLast(new StringEncoder());
                            // 业务处理
                            ch.pipeline().addLast(new NettyChatServerHandler());
                        }
                    });
            //9. 启动服务端并绑定端口,同时将异步改为同步
            ChannelFuture future = serverBootstrap.bind(port);
            future.addListener(new ChannelFutureListener() {
                @Override
                public void operationComplete(ChannelFuture future) throws Exception {
                    if (future.isSuccess()) {
                        System.out.println("端口绑定成功!");
                    } else {
                        System.out.println("端口绑定失败!");
                    }
                }
            });
            System.out.println("聊天室服务端启动成功.");
            //10. 关闭通道(并不是真正意义上关闭,而是监听通道关闭的状态)和关闭连接池
            future.channel().closeFuture().sync();
        } finally {
            bossGroup.shutdownGracefully();
            workerGroup.shutdownGracefully();
        }
    }

    public static void main(String[] args) throws InterruptedException {
        new NettyChatServer(9998).run();
    }
}
```



##### NettyChatServerHandle

```java
import io.netty.channel.Channel;
import io.netty.channel.ChannelHandlerContext;
import io.netty.channel.SimpleChannelInboundHandler;

import java.util.ArrayList;
import java.util.List;

/**
 * 聊天室业务处理类
 */
public class NettyChatServerHandler extends SimpleChannelInboundHandler<String> {
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
        System.out.println("[Server]:" +
                channel.remoteAddress().toString().substring(1) + "在线.");
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
        System.out.println("[Server]:" +
                channel.remoteAddress().toString().substring(1) + "下线.");
    }

    /**
     * 通道读取事件
     *
     * @param ctx
     * @param msg
     * @throws Exception
     */
    @Override
    protected void channelRead0(ChannelHandlerContext ctx, String msg) throws Exception {
        //当前发送消息的通道, 当前发送的客户端连接
        Channel channel = ctx.channel();
        for (Channel channel1 : channelList) {
            //排除自身通道
            if (channel != channel1) {
                channel1.writeAndFlush("[" + channel.remoteAddress().toString().substring(1)
                        + "]说:" + msg);
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
        System.out.println("[Server]:" +
                channel.remoteAddress().toString().substring(1) + "异常.");
    }
}
```





### 三、聊天室客户端编写

##### NettyChatClient

```java
import com.lagou.demo.NettyClientHandler;
import io.netty.bootstrap.Bootstrap;
import io.netty.channel.Channel;
import io.netty.channel.ChannelFuture;
import io.netty.channel.ChannelInitializer;
import io.netty.channel.EventLoopGroup;
import io.netty.channel.nio.NioEventLoopGroup;
import io.netty.channel.socket.SocketChannel;
import io.netty.channel.socket.nio.NioSocketChannel;
import io.netty.handler.codec.string.StringDecoder;
import io.netty.handler.codec.string.StringEncoder;

import java.util.Scanner;

/**
 * 聊天室的客户端
 */
public class NettyChatClient {

    private String ip;//服务端IP
    private int port;//服务端端口号

    public NettyChatClient(String ip, int port) {
        this.ip = ip;
        this.port = port;
    }

    public void run() throws InterruptedException {
        //1. 创建线程组
        EventLoopGroup group = null;
        try {
            group = new NioEventLoopGroup();
            //2. 创建客户端启动助手
            Bootstrap bootstrap = new Bootstrap();
            //3. 设置线程组
            bootstrap.group(group)
                    .channel(NioSocketChannel.class)//4. 设置客户端通道实现为NIO
                    .handler(new ChannelInitializer<SocketChannel>() { //5. 创建一个通道初始化对象
                        @Override
                        protected void initChannel(SocketChannel ch) throws Exception {
                            //6. 向pipeline中添加自定义业务处理handler
                            //添加编解码器
                            ch.pipeline().addLast(new StringDecoder());
                            ch.pipeline().addLast(new StringEncoder());
                            //添加客户端的处理类
                            ch.pipeline().addLast(new NettyChatClientHandler());
                        }
                    });
            //7. 启动客户端,等待连接服务端,同时将异步改为同步
            ChannelFuture channelFuture = bootstrap.connect(ip, port).sync();
            Channel channel = channelFuture.channel();
            System.out.println("-------" + channel.localAddress().toString().substring(1) + "--------");
            Scanner scanner = new Scanner(System.in);
            while (scanner.hasNextLine()) {
                String msg = scanner.nextLine();
                //向服务端发送消息
                channel.writeAndFlush(msg);
            }
            //8. 关闭通道和关闭连接池
            channelFuture.channel().closeFuture().sync();
        } finally {
            group.shutdownGracefully();
        }
    }

    public static void main(String[] args) throws InterruptedException {
        new NettyChatClient("127.0.0.1", 9998).run();
    }
}
```



##### NettyChatClientHandle

```java
import io.netty.channel.ChannelHandlerContext;
import io.netty.channel.SimpleChannelInboundHandler;

/**
 * 聊天室处理类
 */
public class NettyChatClientHandler extends SimpleChannelInboundHandler<String> {

    /**
     * 通道读取就绪事件
     *
     * @param ctx
     * @param msg
     * @throws Exception
     */
    @Override
    protected void channelRead0(ChannelHandlerContext ctx, String msg) throws Exception {
        System.out.println(msg);
    }
}
```
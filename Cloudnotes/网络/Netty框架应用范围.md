- (Dubbo、RocketMQ、Zookeeper) >>> Netty >>> Java NIO（同步非阻塞） >>> 一个线程中处理多个Socket套接字（基于事件驱动思想，采用的是selector模式）：包含一个接收连接的线程池（也有可能是单个线程，boss线程池）以及一个处理连接的线程池（worker线程池）。boss负责接收连接，并进行IO监听；worker负责后续的处理 >>> Netty中的NioEventLoopGroup类

- netty框架能自定义多种io模式处理socket，socket对tcp操作封装，即套接字（TCP连接的端点，包含主机ip和端口）
 
- 微服务框架springcloud的eureka组件基于rest服务通信>>>rest通信基于http协议
- 微服务框架springcloud的zuul组件2.0基于netty框架实现非阻塞通信
 
- 微服务治理框架Dubbo使用RPC通信，RPC通信基于自定义协议（编解码，传输报文，解析报文）
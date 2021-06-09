### 三次握手
##### 客户端与服务器之间建立相互通信的连接
1. 第一次握手：client发送Server带有SYN标志的数据包，建立client到server的连接
1. 第二次握手：Server收到client的消息，发出SYN数据包，建立server到client的连接，并且发出ACK数据包，通知client的发送连接正常
1. 第三次握手：client收到Server的消息，发出ACK数据包，通知Server的发送连接正常


### 四次挥手
1. 客户端与服务器之间关闭相互通信的连接
1. 第一次挥手：client发送带有FIN的数据包，半关闭client的发送连接
1. 第二次挥手：server收到client的关闭请求，发出ACK数据包，通知client半关闭成功
1. 第三次挥手：server收到client的关闭请求，发出FIN数据包，半关闭server的发送连接
1. 第四次挥手：client收到server的关闭请求，发出ACK数据包，通知server关闭成功，此时完全释放连接
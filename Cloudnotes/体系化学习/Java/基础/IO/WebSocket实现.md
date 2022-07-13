[toc]

#### 1. 消息推送实现

技术选型：

- netty-socketio 的作用是建立socket 连接

- redisson 的作用是利用redis 在服务器集群时共享socket 连接





#### 2.netty-socketIO的使用

​		Netty-SocketIO是一个开源的、基于Netty的、Java版的即时消息推送项目。通过Netty-SocketIO，我们可以轻松的实现服务端主动向客户端推送消息的场景。它和websocket有相同的作用，只不过Netty-SocketIO可支持所有的浏览器。

​		Socket.IO除了支持WebSocket通讯协议外，还支持许多种轮询（Polling）机制以及其它实时通信方式，并封装成了通用的接口，并且在服务端实现了这些实时机制的相应代码。Socket.IO能够根据浏览器对通讯机制的支持情况自动地选择最佳的方式来实现网络实时应用。

添加依赖：

```xml
		<dependency>
            <groupId>com.corundumstudio.socketio</groupId>
            <artifactId>netty-socketio</artifactId>
            <version>1.7.17</version>
        </dependency>

```

实现功能：服务端向前台页面每隔一秒钟，推送两个100以内的正整数，前台页面进行实时的显示。

服务端：

```java
	private static List<SocketIOClient> clients = new ArrayList<SocketIOClient>();//用于保存所有客户端
    public static void main(String[] args) {

        Configuration config = new Configuration();
        config.setHostname("localhost");
        config.setPort(9092);

        final SocketIOServer server = new SocketIOServer(config);
        //添加创建连接的监听器
        server.addConnectListener(new ConnectListener() {

            @Override
            public void onConnect(SocketIOClient client) {
                clients.add(client);
            }
        });
        //添加断开连接的监听器
        server.addDisconnectListener(new DisconnectListener() {
            @Override
            public void onDisconnect(SocketIOClient client) {
                clients.remove(client);
            }
        });

        //启动服务
        server.start();

        System.out.println("开始推送了..................");
        Timer timer = new Timer();
        timer.schedule(new TimerTask() {
            @Override
            public void run() {
                Random random = new Random();

                Packet packet = new Packet(PacketType.EVENT);
                packet.setData(random.nextInt(100));

                for(SocketIOClient client : clients) {
                    client.sendEvent("hello", new Point(random.nextInt(100), random.nextInt(100)));
                    //client.sendEvent("hello", packet);
                }
                //System.out.println(clients.size());
            }
        }, 1000, 1000);  //每隔一秒推送一次


    }
```



客户端：

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Title</title>
    <script src="http://libs.baidu.com/jquery/2.0.0/jquery.min.js" type="application/javascript"></script>
    <script src="https://lib.baomitu.com/socket.io/2.3.0/socket.io.js" type="application/javascript"></script>

    <script>
        $(function(){
            
            var socket =  io.connect('http://127.0.0.1:9092');
            //监听名为hello的事件，这与服务端推送的那个事件名称必须一致
            socket.on("hello", function(data){
                //console.log(data);
                $('#x').text(data.x);
                $('#y').text(data.y);

            });
        });

    </script>
</head>
<body>

    <div id="display" style="height:50px;">
        x=<span id="x">0</span>, y=<span id="y">0</span>
    </div>

</body>
</html>
```



#### 3.创建项目，创建数据库

#### 4.基础功能实现

#### 5. 方案

- 建立webSocket 连接

  注：如果同一个用户开了多个客户端，同时建立多个连接，为了保证可以给多个客户端都能推送消息，对于这种情况会引入Room 的概念，简单理解也就是把同一个用户建立的多个不同连接，放到一个集合中，当需要给该用户推送消息的时候，根据用户ID 获取到集合列表，然后循环发送，从而保证可以给多个客户端分别推送消息。

  ![image-20220301134023956](images/image-20220301134023956.png)

- 推送消息

  ![image-20220301134121064](images/image-20220301134121064.png)

- 断开连接

  当用户关闭浏览器的时候，服务器端会监听到该操作，必须把该连接从对应的Room 中移除掉，并且断开连接。防止连接跟缓存占用太多，导致服务器出问题。

  ![image-20220301134202018](images/image-20220301134202018.png)








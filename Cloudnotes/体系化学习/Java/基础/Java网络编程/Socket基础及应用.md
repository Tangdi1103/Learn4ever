ServerSockt ---> 服务端

Socket ---> 客户端



### 阻塞点：



一、服务端监听端口，并等待客户端的连接

```java
ServerSockt serverSockt = new ServerSockt (port);

// 此时阻塞状态，直到有客户端通过new Socket(host,port)建立与服务端的连接
Sockt socket = serverSockt.accept();
```



客户端建立与服务端的连接，通过TCO三次握手建立连接

```java
Sockt  sockt  = new  Sockt (host,port);
```



二、服务端获取InputStream，并执行read读取数据

```java
InputStream inputStream = socket.getInputStream()
byte[] bytes = new byte[1024];
// read读取数据阻塞，直到客户端的OutputStream执行write写数据
inputStream.read(bytes)
```



客户端建立连接后，通过InputStream和OutputStream与服务端交互数据

```java
OutputStream outputStream = socket.getOutputStream()
outputStream.write("今天这么晚呀");

InputStream inputStream = socket.getInputStream();
byte[] bytes = new byte[1024];
inputStream.read(bytes)
```


ServerSockt ---> 服务端

Socket ---> 客户端



## BIO：

##### 缺点：

- **每个请求进来，都由线程池分配一个线程来处理连接及IO操作，当并发量大时，需要创建大量线程来处理，系统资源占用很大**
- **与客户端建立连接后，分配线程去处理连接，当客户端没有OS的write操作，则当前线程IS的read操作会一直阻塞，浪费系统资源**
- **有多少个请求同时过来，就需要分配多少个线程取处理**



##### 阻塞点

**一、（连接阻塞）服务端监听端口，并等待客户端的连接**

```java
ServerSockt serverSockt = new ServerSockt (port);

// 此时阻塞状态，直到有客户端通过new Socket(host,port)建立与服务端的连接
Sockt socket = serverSockt.accept();
```



客户端建立与服务端的连接，通过TCO三次握手建立连接

```java
Sockt  sockt  = new  Sockt (host,port);
```



**二、（读写阻塞）服务端获取InputStream，并执行read读取数据**

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





## NIO

### 优点：

- **一千个请求同时过来，可能只需十几个线程就能完成处理**
- **通过selector监听连接事件和读写事件，只有发生读写事件时，才会交给线程处理，大大节省了系统资源**

### 缓存区(Buffer)

缓冲区对象创建：allocate、wrap

缓冲区对象添加数据：position()/position(intnewPosition)、limit/limit(int newLimit)、capacity、remaining、put(byte b)/put(byte[] src)

缓冲区对象读取数据：flip、clear、get

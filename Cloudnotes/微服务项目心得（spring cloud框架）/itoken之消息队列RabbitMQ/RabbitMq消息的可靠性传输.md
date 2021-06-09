![image](https://note.youdao.com/yws/public/resource/c5be5802daf0385d18fbdfde57d959e9/xmlnote/38B001ABDF514A28A42FC73FC3DAE180/5569)

![image](https://note.youdao.com/yws/public/resource/c5be5802daf0385d18fbdfde57d959e9/xmlnote/F837ED7F237342479382FFD94DE77E8D/5642)

### 1.生产者发送时丢失

##### 方案一（同步阻塞）

Rabbitmq事务机制：生产者发送数据之前开启 RabbitMQ 事务channel.txSelect()，然后发送消息，如果消息没有成功被 RabbitMQ 接收到，那么生产者会收到异常报错，此时就可以回滚事务channel.txRollback()，然后重试发送消息；如果收到了消息，那么可以提交事务channel.txCommit()

##### 方案二（Confirm的异步模式）
Confirm确认机制：在生产者那里设置开启 confirm 模式channel.confirmSelect()，你每次写的消息都会分配一个唯一的 id，写入MQ时，MQ 回调ack接口表示接收成功，回调nack接口表示接收失败可以尝试重发

```
// 创建连接
ConnectionFactory factory = new ConnectionFactory();
factory.setUsername(config.UserName);
factory.setPassword(config.Password);
factory.setVirtualHost(config.VHost);
factory.setHost(config.Host);
factory.setPort(config.Port);
Connection conn = factory.newConnection();
// 创建信道
Channel channel = conn.createChannel();
// 声明队列
channel.queueDeclare(config.QueueName, false, false, false, null);
// 开启发送方确认模式
channel.confirmSelect();
for (int i = 0; i < 10; i++) {
    String message = String.format("时间 => %s", new Date().getTime());
    channel.basicPublish("", config.QueueName, null, message.getBytes("UTF-8"));
}
//异步监听确认和未确认的消息
channel.addConfirmListener(new ConfirmListener() {
    @Override
    public void handleNack(long deliveryTag, boolean multiple) throws IOException {
        System.out.println("未确认消息，标识：" + deliveryTag);
    }
    @Override
    public void handleAck(long deliveryTag, boolean multiple) throws IOException {
        System.out.println(String.format("已确认消息，标识：%d，多个消息：%b", deliveryTag, multiple));
    }
});
```

---


### 2.MQ弄丢了数据

##### 方案：
首先创建 queue 的时候将其设置为持久化，其次发送消息的时候将消息的 deliveryMode 设置为 2。

###### 注意：必须要同时设置这两个持久化才行，RabbitMQ 挂了后，再次重启，会从磁盘上重启恢复 queue，然后恢复这个 queue 里的数据。

所以，持久化可以跟生产者那边的confirm机制配合起来，只有消息被持久化到磁盘之后，才会通知生产者ack了，所以哪怕是在持久化到磁盘之前，RabbitMQ 挂了，数据丢了，生产者收不到 ack，你也是可以自己重发的。

---

### 3.消费者弄丢数据

##### 方案：

使用RabbitMQ 提供的 ack 机制，简单来说，就是你必须关闭 RabbitMQ 的自动 ack，可以通过一个api来调用就行，然后每次你自己代码里确保处理完的时候，再在程序里 ack 一把。这样的话，如果你还没处理完，不就没有 ack 了？那 RabbitMQ就认为你还没处理完，这个时候RabbitMQ会把这个消费分配给别的 consumer 去处理，消息是不会丢的。
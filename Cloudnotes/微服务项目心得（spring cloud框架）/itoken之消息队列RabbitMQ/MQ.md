Broker是消息队列的服务器

Actor模块使用ErLang语言开发，实现了任务的公平调度


- 生产者和消费者的对象实体类所在的目录必须一致，并且实现序列化接口
- 序列化和反序列化方式必须一致


fanout交换机

生产者：创建连接工厂，工厂设置ip端口账号密码，工厂创建连接对象，连接对象创建channel通道对象，channel.exchangDeclare指定交换机，channel.queueDeclare指定队列（可以是集合），channel.queueBind通过routingKey绑定交换机和队列，channel.basicPublish(exchange，key，props，消息)通过routingKey推送消息到交换机，channel.close，connection.close


direct交换机(“”默认交换机)

生产者：指定单个队列，不用指定交换机，交换机不用绑定队列，推送到队列(“”，queue，props，消息)

消费者：指定队列；channel.basicQos(0，1，false)；new DefaultConsumer(channel)创建消费者，手动basicAck(envelope.getDeliverTag，false)；channel.basicConsumer(队列，是否ack，消费者)



















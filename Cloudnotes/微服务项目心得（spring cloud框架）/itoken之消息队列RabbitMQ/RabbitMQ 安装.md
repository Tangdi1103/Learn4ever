我们基于 Docker 来安装 RabbitMQ

### docker-compose.yml


```
version: '3.1'
services:
  rabbitmq:
    restart: always
    image: rabbitmq:management
    container_name: rabbitmq
    ports:
      - 5672:5672
      - 15672:15672
    environment:
      TZ: Asia/Shanghai
      RABBITMQ_DEFAULT_USER: rabbit
      RABBITMQ_DEFAULT_PASS: 123456
    volumes:
      - ./data:/var/lib/rabbitmq
```

### RabbitMQ WebUI

##### 访问地址

http://ip:15672

##### 首页


![image](https://note.youdao.com/yws/public/resource/c5be5802daf0385d18fbdfde57d959e9/xmlnote/7B37491EA8974322AB8E3B7F6974D40E/3165)

- Connections：连接数
- Channels：频道数
- Exchanges：交换机数
- Queues：队列数
- Consumers：消费者数
 

##### 队列页面


- Name：消息队列的名称，这里是通过程序创建的
- Features：消息队列的类型，durable:true为会持久化消息
- Ready：准备好的消息
- Unacked：未确认的消息
- Total：全部消息
- 备注：如果都为 0 则说明全部消息处理完成
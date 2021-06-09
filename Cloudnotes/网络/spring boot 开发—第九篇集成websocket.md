### 引入依赖
```
<!-- 引入 websocket 依赖类-->
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-websocket</artifactId>
</dependency>

```

### 创建请求消息实体


```
package com.vesus.springbootwebsocket.model;

/**
 * @Description:
 * @Author: vesus
 * @CreateDate: 2018/5/28 下午5:46
 * @Version: 1.0
 */
public class RequestMessage {

    /***
     * 请求消息
     */
    private String message ;

    public String getMessage() {
        return message;
    }

    public void setMessage(String message) {
        this.message = message;
    }
}

```
### 创建响应消息实体


```
package com.vesus.springbootwebsocket.model;

/**
 * @Description:
 * @Author: vesus
 * @CreateDate: 2018/5/28 下午5:47
 * @Version: 1.0
 */
public class ResponseMessage {

    /**
     * 响应消息
     */
    private String message ;

    public String getMessage() {
        return message;
    }

    public void setMessage(String message) {
        this.message = message;
    }
}

```
### 配置消息代理


```
package com.vesus.springbootwebsocket.config;

import org.springframework.context.annotation.Configuration;
import org.springframework.messaging.simp.config.MessageBrokerRegistry;
import org.springframework.web.socket.config.annotation.EnableWebSocketMessageBroker;
import org.springframework.web.socket.config.annotation.StompEndpointRegistry;
import org.springframework.web.socket.config.annotation.WebSocketMessageBrokerConfigurer;

/**
 * @Description:
 * @Author: vesus
 * @CreateDate: 2018/5/29 上午10:41
 * @Version: 1.0
 */
@Configuration
@EnableWebSocketMessageBroker
public class WebSocketConfig implements WebSocketMessageBrokerConfigurer {
    /***
     * 注册 Stomp的端点
     * addEndpoint：添加STOMP协议的端点。提供WebSocket或SockJS客户端访问的地址
     * withSockJS：使用SockJS协议
     * @param registry
     */
    public void registerStompEndpoints(StompEndpointRegistry registry) {
        registry.addEndpoint("/api/v1/socket")
                .setAllowedOrigins("*")//添加允许跨域访问
                .withSockJS() ;
    }

    /**
     * 配置消息代理
     * 启动Broker，消息的发送的地址符合配置的前缀来的消息才发送到这个broker
     */
    public void configureMessageBroker(MessageBrokerRegistry registry) {
        registry.enableSimpleBroker("/api/v1/socket/send");//推送消息前缀
        registry.setApplicationDestinationPrefixes("/api/v1/socket/req");//应用请求前缀
        registry.setUserDestinationPrefix("/user");//推送用户前缀
    }

}

```

### 控制器


```
package com.vesus.springbootwebsocket.controller;

import com.vesus.springbootwebsocket.model.RequestMessage;
import com.vesus.springbootwebsocket.model.ResponseMessage;
import org.springframework.messaging.handler.annotation.MessageMapping;
import org.springframework.messaging.handler.annotation.SendTo;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;

import javax.annotation.Resource;

/**
 * @Description:
 * @Author: vesus
 * @CreateDate: 2018/5/29 下午1:48
 * @Version: 1.0
 */
@Controller
public class WebSocketController {

    @Resource
    private SimpMessagingTemplate messagingTemplate ;

    @RequestMapping("/index")
    public String index(){
        return "index";
    }

    @MessageMapping("/welcome")
    public ResponseMessage toTopic(RequestMessage msg) throws Exception
    {
        System.out.println("======================"+msg.getMessage());
        this.messagingTemplate.convertAndSend("/api/v1/socket/send",msg.getMessage());
        return new ResponseMessage("欢迎使用webScoket："+msg.getMessage());
    }

    @MessageMapping("/message")
    public ResponseMessage toUser(RequestMessage msg ) {
        System.out.println(msg.getMessage());
        this.messagingTemplate.convertAndSendToUser("123","/message",msg.getMessage());
        return new ResponseMessage("欢迎使用webScoket："+msg.getMessage());
    }
}

```

### 前端HTML


```
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head>
    <title>WebScoket广播式</title>
    <script src="/sockjs.js"></script>
    <script src="/stomp.js"></script>
    <script src="/jquery.js"></script>
</head>
<body onload="disconnect()">
<button id="connect" onclick="connect()">连接</button>
<button id="disconnect" onclick="disconnect()" disabled="disabled">断开连接</button><br/>
<div id="inputDiv">
    输入名称：<input type="text" id="name"/><br/>
    <button id="sendName" onclick="sendName()">发送</button><br/>
    <p id="response"></p>
</div>
<script>
    var stompClient = null;
    //设置连接状态控制显示隐藏
    function setConnected(connected)
    {
        $("#connect").attr("disabled",connected);
        $("#disconnect").attr("disabled",!connected);
        if(!connected) {
            $("#inputDiv").hide();
        }else{
            $("#inputDiv").show();
        }
        $("#reponse").html("");
    }
    //连接
    function connect()
    {
        var socket = new SockJS("/api/v1/socket");
        stompClient = Stomp.over(socket);
        stompClient.connect({},function (frame) {
            setConnected(true);
            console.log("connected : "+frame);
            stompClient.subscribe("/api/v1/socket/send",function (response) {
                showResponse(JSON.parse(response.body));
            })
        })
    }
    //断开连接
    function disconnect(){
        if(stompClient!=null)
        {
            stompClient.disconnect();
        }
        setConnected(false);
        console.log("disconnected!");
    }
    //发送名称到后台
    function sendName(){
        var name = $("#name").val();
        stompClient.send("/api/v1/socket/req/message",{},JSON.stringify({'message':name}));
    }
    //显示socket返回消息内容
    function showResponse(message)
    {
        $("#response").html(message);
    }
</script>
</body>
</html>

```
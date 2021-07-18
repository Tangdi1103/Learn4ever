



### tomcat是一个servlet的具体实现

### 网络请求流程

### tomcat的核心组成

##### http服务器

封装了socket处理，http数据解析和io操作，封装成一个request对象。与浏览器进行tcp通信，应用层协议为http的格式

连接器组件（Connector）：tomcat中连接器组件是Coyote，内部包含Endpoint、Processor和Adaper，分别进行socket处理，http数据解析和请求/响应对象转换

##### servlet容器：

注册了业务端所有servclet，根据请求url分发请求到对应servlet

容器组件（Container）：tomcat中容器组件是Catalina

### tomcat架构：

tomcat就是一个Catalina实例（加载server.xml），下面有一个Server实例，再下面有多个service实例，再下面有多个connector和一个 container。Server的配置就是Server.xml
### 一、首先了解下web.xml中元素的加载顺序：

1. 启动web项目后，web容器首先回去找web.xml文件，读取这个文件
2. 容器会创建一个 ServletContext （ servlet 上下文），整个 web 项目的所有部分都将共享这个上下文
3. 容器将 转换为键值对，并交给 servletContext
4. 容器创建 中的类实例，创建监听器
5. 容器加载filter，创建过滤器， 要注意对应的filter-mapping一定要放在filter的后面
6. 容器加载servlet，加载顺序按照 Load-on-startup 来执行

**web容器完整加载顺序：ServletContext -> context-param -> listener-> filter -> servlet**

### 二、监听器启动Spring，Servlet启动SpringMVC

```xml
<context-param>
    <param-name>contextConfigLocation</param-name>
    <param-value>classpath*:applicationContext*.xml</param-value>
</context-param>

<!--监听器初始化启动spring容器-->
<listener>
	<listenerclass>org.springframework.web.context.ContextLoaderListener</listenerclass>
</listener>

<!--springmvc启动-->
<servlet>
    <servlet-name>springmvc</servlet-name>
    <servletclass>org.springframework.web.servlet.DispatcherServlet</servletclass>
    <init-param>
        <param-name>contextConfigLocation</param-name>
        <param-value>classpath*:springmvc.xml</param-value>
    </init-param>
    <load-on-startup>1</load-on-startup>
</servlet>
<servlet-mapping>
    <servlet-name>springmvc</servlet-name>
    <url-pattern>/</url-pattern>
</servlet-mapping>
```


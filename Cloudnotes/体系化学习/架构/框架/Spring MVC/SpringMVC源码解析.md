 SpringMVC容器和Spring容器的关系是子父容器，MVC初始化Conteroller bean，Spring初始化Service和Dao bean



![image-20210627221121634](images/image-20210627221121634.png)



### 1.org.springframework.web.servlet.HttpServletBean#init

![image-20210627221245731](images/image-20210627221245731.png)



### 2.org.springframework.web.servlet.FrameworkServlet#initServletBean

![image-20210627221214204](images/image-20210627221214204.png)



### 3.org.springframework.web.servlet.FrameworkServlet#setApplicationContext

![image-20210627221710965](images/image-20210627221710965.png)

### 4.org.springframework.web.servlet.FrameworkServlet#initWebApplicationContext

![webApplicationContext](images/webApplicationContext.png)

**4.1 WebApplicationContext rootContext = WebApplicationContextUtils.getWebApplicationContext(getServletContext());方法获取servlet上下文中的默认配置的WebApplicationContext**

**4.2 cwac.setParent(rootContext);方法将Spring容器作为SpringMVC容器的父容器**

**4.3 configureAndRefreshWebApplicationContext(cwac)；初始化了SpringMVC容器的一些数据并调用org.springframework.context.support.AbstractApplicationContext#refresh，进入Spring容器启动的流程([详情查看SpringIoC源码解析](../Spring/SpringIoC/源码解析.md) )**

![image-20210627223607171](images/image-20210627223607171.png)

### 5.org.springframework.web.servlet.DispatcherServlet#onRefresh

**5.1 DispatcherServlet重写了父类FrameworkServlet的onRefresh方法**

**5.2 进行了SpringMVC九大组件的初始化工作**

![image-20210627224434724](images/image-20210627224434724.png)
<font size = 4>

##### 传统的SSM架构由Spring+SpringMVC+Mybatis组成，需挂载Web容器中运行（如tomcat）。且一般前后端一体（页面一般是jsp），由SpringMVC组件返回modelAndView（经model数据渲染的视图）。


##### SpringBoot内置Web容器，可以直接运行启动。SpringBoot项目使用SpringMVC处理前端请求，通常不会返回View，而是做成RESTful API(接口)服务只返回数据，格式一般为JSON或XML。


##### spring boot就是一个大框架里面包含了许许多多的东西，其中spring就是最核心的内容之一，当然就包含spring mvc。spring mvc 是只是spring 处理web层请求的一个模块。因此他们的关系大概就是这样：spring mvc  < spring <springboot。


##### Spring MVC是基于 Servlet 的一个 MVC 框架 主要解决 WEB 开发的问题，因为 Spring 的配置非常复杂，各种XML、 JavaConfig、hin处理起来比较繁琐。


##### 于是为了简化开发者的使用，从而创造性地推出了Spring boot，约定优于配置，简化了spring的配置流程。


##### 然后有发现每次开发都写很多样板代码，为了简化工作流程，于是开发出了一些“懒人整合包”（starter），这套就是 Spring Boot。


##### Spring MVC的功能Spring MVC提供了一种轻度耦合的方式来开发web应用。Spring MVC是Spring的一个模块，式一个web框架。



##### 通过Dispatcher Servlet, ModelAndView 和 View Resolver，开发web应用变得很容易。解决的问题领域是网站应用程序或者服务开发——URL路由、Session、模板引擎、静态Web资源等等。



##### Spring Boot的功能Spring Boot实现了自动配置，降低了项目搭建的复杂度。



##### 众所周知Spring框架需要进行大量的配置，Spring Boot引入自动配置的概念，让项目设置变得很容易。



##### Spring Boot本身并不提供Spring框架的核心特性以及扩展功能，只是用于快速、敏捷地开发新一代基于Spring框架的应用程序。也就是说，它并不是用来替代Spring的解决方案，而是和Spring框架紧密结合用于提升Spring开发者体验的工具。



##### 同时它集成了大量常用的第三方库配置(例如Jackson, JDBC, Mongo, Redis, Mail等等)，Spring Boot应用中这些第三方库几乎可以零配置的开箱即用(out-of-the-box)，大部分的Spring Boot应用都只需要非常少量的配置代码，开发者能够更加专注于业务逻辑。



##### Spring Boot只是承载者，辅助你简化项目搭建过程的。如果承载的是WEB项目，使用Spring MVC作为MVC框架，那么工作流程和你上面描述的是完全一样的，因为这部分工作是Spring MVC做的而不是Spring Boot。对使用者来说，换用Spring Boot以后，项目初始化方法变了，配置文件变了，另外就是不需要单独安装Tomcat这类容器服务器了，maven打出jar包直接跑起来就是个网站，但你最核心的业务逻辑实现与业务流程实现没有任何变化。



##### 所以，用最简练的语言概括就是：
- Spring 是一个“引擎”；
- Spring MVC 是基于Spring的一个 MVC 框架 ；
- Spring Boot 是基于Spring4的条件注册的一套快速开发整合包。

整理的比较清楚的帖子：https://www.cnblogs.com/hgmyz/p/12351527.html
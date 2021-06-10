[toc]
<font size=4>
# 第1节Spring 简介
> Spring 是分层的full-stack（全栈） 轻量级开源框架，以IoC 和AOP 为内核，提供了展现层Spring
> MVC 和业务层事务管理等众多的企业级应⽤技术，还能整合开源世界众多著名的第三⽅框架和类库，已经成为使⽤最多的Java EE 企业应⽤开源框架。

> Spring 官⽅⽹址：http://spring.io/

> 我们经常说的Spring 其实指的是Spring Framework（spring 框架）。


# 第2节Spring 发展历程

在Spring之前，JAVA主流的框架是EJB，程序员在开发应用的时候往往花费更多时间在底层技术实现上，另外其配套的环境及组件庞大臃肿，启动调试及其困难。

- 1997年IBM 提出了EJB的思想； 
- 1998年，SUN 制定开发标准规范EJB1.0； 
- 1999年，EJB 1.1发布； 
- 2001年，EJB 2.0发布； 
- 2003年，EJB 2.1发布； 
- 2006年，EJB 3.0发布；
- Rod Johnson（spring之⽗）
    - Expert One-to-One J2EE Design and Development(2002) 阐述了J2EE使⽤EJB开发设计的优点及解决⽅案
    - Expert One-to-One J2EE Development without EJB(2004) 阐述了J2EE开发不使⽤EJB的解决⽅式（Spring雏形）
- 2017 年9 ⽉份发布了Spring 的最新版本Spring 5.0 通⽤版（GA）


# 第3节Spring 的优势

## ⽅便解耦，简化开发
通过Spring提供的IoC容器，可以将对象间的依赖关系交由Spring进⾏控制，避免硬编码所造成的
过度程序耦合。⽤户也不必再为单例模式类、属性⽂件解析等这些很底层的需求编写代码，可以更
专注于上层的应⽤及业务开发。

## AOP编程的⽀持
通过Spring的AOP功能，⽅便进⾏⾯向切⾯的编程，许多不容易⽤传统OOP实现的功能可以通过
AOP轻松应付。

## 声明式事务的⽀持
@Transactional
可以将我们从单调烦闷的事务管理代码中解脱出来，通过声明式⽅式灵活的进⾏事务的管理，提⾼
开发效率和质量。

## ⽅便程序的测试
可以⽤⾮容器依赖的编程⽅式进⾏⼏乎所有的测试⼯作，测试不再是昂贵的操作，⽽是随⼿可做的
事情。

## ⽅便集成各种优秀框架
Spring可以降低各种框架的使⽤难度，提供了对各种优秀框架（Struts、Hibernate、Hessian、
Quartz等）的直接⽀持。

## 降低JavaEE API的使⽤难度
Spring对JavaEE API（如JDBC、JavaMail、远程调⽤等）进⾏了薄薄的封装层，使这些API的使⽤
难度⼤为降低。

## 源码是经典的Java 学习范例
Spring的源代码设计精妙、结构清晰、匠⼼独⽤，处处体现着⼤师对Java设计模式灵活运⽤以及对
Java技术的⾼深造诣。它的源代码⽆意是Java技术的最佳实践的范例。

# 第4节Spring 的核⼼结构

Spring是⼀个分层⾮常清晰并且依赖关系、职责定位⾮常明确的轻量级框架，主要包括⼏个⼤模块：数
据处理模块、Web模块、AOP（Aspect Oriented Programming）/Aspects模块、Core Container模块
和Test 模块，如下图所示，Spring依靠这些基本模块，实现了⼀个令⼈愉悦的融合了现有解决⽅案的零
侵⼊的轻量级框架。 

<img src="images/11206" alt="image"  />

- Spring核⼼容器（Core Container） 容器是Spring框架最核⼼的部分，它管理着Spring应⽤中bean的创建、配置和管理。在该模块中，包括了Spring bean⼯⼚，它为Spring提供了DI的功能。基于bean⼯⼚，我们还会发现有多种Spring应⽤上下⽂的实现。所有的Spring模块都构建于核⼼容器之上。

- ⾯向切⾯编程（AOP）/Aspects Spring对⾯向切⾯编程提供了丰富的⽀持。这个模块是Spring应⽤系统中开发切⾯的基础，与DI⼀样，AOP可以帮助应⽤对象解耦。

- 数据访问与集成（Data Access/Integration）——Spring的JDBC和DAO模块封装了⼤量样板代码，这样可以使得数据库代码变得简洁，也可以更专注于我们的业务，还可以避免数据库资源释放失败⽽引起的问题。 另外，Spring AOP为数据访问提供了事务管理服务，同时Spring还对ORM进⾏了集成，如Hibernate、MyBatis等。该模块由JDBC、Transactions、ORM、OXM 和JMS 等模块组成。

- Web 该模块提供了SpringMVC框架给Web应⽤，还提供了多种构建和其它应⽤交互的远程调⽤⽅案。 SpringMVC框架在Web层提升了应⽤的松耦合⽔平。

- Test 为了使得开发者能够很⽅便的进⾏测试，Spring提供了测试模块以致⼒于Spring应⽤的测试。 通过该模块，Spring为使⽤Servlet、JNDI等编写单元测试提供了⼀系列的mock对象实现。


</font>
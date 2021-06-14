### OOP解决解决纵向代码重复问题

    如猫/狗/猪 属性都有身高/体重，行为都有吃/跑。此时创建一个动物类涵盖这些属性和行为。就能解决代码重复问题

### AOP解决横切逻辑代码重复问题，和业务代码耦合

    切：原有业务逻辑代码不能动，只能操作横切逻辑，如性能监控/日志打印/事务控制，所以面向横切逻辑变成
    面：通常有多个使用了横切逻辑代码的纵向方法，组成了面
    AOP可将横切逻辑代码与业务代码拆分，并不影响原业务逻辑

​    

### 问题1：

​	传统开发方式中，需要调用外部方法时都要new一个对象，如果调用地方多或者功能变更，如DAO层改为Mybatis。对每⼀个new 的地⽅都需要修改源代码，重新编译，很是麻烦，如何才能⾯向接⼝开发？

### 问题2：

​	servlet层的对象如果不被容器管理，那么spring mvc的controller是怎么通过注解依赖到service层的？

### 问题3：

​	怎么才能在servlet层不被托管情况下，注入依赖对象

### 问题4

​	如何在MVC架构中，service同个方法调用多个dao方法，对事务进行管理控制

### 问题5

 	如果有成百上千个service层需要事务控制，是不是要每个方法都要执行关闭autoCommit（可全局配置关闭），统一提交事务，异常回滚？

### 问题6

​		单例模式的静态方法的区别

### 思考1：

​	需要被托管的类，只要配置beans.xml，在web容器启动的时候解析xml，创建所有带bean标签的类实例保存到beanFactory的Map内存中。然后通过反射判断该类的属性有哪些带@AutoWired的属性，通过反射将这些属性赋值（由之前组装的Map中获取）



### 思考2

​	怎么才能进行事务控制呢？业务集中在service层，所以应该在service层中进行事务控制。而一个service方法可能调用多次dao层，所以应该保证每个线程获得到的connection都得是同一个，才能在异常时rollback。

​	所以dao层进行jdbc操作时候，得保证同个线程得到得连接相同。到这里，大家也都猜到了用ThreadLocal啦。用ThreadLocal来保存线程的上下文，保证每次获取都是同一个连接

1. 事务管理必须关闭autoCommit，进行手动commit来管控事务，需在全局配置SqlMapConfig中配置
2. Mybatis有三种事务管理器，分别为JdbcTransaction、ManagedTransaction和SpringManagedTransaction
3. SqlSessionFactory创建SqlSession前，根据Configuration核心配置类创建对应Transaction
4. 将Transaction传入Executor执行器，由Transaction控制jdbc连接和事务
5. 事务控制的前提是，一个方法中所有的jdbc操作都是同一个连接。如果实现了DAO层，并且在service方法中调用了多个DAO方法操作数据库，那DAO接口的实现类或者是接口代理实现类就不能直接通过连接池获取Connection连接。解决方法是，通过**ThreadLocal**来保证每个线程的连接是同一个

### 思考3

​	代理分为动态代理、静态代理。

 1. 静态代理

    1.1. 对应不同功能，需要编写不同代理类

    1.2. 代理与被代理实现同一个接口（拥有相同行为），代理类增强被代理类功能（被代理类传入代理类中，代理方法调用被代理方法）

    1.3. 如下，就是静态代理，代理类需被代理类传入。代理类来增强功能

    ```java
    // 租房接口
    public interface RentingHouse{
        void rentHouse();
    }
    
    // 委托类
    public class IRentingHouseImpl implements RentingHouse{
        @Override
        public void rentHouse(){
            System.out.print("我要租一室一厅");
        }
    }
    
    // 代理类
    public class IRentingHouseProxy implements RentingHouse{
        
        RentingHouse rentHouse;
        
        public IRentingHouseProxy(RentingHouse rentHouse){
            this.rentHouse = rentHouse;
        }
        
        @Override
        public void rentHouse(){
            System.out.print("中介（代理）收取3%服务费");
            rentHouse.rentHouse();
            System.out.print("客服信息买了3毛钱");
        }
    }
    
    public class Test {
        public static void main(String[] args){
            IRentingHouse iRentingHouse = new IRentingHouseImpl();  // 委托对象
            IRentingHouse iRentingHouseProxy = new IRentingHouseProxy(iRentingHouse); //代理类
            iRentingHouseProxy.rentHouse();
        }
    }
    ```

    

 2. 动态代理

    1.1. 对应布通功能，可用同一代理类

    1.2. 动态代理分为：JDK动态代理，cglib动态代理（三方类库）

    1.3. jdk动态代理如下：

    ```java
    // 租房接口
    public interface RentingHouse{
        void rentHouse();
    }
    
    // 委托类
    public class IRentingHouseImpl implements RentingHouse{
        @Override
        public void rentHouse(){
            System.out.print("我要租一室一厅");
        }
    }
    
    
    
    public class Test {
        public static void main(String[] args){
            IRentingHouse iRentingHouse = new IRentingHouseImpl();  // 委托对象
            
            // 生成代理对象
            Object o = Proxy.newInstanceProxy(Test.Class.getClassLoader,new Class[]{IRentingHouse.class]},new InvocationHandler(){
                @Overrid
                public Object invoke(Proxy p,Method m,Object[] args){
                    ...
                    Object o = m.invoke(iRentingHouse,args);
                    ...
                    return o;
                }
            });//代理类
            iRentingHouseProxy.rentHouse();
        }
    }
    ```

    1.4. cglib动态代理如下

    ```java
    // 租房接口
    public interface RentingHouse{
        void rentHouse();
    }
    
    // 委托类
    public class IRentingHouseImpl implements RentingHouse{
        @Override
        public void rentHouse(){
            System.out.print("我要租一室一厅");
        }
    }
    
    
    
    public class Test {
        public static void main(String[] args){
            IRentingHouse iRentingHouse = new IRentingHouseImpl();  // 委托对象
            
            // 生成代理对象
            Object o = Enhancer.create(iRentingHouse.getClass(),new MethodInterceptor(){
                @Overrid
                public Object intercept(Object o,Method method,Object[] objects,MethodProxy methodProxy){
                    ...
                    Object o = method.invoke(iRentingHouse,args);
                    ...
                    return o;
                }
            });//代理类
            iRentingHouseProxy.rentHouse();
        }
    }
    ```

    create中的入参

    1. Class<?>委托对象的Class
    2. MethodInterceptor增强的业务逻辑，通过方法拦截器实现逻辑增强
       1. Object委托对象的引用
       2. Method委托对象的方法
       3. Object[]委托对象方法的入参
       4. MethodProxy当前执行方法代理对象的封装

    

    cglib需要引入jar包

    ```xml
    <dependency>
        <groupId>cglib</groupId>
        <artifact>cglib</artifact>
        <version>2.1.2</version>
    </dependency>
    ```

    

    

    1.5. 俩区别

    jdk动态代理的委托类必须实现接口，而cglib则没这个要求





## 一、自定义IOC和AOP思路

### 1.1 beans.xml

beans.xml主要表述bean之间的依赖关系

```xml
<bean id="transferService" class="com.lagou.edu.service.impl.TransferServiceImpl">
	<property name="AccountDao" ref="accountDao"></property>
</bean>
```

### 1.2 BeanFactory

​	相当于IOC容器，管理bean的容器

1. BeanFactory工厂主要负责解析beans.xml

2. 通过反射获取bean实例存入Map中，property代表其所依赖bean，根据配置将所需依赖注入bean的属性中
3. 提供方法根据id从map中获取bean实例

### 1.3 ConnectionUtils

 	1. 使用ThreadLocal保证线程上下文的连接是同一个
 	2. 提供获取getConnection()方法

### 1.4 TransactionManager

​	提供事务管理，包括关闭自动提交、提交事务、回滚事务

### 1.5 ProxyFactory

	1. 代理工厂提供多种代理对象的创建
 	2. 这里的代理主要用来做事务管控，依赖TransactionManager

[TOC]



# 一、动态代理和静态代理

**代理机制**，如果熟悉设计模式中的代理模式，我们会知道，代理可以看作是对调用目标的一个包装，这样我们对目标代码的调用不是直接发生的，而是通过代理完成。其实很多动态代理场景，我认为也可以看作是装饰器（Decorator）模式的应用

## 1.静态代理

#### 1.1. 静态代理的缺点：无法将代理类通用给其他委托类使用，在代理类中固定了传入的委托类类型

#### 	1.2. 静态代理类似于模板模式、装饰器模式，不同的是代理类需要实现委托类的接口，最后调用相同的方法

#### 	1.3. 静态代理示例

委托类传入代理类中，代理类实现委托接口重写方法增强功能并调用委托类

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
        RentingHouse iRentingHouse = new IRentingHouseImpl();  // 委托对象
        RentingHouse iRentingHouseProxy = new IRentingHouseProxy(iRentingHouse); //代理类
        iRentingHouseProxy.rentHouse();
    }
}
```



## 2.动态代理+工厂模式

动态代理是一种方便运行时动态构建代理、增强委托类功能的机制，很多场景都是利用类似机制做到的，比如用来包装 RPC 调用、面向切面的编程（AOP）。

#### 1.1. 动态代理优点：弥补的静态代理的缺点，可代理任意委托类类型

#### 	1.2. 动态代理分为：JDK动态代理，cglib动态代理（三方类库）

#### 1.3. 现在创建一些组件：委托层、代理接口、工厂类

**委托接口**

```java
public interface Delegator {
    void introduce();
    void play();
}
```

**委托实现类**

```java
public class DelegatorImpl implements Delegator{

    private String name = "Delegator";

    public void introduce() {
        System.out.println("Hello! My name is " + name);
    }

    @Override
    public void play() {
        System.out.println("Let's go to play LOL!!");
    }
}

```

**统一代理接口**

```java
public interface ProxyHandler {

    Object getProxy();
}
```

**代理工厂**

根据传入委托类，选择对应的动态代理模式，有接口则使用JDK，无接口则使用cglib

```java
import java.util.Arrays;

/**
 * @program: demo5
 * @description:
 * @author: Wangwt
 * @create: 14:02 2021/7/10
 */
public class ProxyFactory {

    public Object getIntroduceProxy(Object object) {
        System.out.println(object.getClass().isInterface());
        System.out.println(Arrays.toString(object.getClass().getInterfaces()));
        if (object.getClass().isInterface()) {
            return new IntroduceJdkProxy(object).getProxy();
        } else if (object.getClass().getInterfaces().length > 0){
            return new IntroduceJdkProxy(object).getProxy();
        } else {
            return new IntroduceCglibProxy(object).getProxy();
        }
    }
}

```

**测试类**

```java
package com.example.demo5.design.proxy;

import java.lang.reflect.Field;

/**
 * @program: demo5
 * @description:
 * @author: Wangwt
 * @create: 14:42 2021/7/10
 */
public class MainTest {

    public static void main(String[] args) throws IllegalAccessException, NoSuchFieldException {
        DelegatorImpl delegator = new DelegatorImpl();
        System.out.println("===========代理前============");
        delegator.introduce();
        System.out.println("===========代理前============");

        ProxyFactory proxyFactory = new ProxyFactory();
        Delegator proxy = (Delegator) proxyFactory.getIntroduceProxy(delegator);
        Field name = delegator.getClass().getDeclaredField("name");
        name.setAccessible(true);
        name.set(delegator,"dacongming");
        System.out.println("===========代理后============");
        proxy.introduce();
        System.out.println("===========代理后============");
    }
}


运行结果：
    > Task :MainTest.main()
===========代理前============
Hello! My name is Delegator
===========代理前============
false
class com.example.demo5.design.proxy.DelegatorImpl
[interface com.example.demo5.design.proxy.Delegator]
===========代理后============
I am jdkProxy
Hello! My name is dacongming
===========代理后============
```



#### 1.4. jdk动态代理：

```java
import java.lang.reflect.InvocationHandler;
import java.lang.reflect.Method;
import java.lang.reflect.Proxy;

/**
 * @program: demo5
 * @description:
 * @author: Wangwt
 * @create: 14:05 2021/7/10
 */
public class IntroduceJdkProxy implements ProxyHandler {

    private Object object;

    public IntroduceJdkProxy(Object object) {
        this.object = object;
    }

    @Override
    public Object getProxy(){
        return Proxy.newProxyInstance(object.getClass().getClassLoader(), object.getClass().getInterfaces(), new InvocationHandler() {
            /**
             *
             * @param proxy 代理对象
             * @param method 委托对象执行的方法
             * @param args 委托对象执行的方法的参数
             * @return
             * @throws Throwable
             */
            @Override
            public Object invoke(Object proxy, Method method, Object[] args) throws Throwable {
                System.out.println("I am jdkProxy");
                Object result = method.invoke(object, args);
                return result;
            }
        });
    }
}
```

**JDK动态代理生成的对象相当于接口的一个实现类**

**newInstanceProxy()方法中的入参：**

1. ClassLoader类加载器
2. 需被代理类的接口类型

 3. 代理增强功能的逻辑

    1. `Proxy`代理本身
    2. `method`被代理类的方法
    3. `args`被代理类的方法入参

1和2使用反射机制，在底层动态的生成了一个代理对象

#### 	1.5. cglib动态代理

```java
import net.sf.cglib.proxy.Enhancer;
import net.sf.cglib.proxy.MethodInterceptor;
import net.sf.cglib.proxy.MethodProxy;

import java.lang.reflect.Method;

/**
 * @program: demo5
 * @description:
 * @author: Wangwt
 * @create: 14:06 2021/7/10
 */
public class IntroduceCglibProxy implements ProxyHandler {

    private Object object;

    public IntroduceCglibProxy(Object object) {
        this.object = object;
    }

    @Override
    public Object getProxy(){
        return Enhancer.create(object.getClass(), new MethodInterceptor() {
            /**
             * @param obj 代理对象
             * @param method 委托类执行的方法
             * @param args 委托类方法的参数
             * @param proxy 代理对象执行的方法
             * @return
             * @throws Throwable
             */
            @Override
            public Object intercept(Object obj, Method method, Object[] args, MethodProxy proxy) throws Throwable {
                System.out.println("I am cglibProxy");
                Object result = method.invoke(object, args);
                return result;
            }
        });
    }
}

```

**cglib动态代理生成的对象相当于委托类的一个子类**

**create中的入参**

1. Class<?>委托对象的Class
2. MethodInterceptor增强的业务逻辑，通过方法拦截器实现逻辑增强
   1. `Object`代理对象
   2. `Method`委托对象的方法
   3. `Object[]`委托对象方法的入参
   4. `MethodProxy`当前执行方法代理对象的封装



**cglib需要引入jar包**

```xml
<dependency>
    <groupId>cglib</groupId>
    <artifact>cglib</artifact>
    <version>2.1.2</version>
</dependency>
```

#### 1.6. jdk动态代理与cglib动态代理的比较

jdk动态代理

1. 委托类必须实现接口，得到代理对象必须转型为接口类型
2. 无需依赖三方类库，提高可维护性，支持平滑进行jdk升级

cglib动态代理

1. 委托类无需提供接口，减少代理侵入性
2. 需依赖三方类库，影响程序的可维护性，





# 二、Mybatis中的应用：

Mybatis的sqlSession获得DAO接口代理对象方法如下：

```java
@Override
    public Object getMapper(Class<?> mapperClass) {
        MapperProxyHandler mapperProxyHandler = new MapperProxyHandler(configuration,executor);
        return Proxy.newProxyInstance(DfaultSqlSession.class.getClassLoader(),new Class[]{mapperClass},mapperProxyHandler);
    }
```

Mybatis中通过getMapper得到代理对象，具体代理实现逻辑如下：

```java
public class MapperProxyHandler implements InvocationHandler {

    private Configuration configuration;
    private Executor executor;

    public MapperProxyHandler(Configuration configuration, Executor executor) {
        this.configuration = configuration;
        this.executor = executor;
    }

    @Override
    public Object invoke(Object proxy, Method method, Object[] args) throws Throwable {
        Class<?> aClass = method.getDeclaringClass();
        String spacename = aClass.getName();
        String id = method.getName();
        String key = spacename + "." + id;
        MappedStatement mappedStatement = configuration.getMappedStatements().get(key);
        String sqlType = mappedStatement.getSqlType();
        if ("select".equalsIgnoreCase(sqlType)){
            Type genericReturnType = method.getGenericReturnType();
            if (genericReturnType instanceof ParameterizedType){
                return executor.query(mappedStatement, "list",args);
            }
            return executor.query(mappedStatement, "one",args);
        } else {
            return executor.update(mappedStatement, args);
        }
    }
}
```

将客户端加载配置文件，创建sqlSessionFactory和生产sqlSession的重复代码放入DAO接口的代理实现内中，实现只用调用DAO接口就完成数据库操作


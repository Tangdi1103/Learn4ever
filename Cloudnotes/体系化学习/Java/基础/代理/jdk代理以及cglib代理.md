[TOC]



# 一、动态代理和静态代理

**代理机制**，如果熟悉设计模式中的代理模式，我们会知道，代理可以看作是对调用目标的一个包装，这样我们对目标代码的调用不是直接发生的，而是通过代理完成。其实很多动态代理场景，我认为也可以看作是装饰器（Decorator）模式的应用

### 1.静态代理

##### 1.1. 静态代理的缺点

无法将代理类通用给其他委托类使用，在代理类中固定了传入的委托类类型

##### 	1.2. 属于哪种设计模式

属于代理模式，也类似于模板模式、装饰器模式，不同的是代理类需要实现委托类的接口，然后代理类中调用委托类的方法

##### 1.3. 静态代理示例

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



### 2.动态代理+工厂模式

动态代理是一种方便运行时动态构建代理、增强委托类功能的机制，很多场景都是利用类似机制做到的，比如用来包装 RPC 调用、面向切面的编程（AOP）

##### 1.1. 动态代理优点

无视委托类的类型或者接口的类型，**都可以委托给同一个动态代理**

##### 	==1.2. 动态代理的种类==

###### [JDK 动态代理（不推荐）](#1.4. JDK 动态代理代码)

- **原理**

  使用**反射机制**，通过类加载器和**委托接口类型**，在底层**动态的生成了一个代理对象**，并将`InvocationHandler` 对象作为参数被传入代理对象中

- **优点**

  JDK自带

- **缺点（致命缺点）**

  **只能对接口代理**，如果要代理一个**没有实现接口的普通类**，则 **JDK动态代理则无法使用了**

- **使用场景**

  通过直接使用接口，**隐藏底层细节**的时候，使用JDK动态代理！**如：Mybatis**

###### [CGLIB 动态代理（推荐）](#1.5. CGLIB 动态代理代码)

- **原理**

  CGLIB通过**字节码处理框架ASM**，动态**生成委托类的一个子类**，就相当于是代理类了**，所以**无法代理 final 的类或方法。在子类中采用方法拦截的技术**拦截所有父类方法的调用**，顺势织入横切逻辑。它**比使用 java反射的 JDK动态代理要快**。

- **优点**

  在子类中采用方法拦截的技术拦截所有父类方法的调用，顺势织入横切逻辑。它比使用java反射的JDK动态代理要快。

- **缺点**

  依赖三方类库，**无法代理 final 的类或方法**

- **使用场景**

  **织入横切的逻辑**，来**增强委托对象的功能**，如 **AOP**。虽然JDK动态代理也能做到，但是**AOP的场景一般使用CGLIB**，其**基于字节码的性能高于JDK的反射**！



##### 1.3. 委托类及工厂

- 委托接口

  ```java
  public interface Delegator {
      void introduce();
      void play();
  }
  ```

- 委托类

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

- 统一代理接口

  ```java
  public interface ProxyHandler {
  
      Object getProxy();
  }
  ```

- 代理工厂

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



##### 1.4. JDK 动态代理代码

**原理：使用反射机制，通过类加载器和委托接口，在底层动态的生成了一个代理对象，并将`InvocationHandler` 对象作为参数被传入代理对象中**

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

2. 委托的接口

 3. `InvocationHandler` 增强逻辑

    `InvocationHandler` 对象作为参数被传入代理对象中

    1. `Proxy` 代理本身
    2. `method` 委托类的方法
    3. `args` 委托类的方法入参



##### 	1.5. CGLIB 动态代理代码

**首先引入依赖**

```xml
<dependency>
    <groupId>cglib</groupId>
    <artifact>cglib</artifact>
    <version>2.1.2</version>
</dependency>
```

CGLIB通过**字节码处理框架ASM**，动态**生成委托类的一个子类**，就相当于是代理类了**，所以**无法代理 final 的类或方法。在子类中采用方法拦截的技术**拦截所有父类方法的调用**，顺势织入横切逻辑。它**比使用 java反射的 JDK动态代理要快**。

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

**create中的入参**

1. Class<?> 委托对象的Class
2. MethodInterceptor增强的业务逻辑，通过方法拦截器实现逻辑增强
   1. `Object` 代理对象
   2. `Method` 委托对象执行的方法
   3. `Object[]` 委托对象执行的方法的参数
   4. `MethodProxy` 当代理对象执行的方法



##### 1.6 测试

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







# 二、那啥时候使用JDK动态代理呢？

众所周知，JDK动态代理的性能低于CGLIB，那我们什么时候可以使用 JDK动态代理呢？**Mybatis**！通过**直接使用接口**，**隐藏底层细节**的时候，使用 JDK动态代理！

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


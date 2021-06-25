[TOC]



# 一、动态代理和静态代理

**代理机制**，如果熟悉设计模式中的代理模式，我们会知道，代理可以看作是对调用目标的一个包装，这样我们对目标代码的调用不是直接发生的，而是通过代理完成。其实很多动态代理场景，我认为也可以看作是装饰器（Decorator）模式的应用

## 1.静态代理

#### 	1.1. 对应不同功能，需要编写不同代理类

#### 	1.2. 代理与被代理实现同一个接口（拥有相同行为），代理类增强被代理类功能（被代理类传入代理类中，代理方法调用被代理方法）

#### 	1.3. 如下，就是静态代理，代理类需被代理类传入。代理类来增强功能

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



## 2.动态代理

动态代理是一种方便运行时动态构建代理、增强委托类功能的机制，很多场景都是利用类似机制做到的，比如用来包装 RPC 调用、面向切面的编程（AOP）。

#### 	1.1. 对应不同功能，可用同一代理类

#### 	1.2. 动态代理分为：JDK动态代理，cglib动态代理（三方类库）

#### 	1.3. jdk动态代理如下：

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
        IRentingHouse iRentingHouse = new IRentingHouseImpl();  // 委托类
        
        // 生成代理对象
        Object o = Proxy.newInstanceProxy(iRentingHouse.getClass().getClassLoader,iRentingHouse.getClass().getInterfaces(),new InvocationHandler(){
            @Overrid
            public Object invoke(Proxy p,Method method,Object[] args){
                ...
                Object o =m.invok(iRentingHouse,args);
                ...
                return null;
            }
        });//代理类
        iRentingHouseProxy.rentHouse();
    }
}
```

**JDK动态代理生成的对象相当于接口的一个实现类**

**newInstanceProxy()方法中的入参：**

1. ClassLoader类加载器
2. 需被代理类的接口类型

 3. 代理增强功能的逻辑

    1. Proxy代理本身
    2. method被代理类的方法
    3. args被代理类的方法入参

1和2使用反射机制，在底层动态的生成了一个代理对象

#### 	1.4 cglib动态代理如下

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

**cglib动态代理生成的对象相当于委托类的一个子类**

**create中的入参**

1. Class<?>委托对象的Class
2. MethodInterceptor增强的业务逻辑，通过方法拦截器实现逻辑增强
   1. Object委托对象的引用
   2. Method委托对象的方法
   3. Object[]委托对象方法的入参
   4. MethodProxy当前执行方法代理对象的封装



**cglib需要引入jar包**

```xml
<dependency>
    <groupId>cglib</groupId>
    <artifact>cglib</artifact>
    <version>2.1.2</version>
</dependency>
```

#### 1.5. jdk动态代理与cglib动态代理的比较

jdk动态代理

1. 委托类必须实现接口
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


[toc]

# 一、AOP的概念

AOP本质：在不改变原有业务逻辑的情况下增强横切逻辑，横切逻辑代码往往是权限校验代码、⽇志代码、事务控制代码、性能监控代码



**未采用AOP的程序设计如下：**

![image-20210620221125082](images/image-20210620221125082.png)

**采用AOP的程序设计如下：**

![image-20210620221437007](images/image-20210620221437007.png)

最直观的感觉是，未采用AOP的程序存在大量红圈的重复代码，在多个方法的相同位置充斥大量重复代码及有大量的横切逻辑代码。

而采用AOP的程序，将横切逻辑抽取出来，使用动态代理技术在程序运行时，对业务逻辑需要的地方进行功能增强



# 二、SpringAOP相关概念

| 名词              |                                                              |
| ----------------- | ------------------------------------------------------------ |
| Joinpoint(连接点) | 指需要**被切入的一个方法**，在该方法执行前后**通过动态代理**织入增强代码（共通业务逻辑）。 |
| Pointcut(切入点)  | 相当于Joinpoint连接点地集合，一般使用表达式来表达需要切入的某一群方法。又称**切点表达式** |
| Advice(通知)      | 代表**切面代码的执行时机**，比如方法执行前，方法执行后，方法异常时等。SpringAOP在有：前置通知、后置通知、异常通知、最终通知、环绕通知。 |
| Target            | 被切入的目标对象，即委托对象。                               |
| Proxy             | 代理对象                                                     |
| Aspect(切⾯)      | 增强代码也就是共通的业务逻辑，通常封装在⼀个类中，这个类就是切面类。相当于JDK动态代理的invocationHandler实现的方法。 |



# 三、Spring中AOP的代理选择

#### Spring 实现AOP思想使⽤的是动态代理技术，若实现接口则使用JDK动态代理，若没有接口则使用cglib动态代理



# 四、 SpringAOP的使用

在Spring的AOP配置中，也和IoC配置⼀样，⽀持3类配置⽅式。

第⼀类：使⽤XML配置

第⼆类：使⽤XML+注解组合配置

第三类：使⽤纯注解配置

## 4.1 五种通知类型

| 通知类型                    | 执行时机                                     | 细节                                                         |
| --------------------------- | -------------------------------------------- | ------------------------------------------------------------ |
| 前置通知（before）          | 在某连接点方法执行前执行                     | 可以获取到连接点方法的参数，并对其进行增强                   |
| 后置通知（after-returning） | 在某连接点方法执行正常后（没有异常）执行     |                                                              |
| 异常通知（after-throwing）  | 在某连接点方法**抛出异常并退出**后执行       | 不仅可以获取到连接点方法的参数，也可以获取其抛出的异常信息   |
| 最终通知（after）           | 在某连接点方法**退出时**执行（不论是否异常） | 可以获取到连接点方法的参数，同时它可以做⼀些清理操作         |
| 环绕通知（around）          | 在连接点方法执行前后执行                     | 借助的ProceedingJoinPoint接口及其实现类，实现主动调用委托对象的方法，相当于method.invoke(O,Args) |

## 4.2 切入点的AspectJ表达式

#### 全限定方法名

```java
// 全匹配⽅式
public void com.lagou.service.impl.TransferServiceImpl.updateAccountByCardNo(com.lagou.pojo.Account)
    
// 访问修饰符可以省略
void com.lagou.service.impl.TransferServiceImpl.updateAccountByCardNo(com.lagou.pojo.Account)
    
// 返回值可以使⽤*，表示任意返回值
* com.lagou.service.impl.TransferServiceImpl.updateAccountByCardNo(com.lagou.pojo.Account)
    
// 包名可以使⽤.表示任意包，但是有⼏级包，必须写⼏个
* ....TransferServiceImpl.updateAccountByCardNo(com.lagou.pojo.Account)

// 包名可以使⽤..表示当前包及其⼦包
* ..TransferServiceImpl.updateAccountByCardNo(com.lagou.pojo.Account)
    
// 类名和⽅法名，都可以使⽤.表示任意类，任意⽅法
* ...(com.lagou.pojo.Account)
    
// 基本类型直接写类型名称 ：int 
// 引⽤类型必须写全限定类名：java.lang.String
// 参数列表可以使⽤*，表示任意参数类型，但是必须有参数
* *..*.*(*)
    
// 参数列表可以使⽤..，表示有⽆参数均可。有参数可以是任意类型
// 全通配⽅式
* *..*.*(..)
```



## 4.3 导入依赖

```xml
<dependency>
    <groupId>org.springframework</groupId>
    <artifactId>spring-aop</artifactId>
    <version>5.1.12.RELEASE</version>
</dependency>
<dependency>
    <groupId>org.aspectj</groupId>
    <artifactId>aspectjweaver</artifactId>
    <version>1.9.4</version>
</dependency>
```



## 4.4 纯注解配置（xml配置太麻烦。。）

##### 在配置类中使⽤如下注解

```java
/**
* @author 应癫
*/
@Configuration
@ComponentScan("com.lagou")
@EnableAspectJAutoProxy //开启spring对注解AOP的⽀持
public class SpringConfiguration{
}
```

##### 案例

```java
/**
* 模拟记录⽇志
* @author 应癫
*/
@Component
@Aspect
public class LogUtil{
    /**
	* 我们在xml中已经使⽤了通⽤切⼊点表达式，供多个切⾯使⽤，那么在注解中如何使⽤呢？
	* 第⼀步：编写⼀个⽅法
    * 第⼆步：在⽅法使⽤@Pointcut注解
    * 第三步：给注解的value属性提供切⼊点表达式
    * 细节：
    * 1.在引⽤切⼊点表达式时，必须是⽅法名+()，例如"pointcut()"。
    * 2.在当前切⾯中使⽤，可以直接写⽅法名。在其他切⾯中使⽤必须是全限定⽅法名。
    */
    //@Pointcut("this(com.csair.common.BaseWebApi)")继承BaseWebApi接口的切
    //@Pointcut("@annotation(org.springframework.web.bind.annotation.PostMapping)")对该注解切
    @Pointcut("execution(* com.lagou.service.impl.*.*(..))")
    public void pointcut(){}
    
    
    // 前置通知
    @Before("pointcut()")
    public void beforePrintLog(JoinPoint jp){
        Object[] args = jp.getArgs();
        System.out.println("前置通知：beforePrintLog，参数是："+
        Arrays.toString(args));
    }
    
    // 后置通知
    @AfterReturning(value = "pointcut()",returning = "rtValue")
    public void afterReturningPrintLog(Object rtValue){
        System.out.println("后置通知：afterReturningPrintLog，返回值
        是："+rtValue);
    }
    
    // 异常通知
    @AfterThrowing(value = "pointcut()",throwing = "e")
    public void afterThrowingPrintLog(Throwable e){
    	System.out.println("异常通知：afterThrowingPrintLog，异常是："+e);
    }

    // 最终通知
    @After("pointcut()")
    public void afterPrintLog(){
    	System.out.println("最终通知：afterPrintLog");
    }
                           
                           
    /**
    * 环绕通知
    * @param pjp
    * @return
    */
    @Around("pointcut()")
    // @Around("@annotation(with)")
    // public Object aroundPrintLog(ProceedingJoinPoint pjp,RoutingWith with){
    public Object aroundPrintLog(ProceedingJoinPoint pjp){
        //定义返回值
        Object rtValue = null;
        try{
            //前置通知
            System.out.println("前置通知");
            //1.获取参数
            Object[] args = pjp.getArgs();
            //2.执⾏切⼊点⽅法
            rtValue = pjp.proceed(args);
            //后置通知
            System.out.println("后置通知");
        } catch(Throwable t) {
            //异常通知
            System.out.println("异常通知");
            t.printStackTrace();
        }finally{
            //最终通知
            System.out.println("最终通知");
        }
        return rtValue;
	}
                           

    
```


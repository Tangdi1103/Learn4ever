
### bean生命周期
```
1、  启动spring容器,也就是创建beanFactory(bean工厂),
     一般用的是beanFactory的子类applicationcontext,
     applicationcontext比一般的beanFactory要多很多功能,比如aop、事件等。
     通过applicationcontext加载配置文件,或者利用注解的方式扫描将bean
     的配置信息加载到spring容器里面。

 2、  加载之后,spring容器会将这些配置信息(java bean的信息),封装成BeanDefinition对象
      BeanDefinition对象其实就是普通java对象之上再封装一层,
      赋予一些spring框架需要用到的属性,比如是否单例,是否懒加载等等。

3、  然后将这些BeanDefinition对象以key为beanName,
     值为BeanDefinition对象的形式存入到一个map里面,
     将这个map传入到spring beanfactory去进行springBean的实例化。
  
4、  传入到pring beanfactory之后,利用BeanFactoryPostProcessor接口这个扩展点
     去对BeanDefinition对象进行一些属性修改。

5、  开始循环BeanDefinition对象进行springBean的实例化,springBean的实例化也就
     是执行bean的构造方法(单例的Bean放入单例池中,但是此刻还未初始化),
     在执行实例化的前后,可以通过InstantiationAwareBeanPostProcessor扩展点
     (作用于所有bean)进行一些修改。

6、   spring bean实例化之后,就开始注入属性,
      首先注入自定义的属性,比如标注@autowrite的这些属性,
      再调用各种Aware接口扩展方法,注入属性(spring特有的属性),
      比如BeanNameAware.setBeanName,设置Bean的ID或者Name;

7、   初始化bean,对各项属性赋初始化值,,初始化前后执行BeanPostProcessor
      (作用于所有bean)扩展点方法,对bean进行修改。

      初始化前后除了BeanPostProcessor扩展点还有其他的扩展点,执行顺序如下:

        (1). 初始化前                	   postProcessBeforeInitialization()
        (2). 执行构造方法之后                执行 @PostConstruct 的方法
        (3). 所有属性赋初始化值之后           afterPropertiesSet()
        (4). 初始化时              	       配置文件中指定的 init-method 方法
        (5). 初始化后                	   postProcessAfterInitialization()

		先执行BeanPostProcessor扩展点的前置方法postProcessBeforeInitialization(),
		再执行bean本身的构造方法
		再执行@PostConstruct标注的方法
		所有属性赋值完成之后执行afterPropertiesSet()
		然后执行 配置文件或注解中指定的 init-method 方法
		最后执行BeanPostProcessor扩展点的后置方法postProcessAfterInitialization()

8、     此时已完成bean的初始化,在程序中就可以通过spring容器拿到这些初始化好的bean。

9、     随着容器销毁,springbean也会销毁,销毁前后也有一系列的扩展点。
  		销毁bean之前,执行@PreDestroy 的方法
	    销毁时,执行配置文件或注解中指定的 destroy-method 方法。


  		以上就是spring bean的整个生命周期

  		其实就是根据配置文件或注解信息,生成BeanDefinition,
  		循环BeanDefinition去实例化-》注入属性-》初始化-》销毁,在这4个阶段执行前后,
  		spring框架提供了一系列的扩展点。
```

### 扩展

```
(1)、容器级扩展点(作用于所有bean):

	BeanFactoryPostProcessor接口:
	
	在循环初始化springbean之前,对BeanDefinition元数据做扩展处理
	
	InstantiationAwareBeanPostProcessor接口:
	
	在对象实例化前后扩展,作用于所有bean
	
	BeanPostProcessor接口:
	
	在对象初始化化前后扩展,作用于所有bean

(2)、Bean扩展点(作用于单个bean):

	Aware接口:
	
	springBean实例化并且注入自定义属性之后
	
	InitializingBean接口:
	
	springBean初始化时,执行构造方法结束,并且属性赋初始化值结束之后执行
	
	DiposableBean接口:
	
	springBean销毁之前执行。

(3)、Bean自身的方法

	包括了Bean本身调用的方法
	
	通过配置文件中<bean>的init-method和destroy-method指定的方法(或者用注解的方式)
	
	(4)、包括了AspectJWeavingEnabler, 
	 ConfigurationClassPostProcessor, 
	 CustomAutowireConfigurer等等非常有用的工厂后处理器接口的方法。
	 工厂后处理器也是容器级的。在应用上下文装配配置文件之后立即调用。

```


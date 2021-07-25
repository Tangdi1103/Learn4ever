### IOC的实现有配置实现和注解实现两种


#### 1.注入
##### 使用配置注入bean:

```
<bean id="customerService" class="cn.itcast.crm.service.impl.CustomerServiceImpl"></bean>
```

##### 使用注解注入bean:
```
使用@Component、@Service、@Repository注解类
```

1. @Service，@controller，@component——用于将自身写的类交给ioc容器托管
1. @Configuration和@Bean——用于第三方框架的类交给ioc容器托管
1. @Scope——用于选择Bean的做用于，有单例、多例等
1. SpringBoot的启动类配置@SpringBootApplication自带扫描下级所有包类
1. Spring需要在xml中配置ScanBase扫描器


#### 2.获取:
##### 从配置中获取：
```
 ApplicationContext applicationContext = new ClassPathXmlApplicationContext("applicationContext.xml");

 CustomerService customerService = (CustomerService) applicationContext.getBean("customerService");

 customerService.save(customer);
```

##### 使用注解获取

```
直接使用@Autowired获取bean
```


----------------------------------------------------

### Spring静态注入bean的方式


#### 1.使用@PostConstruct

```
@Component
public class UserUtil{

    private static UserUtil user;

    @Autowired
    UserDao dao;

    @PostConstruct
    public void init(){
        user = this;
    }
    
}
或者
public class UserUtil{

    private static UserDao userdao;

    @Autowired
    UserDao dao;

    @PostConstruct
    public void init(){
        userdao = dao;
    }
    
}

//该工具类需要注解@Component或者别的，被Spring托管，才能使用@Autowired
//（注：@PostConstruct修饰的方法会在服务器加载Servle的时候运行，并且只会被服务器执行一次。PostConstruct在构造函数之后执行,init()方法之前执行。）
```

#### 2.使用InitializingBean

```
public abstract class BaseMybatisDAO implements InitializingBean {
    @Override
    public void afterPropertiesSet() throws Exception {
        sequence = SequenceBuilder.create().name(getTableName()).sequenceDao(sequenceDao).build();
    }
}
    
    //通过实现InitializingBean，并且重写afterPropertiesSet()方法，在这个方法中进行Sequence的初始化。
```


#### 3.自定义工厂工具类实现ApplicationContextAware接口（自动装配bean）

```
public class SpringFactoryUtil implements ApplicationContextAware{
    /**
     * Spring应用上下文环境
     */
    private static ApplicationContext applicationContext;

    @Override
    public void setApplicationContext(ApplicationContext applicationContext) throws BeansException {
        SpringHelper.applicationContext = applicationContext;
    }

    public static ApplicationContext getApplicationContext() {
        return applicationContext;
    }

    @SuppressWarnings("unchecked")
    public static <T> T getBean(String name) throws BeansException {
        return (T) applicationContext.getBean(name);
    }
    
    public static <T> T getBean(Class<T> clazz) {
        return (T)applicationContext.getBean(clazz);
    }
}
//beanfactory采用的时延迟加载形式来注入bean，只有在调用getBean(),才对该bean加载实例化
//ApplicationContext建立在BeanFactory基础之上
//applicationContext是在容器启动的时候，一次性创建所有的bean，这样容器启动的时候，我们就可以发现配置出现的问题。
```

#### 4.自定义工厂工具类不实现ApplicationContextAware接口（手动装配）

```
public class SpringFactory {
    private static ApplicationContext applicationContext;

	public static ApplicationContext getApplicationContext() {
		return applicationContext;
	}

	public static void setApplicationContext(ApplicationContext applicationContext) {
		SpringFactory.applicationContext = applicationContext;
	}

}

@EnableDiscoveryClient
@SpringBootApplication
public class App {

    public static void main(String[] args) {
        //获取Spring上下文环境
        ApplicationContext context = SpringApplication.run(App.class, args);
        //放入工厂
        SpringFactory.setApplicationContext(appContext);
    }
}
```







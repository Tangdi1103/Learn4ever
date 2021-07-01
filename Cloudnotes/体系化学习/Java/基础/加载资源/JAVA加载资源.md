# 一、加载方式

### 1.使用类加载器

类加载器的作用不仅仅是加载类的，还能**加载其他任意资源**。加载资源也遵循了**双亲委派原则**

```java
InputStream is = Thread.currentThread().getContextClassLoader().getResourceAsStream("application.xml");

URL url = Thread.currentThread().getContextClassLoader().getResources("com/tangdi");

Enumeration<URL> urls = Thread.currentThread().getContextClassLoader().getResource("com/tangdi");
```

线程上下文类加载器默认使用的是AppClassloader，而AppClassloader只加载classpath路径下的资源，所以该方式不默认加载的路径就在classpath下。如传入path为""——空字符串，则加载的路径为classpath目录

### 2.使用文件流（需绝对路径）

```java
InputStream is = new FileInputStream(System.getProperty("user.dir") + "/WebContent/WEB-INF/" + resource);
```

### 3.使用Spring加载外部资源文件

```java
@Configuration
@PropertySource("classpath:redis.properties")
public class RedisConfig {
	
	@Value("${spring.redis.switchState}")
    private boolean switchState;
}
```

### 4.使用Springboot批量加载全局配置的属性

```java
//注解将配置映射到到实体类
@ConfigurationProperties(prefix = "mq.upp.callback.rocket", ignoreUnknownFields = false)
@Component
public class RocketMqUPPCallBackConfig {
    private String configUrl;
    private String produceAppName;
    private String produceTopicName;
    private String consumeAppName;
    private String consumeTopicName;
    
    //getter
    //setter
}
//注解启动加载上述配置映射实体类到该类中
@Component
@EnableConfigurationProperties(RocketMqUPPCallBackConfig.class)
@Configuration
public class RocketMqUPPCallBackBean {
private static final Logger LOGGER= LoggerFactory.getLogger(RocketMqUPPCallBackBean.class);

    @Bean
    MQConsumerFactory callbackMqConsumer(RocketMqUPPCallBackConfig rocketMqUPPCallBackConfig, PamentCallBackMqListener listener){
        MQConsumerFactory mqConsumerFactory = new MQConsumerFactory();
        try {
            mqConsumerFactory.setConfigUrl(rocketMqUPPCallBackConfig.getConfigUrl());
            mqConsumerFactory.setAppName(rocketMqUPPCallBackConfig.getConsumeAppName());
            mqConsumerFactory.setTopicName(rocketMqUPPCallBackConfig.getConsumeTopicName());
            mqConsumerFactory.setListenerConcurrently(listener);
            mqConsumerFactory.setMessageModel(MessageModel.BROADCASTING);
            return mqConsumerFactory;
        } catch (Exception e) {
            LOGGER.error("初始化rocketmq异常",e);
        }
        return mqConsumerFactory;
    }
}
```

### 5.使用Spring加载外部资源（国际化）

```java
org.springframework.core.io.support.PropertiesLoaderUtils.loadAllProperties(i18n/exception_ko.properties);
```



# 二、解析方式

### 1.解析java.util.properties

**Properties的处理方式是将其作为一个映射表,而且这个类表示了一个持久的属性集,他是继承HashTable这个类**

```java
InputStream is = Thread.currentThread().getContextClassLoader().getResourceAsStream("application.xml");
Properties p = new Properties();
p.load(is);
System.out.println(p.get("payment.no.selfService"));
```

### 2.解析xml(使用dom4j)

```java
Document document = new SAXReader().read(in);
Element root = document.getRootElement();
root.selectNodes(//xxx) //获取整个报文所有xxx
root.attributeValue("xxx")//获取attribute
```

### 3.解析java.util.ResourceBundle

**ResourceBundle本质上也是一个映射，但是它提供了国际化的功能。**

```java
// 创建实例并指定地区
ResourceBundle bundleCN = ResourceBundle.getBundle("props.messages",new Locale("zh","CN"));
ResourceBundle bundleUS = ResourceBundle.getBundle("props.messages",new Locale("en","US"));
msg=bundleCN.getString("payment.no.selfService");
```


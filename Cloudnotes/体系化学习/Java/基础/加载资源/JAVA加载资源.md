[toc]

# 一、加载方式

### 1.使用类加载器

类加载器的作用不仅仅是加载类的，还能**加载其他任意资源**。加载资源也遵循了**双亲委派原则**

```java
InputStream is = Thread.currentThread().getContextClassLoader().getResourceAsStream("application.xml");

URL url = Thread.currentThread().getContextClassLoader().getResource("com/tangdi");

List<URL> urls = Collections.list(Thread.currentThread().getContextClassLoader().getResources("com/tangdi"));
```

线程上下文类加载器默认使用的是AppClassloader，而AppClassloader只加载classpath路径下的资源，所以该方式默认加载的路径就在classpath下

##### 注意：虽然可以正常加载到流以及url路径，但如果后续对url进行解析时，需要注意该URL可能是个JAR中的路径。就得对JAR文件解析，而不能使用File文件流来解析



### 2.使用文件流（需绝对路径）

```java
InputStream is = new FileInputStream(System.getProperty("user.dir") + "/WebContent/WEB-INF/" + resource);
```



### 3.使用Spring核心组件ResourceUtils加载资源（底层就是使用类加载器加载）





### 4.使用Spring的@Value注入单个属性

```java
@Component
public class RocketMqUPPCallBackComponent {
	
	@Value("${mq.upp.callback.rocket}")
    private boolean switchState;
}
```



### 5.使用Spring注解@PropertySource加载外部资源文件及@Value属性注入

```java
@Configuration
@PropertySource("classpath:redis.properties")
public class RedisConfig {
	
	@Value("${spring.redis.switchState}")
    private boolean switchState;
    
    @Value("${spring.redis.ip}")
    private String ip;
    
    @Value("${spring.redis.port}")
    private String port;
}
```



### 6.使用Springboot注解@ConfigurationProperties批量加载全局配置的属性

**注意@ConfigurationProperties使用setter方式注入属性**

```java
//注解将配置映射到到实体类
@Component
@ConfigurationProperties(prefix = "mq.upp.callback.rocket", ignoreUnknownFields = false)
public class RocketMqUPPCallBackConfig {
    private String configUrl;
    private String produceAppName;
    private String produceTopicName;
    private String consumeAppName;
    private String consumeTopicName;
    
    //getter
    //setter
}

@Configuration // 标识为配置类
@EnableConfigurationProperties(RocketMqUPPCallBackConfig.class)// 开启批量属性注入
@ConfigurationProperties(prefix = "mq.upp.callback.rocket", ignoreUnknownFields = false) // 通过setter批量注入属性
public class RocketMqUPPCallBackConfig {
     private String configUrl;
    private String produceAppName;
    private String produceTopicName;
    private String consumeAppName;
    private String consumeTopicName;
    
    //getter
    //setter
}
```

**@ConfigurationProperties**配合**@bean**为第三方类注入属性

```java
@Configuration
public class MyService {
    
   @Bean
   @ConfigurationProperties("another")
   public AnotherComponent anotherComponent(){
       return new AnotherComponent();
   }
}
```

**若是自定义的属性，可配置以下依赖，就能在全局配置中编写属性值时自动提醒javaConfig的属性**

```xml
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-configuration-processor</artifactId>
    <optional>true</optional>
</dependency>
```



### 7.使用Spring加载外部资源（国际化）

```java
org.springframework.core.io.support.PropertiesLoaderUtils.loadAllProperties(i18n/exception_ko.properties);
```



# 二、解析方式

### 1.使用Java原生API解析java.net.URL

参考ClassLoader中的方法即可，因为ClassLoader加载资源时，最终都是解析的的URL

```java
InputStream in = url.openStream();
InputStream in = url.openConnection().getInputStream();
```



### 2.使用Spring的UrlResource解析java.net.URL（底层就是使用URL）



### 3.使用Spring的PropertiesLoaderUtils解析java.util.properties（封装各种properties操作）



### 4.解析java.util.properties

**Properties的处理方式是将其作为一个映射表,而且这个类表示了一个持久的属性集,他是继承HashTable这个类**

```java
InputStream is = Thread.currentThread().getContextClassLoader().getResourceAsStream("application.xml");
Properties p = new Properties();
p.load(is);
System.out.println(p.get("payment.no.selfService"));
```



### 5.解析xml(使用dom4j)

```java
Document document = new SAXReader().read(in);
Element root = document.getRootElement();
root.selectNodes(//xxx) //获取整个报文所有xxx
root.attributeValue("xxx")//获取attribute
```



### 6.解析java.util.ResourceBundle

**ResourceBundle本质上也是一个映射，但是它提供了国际化的功能。**

```java
// 创建实例并指定地区
ResourceBundle bundleCN = ResourceBundle.getBundle("props.messages",new Locale("zh","CN"));
ResourceBundle bundleUS = ResourceBundle.getBundle("props.messages",new Locale("en","US"));
msg=bundleCN.getString("payment.no.selfService");
```



### 7.解析jar文件

```java
List<URL> urls = Collections.list(Thread.currentThread().getContextClassLoader().getResources(newpath));

for (URL u : urls) {
    if ("jar".equals(u.getProtocol())){
        JarFile jarFile = ((JarURLConnection) u.openConnection()).getJarFile();
        List<JarEntry> entries = Collections.list(jarFile.entries());
        for (JarEntry e : entries) {
            String name = e.getName();
            if (name.replace('/','.').startsWith(path) && name.endsWith(".class") && !name.contains("$")){
                list.add(name.replace(".class","").replace('/','.'));
            }
        }
    }
}
```


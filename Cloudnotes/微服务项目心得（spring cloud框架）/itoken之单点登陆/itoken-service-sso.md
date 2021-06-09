### pom


```
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>

    <parent>
        <groupId>com.tangdi</groupId>
        <artifactId>itoken-dependencies</artifactId>
        <version>1.0.0-SNAPSHOT</version>
        <relativePath>../itoken-dependencies/pom.xml</relativePath>
    </parent>

    <artifactId>itoken-service-sso</artifactId>
    <packaging>jar</packaging>

    <dependencies>
        <dependency>
            <groupId>com.tangdi</groupId>
            <artifactId>itoken-common-domain</artifactId>
            <version>${project.parent.version}</version>
        </dependency>
        <dependency>
            <groupId>com.tangdi</groupId>
            <artifactId>itoken-common-web</artifactId>
            <version>${project.parent.version}</version>
        </dependency>
        <dependency>
            <groupId>com.tangdi</groupId>
            <artifactId>itoken-common-service</artifactId>
            <version>${project.parent.version}</version>
        </dependency>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-test</artifactId>
            <scope>test</scope>
        </dependency>
    </dependencies>

    <build>
        <plugins>
            <plugin>
                <groupId>org.springframework.boot</groupId>
                <artifactId>spring-boot-maven-plugin</artifactId>
                <configuration>
                    <mainClass>com.tangdi.itoken.service.sso.ServiceSSOApplication</mainClass>
                </configuration>
            </plugin>
        </plugins>
    </build>

    <repositories>
        <repository>
            <id>nexus</id>
            <name>Nexus Repository</name>
            <url>http://192.168.243.129:8081/repository/maven-public/</url>
            <snapshots>
                <enabled>true</enabled>
            </snapshots>
            <releases>
                <enabled>true</enabled>
            </releases>
        </repository>
    </repositories>
    <pluginRepositories>
        <pluginRepository>
            <id>nexus</id>
            <name>Nexus Plugin Repository</name>
            <url>http://192.168.243.129:8081/repository/maven-public/</url>
            <snapshots>
                <enabled>true</enabled>
            </snapshots>
            <releases>
                <enabled>true</enabled>
            </releases>
        </pluginRepository>
    </pluginRepositories>
</project>
```

---

# Application


```
package com.tangdi.itoken.service.sso;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.cloud.client.discovery.EnableDiscoveryClient;
import org.springframework.cloud.netflix.eureka.EnableEurekaClient;
import org.springframework.cloud.openfeign.EnableFeignClients;
import tk.mybatis.spring.annotation.MapperScan;

@SpringBootApplication(scanBasePackages = "com.tangdi.itoken")
@EnableEurekaClient
@EnableDiscoveryClient
@EnableFeignClients
@MapperScan(basePackages = "com.tangdi.itoken.service.sso.mapper")
public class ServiceSSOApplication {
    public static void main(String[] args) {
        SpringApplication.run(ServiceSSOApplication.class,args);
    }
}

```

---

# 本地配置

###  bootstrap.yml


```
spring:
  cloud:
    config:
      uri: http://localhost:8888
      name: itoken-service-sso
      label: master
      profile: dev
```

### bootstrap-prod.yml

```
spring:
  cloud:
    config:
      uri: http://192.168.243.138:8888
      name: itoken-service-sso
      label: master
      profile: prod
```
---

# 云配置

### itoken-service-sso-dev.yml

```
spring:
  application:
    name: itoken-service-sso
  zipkin:
      base-url: http://localhost:9411
  boot:
    admin:
      client:
        url: http://localhost:8084
  datasource:
      druid:
        url: jdbc:mysql://192.168.243.131:3306/itoken-service-admin?useUnicode=true&characterEncoding=utf-8&useSSL=false
        username: root
        password: 123456
        initial-size: 1
        min-idle: 1
        max-active: 20
        test-on-borrow: true
        driver-class-name: com.mysql.jdbc.Driver
  thymeleaf:
    cache: false
    mode: LEGACYHTML5
    encoding: UTF-8
    servlet:
     content-type: text/html

logging:
  file: logs/itoken-service-admin.log

feign:
  hystrix:
    enabled: true

mybatis:
    type-aliases-package: com.tangdi.itoken.common.domain
    mapper-locations: classpath:mapper/*.xml

server:
  port: 8503

eureka:
  client:
    serviceUrl:
      defaultZone: http://localhost:8761/eureka/

management:
  endpoint:
    health:
      show-details: always
  endpoints:
    web:
      exposure:
        include: health,info
```
### itoken-service-sso-prod.yml


```
spring:
  application:
    name: itoken-service-sso
  zipkin:
      base-url: http://192.168.243.138:9411
  boot:
    admin:
      client:
        url: http://192.168.243.138:8084
  datasource:
      druid:
        url: jdbc:mysql://192.168.243.131:3306/itoken-service-admin?useUnicode=true&characterEncoding=utf-8&useSSL=false
        username: root
        password: 123456
        initial-size: 1
        min-idle: 1
        max-active: 20
        test-on-borrow: true
        driver-class-name: com.mysql.jdbc.Driver
  thymeleaf:
    cache: false
    mode: LEGACYHTML5
    encoding: UTF-8
    servlet:
     content-type: text/html

logging:
  file: logs/itoken-service-admin.log

mybatis:
    type-aliases-package: com.tangdi.itoken.common.domain
    mapper-locations: classpath:mapper/*.xml

feign:
  hystrix:
    enabled: true

server:
  port: 8503

eureka:
  client:
    serviceUrl:
      defaultZone: http://192.168.243.138:8761/eureka/,http://192.168.243.138:8861/eureka/,http://192.168.243.138:8961/eureka/

management:
  endpoint:
    health:
      show-details: always
  endpoints:
    web:
      exposure:
        include: health,info
```
---

### 利用itoken-common-service中tk.mybatis

##### 生成java下mypper,domain

##### 生成resources下mapper.xml

---

# 消费redis服务

### 创建接口

```
package com.tangdi.itoken.service.sso.service.consumer;

import com.tangdi.itoken.service.sso.service.consumer.fallback.RedisServiceFallback;
import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;

@FeignClient(value = "itoken-service-redis",fallback = RedisServiceFallback.class)
public interface RedisService {

    @RequestMapping(value = "put",method = RequestMethod.POST)
    public String put(@RequestParam(value = "key") String key,@RequestParam(value = "value") String value,@RequestParam(value = "seconds") long seconds);

    @RequestMapping(value = "get",method = RequestMethod.GET)
    public String get(@RequestParam(value = "key") String key);

    @RequestMapping(value = "del",method = RequestMethod.POST)
    public String del(@RequestParam(value = "key") String key);

}

```

### 创建熔断器


```
import com.tangdi.itoken.common.hystrix.Fallback;
import com.tangdi.itoken.service.sso.service.consumer.RedisService;
import org.springframework.stereotype.Component;

@Component
public class RedisServiceFallback implements RedisService {

    @Override
    public String put(String key, String value, long seconds) {
        return null;
    }

    @Override
    public String get(String key) {
        return null;
    }

    @Override
    public String del(String key) {
        return null;
    }
}

```

---

# 创建sso服务提供者

### 创建接口


```
import com.tangdi.itoken.common.domain.TbSysUser;

public interface SsoService {

    /**
     * 登录接口
     * @param loginCode 账号
     * @param plantPassword  密码
     */
    public TbSysUser login(String loginCode, String plantPassword);
}

```

### 实现接口


```
import com.tangdi.itoken.common.domain.TbSysUser;
import com.tangdi.itoken.common.utils.MapperJacksonUtils;
import com.tangdi.itoken.service.sso.mapper.TbSysUserMapper;
import com.tangdi.itoken.service.sso.service.SsoService;
import com.tangdi.itoken.service.sso.service.consumer.RedisService;
import com.tangdi.itoken.service.sso.service.consumer.fallback.RedisServiceFallback;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.DigestUtils;
import tk.mybatis.mapper.entity.Example;

@Service
@Transactional(readOnly = true)
public class SsoServiceImpl implements SsoService {

    private static  final Logger logger = LoggerFactory.getLogger(SsoServiceImpl.class);

    @Autowired
    private TbSysUserMapper tbSysUserMapper;

    @Autowired
    private RedisService redisService;


    @Transactional(readOnly = false)
    @Override
    public TbSysUser login(String loginCode, String plantPassword) {

        TbSysUser tbSysUser = null;
        String json = redisService.get(loginCode);
        //没有缓存
        if(json == null){
            Example example = new Example(TbSysUser.class);
            example.createCriteria().andEqualTo("loginCode", loginCode);

            tbSysUser = tbSysUserMapper.selectOneByExample(example);
            if (tbSysUser != null) {
                String password = DigestUtils.md5DigestAsHex(plantPassword.getBytes());
                if (password.equals(tbSysUser.getPassword())) {
                    try {
                        redisService.put(loginCode,MapperJacksonUtils.obj2json(tbSysUser),60*60*24);
                    } catch (Exception e) {
                        e.printStackTrace();
                    }
                    return tbSysUser;
                }
            }
            return null;
        }
        //有缓存
        else{
            try {
                tbSysUser = MapperJacksonUtils.json2pojo(json, TbSysUser.class);
            } catch (Exception e) {
                logger.warn("触发熔断：{}",e.getMessage());
            }
        }
        return tbSysUser;
    }
}

```

---

# Controller
### 消费自身提供的业务层


```
import com.tangdi.itoken.common.domain.TbSysUser;
import com.tangdi.itoken.common.utils.CookieUtils;
import com.tangdi.itoken.common.utils.MapperJacksonUtils;
import com.tangdi.itoken.service.sso.service.SsoService;
import com.tangdi.itoken.service.sso.service.consumer.RedisService;
import org.apache.commons.lang3.StringUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.util.UUID;

@Controller
public class SSOController {

    @Autowired
    private RedisService redisService;

    @Autowired
    private SsoService ssoService;

    //跳转登陆页
    @RequestMapping(value = {"","login"},method = RequestMethod.GET)
    public String login(@RequestParam(required = false) String url,
                        HttpServletRequest req,
                        Model model){
        String token = CookieUtils.getCookieValue(req, "token");

        if(StringUtils.isBlank(token)){

        }

        else {
            String loginCode = redisService.get(token);
            if(! StringUtils.isBlank(loginCode)){
                String json = redisService.get(loginCode);
                if(! StringUtils.isBlank(json)){
                    try {
                        TbSysUser tbSysUser = MapperJacksonUtils.json2pojo(json,TbSysUser.class);
                        if(tbSysUser !=null){
                            if(!StringUtils.isBlank(url)){
                                return "redirect:"+url;
                            }
                        }
                        model.addAttribute("tbSysUser",tbSysUser);
                    } catch (Exception e) {
                        e.printStackTrace();
                    }
                }
            }
        }

        if (StringUtils.isNotBlank(url)) {
            model.addAttribute("url", url);
        }

        return "login";
    }

    /**
     * 登陆界面
     * @param loginCode
     * @param passWord
     * @param url
     * @param req
     * @param res
     * @param redirectAttributes
     * @return
     */
    @RequestMapping(value = {"","login"},method = RequestMethod.POST)
    public String login(@RequestParam(required = true) String loginCode,
                        @RequestParam(required = true)String passWord,
                        @RequestParam(required = false) String url,
                        HttpServletRequest req, HttpServletResponse res, RedirectAttributes redirectAttributes){
        TbSysUser tbSysUser = ssoService.login(loginCode, passWord);
        //登陆失败
        if(tbSysUser==null){
            redirectAttributes.addFlashAttribute("message","用户名或密码错误，请重新登陆");
        }
        //登陆成功
        else {
            String token = UUID.randomUUID().toString();
            String json = redisService.put(token, loginCode, 60 * 60 * 24);
            if(StringUtils.isNotBlank(json) && "ok".equals(json)){
                CookieUtils.setCookie(req,res,"token",token,60 * 60 * 24);
                if( !StringUtils.isBlank(url)){
                    return "redirect:"+url;
                }
            }
            // 熔断处理
            else {
                redirectAttributes.addFlashAttribute("message", "服务器异常，请稍后再试");
            }
        }
        return "redirect:/login";
    }

    @RequestMapping(value = "logout", method = RequestMethod.GET)
    public String logout(HttpServletRequest request, HttpServletResponse response, @RequestParam(required = false) String url, Model model) {
        try {
            String token = CookieUtils.getCookieValue(request, "token");
            String json = redisService.del(token);
            CookieUtils.deleteCookie(request, response, "token");
        } catch (Exception e) {
            e.printStackTrace();
        }
        return login(url, request, model);
    }

}

```













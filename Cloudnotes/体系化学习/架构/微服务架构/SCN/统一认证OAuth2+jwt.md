[toc]



## 一、统一身份认证/SSO单点登陆实现方式



### 1. 使用Session的传统方式实现

用户登陆成功后，将信息写入Session，并**==通过Redis、Session复制==**等方式实现分布式架构下的**==Session共享==**，并将**==SessionId写入cookie响应给客户端==**。

**缺点：**目前时代发展，**==并不是所有客户端都支持cookie了==**，比如移动端以及一些新的浏览器；并且容易跨域

### 2. 使用Token的认证方式（推荐、主流）

利用token进行用户身份验证的流程：

- 客户端使用用户名和密码请求登录

- 服务端收到请求，验证用户名和密码
- **验证成功后，服务端会签发一个token，再把这个token返回给客户端**
- 客户端收到token后可以把它存储起来，比如放到cookie中
- 客户端每次向服务端请求资源时**需要携带服务端签发的token**，可以在cookie或者**header中携带**
- 服务端收到请求，然后去**验证客户端请求里面带着的token**，如果验证成功，就向客户端返回请求数据





## 二、OAuth2  开放授权协议/标准

### 1. OAuth2 简介

**==OAuth（开放授权）是⼀个开放协议/标准==**，允许⽤户授权第三⽅应⽤访问他们存储在另外的服务提供者上的信息，⽽不需要将⽤户名和密码提供给第三⽅应⽤或分享他们数据的所有内容。针对定义，以下通过拉勾网和QQ来打个比方



当求职者想在拉钩网查询职位，但是又不想在拉勾网注册账号，由此拉勾网提供了**第三方登陆如微信、QQ、微博**，来进行授权登陆。**用户通过QQ授权并登陆**，**QQ认证中心**将一个带有用户信息的**令牌分发给拉勾网**，拉勾网即可使用令牌获取用户信息而**无需知晓用户的账号密码**。

- 第三⽅应⽤：拉勾网
- 服务提供者：QQ、微信、微博



### 2. OAuth2 角色及流程

1. 用户在某平台选择第三方登陆（如QQ登陆）
2. 跳转到QQ认证中心页面，请求授权
3. 用户输入QQ账号/密码，点击授权并登录
4. 客户端收到授权许可，向QQ认证中心申请令牌
5. 认证中心向服务器分发Access Token令牌
6. 客户端携带Access Token请求QQ资源服务器，获取用户信息
7. 返回受保护的用户信息给客户端

![image-20210905214258051](images/image-20210905214258051.png)

- **==资源所有者（Resource Owner）==**：⽤户⾃⼰

- **==客户端（Client）==**：想登陆的⽹站或应⽤，⽐如拉勾⽹

  - client_id ：客户端id（QQ最终相当于⼀个认证授权服务器，拉勾⽹就相当于⼀个客户端了，所以会给⼀个客户端id），相当于账号

  - secret：相当于密码

- **==认证服务器（Authorization Server）==**

  对外提供认证的认证中心，如微信、QQ的认证中心。**登陆认证、生成并颁发token、验证token、刷新token**

- **==资源服务器（Resource Server）==**：微信、QQ的服务



### 3. OAuth2 使用场景

- **==第三方授权登陆的场景==**

  作为大平台，实现一个认证中心，为其他第三方应用提供授权登陆的服务。

- **==单点登陆场景==**

  作为微服务架构，需要一个统一登陆及认证的服务，为其他所有服务进行统一的认证，实现一次登陆全服务授权



### 4. OAuth2 授权方式

- **==授权码（authorization-code）==**

  使⽤到了回调地址，是最复杂的授权⽅式，微博、微信、QQ等第三⽅登录就是这种模式

- **==密码式（password）==**提供⽤户名+密码换取token令牌

- 隐藏式（implicit） 

- 客户端凭证（client credentials）





## 三、JWT 

### 1. JWT简介

JWT是 Token的一种具体实现方式，其全称是JSON WebToken，官网地址：https://jwt.io/

**JWT的本质就是一个字符串**，它是**将用户信息保存到一个Json字符串**中，然后进行**编码后得到一个token**，并且这个JWT **token带有签名信息（使用RSA非对称加密算法签名），接收后可以校验是否被篡改**，所以可以用于在各方之间**安全地将信息作为 Json对象传输**



### 2. Token进行用户身份验证的流程

![image-20220225191916140](images/image-20220225191916140.png)

- 客户端使用用户名和密码请求登录

- 服务端收到请求，验证用户名和密码
- **验证成功后，服务端会签发一个token，再把这个token返回给客户端**
- 客户端收到token后可以把它存储起来，比如放到cookie中
- 客户端每次向服务端请求资源时**需要携带服务端签发的token**，可以在cookie或者**header中携带**
- 服务端收到请求，然后去**验证客户端请求里面带着的token**，如果验证成功，就向客户端返回请求数据

### 3. JWT结构

JWT由3部分组成：**标头(Header)**、**有效载荷(Payload)** 和 **签名(Signature)**

在传输的时候，会将JWT的3部分分别进行Base64编码后用 `.` 进行连接形成最终传输的字符串，jwt格式如下

```
JWTString = Base64(Header).Base64(Payload).HMACSHA256(base64UrlEncode(header)+"."+base64UrlEncode(payload),secret)
```

注意：

- header和payload可以直接利用base64解码出原文，从**header中获取 哈希签名的算法**，从**payload中获取有效数据** 
- **signature**由于使用了不可逆的加密算法，无法解码出原文，它的**作用 是校验token有没有被篡改**。服务端获取header中的加密算法之后，利 用该算法加上secretKey对header、payload进行加密，比对加密后的 数据和客户端发送过来的是否一致。注意secretKey只能保存在服务端，而且对于不同的加密算法其含义有所不同，一般对于MD5类型的摘要加密算法，secretKey实际上代表的是盐值

![image-20220225193223568](images/image-20220225193223568.png)

- Header

  标头描述JWT元数据的JSON对象

  - alg-签名使用的算法，默认是HMACSHA256
  - typ-令牌的类型

  ```json
  {
   "alg": "HS256",
   "typ": "JWT"
  }
  ```

  

- Payload

  有效载荷**存放主题内容**，JWT指定了七个默认字段：iss（发行人）、exp（到期时间）、sub（主题）、aud（用户）、iat：发布时间、jti：JWT ID

  也可⾃定义字段，**请勿存放敏感信息**，此部分可解码为明文

  ```json
  {
   "sub": "1234567890",
   "name": "John Doe",
   "iat": 1516239022
  }
  ```

  

- Signature

  **签名**，用于**校验jwt内容是否被篡改**。 **secret**是生成签名所使用的**私钥**

  - **对前两部分进行base64url编码**，编码后使用`.`连接
  - 然后使用**header中声明的签名算法进行签名**

  ```json
  HMACSHA256(
   base64UrlEncode(header) + "." +
   base64UrlEncode(payload),
   secret)
  ```






## 四、Spring Cloud OAuth2 + JWT 实现实现统一认证

Spring Cloud OAuth2 是 Spring Cloud 体系对OAuth2协议的实现

可以⽤来做多个微服务的统⼀认证（验证身份合法性）授权（验证权限）。通过向OAuth2服务（统⼀认证授权服务）发送某个类型的grant_type进⾏集中认证和授权，从⽽获得access_token（访问令牌），⽽这个token是受其他微服务信任的

### 1. 认证中心在微服务架构

![image-20210905223427119](images/image-20210905223427119.png)



### 2. 搭建认证中心

认证服务器（Authorization Server），负责登陆认证、生成并颁发token、验证token、刷新token

#### 2.1 pom.xml

```xml
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
    <parent>
        <artifactId>scn-demo</artifactId>
        <groupId>com.tangdi</groupId>
        <version>1.0-SNAPSHOT</version>
    </parent>
    <modelVersion>4.0.0</modelVersion>

    <artifactId>oauth-server</artifactId>


    <dependencies>
        <dependency>
            <groupId>com.tangdi</groupId>
            <artifactId>api-service</artifactId>
            <version>1.0-SNAPSHOT</version>
        </dependency>

        <!--导入Eureka Client依赖-->
        <dependency>
            <groupId>org.springframework.cloud</groupId>
            <artifactId>spring-cloud-starter-netflix-eureka-client</artifactId>
        </dependency>


        <!--导入spring cloud oauth2依赖-->
        <dependency>
            <groupId>org.springframework.cloud</groupId>
            <artifactId>spring-cloud-starter-oauth2</artifactId>
            <exclusions>
                <exclusion>
                    <groupId>org.springframework.security.oauth.boot</groupId>
                    <artifactId>spring-security-oauth2-autoconfigure</artifactId>
                </exclusion>
            </exclusions>
        </dependency>
        <dependency>
            <groupId>org.springframework.security.oauth.boot</groupId>
            <artifactId>spring-security-oauth2-autoconfigure</artifactId>
            <version>2.1.11.RELEASE</version>
        </dependency>
        <!--引入security对oauth2的支持-->
        <dependency>
            <groupId>org.springframework.security.oauth</groupId>
            <artifactId>spring-security-oauth2</artifactId>
            <version>2.3.4.RELEASE</version>
        </dependency>


        <!--分布式配置中心config client-->
        <dependency>
            <groupId>org.springframework.cloud</groupId>
            <artifactId>spring-cloud-config-client</artifactId>
        </dependency>

        <dependency>
            <groupId>mysql</groupId>
            <artifactId>mysql-connector-java</artifactId>
        </dependency>
        <dependency>
            <groupId>com.alibaba</groupId>
            <artifactId>druid-spring-boot-starter</artifactId>
            <version>1.1.10</version>
        </dependency>
        <!--操作数据库需要事务控制-->
        <dependency>
            <groupId>org.springframework</groupId>
            <artifactId>spring-tx</artifactId>
        </dependency>
        <dependency>
            <groupId>org.springframework</groupId>
            <artifactId>spring-jdbc</artifactId>
        </dependency>

    </dependencies>
</project>
```



#### 2.2 全局配置文件

##### 系统级配置

```yaml
spring:
  cloud:
    # config客户端配置,和ConfigServer通信，并告知ConfigServer希望获取的配置信息在哪个⽂件中
    config:
      name: oauth-server #配置⽂件名称
      profile: pre #后缀名称
      label: master #分⽀名称
      #ConfigServer配置中⼼地址
#      uri: http://scn-config-server
      # 从注册中心获取配置中心地址
      discovery:
        enabled: true
        service-id: scn-config-server
```

##### 公共配置

```yaml
spring:
  profiles:
    active: dev
```

##### 测试环境配置

```yaml
server:
  port: 8084
spring:
  application:
    name: oauth-server
  datasource:
    driver-class-name: com.mysql.jdbc.Driver
    url: jdbc:mysql://localhost:3306/demo_jpa?useSSL=false&characterEncoding=utf-8&serverTimezone=GMT
    username: root
    password: 123456


#注册到Eureka服务中心
eureka:
  client:
    # 每隔多久拉取⼀次服务列表
    registry-fetch-interval-seconds: 10
    service-url:
      # 注册到集群，就把多个Eurekaserver地址使用逗号连接起来即可
      defaultZone: http://localhost:8761/eureka,http://localhost:8762/eureka
  instance:
    prefer-ip-address: true  #使⽤ip注册，否则会使⽤主机名注册了（此处考虑到对⽼版本的兼容，新版本经过实验都是ip）
    # 实例名称： 192.168.1.103:lagou-service-resume:8080，我们可以自定义它
    instance-id: ${spring.cloud.client.ip-address}:${spring.application.name}:${server.port}
    # 租约续约间隔时间，默认30秒
    lease-renewal-interval-in-seconds: 10
    # 租约到期，服务时效时间，默认值90秒,服务超过90秒没有发⽣⼼跳，EurekaServer会将服务从列表移除
    lease-expiration-duration-in-seconds: 30
```

##### 测试环境配置

```yaml
server:
  port: 7074
spring:
  application:
    name: oauth-server
  datasource:
    driver-class-name: com.mysql.jdbc.Driver
    url: jdbc:mysql://localhost:3306/demo_jpa?useSSL=false&characterEncoding=utf-8&serverTimezone=GMT
    username: root
    password: 123456


#注册到Eureka服务中心
eureka:
  client:
    # 每隔多久拉取⼀次服务列表
    registry-fetch-interval-seconds: 10
    service-url:
      # 注册到集群，就把多个Eurekaserver地址使用逗号连接起来即可
      defaultZone: http://localhost:8761/eureka,http://localhost:8762/eureka
  instance:
    prefer-ip-address: true  #使⽤ip注册，否则会使⽤主机名注册了（此处考虑到对⽼版本的兼容，新版本经过实验都是ip）
    # 实例名称： 192.168.1.103:lagou-service-resume:8080，我们可以自定义它
    instance-id: ${spring.cloud.client.ip-address}:${spring.application.name}:${server.port}
    # 租约续约间隔时间，默认30秒
    lease-renewal-interval-in-seconds: 10
    # 租约到期，服务时效时间，默认值90秒,服务超过90秒没有发⽣⼼跳，EurekaServer会将服务从列表移除
    lease-expiration-duration-in-seconds: 30
```



#### 2.3 OAuth授权的客户端信息DDL

```sql
SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;
-- ----------------------------
-- Table structure for oauth_client_details
-- ----------------------------
DROP TABLE IF EXISTS `oauth_client_details`;
CREATE TABLE `oauth_client_details` (
 `client_id` varchar(48) NOT NULL,
 `resource_ids` varchar(256) DEFAULT NULL,
 `client_secret` varchar(256) DEFAULT NULL,
 `scope` varchar(256) DEFAULT NULL,
 `authorized_grant_types` varchar(256) DEFAULT NULL,
 `web_server_redirect_uri` varchar(256) DEFAULT NULL,
 `authorities` varchar(256) DEFAULT NULL,
 `access_token_validity` int(11) DEFAULT NULL,
 `refresh_token_validity` int(11) DEFAULT NULL,
 `additional_information` varchar(4096) DEFAULT NULL,
 `autoapprove` varchar(256) DEFAULT NULL,
 PRIMARY KEY (`client_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
-- ----------------------------
-- Records of oauth_client_details
-- ----------------------------
BEGIN;
INSERT INTO `oauth_client_details` VALUES ('client_lagou',
'autodeliver,resume', 'abcxyz', 'all', 'password,refresh_token',
NULL, NULL, 7200, 259200, NULL, NULL);
COMMIT;
SET FOREIGN_KEY_CHECKS = 1;
```



#### 2.4 用户信息DDL

```sql
SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;
-- ----------------------------
-- Table structure for users
-- ----------------------------
DROP TABLE IF EXISTS `users`;
CREATE TABLE `users` (
 `id` int(11) NOT NULL AUTO_INCREMENT,
 `username` char(10) DEFAULT NULL,
 `password` char(100) DEFAULT NULL,
 PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8;
-- ----------------------------
-- Records of users
-- ----------------------------
BEGIN;
INSERT INTO `users` VALUES (4, 'admin', '123456');
COMMIT;
SET FOREIGN_KEY_CHECKS = 1;
```



#### 2.5 OAuth2 认证中心启动类

```java
package com.tangdi;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.cloud.client.discovery.EnableDiscoveryClient;

/**
 * @program: scn-demo
 * @description:
 * @author: Wangwentao
 * @create: 2021-11-12 17:07
 **/
@SpringBootApplication
@EnableDiscoveryClient
public class OAuthServerApplication {
    public static void main(String[] args) {
        SpringApplication.run(OAuthServerApplication.class,args);
    }

}

```



#### 2.6 OAuth2 认证中心配置类 

```java
package com.tangdi.config;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.http.HttpMethod;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.jwt.crypto.sign.MacSigner;
import org.springframework.security.oauth2.config.annotation.configurers.ClientDetailsServiceConfigurer;
import org.springframework.security.oauth2.config.annotation.web.configuration.AuthorizationServerConfigurerAdapter;
import org.springframework.security.oauth2.config.annotation.web.configuration.EnableAuthorizationServer;
import org.springframework.security.oauth2.config.annotation.web.configurers.AuthorizationServerEndpointsConfigurer;
import org.springframework.security.oauth2.config.annotation.web.configurers.AuthorizationServerSecurityConfigurer;
import org.springframework.security.oauth2.provider.client.JdbcClientDetailsService;
import org.springframework.security.oauth2.provider.token.AuthorizationServerTokenServices;
import org.springframework.security.oauth2.provider.token.DefaultTokenServices;
import org.springframework.security.oauth2.provider.token.TokenStore;
import org.springframework.security.oauth2.provider.token.store.JwtAccessTokenConverter;
import org.springframework.security.oauth2.provider.token.store.JwtTokenStore;

import javax.sql.DataSource;


/**
 * 当前类为Oauth2 server的配置类（需要继承特定的父类 AuthorizationServerConfigurerAdapter）
 */
@Configuration
// 开启认证服务器功能
@EnableAuthorizationServer
public class OauthServerConfiger extends AuthorizationServerConfigurerAdapter {


    @Autowired
    private AuthenticationManager authenticationManager;

    @Autowired
    private MyAccessTokenConvertor myAccessTokenConvertor;

    @Autowired
    private DataSource dataSource;

    // jwt签名密钥
    private String sign_key = "test123";


    /**
     * 认证服务器最终是以api接口的方式对外提供服务（校验合法性并生成令牌、校验令牌等）
     * 那么，以api接口方式对外的话，就涉及到接口的访问权限，我们需要在这里进行必要的配置
     * @param security
     * @throws Exception
     */
    @Override
    public void configure(AuthorizationServerSecurityConfigurer security) throws Exception {
        super.configure(security);
        // 相当于打开endpoints 访问接口的开关，这样的话后期我们能够访问该接口
        security
            // 允许客户端表单认证
            .allowFormAuthenticationForClients()
            // 开启端口/oauth/token_key的访问权限（允许）
            .tokenKeyAccess("permitAll()")
            // 开启端口/oauth/check_token的访问权限（允许）
            .checkTokenAccess("permitAll()");
    }

    /**
     * 客户端详情配置，
     *  比如client_id，secret
     *  当前这个服务就如同QQ平台，拉勾网作为客户端需要qq平台进行登录授权认证等，提前需要到QQ平台注册，QQ平台会给拉勾网
     *  颁发client_id等必要参数，表明客户端是谁
     * @param clients
     * @throws Exception
     */
    @Override
    public void configure(ClientDetailsServiceConfigurer clients) throws Exception {
        super.configure(clients);


        // 从内存中加载客户端详情

        /*clients.inMemory()// 客户端信息存储在什么地方，可以在内存中，可以在数据库里
                .withClient("client_lagou")  // 添加一个client配置,指定其client_id
                .secret("abcxyz")                   // 指定客户端的密码/安全码
                .resourceIds("autodeliver")         // 指定客户端所能访问资源id清单，此处的资源id是需要在具体的资源服务器上也配置一样
                // 认证类型/令牌颁发模式，可以配置多个在这里，但是不一定都用，具体使用哪种方式颁发token，需要客户端调用的时候传递参数指定
                .authorizedGrantTypes("password","refresh_token")
                // 客户端的权限范围，此处配置为all全部即可
                .scopes("all");*/

        // 从数据库中加载客户端详情
        clients.withClientDetails(createJdbcClientDetailsService());

    }


    /**
     * 认证服务器是玩转token的，那么这里配置token令牌管理相关（token此时就是一个字符串，当下的token需要在服务器端存储，
     * 那么存储在哪里呢？都是在这里配置）
     * @param endpoints
     * @throws Exception
     */
    @Override
    public void configure(AuthorizationServerEndpointsConfigurer endpoints) throws Exception {
        super.configure(endpoints);
        endpoints
            // 指定token的存储方法
            .tokenStore(tokenStore())
            // token服务的一个描述，可以认为是token生成细节的描述，比如有效时间多少等
            .tokenServices(authorizationServerTokenServices())
            // 指定认证管理器，随后注入一个到当前类使用即可
            .authenticationManager(authenticationManager)
            .allowedTokenEndpointRequestMethods(HttpMethod.GET,HttpMethod.POST);
    }


    @Bean
    public JdbcClientDetailsService createJdbcClientDetailsService() {
        return new JdbcClientDetailsService(dataSource);
    }


    /**
     * 该方法用户获取一个token服务对象（该对象描述了token有效期等信息）
     */
    private AuthorizationServerTokenServices authorizationServerTokenServices() {
        // 使用默认实现
        DefaultTokenServices defaultTokenServices = new DefaultTokenServices();
        // 是否开启令牌刷新
        defaultTokenServices.setSupportRefreshToken(true);
        defaultTokenServices.setTokenStore(tokenStore());

        // 针对jwt令牌的添加
        defaultTokenServices.setTokenEnhancer(jwtAccessTokenConverter());

        // 设置令牌有效时间（一般设置为2个小时，此处设置20秒）
        // access_token就是我们请求资源需要携带的令牌
        defaultTokenServices.setAccessTokenValiditySeconds(20);
        // 设置刷新令牌的有效时间
        // 3天
        defaultTokenServices.setRefreshTokenValiditySeconds(259200);

        return defaultTokenServices;
    }

    /**
     * 该方法用于创建tokenStore对象（令牌存储对象） token以什么形式存储
     * @return
     */
    private TokenStore tokenStore(){
        //return new InMemoryTokenStore();
        // 使用jwt令牌
        return new JwtTokenStore(jwtAccessTokenConverter());
    }

    /**
     * 返回jwt令牌转换器（帮助我们生成jwt令牌的）
     * 在这里，我们可以把签名密钥传递进去给转换器对象
     * @return
     */
    private JwtAccessTokenConverter jwtAccessTokenConverter() {
        JwtAccessTokenConverter converter = new JwtAccessTokenConverter();
        /*//钥匙对
        KeyPair keyPair = new KeyStoreKeyFactory(
                keyProperties.getKeyStore().getLocation(),                          //证书路径
                keyProperties.getKeyStore().getSecret().toCharArray())              //证书密钥
                .getKeyPair(
                        keyProperties.getKeyStore().getAlias(),                     //证书别名
                        keyProperties.getKeyStore().getPassword().toCharArray());   //证书密码
        converter.setKeyPair(keyPair);*/
        
        
        // 签名密钥
        converter.setSigningKey(sign_key);
        // 验证时使用的密钥，和签名密钥保持一致
        converter.setVerifier(new MacSigner(sign_key));
        // 扩展jwt生成器
        converter.setAccessTokenConverter(myAccessTokenConvertor);

        return converter;
    }
}

```

- **三个confifigure⽅法**

  - **confifigure(ClientDetailsServiceConfifigurer clients)**

    用来配置客户端详情服务（ClientDetailsService），客户端详情信息在 这⾥进⾏初始化，你能够把客户端详情信息写死在这⾥或者是通过数据库来存储调取详情信息

  - **confifigure(AuthorizationServerEndpointsConfifigurer endpoints)**

    ⽤来配置令牌（token）的访问端点和令牌服务(token services)

  - **confifigure(AuthorizationServerSecurityConfifigurer oauthServer)**

    ⽤来配置令牌端点的安全约束

- **TokenStore**

  - **InMemoryTokenStore**

    默认采⽤，它可以完美的⼯作在单服务器上（即访问并发量 压⼒不⼤的情况下，并且它在失败的时候不会进⾏备份），⼤多数的项⽬都可以使⽤这个版本的实现来进⾏ 尝试，你可以在开发的时候使⽤它来进⾏管理，因为不会被保存到磁盘中，所以更易于调试

  - **JdbcTokenStore**

    基于JDBC的实现版本，令牌会被保存进关系型数据库。使⽤这个版本的实现时， 你可以在不同的服务器之间共享令牌信息，使⽤这个版本的时候请注意把"spring-jdbc"这个依赖加⼊到你的 classpath当中

  - **JwtTokenStore**

    JSON Web Token（JWT），它可以把令牌相关的数据进⾏编码（因此对于后端服务来说，它不需要进⾏存储，这将是⼀个重⼤优势），缺点就是这个令牌占⽤的空间会⽐较⼤，如果你加⼊了⽐较多⽤户凭证信息，JwtTokenStore 不会保存任何数据





#### 2.7 用户信息认证安全配置类

```java
package com.tangdi.config;

import com.tangdi.service.JdbcUserDetailsService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.config.annotation.authentication.builders.AuthenticationManagerBuilder;
import org.springframework.security.config.annotation.web.configuration.WebSecurityConfigurerAdapter;
import org.springframework.security.crypto.password.NoOpPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;


/**
 * 该配置类，主要处理用户名和密码的校验等事宜
 */
@Configuration
public class SecurityConfiger extends WebSecurityConfigurerAdapter {

    @Autowired
    private PasswordEncoder passwordEncoder;

    @Autowired
    private JdbcUserDetailsService jdbcUserDetailsService;

    /**
     * 注册一个认证管理器对象到容器
     */
    @Bean
    @Override
    public AuthenticationManager authenticationManagerBean() throws Exception {
        return super.authenticationManagerBean();
    }


    /**
     * 密码编码对象（密码不进行加密处理）
     * @return
     */
    @Bean
    public PasswordEncoder passwordEncoder() {
        return NoOpPasswordEncoder.getInstance();
    }

    /**
     * 处理用户名和密码验证事宜
     * 1）客户端传递username和password参数到认证服务器
     * 2）一般来说，username和password会存储在数据库中的用户表中
     * 3）根据用户表中数据，验证当前传递过来的用户信息的合法性
     */
    @Override
    protected void configure(AuthenticationManagerBuilder auth) throws Exception {
        // 在这个方法中就可以去关联数据库了，当前我们先把用户信息配置在内存中
        // 实例化一个用户对象(相当于数据表中的一条用户记录)
        /*UserDetails user = new User("admin","123456",new ArrayList<>());
        auth.inMemoryAuthentication()
                .withUser(user).passwordEncoder(passwordEncoder);*/

        auth.userDetailsService(jdbcUserDetailsService).passwordEncoder(passwordEncoder);
    }
}

```



#### 2.8 实现UserDetailsService接口，查询用户详情Service

```java
package com.tangdi.service;

import com.tangdi.dao.UsersRepository;
import com.tangdi.domain.user.Users;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.userdetails.User;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;

import java.util.ArrayList;

@Service
public class JdbcUserDetailsService implements UserDetailsService {

    @Autowired
    private UsersRepository usersRepository;

    /**
     * 根据username查询出该用户的所有信息，封装成UserDetails类型的对象返回，至于密码，框架会自动匹配
     * @param username
     * @return
     * @throws UsernameNotFoundException
     */
    @Override
    public UserDetails loadUserByUsername(String username) throws UsernameNotFoundException {
        Users users = usersRepository.findByUsername(username);
        return new User(users.getUsername(),users.getPassword(),new ArrayList<>());
    }
}

```



#### 2.9 用户实体类及Dao

```java
package com.tangdi.domain.user;

import lombok.Data;

import javax.persistence.Entity;
import javax.persistence.Id;
import javax.persistence.Table;

@Data
@Entity
@Table(name="users")
public class Users {
    @Id
    private Long id;
    private String username;
    private String password;
}

```

```java
package com.tangdi.dao;

import com.tangdi.domain.user.Users;
import org.springframework.data.jpa.repository.JpaRepository;

public interface UsersRepository extends JpaRepository<Users,Long> {

    Users findByUsername(String username);
}

```



#### 2.10 基于Oauth2的 JWT 令牌信息扩展

##### 		2.10.1 往 JWT令牌 写入自定义字段，如请求的ip，用于在网关中的IP验证

##### 2.10.2 将自定义转换器注入认证服务配置类中

```java
package com.tangdi.config;

import org.springframework.security.oauth2.common.OAuth2AccessToken;
import org.springframework.security.oauth2.provider.OAuth2Authentication;
import org.springframework.security.oauth2.provider.token.DefaultAccessTokenConverter;
import org.springframework.stereotype.Component;
import org.springframework.web.context.request.RequestContextHolder;
import org.springframework.web.context.request.ServletRequestAttributes;

import javax.servlet.http.HttpServletRequest;
import java.util.Map;


/**
 * 扩展jwt令牌信息
 */
@Component
public class MyAccessTokenConvertor extends DefaultAccessTokenConverter {


    @Override
    public Map<String, ?> convertAccessToken(OAuth2AccessToken token, OAuth2Authentication authentication) {
        // 获取到request对象
        HttpServletRequest request = ((ServletRequestAttributes) (RequestContextHolder.getRequestAttributes())).getRequest();
        // 获取客户端ip（注意：如果是经过代理之后到达当前服务的话，那么这种方式获取的并不是真实的浏览器客户端ip）
        String remoteAddr = request.getRemoteAddr();
        Map<String, String> stringMap = (Map<String, String>) super.convertAccessToken(token, authentication);
        stringMap.put("clientIp",remoteAddr);
        return stringMap;
    }
}

```



#### 2.11 对外提供的API接口 

##### 2.11.1 认证并生成token

http://localhost:8084/oauth/token?client_secret=abcxyz&grant_type=password&username=admin&password=123456&client_id=client_lagou

![image-20211112183523873](images/image-20211112183523873.png)

- **client_id**：客户端id

- **client_secret**：客户单密码

- **grant_type**：指定使⽤哪种颁发类型，password

- **username**：⽤户名

- **password**：密码

##### 2.11.2 验证token

http://localhost:8084/oauth/check_token?token=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJhdWQiOlsicmVzdW1lIiwiY29kZSIsImF1dG9kZWxpdmVyIl0sInVzZXJfbmFtZSI6ImFkbWluIiwic2NvcGUiOlsiYWxsIl0sImNsaWVudElwIjoiMDowOjA6MDowOjA6MDoxIiwiZXhwIjoxNjM2NzEzMzg3LCJqdGkiOiIzNGYzMzE4NS1iYjU0LTQ2ZGYtOTQwYy03MGE4YjFkNGRkZDYiLCJjbGllbnRfaWQiOiJjbGllbnRfbGFnb3UifQ.-_PB3t4po_vcuqzZT7EiDOjmisBJKpmNPKjo7L6bo80

![image-20211112183643254](images/image-20211112183643254.png)





##### 2.11.3 刷新token

http://localhost:8084/oauth/token?grant_type=refresh_token&client_id=client_lagou&client_secret=abcxyz&refresh_token=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJhdWQiOlsicmVzdW1lIiwiY29kZSIsImF1dG9kZWxpdmVyIl0sInVzZXJfbmFtZSI6ImFkbWluIiwic2NvcGUiOlsiYWxsIl0sImF0aSI6IjIxY2EyMTNjLTBhNjItNDI3ZS1hZjc0LTg3NThmMGVkYzJlYyIsImNsaWVudElwIjoiMDowOjA6MDowOjA6MDoxIiwiZXhwIjoxNjM2OTcyMzQ3LCJqdGkiOiIzMGM2NDgwMy05OTc5LTQ4ZDctOGU3YS1lODhmMjM5ZTY0MzgiLCJjbGllbnRfaWQiOiJjbGllbnRfbGFnb3UifQ.B6oxxVXXTS1rHfdo4-ihM5XTZ2N3oAeEMCW5koSFSGw

![image-20211112183702059](images/image-20211112183702059.png)





### 3 资源服务器（希望访问被认证的微服务）

在原有的微服务中改造，添加Spring Cloud Oauth相关的配置及代码，

#### 3.1 无需认证的微服务，则无需改造为资源服务器



#### 3.2 添加依赖

```xml
<!--导入spring cloud oauth2依赖-->
<dependency>
    <groupId>org.springframework.cloud</groupId>
    <artifactId>spring-cloud-starter-oauth2</artifactId>
    <exclusions>
        <exclusion>
            <groupId>org.springframework.security.oauth.boot</groupId>
            <artifactId>spring-security-oauth2-autoconfigure</artifactId>
        </exclusion>
    </exclusions>
</dependency>
<dependency>
    <groupId>org.springframework.security.oauth.boot</groupId>
    <artifactId>spring-security-oauth2-autoconfigure</artifactId>
    <version>2.1.11.RELEASE</version>
</dependency>
<!--引入security对oauth2的支持-->
<dependency>
    <groupId>org.springframework.security.oauth</groupId>
    <artifactId>spring-security-oauth2</artifactId>
    <version>2.3.4.RELEASE</version>
</dependency>
```



#### 3.3 资源服务配置类

```java
package com.tangdi.config;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.jwt.crypto.sign.MacSigner;
import org.springframework.security.oauth2.config.annotation.web.configuration.EnableResourceServer;
import org.springframework.security.oauth2.config.annotation.web.configuration.ResourceServerConfigurerAdapter;
import org.springframework.security.oauth2.config.annotation.web.configurers.ResourceServerSecurityConfigurer;
import org.springframework.security.oauth2.provider.token.TokenStore;
import org.springframework.security.oauth2.provider.token.store.JwtAccessTokenConverter;
import org.springframework.security.oauth2.provider.token.store.JwtTokenStore;

/**
 * @program: scn-demo
 * @description:
 * @author: Wangwentao
 * @create: 2021-11-12 17:48
 **/
@Configuration
@EnableResourceServer  // 开启资源服务器功能
@EnableWebSecurity  // 开启web访问安全
public class ResourceServerConfiger extends ResourceServerConfigurerAdapter {

    // jwt签名密钥
    private String sign_key = "test123";

    @Autowired
    private MyAccessTokenConvertor myAccessTokenConvertor;

    /**
     * 该方法用于定义资源服务器向远程认证服务器发起请求，进行token校验等事宜
     * @param resources
     * @throws Exception
     */
    @Override
    public void configure(ResourceServerSecurityConfigurer resources) throws Exception {

        /*// 设置当前资源服务的资源id
        resources.resourceId("autodeliver");
        // 定义token服务对象（token校验就应该靠token服务对象）
        RemoteTokenServices remoteTokenServices = new RemoteTokenServices();
        // 校验端点/接口设置
        remoteTokenServices.setCheckTokenEndpointUrl("http://localhost:9999/oauth/check_token");
        // 携带客户端id和客户端安全码
        remoteTokenServices.setClientId("client_lagou");
        remoteTokenServices.setClientSecret("abcxyz");

        // 别忘了这一步
        resources.tokenServices(remoteTokenServices);*/


        // jwt令牌改造
        resources.resourceId("autodeliver").tokenStore(tokenStore()).stateless(true);// 无状态设置
    }


    /**
     * 场景：一个服务中可能有很多资源（API接口）
     *    某一些API接口，需要先认证，才能访问
     *    某一些API接口，压根就不需要认证，本来就是对外开放的接口
     *    我们就需要对不同特点的接口区分对待（在当前configure方法中完成），设置是否需要经过认证
     *
     * @param http
     * @throws Exception
     */
    @Override
    public void configure(HttpSecurity http) throws Exception {
        http    // 设置session的创建策略（根据需要创建即可）
                .sessionManagement().sessionCreationPolicy(SessionCreationPolicy.IF_REQUIRED)
                .and()
                .authorizeRequests()
                // autodeliver为前缀的请求需要认证
                .antMatchers("/autodeliver/**").authenticated()
                // codeTest为前缀的请求需要认证
                .antMatchers("/codeTest/**").authenticated()
                .anyRequest().permitAll();  //  其他请求不认证
    }


    /**
     * 该方法用于创建tokenStore对象（令牌存储对象） token以什么形式存储
     * @return
     */
    public TokenStore tokenStore(){
        //return new InMemoryTokenStore();

        // 使用jwt令牌
        return new JwtTokenStore(jwtAccessTokenConverter());
    }

    /**
     * 返回jwt令牌转换器（帮助我们生成jwt令牌的）
     * 在这里，我们可以把签名密钥传递进去给转换器对象
     * @return
     */
    public JwtAccessTokenConverter jwtAccessTokenConverter() {
        JwtAccessTokenConverter jwtAccessTokenConverter = new JwtAccessTokenConverter();
        // 签名密钥
        jwtAccessTokenConverter.setSigningKey(sign_key);
        // 验证时使用的密钥，和签名密钥保持一致
        jwtAccessTokenConverter.setVerifier(new MacSigner(sign_key));
        jwtAccessTokenConverter.setAccessTokenConverter(myAccessTokenConvertor);
        return jwtAccessTokenConverter;
    }
}

```

或者

```java
@Configuration
@EnableResourceServer
@EnableGlobalMethodSecurity(prePostEnabled = true, securedEnabled = true)
public class ResourceServerConfig extends ResourceServerConfigurerAdapter {

    //公钥
    private static final String PUBLIC_KEY = "public.key";

    /***
         * 定义JwtTokenStore
         * @param jwtAccessTokenConverter
         * @return
         */
    @Bean
    public TokenStore tokenStore(JwtAccessTokenConverter jwtAccessTokenConverter) {
        return new JwtTokenStore(jwtAccessTokenConverter);
    }

    /***
         * 定义JwtAccessTokenConverter
         * @return
         */
    @Bean
    public JwtAccessTokenConverter jwtAccessTokenConverter() {
        JwtAccessTokenConverter converter = new JwtAccessTokenConverter();
        converter.setVerifierKey(getPubKey());
        return converter;
    }

    /**
         * 获取非对称加密公钥 Key
         *
         * @return 公钥 Key
         */
    private String getPubKey() {
        Resource resource = new ClassPathResource(PUBLIC_KEY);
        try {
            InputStreamReader inputStreamReader = new InputStreamReader(resource.getInputStream());
            BufferedReader br = new BufferedReader(inputStreamReader);
            return br.lines().collect(Collectors.joining("\n"));
        } catch (IOException ioe) {
            return null;
        }
    }

    /***
         * Http安全配置，对每个到达系统的http请求链接进行校验
         * @param http
         * @throws Exception
         */
    @Override
    public void configure(HttpSecurity http) throws Exception {
        //所有请求必须认证通过
        http.authorizeRequests()
            //下边的路径放行
            .antMatchers(
            "/template/**") //放行模板接口
            .permitAll()
            .anyRequest()
            .authenticated(); //其他地址需要认证授权
    }
}
```





#### 3.4 取出Oauth2的 JWT 令牌信息

```java
package com.tangdi.config;

import org.springframework.security.oauth2.provider.OAuth2Authentication;
import org.springframework.security.oauth2.provider.token.DefaultAccessTokenConverter;
import org.springframework.stereotype.Component;

import java.util.Map;


@Component
public class MyAccessTokenConvertor extends DefaultAccessTokenConverter {


    @Override
    public OAuth2Authentication extractAuthentication(Map<String, ?> map) {

        OAuth2Authentication oAuth2Authentication = super.extractAuthentication(map);
        // 将map放入认证对象中，认证对象在controller中可以拿到
        oAuth2Authentication.setDetails(map);
        return oAuth2Authentication;
    }
}

```



#### 3.5 在需要认证的接口中，获取 JWT 信息

```java
package com.tangdi.controller;

import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

/**
 * @program: scn-demo
 * @description:
 * @author: Wangwt
 * @create: 11:41 2021/9/4
 */
@RestController
@RequestMapping("/codeTest")
public class TestController {

    @PostMapping("/test")
    public String test(){
        Object details = SecurityContextHolder.getContext().getAuthentication().getDetails();
        System.out.println(details);
        return "Feign test=====================>";
    }
}
```



#### 3.6 资源服务器验证

http://localhost:8081/code/codeTest/test?access_token=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJhdWQiOlsicmVzdW1lIiwiY29kZSIsImF1dG9kZWxpdmVyIl0sInVzZXJfbmFtZSI6ImFkbWluIiwic2NvcGUiOlsiYWxsIl0sImNsaWVudElwIjoiMDowOjA6MDowOjA6MDoxIiwiZXhwIjoxNjM2NzEzMjU2LCJqdGkiOiI4NWUxZTYwYS1lZGIzLTRhNDAtOGZiYi02NTlhZTFjNjc1ZTgiLCJjbGllbnRfaWQiOiJjbGllbnRfbGFnb3UifQ.gCtHiavOTIXx30bj27cgiFQuRiCBKPWz6MkZAp-zTzg

![image-20211112183847778](images/image-20211112183847778.png)



#### 3.7 令牌传递(通过feign拦截器，添加token到请求头)

```java
@Configuration
public class FeginInterceptor implements RequestInterceptor {
    @Override
    public void apply(RequestTemplate requestTemplate) {
        try {
            Map<String, String> headers = getHeaders();
            for (String headerName : headers.keySet()) {
                requestTemplate.header(headerName, headers.get(headerName));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    private Map<String, String> getHeaders() {
        HttpServletRequest request = ((ServletRequestAttributes) RequestContextHolder.getRequestAttributes()).getRequest();
        Map<String, String> map = new LinkedHashMap<>();
        Enumeration<String> enumeration = request.getHeaderNames();
        while (enumeration.hasMoreElements()) {
            String key = enumeration.nextElement();
            String value = request.getHeader(key);
            map.put(key, value);
        }
        return map;
    }
}
```











### 4. 网关配置

#### 新增路由-认证中心

```yaml
spring:
  cloud:
    gateway:
      routes:
        - id: service-oauth-router
          uri: lb://lagou-cloud-oauth-server
          predicates:
            - Path=/oauth/**
```


当 Client 向 Server 注册时，它会提供一些元数据，例如主机和端口，URL，主页等。Eureka Server 从每个 Client 实例接收心跳消息。 如果心跳超时，则通常将该实例从注册 Server 中删除。

# pom.xml文件


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

    <artifactId>itoken-service-admin</artifactId>
    <packaging>jar</packaging>

    <dependencies>
        <dependency>
            <groupId>com.tangdi</groupId>
            <artifactId>itoken-common-domain</artifactId>
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
                    <mainClass>com.tangdi.itoken.service.admin.ServiceAdminApplication</mainClass>
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

通过注解 ==@EnableEurekaClient== 表明自己是一个 Eureka Client.


```
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.cloud.netflix.eureka.EnableEurekaClient;
import tk.mybatis.spring.annotation.MapperScan;

@SpringBootApplication
@EnableEurekaClient
@MapperScan(basePackages = {"com.tangdi.itoken.service.admin.mapper","com.tangdi.itoken.common.mapper"})
public class ServiceAdminApplication {
    public static void main(String[] args) {
        SpringApplication.run(ServiceAdminApplication.class,args);
    }
}

```
---

# 本地配置

#### bootstrap.yml


```
spring:
  cloud:
    config:
      uri: http://localhost:8888
      name: itoken-service-admin
      label: master
      profile: dev
```
#### bootstrap-prod.yml


```
spring:
  cloud:
    config:
      uri: http://192.168.243.135:8888
      name: itoken-service-admin
      label: master
      profile: prod
```

---

# 云配置

#### itoken-service-admin-dev.yml


```
spring:
  application:
    name: itoken-service-admin
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
  redis:
    lettuce:
      pool:
        max-active: 8
        max-idle: 8
        max-wait: -1ms
        min-idle: 0
    sentinel:
      master: mymaster
      nodes: 192.168.243.132:26379

logging:
  file: logs/itoken-service-admin.log

mybatis:
#   开启二级缓存
    configuration:
      cache-enabled: true
    type-aliases-package: com.tangdi.itoken.service.admin.domain
    mapper-locations: classpath:mapper/*.xml

server:
  port: 8501

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

#### itoken-service-admin-prod.yml

```
spring:
  application:
    name: itoken-service-admin
  zipkin:
      base-url: http://192.168.243.135:9411
  boot:
    admin:
      client:
        url: http://192.168.243.135:8084
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
  redis:
    lettuce:
      pool:
        max-active: 8
        max-idle: 8
        max-wait: -1ms
        min-idle: 0
    sentinel:
      master: mymaster
      nodes: 192.168.243.132:26379

mybatis:
#   开启二级缓存
    configuration:
      cache-enabled: true
    type-aliases-package: com.tangdi.spring.boot.entity
    mapper-locations: classpath:mapper/*.xml

server:
  port: 8501

eureka:
  client:
    serviceUrl:
      defaultZone: http://192.168.243.135:8761/eureka/

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

# 创建业务层

#### AdminService

```
import com.tangdi.itoken.common.domain.BaseDomain;
import com.tangdi.itoken.common.service.BaseService;

public interface AdminService<T extends BaseDomain> extends BaseService<T> {
}
```


#### AdminServiceImpl


```
import com.tangdi.itoken.common.domain.TbSysUser;
import com.tangdi.itoken.common.mapper.TbSysUserMapper;
import com.tangdi.itoken.common.service.impl.BaseServiceImpl;
import com.tangdi.itoken.service.admin.service.AdminService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.DigestUtils;
import tk.mybatis.mapper.entity.Example;

@Service
@Transactional(readOnly = true)
public class AdminServiceImpl extends BaseServiceImpl<TbSysUser,TbSysUserMapper> implements AdminService<TbSysUser> {
}
```
---

# 扩展dao层

#### 创建TbSysUserExtendMapper 接口
```
package com.tangdi.itoken.service.admin.mapper;

import com.tangdi.itoken.common.domain.TbSysUser;
import org.springframework.stereotype.Repository;
import tk.mybatis.mapper.MyMapper;

@Repository
public interface TbSysUserExtendMapper extends MyMapper<TbSysUser> {
}
```
#### 创建TbSysUserExtendMapper.xml


```
从itoken-common-service中拷贝过来，并自行修改
```

---

# Controller 

##### 需要提供restful的API


```
package com.tangdi.itoken.service.admin.controller;


import com.github.pagehelper.PageInfo;
import com.tangdi.itoken.common.domain.TbSysUser;
import com.tangdi.itoken.common.dto.BaseResult;
import com.tangdi.itoken.common.utils.MapperJacksonUtils;
import com.tangdi.itoken.service.admin.service.impl.AdminServiceImpl;
import org.apache.commons.lang3.StringUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.util.DigestUtils;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping(value = "v1/admins")
public class AdminController {

    @Autowired
    private AdminServiceImpl service;

    @RequestMapping(value = "page/{pageNum}/{pageSize}",method = RequestMethod.GET)
    public BaseResult page(@PathVariable(required = true) int pageNum,
                     @PathVariable(required = true) int pageSzie,
                     @RequestParam(required = false)TbSysUser tbSysUser){
        //得到分页信息
        PageInfo pageInfo = service.page(pageNum, pageSzie, tbSysUser);
        //分页结果集
        List<TbSysUser> list = pageInfo.getList();
        //封装Cursor进BaseResult返回给前端
        BaseResult.Cursor cursor = new BaseResult.Cursor(new Long(pageInfo.getTotal()).intValue(),pageNum,pageSzie);
        return BaseResult.ok(list,cursor);
    }

    @RequestMapping(value = "{userCode}",method = RequestMethod.GET)
    public BaseResult select(@PathVariable(required = true)String userCode){
        TbSysUser tbSysUser = new TbSysUser();
        tbSysUser.setUserCode(userCode);
        TbSysUser object = service.selectOne(tbSysUser);
        return BaseResult.ok(object);
    }

    @RequestMapping(method =RequestMethod.POST)
    public BaseResult save(@RequestParam(required = true)String tbSysUserjson,
                           @RequestParam(required = true)String optsBy){

        TbSysUser tbSysUser = null;
        int resoult = 0;

        try {
            tbSysUser = MapperJacksonUtils.json2pojo(tbSysUserjson, TbSysUser.class);
        } catch (Exception e) {
            e.printStackTrace();
        }

        if(tbSysUser != null){
            String passWord = DigestUtils.md5DigestAsHex(tbSysUser.getPassword().getBytes());
            tbSysUser.setPassword(passWord);
            //新增
            if(StringUtils.isBlank(tbSysUser.getUserCode())){
                tbSysUser.setUserCode(UUID.randomUUID().toString());
                resoult = service.insert(tbSysUser, optsBy);
            }
            //修改
            else{
                resoult = service.update(tbSysUser, optsBy);
            }

            if(resoult>0){
                return BaseResult.ok("保存成功");
            }
        }
        return BaseResult.notOk("保存失败");
    }

}

```






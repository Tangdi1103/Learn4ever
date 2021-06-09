# 简介
Thymeleaf 是一个跟 Velocity、FreeMarker 类似的模板引擎，它可以完全替代 JSP ，Spring Boot 中推荐使用 Thymeleaf 作为模板引擎，因为 Thymeleaf 提供了完美的 Spring MVC 支持，优势强大


---

# 引入依赖

==spring-boot-starter-thymeleaf==：Thymeleaf 自动配置

==nekohtml==：允许使用非严格的 HTML 语法


```
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-thymeleaf</artifactId>
</dependency>
<dependency>
    <groupId>net.sourceforge.nekohtml</groupId>
    <artifactId>nekohtml</artifactId>
    <version>1.9.22</version>
</dependency>
```

# 在 application.yml 中配置 Thymeleaf


```
spring:
  thymeleaf:
    cache: false # 开发时关闭缓存,不然没法看到实时页面
    mode: LEGACYHTML5 # 用非严格的 HTML
    encoding: UTF-8
    servlet:
      content-type: text/html
```

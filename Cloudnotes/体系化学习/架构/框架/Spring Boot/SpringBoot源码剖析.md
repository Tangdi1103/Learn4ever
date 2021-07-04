自动配置原理

 	1. @SpringBootApplication注解由以下注解组合而成
      	1. @SpringBootConfiguration-标识为配置类
      	2. @EnableAutoConfiguration-开启自动配置
      	3. @ComponentScan-注解扫描
 	2. @EnableAutoConfiguration由@AutoConfigurationPackage和@Import(AutoConfigurationImportSelector.class)组合成。AutoConfigurationPackage使用@Import向SpringIoC容器注册了一个自动配置包组件——用于扫描路径。而@Import(AutoConfigurationImportSelector.class)向容器注册了一个selector组件，用于加载各个starter（jar包）下META-INF/spring.factories文件，该文件配置了每个包需要被自动加载对象的全限定路径名。被IoC容器加载后，根据类上的注解@ConditionOnXXX判断是否满足需求，然后决定是否实例化bean


一、SpringBoot概念

1. 什么SpringBoot
2. 什么是约定由于配置
3. SpringBoot有哪些特性（核心），分别具有什么优点
   1. 什么是起步依赖（Spring boot starter），有哪些优点
   2. 什么是JavaConfig，有哪些优点（说说spring3.0、4.0的servlet规范）
   3. 什么是自动配置，有哪些优点
   4. 为什么不需要配置web容器就可以直接启动？

二、Springboot的热部署——DevTools

1. 重新编译更改classpath资源文件
2. 自定义类加载器RestartClassLoader加载自开发项目类
3. 而APPClassLoader则只加载三方类库
4. RestartClassLoader类加载器来监控classpath的变动，若发生变动则重新加载类

​	自定义了一个RestartClassLoader来监控classpath下的变动来重新加载类，而依赖的三方类库还是由APPClassLoader在服务启动的时候加载。再配合自动编译实现了无需重启服务，也能使更改代码实时生效

三、Springboot全局配置


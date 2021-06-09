1. gradel使用jar的仓库分为三部分：远程库，本地maven库，gradle缓存库
1. 创建项目的时候会根据gradle.build的配置去一次读取项目所需要的jar，不管是从远程库还是本地的maven库，然后都存储在gradle的缓存库中。
1. 问题在于如何使用自己发布的jar呢，由于gradle没有本地库，故而打包jar或者war都是需要发布到远程仓库和本地maven库的
1. 利用插件发布项目到本地库或远程库  


#### 利用gradle插件发布jar到本地maven或远程库

```
//在build.gradle中导入插件
apply plugin: 'maven-publish'

//然后配置插件
//利用publishing启动项目打包
publishing {
    //发布内容
    publications {
        //自命名"myPublish"为一个发布任务
        myPublish(MavenPublication) {
            //jar来源
            from components.java
        }
    }
    //配置仓库信息
    repositories {
       maven {
        //库名称
        name "myRepo"
        url "远程库的url/"
        }
    }
 
```

#### 直接利用gradle运行插件就完成
![image](https://img-blog.csdnimg.cn/20181101104640661.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L2phdmFfdHp4,size_16,color_FFFFFF,t_70)
publish是发布jar到远程maven的（如果是多个项目会全部发布） 

publishToMavenLocal是发布jar到本地的 （同上）

---------

如果在build.gradle中添加一个新的dependency,而这个dependency的版本或者name在maven repository中没有的话，使用gradle构建，他仍然会下载远程仓库中的jar包到自己的caches中。

Gradle already checks the local Maven repository for artifacts. If it finds an artifact with matching coordinates and checksum, it will not download it again. (For best results, make sure to use a recent Gradle version.)

这句话是从gradle论坛上找到的，gradle会先检查本地maven仓库，如果发现了对应的依赖库，不会再次下载。从语境中可以分析，如果不存在，那么gradle还是会去下载，并且存放到自己的caches目录中。
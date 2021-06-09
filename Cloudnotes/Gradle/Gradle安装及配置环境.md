#### 1.下载地址 https://services.gradle.org/distributions/

#### 2.环境变量配置

#### 3.配置Gradle仓库源

在Gradle安装目录下的 init.d 文件夹下，新建一个 init.gradle 文件，里面填写以下配置。

```
allprojects {
    repositories {
        maven { url 'file:///C:/Java/maven_repository'}
        mavenLocal()
        maven { name "Alibaba" ; url "https://maven.aliyun.com/repository/public" }
        maven { name "Bstek" ; url "http://nexus.bsdn.org/content/groups/public/" }
        mavenCentral()
    }

    buildscript { 
        repositories { 
            maven { name "Alibaba" ; url 'https://maven.aliyun.com/repository/public' }
            maven { name "Bstek" ; url 'http://nexus.bsdn.org/content/groups/public/' }
            maven { name "M2" ; url 'https://plugins.gradle.org/m2/' }
        }
    }
}
```

> repositories 中写的是获取依赖顺序。先是本地的 Maven 仓库路径；接着的 mavenLocal() 是获取 Maven 本地仓库的路径，应该是和第一条一样，但是不冲突；第三条和第四条是从国内和国外的网络上仓库获取；最后的 mavenCentral() 是从Apache提供的中央仓库获取 jar 包。
#### 4、配置Idea构建及gradle本地仓库地址
![image](https://img-blog.csdnimg.cn/20200921162222325.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl80MTYyNDMxOA==,size_16,color_FFFFFF,t_70#pic_center)
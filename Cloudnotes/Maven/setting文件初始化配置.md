用过Maven的开发人员应该知道Maven可以通过配置 conf文件夹下面的settings.xml文件来修改maven下载的包，默认是下在c盘的用户文件夹下的.m2中，日积月累.m2会越来越庞大，自然会影响windows的响应，所以一般我们都会将其移动到其他非系统盘下。具体是修改下面这段配置:

默认是：

```xml
<!-- localRepository
   | The path to the local repository maven will use to store artifacts.
   |
   | Default: ${user.home}/.m2/repository
  <localRepository>/path/to/local/repo</localRepository>
 -->
```
修改后:


```xml
<localRepository>D:/Maven/.m2/repo</localRepository>
```

这样就将下载的包下到D盘下的.m2中。

这里在补充一个很好的maven的远程地址即阿里云maven地址。

以前用过 开源中国的maven地址，后来该地址不能使用来后一度下不来很多包，要不就是非常慢，慢到心灰意冷。。。

后来发现了 国内maven的救星《阿里云maven》真是由衷的感谢啊！具体配置如下，同样是操作conf下面的settings.xml文件:

将原有被注释了的那段<mirrors>找到并全部替换成下面这样:

```xml
<mirrors>
    <mirror>
      <id>alimaven</id>
      <name>aliyun maven</name>
      <url>http://maven.aliyun.com/nexus/content/groups/public/</url>
      <mirrorOf>central</mirrorOf>        
    </mirror>
  </mirrors>
```

##### 如果需要代理才能上外网，则分别在IDEA和Maven的配置添加代理

```xml
<proxy>
      <id>optional</id>
      <active>true</active>
      <protocol>http</protocol>
      <username></username>
      <password></password>
      <host>xxx.xxx.x.x</host>
      <port>xxx</port>
      <nonProxyHosts>local.net|some.host.com</nonProxyHosts>
    </proxy>
```


















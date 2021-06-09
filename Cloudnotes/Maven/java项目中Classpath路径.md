1、src不是classpath, WEB-INF/classes,lib才是classpath，WEB-INF/ 是资源目录, 客户端不能直接访问。

2、WEB-INF/classes目录存放src目录java文件编译之后的class文件，xml、properties等资源配置文件，这是一个定位资源的入口。

3、引用classpath路径下的文件，只需在文件名前加classpath:

```
<param-value>classpath:applicationContext-*.xml</param-value> 
<!-- 引用其子目录下的文件,如 -->
<param-value>classpath:context/conf/controller.xml</param-value>
```
4、lib和classes同属classpath，两者的访问优先级为: lib>classes。

5、classpath 和 classpath* 区别：


```
classpath：只会到你的class路径中查找找文件;
classpath*：不仅包含class路径，还包括jar文件中(class路径)进行查找。
```

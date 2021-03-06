[toc]

## 一、Maven构建时的生命周期

maven默认的生命周期包括以下阶段（有关生命周期阶段的完整列表，请参阅[生命周期参考](https://maven.apache.org/guides/introduction/introduction-to-the-lifecycle.html#Lifecycle_Reference)）：

- `validate`  -  验证项目是否正确并且所有必要的信息都可用
- `compile `   -  编译项目的源代码
- `test`   - 使用合适的单元测试框架测试编译的源代码。这些测试不应该要求打包或部署代码
- `package` - 将编译后的代码打包成可分发的格式，例如 JAR。
- `verify`  -  对集成测试的结果进行任何检查，以确保满足质量标准
- `install`  -  将包安装到本地仓库中，作为本地其他项目的依赖项
- `deploy`  -  在构建环境中完成，将最终包复制到远程仓库以与其他开发人员和项目共享。

默认的生命周期按顺序执行以上所有阶段。首先验证项目，然后编译源代码，测试运行这些源代码，打包二进制文件（例如 jar），针对该项目运行集成测试包，验证集成测试，将经过验证的包安装到本地存储库，然后将安装的包部署到远程仓库。



### scope

- **compile：**compile是scope默认的值，需要参与项目编译、测试、运行阶段。打包时**被导入lib。**

- **provided：**参与编译和测试，打包时**不会被导入lib。**

- **test：**仅参与测试，打包时**不会被导入lib。**

- **system：**与provided相同，区别在于system不会从远程私库拉取，而是到本地指定仓库获取，需要指定**systemPath**属性，此属性不常用

- **runntime：**参与测试和运行阶段，打包时**被导入lib。**

- **import：**只能用在 `<dependencyManagement>`且 `type` 为 pom的 `dependency` 。作用是引入 target pom下的的所有`<dependencyManagement>`内容。若不使用 `import`则只管理该target pom的版本

  > Maven是单继承机制，也就是parent标签只能有一个。而POM文件的parent标签一般是继承spring-boot-starter-parent。
  >
  > 如果想继承其他的父类（比如：spring-cloud-dependencies）怎么办？
  >
  > import这个scope可以解决这个单继承的问题。

  项目中使用如下：

  - 指定 `parent` 为 `spring-boot-starter-parent`
  - 在`dependencyManagement`中指定Spring Cloud依赖，scope设置为import

  ![image-20220708104108247](images/image-20220708104108247.png)



### optional

- **true：**其他项目依赖此项目也不会进行传递，只能本项目使用。

  项目A --> 项目B --> 项目C，当B引入C使用 `<optional>true</optional>`，则A不会引入C

- **false：**默认为false



## 二、包路径

**使用IDEA工具进行本地编译时**

`classpath`的路径取决于项目的构建工具，是`gradle`还是`maven`。

`gradle`得到的classpath路径为`/build/classes`
`maven`得到的classpath路径为`/target/classes`

**当项目集成为一个文件包时，如JAR、WAR文件**

`classpath`的路径取决于打包的插件

`maven-shade-plugin`得到的classpath即为JAR包里的根路径，可通过classLoader.getResource进行验证

![image-20210710173331024](images/image-20210710173331024.png)

`spring-boot-maven-plugin`得到的classpath在JAR包的BOOT-INF/classes中，可通过classLoader.getResource进行验证

![image-20210710173509028](images/image-20210710173509028.png)






## 三、Maven插件

[详情查看官网文档](https://maven.apache.org/plugins/index.html#)

Maven 本质上是一个插件执行框架，所有的工作都是由插件完成的。maven插件分为构建和报告插件：

- **Build plugins（构建插件）**在构建期间执行，配置在POM文件的`<build/>`标签中
- **Reporting plugins（报告插件）**将在站点生成期间执行，配置在POM文件的`<reporting/>`标签中。因为报告插件的结果是生成站点的一部分，所以报告插件应该国际化和本地化。详情查看官网[插件本地化](https://maven.apache.org/plugins/localization.html)

### 1.Maven默认的核心插件

![image-20210709234230983](images/image-20210709234230983.png)

如图所示这些插件无需配置，为maven默认核心插件。若需要对相关属性进行修改可在<properties>标签中修改，也可在<build><plugins>中进行覆盖。

![image-20210709234450408](images/image-20210709234450408.png)

![image-20210709234527537](images/image-20210709234527537.png)

### 2.常用的打包插件

**制定打包文件的名称**

在<build>标签中使用finalName制定 JAR文件名称

```xml
<build>
      <finalName>p-test-tool</finalName>
</build>
```



**spring-boot-maven-plugin**

springboot项目可使用这个插件打包

- repackage

  最主要的是要添加 `repackage` goal，用来重新打包。

- layout

  layout 属性根据项目类型默认是：jar/war，具体可以设置以下几种：

  - JAR：可执行 jar 包；
  - WAR：可执行 war 包；
  - ZIP（别名：DIR）：和 jar 包相似，使用的是：PropertiesLauncher；
  - NONE：打包所有依赖项和项目资源。不绑定任何启动加载器

- classifier

  默认情况下只会打一个包，但是如果这个模块既是其他模板的依赖，自身又需要打成可执行的运行包，那就需要用这个标签另外指定一个别名包，如：

  - xxx.jar
  - xxx-exec-jar

```xml
<build>
  ...
  <plugins>
    ...
    <plugin>
      <groupId>org.springframework.boot</groupId>
      <artifactId>spring-boot-maven-plugin</artifactId>
      <version>2.2.6.RELEASE</version>
      <configuration>
        <mainClass>${start-class}</mainClass>
        <layout>jar</layout>
      </configuration>
      <executions>
        <execution>
          <goals>
            <goal>repackage</goal>
          </goals>
          <configuration>
        　  <classifier>exec</classifier>
        　</configuration>
        </execution>
      </executions>
    </plugin>
    ...
  </plugins>
  ...
</build>
```





**maven-shade-plugin**

将Java项目以及项目依赖的第三方包打包到一个 JAR文件

`mainClass` -指定程序入口main方法所在的类

`AppendingTransformer` - 聚合多个项目中，用于合并全路径相同的文件

```xml
<plugin>
    <groupId>org.apache.maven.plugins</groupId>
    <artifactId>maven-shade-plugin</artifactId>
    <version>1.4</version>
    <executions>
        <execution>
            <phase>package</phase>
            <goals>
                <goal>shade</goal>
            </goals>
            <configuration>
                <filters>
                    <filter>
                        <artifact>*:*</artifact>
                        <excludes>
                            <exclude>META-INF/*.SF</exclude>
                            <exclude>META-INF/*.DSA</exclude>
                            <exclude>META-INF/*.RSA</exclude>
                        </excludes>
                    </filter>
                </filters>
                <transformers>
                    <transformer implementation="org.apache.maven.plugins.shade.resource.ManifestResourceTransformer">
                        <!-- 程序入口main方法所在的类 -->
                        <mainClass>com.tangdi.MyApplication</mainClass>
                    </transformer>
                    <!-- 合并META-INF/spring.handlers -->
                    <transformer implementation="org.apache.maven.plugins.shade.resource.AppendingTransformer">
                        <resource>META-INF/spring.handlers</resource>
                    </transformer>
                    <!-- 合并META-INF/spring.schemas -->
                    <transformer implementation="org.apache.maven.plugins.shade.resource.AppendingTransformer">
                        <resource>META-INF/spring.schemas</resource>
                    </transformer>
                </transformers>
            </configuration>
        </execution>
    </executions>
</plugin>
```

**maven-war-plugin**

```xml
<build>
    <plugins>
        <plugin>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-maven-plugin</artifactId>
        </plugin>
        <plugin>
            <groupId>org.apache.maven.plugins</groupId>
            <artifactId>maven-war-plugin</artifactId>
            <configuration>
                <warSourceExcludes>src/main/resources/**</warSourceExcludes>
                <warName>LoginProject</warName>
            </configuration>
        </plugin>
    </plugins>
</build>
```



### 3.项目编译插件

目前默认`source`设置为`1.6`，默认`target`设置为`1.6`，与运行 Maven 的 JDK 无关

```xml
<plugin>
    <groupId>org.apache.maven.plugins</groupId>
    <artifactId>maven-compiler-plugin</artifactId>
    <version>3.6.0</version>
    <configuration>
        <source>1.8</source>
        <target>1.8</target>
    </configuration>
</plugin>
```

### 4.web服务插件

可用于远程部署Java Web项目

```xml
<plugin>
    <groupId>org.apache.tomcat.maven</groupId>
    <artifactId>tomcat7-maven-plugin</artifactId>
    <version>2.2</version>
    <configuration>
        <port>8080</port>
        <path>/</path>
        <url>http://59.110.162.178:8080/manager/text</url>
        <username>linjinbin</username>
        <password>linjinbin</password>
    </configuration>
</plugin>
```


# 配置认证信息
在 Maven ==settings.xml== 中添加 Nexus 认证信息(==servers== 节点下)：

```
<server>
  <id>nexus-releases</id>
  <username>admin</username>
  <password>admin123</password>
</server>

<server>
  <id>nexus-snapshots</id>
  <username>admin</username>
  <password>admin123</password>
</server>
```

# Snapshots 与 Releases 的区别

- nexus-releases: 用于发布 Release 版本
- nexus-snapshots: 用于发布 Snapshot 版本（快照版）
- 在项目 ==pom.xml== 中设置的版本号添加 ==SNAPSHOT== 标识的都会发布为 ==SNAPSHOT== 版本，没有 SNAPSHOT 标识的都会发布为 ==RELEASE== 版本。
- ==SNAPSHOT== 版本会自动加一个时间作为标识，如：==1.0.0-SNAPSHOT== 发布后为变成 ==1.0.0-SNAPSHOT-20180522.123456-1.jar==

# 配置自动化部署

在 ==pom.xml== 中添加如下代码：

==***此为部署项目进私服仓库配置***==
```
<distributionManagement>  
  <repository>  
    <id>nexus-releases</id>  
    <name>Nexus Release Repository</name>  
    <url>http://192.168.243.128:8081/repository/maven-releases/</url>
  </repository>  
  <snapshotRepository>  
    <id>nexus-snapshots</id>  
    <name>Nexus Snapshot Repository</name>  
    <url>http://192.168.243.128:8081/repository/maven-snapshots/</url>
  </snapshotRepository>  
</distributionManagement>
```
###### 注意事项：

- ID 名称必须要与 settings.xml 中 Servers 配置的 ID 名称保持一致。
- 项目版本号中有 SNAPSHOT 标识的，会发布到 Nexus Snapshots Repository, 否则发布到 Nexus Release Repository，并根据 ID 去匹配授权账号。


# 部署到仓库

```
mvn clean package deploy -Dmaven.test.skip=true
```

# 上传第三方 JAR 包

Nexus 3.0 不支持页面上传，可使用 maven 命令：

命令在cmd输入

***==此为上传第三方jar包进私服仓库配置==***

```
# 如第三方JAR包：kaptcha-2.3.jar
mvn deploy:deploy-file
 -DgroupId=com.google.code.kaptcha
 -DartifactId=kaptcha -Dversion=2.3
 -Dpackaging=jar -Dfile=D:\MyWorkspace\kaptcha-2.3.jar
 -Durl=http://192.168.243.128:8081/repository/maven-releases/
 -DrepositoryId=nexus-releases
```
###### 注意事项：

- 建议在上传第三方 JAR 包时，创建单独的第三方 JAR 包管理仓库，便于管理有维护。（maven-3rd）
- -DrepositoryId=nexus-releases 对应的是 settings.xml 中 Servers 配置的 ID 名称。（授权）


# 配置代理仓库
***==此为项目到本地仓库到此私服仓库下载配置==***

```
<repositories>
    <repository>
        <id>nexus</id>
        <name>Nexus Repository</name>
        <url>http://192.168.243.128:8081/repository/maven-public/</url>
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
        <url>http://192.168.243.128:8081/repository/maven-public/</url>
        <snapshots>
            <enabled>true</enabled>
        </snapshots>
        <releases>
            <enabled>true</enabled>
        </releases>
    </pluginRepository>
</pluginRepositories>
```

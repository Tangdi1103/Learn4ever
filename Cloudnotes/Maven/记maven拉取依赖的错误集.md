#### 1.项目编译时期，出现Faild to .... jar/pom.lastUpdated，pom/jar.part.lock(目录不存在)

在打包机的maven仓库，查看是否依赖包名有误

#### 2.引入依赖jar/pom总是失败，出现.lastUpdated文件时
首先查看.lastUpdate文件，查看错误信息。可以得知某个在某个私库中拉取失败。
- 方法一：在该仓库上传jar/pom
- 方法二：查看_remote.repositories文件，手动修改远程仓库标识，比如netty-bom-4.1.45.Final.pom>nexus=，nexus为pom.xml或setting.xml配置中的远程仓库id
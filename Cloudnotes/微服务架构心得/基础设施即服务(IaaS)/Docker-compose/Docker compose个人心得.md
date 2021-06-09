# 简介
---简单理解，docker

==Docker Compose== 是==Docker==官方编排（Orchestration）项目之一，负责快速的部署分布式应用。

==Compose== 中有两个重要的概念：

- 服务 (==service==)：一个应用的容器，实际上可以包括若干运行相同镜像的容器实例。
- 项目 (==project==)：由一组关联的应用容器组成的一个完整业务单元，在 docker-compose.yml 文件中定义。


==Compose== 的默认管理对象是项目，通过子命令对项目中的一组容器进行便捷地生命周期管理。

==Compose== 项目由 Python 编写，实现上调用了 Docker 服务提供的 API 来对容器进行管理。因此，只要所操作的平台支持 Docker API，就可以在其上利用 ==Compose== 来进行编排管理。


---


# 安装
使用二进制包安装
在 Linux 上的也安装十分简单，从 官方 ++GitHub Release++ 处直接下载编译好的二进制文件即可。

例如，在 Linux 64 位系统上***直接下载对应的二进制包***。

```
$ sudo curl -L https://github.com/docker/compose/releases/download/1.22.0/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose
$ sudo chmod +x /usr/local/bin/docker-compose
```

**安装完后，*赋予权限***

```
$ chmod +x /usr/local/bin/docker-compose
```

***编写==docker-compose.yml==文件***

```
<--请见配置yaml文件-!>
```


***运行* compose 项目**

```
$ docker-compose up
```


***卸载***

如果是二进制包方式安装的，删除二进制文件即可。

```
$ sudo rm /usr/local/bin/docker-compose
```



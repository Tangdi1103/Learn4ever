# 数据卷
==数据卷== 是一个可供一个或多个容器使用的特殊目录，它绕过 UFS，可以提供很多有用的特性：

- ==数据卷== 可以在容器之间共享和重用
- 对 ==数据卷== 的修改会立马生效
- 对 ==数据卷== 的更新，不会影响镜像
- ==数据卷== 默认会一直存在，即使容器被删除

##### 创建一个数据卷


```
$ docker volume create my-vol
```

##### 启动一个挂载数据卷的容器

在用 ==docker run== 命令的时候，使用 ==--mount== 标记来将 数据卷 挂载到容器里。在一次 ==docker run== 中可以挂载多个 数据卷。

下面创建一个名为 ==web== 的容器，并加载一个 数据卷 到容器的 ==/webapp== 目录。


```
$ docker run -d -P \
    --name web \
    # -v my-vol:/wepapp \
    --mount source=my-vol,target=/webapp \
    training/webapp \
    python app.py
```

##### 查看数据卷的具体信息

查看 web 容器的信息
```
$ docker inspect web
```
##### 删除数据卷


```
$ docker volume rm my-vol
```


---


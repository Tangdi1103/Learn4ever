# 守护态运行

更多的时候，需要让 Docker 在后台运行而不是直接把执行命令的结果输出在当前宿主机下。此时，可以通过添加 -d 参数来实现。

如果使用了 ==-d== 参数运行容器。


```
$ docker run -d ubuntu:17.10 /bin/sh -c "while true; do echo hello world; sleep 1; done"
77b2dc01fe0f3f1265df143181e7b9af5e05279a884f4776ee75350ea9d8017a
```

此时容器会在后台运行并不会把输出的结果 (STDOUT) 打印到宿主机上面(输出结果可以用 ==docker container logs== 查看)。

```
$ docker container logs [container ID or NAMES]
hello world
hello world
hello world
. . .
```


---


# 查看 Docker 版本

```
docker version
```

---

# 从 Docker 文件构建 Docker 映像

```
docker build -t image-name docker-file-location
```

---

# 运行 Docker 映像

```
docker run -d image-name
```

---
# 查看可用的 Docker 映像

```
docker images
```
---
# 查看最近的运行容器

```
docker ps -l
```
---
# 查看所有正在运行的容器

```
docker ps -a
```
---
# 停止运行容器

```
docker stop container_id
```
---
# 删除一个镜像

```
docker rmi image-name
```
---
# 删除所有镜像

```
docker rmi $(docker images -q)
```
---
# 强制删除所有镜像

```
docker rmi -r $(docker images -q)
```
---
# 删除所有为 <none> 的镜像

```
docker rmi $(docker images -q -f dangling=true)
```
---
# 删除所有容器

```
docker rm $(docker ps -a -q)
```
---
# 进入 Docker 容器

```
docker exec -it container-id /bin/bash
```
---
# 查看所有数据卷

```
docker volume ls
```
---
# 删除指定数据卷

```
docker volume rm [volume_name]
```
---
# 删除所有未关联的数据卷

```
docker volume rm $(docker volume ls -qf dangling=true)
```
---
# 从主机复制文件到容器

```
sudo docker cp host_path containerID:container_path
```
---
# 从容器复制文件到主机

```
sudo docker cp containerID:container_path host_path
```

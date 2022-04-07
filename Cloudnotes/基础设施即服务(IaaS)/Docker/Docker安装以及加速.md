# centos8 安装 Docker




```
// 安装依赖
yum install -y yum-utils device-mapper-persistent-data lvm2

// 添加yum仓库
yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
yum makecache

安装docker-ce
dnf -y  install docker-ce --nobest

// 启动 Docker CE
$ sudo systemctl enable docker
$ sudo systemctl start docker

// 添加当前用户到docker group
usermod -aG docker $USER
newgrp docker
```



### 测试 Docker 是否安装正确

```
systemctl status  docker
```

### 运行hello-world
```
$ docker run hello-world

Unable to find image 'hello-world:latest' locally
latest: Pulling from library/hello-world
ca4f61b1923c: Pull complete
Digest: sha256:be0cd392e45be79ffeffa6b05338b98ebb16c87b255f48e297ec7f98e123905c
Status: Downloaded newer image for hello-world:latest

Hello from Docker!
This message shows that your installation appears to be working correctly.

To generate this message, Docker took the following steps:
 1. The Docker client contacted the Docker daemon.
 2. The Docker daemon pulled the "hello-world" image from the Docker Hub.
    (amd64)
 3. The Docker daemon created a new container from that image which runs the
    executable that produces the output you are currently reading.
 4. The Docker daemon streamed that output to the Docker client, which sent it
    to your terminal.

To try something more ambitious, you can run an Ubuntu container with:
 $ docker run -it ubuntu bash

Share images, automate workflows, and more with a free Docker ID:
 https://cloud.docker.com/

For more examples and ideas, visit:
 https://docs.docker.com/engine/userguide/
```
### 镜像加速

###### 国内从 Docker Hub 拉取镜像有时会遇到困难，此时可以配置镜像加速器。Docker 官方和国内很多云服务商都提供了国内加速器服务，例如：

- Docker 官方提供的中国 registry mirror
- 阿里云加速器
- DaoCloud 加速器
- 

**Ubuntu 14.04、Debian 7 Wheezy**

对于使用 upstart 的系统而言，编辑 ==/etc/default/docker== 文件，在其中的 ==DOCKER_OPTS== 中配置加速器地址：

```
DOCKER_OPTS="--registry-mirror=https://registry.docker-cn.com"
```
重新启动服务。

```
sudo service docker restart
```



**Ubuntu 16.04+、Debian 8+、CentOS 7**
对于使用 systemd 的系统，请在 ==/etc/docker/daemon.json== 中写入如下内容（如果文件不存在请新建该文件）


```
{
  "registry-mirrors": [
    "https://registry.docker-cn.com"
  ]
}
```
###### 注意，一定要保证该文件符合 json 规范，否则 Docker 将不能启动。
重新启动服务。

```
sudo systemctl daemon-reload
sudo systemctl restart docker
```
**检查加速器是否生效**

在命令行执行 ==docker info==，如果从结果中看到了如下内容，说明配置成功。

```
Registry Mirrors:
 https://registry.docker-cn.com/
```

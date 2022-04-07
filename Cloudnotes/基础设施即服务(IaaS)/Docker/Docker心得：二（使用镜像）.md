# 获取镜像
++Docker Hub++ 上有大量的高质量的镜像可以用，这里我们就说一下怎么获取这些镜像。

从 Docker 镜像仓库获取镜像的命令是 ==docker pull==。其命令格式为：


```
docker pull [选项] [Docker Registry 地址[:端口号]/]仓库名[:标签]
```
- Docker 镜像仓库地址：地址的格式一般是 <域名/IP>[:端口号]。默认地址是 Docker Hub。
- 仓库名：如之前所说，这里的仓库名是两段式名称，即 <用户名>/<软件名>。对于 Docker Hub，如果不给出用户名，则默认为 library，也就是官方镜像。

比如：


```
$ docker pull ubuntu:16.04
16.04: Pulling from library/ubuntu
bf5d46315322: Pull complete
9f13e0ac480c: Pull complete
e8988b5b3097: Pull complete
40af181810e7: Pull complete
e6f7c7e5c03e: Pull complete
Digest: sha256:147913621d9cdea08853f6ba9116c2e27a3ceffecf3b492983ae97c3d643fbbe
Status: Downloaded newer image for ubuntu:16.04
```
上面的命令中没有给出 Docker 镜像仓库地址，因此将会从 Docker Hub 获取镜像。而镜像名称是 ==ubuntu:16.04==，因此将会获取官方镜像 ==library/ubuntu 仓库==中标签为 ==16.04== 的镜像。

### 运行
有了镜像后，我们就能够以这个镜像为基础启动并运行一个容器，启动里面的 bash 并且以交互式操作的话，可以执行下面的命令。


```
$ docker run -it --rm \
    ubuntu:16.04 \
    bash

root@e7009c6ce357:/# cat /etc/os-release
NAME="Ubuntu"
VERSION="16.04.4 LTS, Trusty Tahr"
ID=ubuntu
ID_LIKE=debian
PRETTY_NAME="Ubuntu 16.04.4 LTS"
VERSION_ID="16.04"
HOME_URL="http://www.ubuntu.com/"
SUPPORT_URL="http://help.ubuntu.com/"
BUG_REPORT_URL="http://bugs.launchpad.net/ubuntu/"
```

==docker run== 就是运行容器的命令，我们这里简要的说明一下上面用到的参数。

- ==--it==：这是两个参数，一个是 -i：交互式操作，一个是 -t 终端。我们这里打算进入 bash 执行一些命令并查看返回结果，因此我们需要交互式终端。
- ==--rm==：这个参数是说容器退出后随之将其删除。默认情况下，为了排障需求，退出的容器并不会立即删除，除非手动 docker rm。我们这里只是随便执行个命令，看看结果，不需要排障和保留结果，因此使用 --rm 可以避免浪费空间。
- ==ubuntu:16.04==：这是指用 ubuntu:16.04 镜像为基础来启动容器。
- ==bash==：放在镜像名后的是命令，这里我们希望有个交互式 Shell，因此用的是 bash。
- 

### 退出
通过 ==exit== 退出了这个容器。

### 删除
根据ID删除
```
docker rmi 镜像ID
```

# 使用 Dockerfile 定制镜像
后续添加

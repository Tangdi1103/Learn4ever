Ubuntu Server 16.04 LTS 版本，属于 systemd 系统，需要在 /etc/docker/daemon.json 中增加如下内容（如果文件不存在请新建该文件）


```
{
  "registry-mirrors": [
    "https://registry.docker-cn.com"
  ],
  "insecure-registries": [
    "ip:5000"
  ]
}
```

### 重新启动服务

```
$ sudo systemctl daemon-reload
$ sudo systemctl restart docker
```

### 检查客户端配置是否生效

使用 ==docker info== 命令手动检查，如果从配置中看到如下内容，说明配置成功（192.168.75.133 为教学案例 IP）


```
Insecure Registries:
 192.168.75.133:5000
 127.0.0.0/8
```


### 测试镜像上传


```
## 拉取一个镜像
docker pull nginx

## 查看全部镜像
docker images

## 标记本地镜像并指向目标仓库（ip:port/image_name:tag，该格式为标记版本号）
docker tag nginx 192.168.75.133:5000/nginx

## 提交镜像到仓库
docker push 192.168.75.133:5000/nginx
```
### 查看全部镜像

```
curl -XGET http://192.168.75.133:5000/v2/_catalog
```
### 查看指定镜像

```
curl -XGET http://192.168.75.133:5000/v2/nginx/tags/list
```
### 测试拉取镜像
###### 先删除镜像

```
docker rmi nginx
docker rmi 192.168.75.133:5000/nginx
```
###### 再拉取镜像


```
docker pull 192.168.75.133:5000/nginx
```

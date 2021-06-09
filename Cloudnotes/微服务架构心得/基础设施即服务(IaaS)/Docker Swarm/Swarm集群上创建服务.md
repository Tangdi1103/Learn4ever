##### 查看原有网络

```
docker network ls
```

swarm集群创建以后，默认已有一个名为ingress的overlay 网络,默认在swarm里使用

##### 查看网络信息

```
docker network inspect ingress
```


##### 创建新的Swarm网络--tangdi


```
docker network create --subnet=10.0.9.0/24 --driver overlay tangdi
```
--subnet 用于指定创建overlay网络的网段，也可以省略此参数

##### 在网络上运行容器


```
docker service create --name idoall-org-test-ping（实例名） --replicas 3 -p 26000:26000 --network=tangdi alpine ping baidu.com（镜像）
```

##### 查看服务
```
docker service ls
```

##### 查看服务实例

```
docker service ps 实例名
```

##### 查看服务详细信息

```
docker service inspect 实例名
```

##### 更新服

```
docker service update --image registry.cntv.net/heqin/tvtime-php:v0.84xidan --log-driver=syslog time-php
```

##### 删除服务

```
docker service rm 实例名
```



##### 扩展(Scaling)应用

假设在程序运行的时候，发现资源不够用，我们可以使用scale进行扩展，现在有3个实例，我们更改为4个实例

```
docker service scale idoall-org-test-ping=4
```

##### 对service服务进行指定运行（默认一个实例）

不管你的实例是几个，是由swarm自动调度定义执行在某个节点上。我们可以通过在创建service的时候可以使用--constraints参数，来对service进行限制，例如我们指定一个服务在c4上运行：

constraint约束可为!=
```
docker service create \
--network tangdi \
--name idoall-org（容器名） \
--constraint 'node.hostname==c4' \
-p 26000:26000 \
mc-regcenter(镜像)
```


##### 由于各地的网络不同，下载镜像可能有些慢，可以使用下面的命令，对命名为idoall-org的镜像进行监控

```
watch docker service ps idoall-org
```

##### 测试dokcer swarm自带的负载均衡

使用--mode global参数，在每个节点上创建一个web服务

```
docker service create --name whoami --mode global -p 8000:8000 jwilder/whoami
```

```
docker service ps whoami
```

在任意一台机器上执行以下命令，可以发现，每次获取到的都是不同的值，超过4次以后，会继续轮询到第1台机器

```
curl $(hostname --all-ip-addresses | awk '{print $1}'):8000
```

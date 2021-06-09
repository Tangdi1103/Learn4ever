假设：

manager节点：192.168.0.129

woker节点：192.168.0.21

所有节点的Docker版本需一致

##### 1.初始化swarm，在manager（或leader）机器上执行swarm init命令


在manager节点上输入命令
```
docker swarm init --advertise-addr 192.168.0.129
```

##### 2.创捷Swarm集群后，查询加入管理者指令和工作者指令

```
docker swarm join-token manager
```

```
docker swarm join-token worker
```

##### 3.查看节点swarm状态

```
docker info
```

##### 4.查看swarm所有节点

```
docker node ls
```

##### 5.node节点加入swarm集群，请查询指令

##### 6.节点离开集群

首先在需要删除的节点上执行，第一步是down


```
docker swarm leave
```

强制离开
```
docker swarm leave --force
```



然后在manager节点上执行


```
docker node rm --force 4lbdwmdsv7brjlyz9p3jx1kd6 #node节点id
```

##### 7.更新Swarm集群节点

在manager节点上执行


```
docker swarm update
```


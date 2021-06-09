![image](https://note.youdao.com/yws/public/resource/c5be5802daf0385d18fbdfde57d959e9/xmlnote/51EB7F3F94C546BBB90CA34024D02D65/719)

![image](https://note.youdao.com/yws/public/resource/c5be5802daf0385d18fbdfde57d959e9/xmlnote/E344C65DBA324E62BA5E7BCC4CF8B2AF/727)

##### linux系统目录的复制命令

```
cp -r 目标目录   目的目录
```

##### 查找文件
which xxx

##### 文件复制

```
cp 目标文件  目的目录
```

##### 查看所有端口和PID
```
netstat -ano
```

##### 将项目结构以文档树结构输出

```
tree  >>	D:/tree.txt 只有文件夹
tree /f >>	D:/tree.txt 包括文件夹和文件
```

##### 查看防火墙状态

```
firewall-cmd --state

```

##### 停止firewall

```
systemctl stop firewalld.service

```

##### 禁止firewall开机启动

```
systemctl disable firewalld.service 

```

##### 查看所有java进程
```
ps -ef |grep java
```


##### 查看监听(Listen)的端口


```
netstat -lntp
```


##### 检查端口被哪个进程占用


```
netstat -lnp|grep 8080
```

##### centos7中的防火墙改成了firewall，使用iptables无作用，开放端口的方法如下：

```
firewall-cmd --zone=public --add-port=80/tcp --permanent

//命令含义：
--zone 作用域
 
--add-port=80/tcp 添加端口，格式为：端口/通讯协议
 
--permanent 永久生效
```

##### 重启防火墙
```
firewall-cmd --reload
```

##### 查看端口是否开放

```
firewall-cmd --query-port=26000/tcp
```

##### 查看开放得端口

```
firewall-cmd --list-port
```

---
##### 超级拷贝

```
本地拷file到远程
scp -r aaa 10.4.6.132:/app/war
scp -P 22 file root@ip:/xx/xx

远程file拷到本地
scp root@ip:file .
```



##### 查看日志

```
tail -f /var/log/message
```

##### 程序添加selinux权限：（举例keepalived）

```
#查找程序在Selinux中对应的名称
cat /var/log/audit/audit.log | grep keepalived       

yum install policycoreutils-python

#keepalived_t是keepalived在Selinux中对应的名称
semodule -i keepalived_t            
or
semanage permissive -a keepalived_t
setsebool -P zabbix_can_network on
```

##### 查找软件名/路径
```
rpm -qa | grep 软件名 
rpm -ql 软件名 
卸载软件
rpm -e --nodeps 软件名 
```

##### 查看磁盘空间使用情况
```
df -hT 
```

##### 查看当前目录下各个文件大小
```
du -sh * 
```

##### 查看内存使用情况
```
free -m 
```

##### 查看nginx状态及配置文件路径
```
nginx -t
```

#### 重启nginx

```
nginx -s reload
```
#### 日志文件查找
查找xxx关键字前后10行

A后，B前，C前后

cat xxx.log | grep ‘xxx’ -C 10


#### vim/gvim使用之跳到指定行

```
页翻转可以直接使用PgUp和PgDn
向前滚动一屏：Ctrl+F
向后滚动一屏：Ctrl+B
向前滚动半屏：Ctrl+D（向下）
向后滚动半屏：Ctrl+U（向上）
向下滚动一行，保持当前光标不动：Ctrl+E
向上滚动一行，保持当前光标不动：Ctrl+Y
命令行输入“ : n ” 然后回车
跳到文件第一行：gg （两个小写的G）
跳到文件最后一行：shift+g （也就是G）
```
#### top指令排序及属性排序

```
shift+< 或 shift+> 切换排序属性
shift+p 排序
```






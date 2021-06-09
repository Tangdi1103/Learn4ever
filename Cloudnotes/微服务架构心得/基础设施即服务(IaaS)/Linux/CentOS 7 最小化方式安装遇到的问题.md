在虚拟机中以最小化方式安装centos7，后无法上网，因为centos7默认网卡未激活。

而且在sbin目录中没有ifconfig文件，这是因为centos7已经不使用 ifconfig命令了，已经用ip命令代替； 

并且网卡名称也不是eth0了，而是改成eno16777736了。 

解决ifconfig不可用：ip addr 即查看分配网卡情况。

激活网卡：在文件 /etc/sysconfig/network-scripts/ifcfg-enp0s3 中 

进入编辑模式，将 ONBOOT=no 改为 ONBOOT=yes，就OK

保存后重启网卡： service network restart 

安装net-tools

```
yum install net-tools
```


此时就可以上网了。（如果不知怎样判断能否上网，ping 一下网址就可以，就是这么简单，例如命令：ping www.baidu.com）

这样yum，wget等等都可以用啦
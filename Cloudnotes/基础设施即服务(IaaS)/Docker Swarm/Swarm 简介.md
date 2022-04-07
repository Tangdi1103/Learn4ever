####  前言
 在docker1.12版本之前，众所周知dokcer本身只能单机上运行，而集群则要依赖mesos、kubernetes、swarm等集群管理方案。其中swarm是docker公司自己的容器集群管理工具，在当时的热度还是低于前两者。docker1.12.0版本发布中，Docker公司出于战略眼光，将swarm集成到docker-engine中，使docker内置了集群解决方案。于是swarm这个“亲儿子”的江湖地位迅速提升，在docker集群方案中与mesos，k8s形成三足鼎立之势，在未来则大有赶超之势。
  
####  简介

Swarm是一套较为简单的工具，用以管理Docker集群，使得Docker集群暴露给用户时相当于一个虚拟的整体。Swarm使用标准的Docker API接口作为其前端访问入口，换言之，各种形式的Docker Client(dockerclient in go, docker_py, docker等)均可以直接与Swarm通信，Swarm几乎全部用Go语言来完成开发。

  swarm是基于docker平台实现的集群技术，他可以通过几条简单的指令快速的创建一个docker集群，接着在集群的共享网络上部署应用，最终实现分布式的服务。
  
  相比起zookeeper等集群管理框架来说，swarm显得十分轻量，作为一个工具，它把节点的加入、管理、发现等复杂的操作都浓缩为几句简单的命令，并且具有自动发现节点和调度的算法，还支持自定制。虽然swarm技术现在还不是非常成熟，但其威力已经可见一般。
  
  
  
####   特点
1. ▲对外以Docker API接口呈现，这样带来的好处是，如果现有系统使用Docker Engine，则可以平滑将Docker Engine切到Swarm上，无需改动现有系统。
1.  ▲Swarm对用户来说，之前使用Docker的经验可以继承过来。非常容易上手，学习成本和二次开发成本都比较低。同时Swarm本身专注于Docker集群管理，非常轻量，占用资源也非常少。 *“Batteries included but swappable”，简单说，就是插件化机制，Swarm中的各个模块都抽象出了API，可以根据自己一些特点进行定制实现。
1.  ▲Swarm自身对Docker命令参数支持的比较完善，Swarm目前与Docker是同步发布的。Docker的新功能，都会第一时间在Swarm中体现。

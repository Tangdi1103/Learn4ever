[toc]

### 1. Mycat安装

- 安装jdk

- 下载Mycat-server工具包

- 解压Mycat工具包

  ```shell
  tar -zxvf Mycat-server-1.6.7.5-release-20200410174409-linux.tar.gz
  ```

- 进入mycat/bin，启动Mycat

  ```shell
  启动命令：./mycat start 
  停止命令：./mycat stop 
  重启命令：./mycat restart 
  查看状态：./mycat status
  ```

- 访问Mycat

  ```shell
  mysql -uroot -proot -h127.0.0.1 -P8066
  ```








### 2. 分库分表

#### 2.1 在rule.xml配置Mycat分库分表

```xml
<mycat:rule xmlns:mycat="http://io.mycat/">
    <tableRule name="b_order_rule">
        <rule>
            <columns>company_id</columns>
            <algorithm>partitionByOrderFunc</algorithm>
        </rule>
    </tableRule>
    <!-- 路由函数定义 -->
    <function name="partitionByOrderFunc" class="io.mycat.route.function.PartitionByMod">
        <property name="count">2</property>
    </function>
</mycat:rule>
```





#### 2.2 Mycat常用分片规则

- 时间类：按天分片、自然分片、单月小时分片

- 哈希类：Hash固定分片、日期范围Hash分片、截取数字Hash求模范围分片、截取数字Hash分片、一致性Hash分片

- 取模类：取模分片、取模范围分片、范围求模分片

- 其他类：枚举分片、范围约定分片、应用指定分片、冷热数据分片





#### 2.3 Mycat常用分片配置示例

##### 2.3.1 自动分片

```xml
<tableRule name="auto-sharding-long"> 
    <rule> 
        <columns>id</columns> 
        <algorithm>rang-long</algorithm> 
    </rule> 
</tableRule>
<function name="rang-long" class="io.mycat.route.function.AutoPartitionByLong"> 
    <property name="mapFile">autopartition-long.txt</property> 
</function>
```

autopartition-long.txt文件内容如下：

```tex
# range start-end ,data node index 
# K=1000,M=10000. 
0-500M=0 
500M-1000M=1 
1000M-1500M=2
```



##### 2.3.2 枚举分片

把数据分类存储

```xml
<tableRule name="sharding-by-intfile"> 
    <rule> 
        <columns>sharding_id</columns> 
        <algorithm>hash-int</algorithm>
    </rule> 
</tableRule> 
<function name="hash-int" class="io.mycat.route.function.PartitionByFileMap"> 
    <property name="mapFile">partition-hash-int.txt</property> 
    <!-- 找不到分片时设置容错规则，把数据插入到默认分片0里面 --> 
    <property name="defaultNode">0</property> 
</function>
```

partition-hash-int.txt文件内容如下：

```tex
10000=0 
10010=1
```



##### 2.3.3 取模分片

根据分片字段值 % 分片数

```xml
<tableRule name="mod-long"> 
    <rule>
        <columns>id</columns> 
        <algorithm>mod-long</algorithm> 
    </rule> 
</tableRule> 
<function name="mod-long" class="io.mycat.route.function.PartitionByMod"> 
    <!--分片数 --> 
    <property name="count">3</property> 
</function>
```



##### 2.3.4 冷热数据分片

根据日期查询日志数据冷热数据分布 ，最近 n 个月的到实时交易库查询，超过 n 个月的按照 m 天分片

```xml
<tableRule name="sharding-by-date">
    <rule> 
        <columns>create_time</columns> 
        <algorithm>sharding-by-hotdate</algorithm> 
    </rule> 
</tableRule>
<function name="sharding-by-hotdate" class="org.opencloudb.route.function.PartitionByHotDate"> 
    <!-- 定义日期格式 --> 
    <property name="dateFormat">yyyy-MM-dd</property> 
    <!-- 热库存储多少天数据 --> 
    <property name="sLastDay">30</property> 
    <!-- 超过热库期限的数据按照多少天来分片 --> 
    <property name="sPartionDay">30</property> 
</function>
```



##### 2.3.5 一致性哈希分片

```xml
<tableRule name="sharding-by-murmur">
    <rule>
        <columns>id</columns>
        <algorithm>murmur</algorithm>
    </rule>
</tableRule>
<function name="murmur" class="io.mycat.route.function.PartitionByMurmurHash">
    <property name="seed">0</property><!-- 默认是0 -->
    <property name="count">2</property><!-- 要分片的数据库节点数量，必须指定，否则没法分片 -->
    <property name="virtualBucketTimes">160</property><!-- 一个实际的数据库节点被映射为这么多虚拟节点，默认是160倍，也就是虚拟节点数是物理节点数的160倍 -->
    <!-- <property name="weightMapFile">weightMapFile</property> 节点的权重，没有指定权重的节点默认是1。以properties文件的格式填写，以从0开始到count-1的整数值也就是节点索引为key，以节点权重值为值。所有权重值必须是正整数，否则以1代替 -->
    <!-- <property name="bucketMapPath">/etc/mycat/bucketMapPath</property>
   用于测试时观察各物理节点与虚拟节点的分布情况，如果指定了这个属性，会把虚拟节点的murmur hash值与物理节点的映射按行输出到这个文件，没有默认值，如果不指定，就不会输出任何东西 -->
</function>
```







### 3. 读写分离

在schema.xml文件中配置Mycat读写分离。使用前需要搭建MySQL主从架构，并实现主从复制，Mycat不负数据同步问题

balance参数：

- 0 ： 所有读操作都发送到当前可用的writeHost

- 1 ：所有读操作都随机发送到readHost和stand by writeHost

writeType参数：

- 0 ： 所有写操作都发送到可用的writeHost

- 1 ：所有写操作都随机发送到readHost

#### 3.1 方式一：

```xml
<dataHost name="localhost1" maxCon="1000" minCon="10" balance="1" writeType="0" dbType="mysql" dbDriver="native"> 
    <heartbeat>select user()</heartbeat> 
    <!-- can have multi write hosts --> 
    <writeHost host="M1" url="localhost:3306" user="root" password="123456"> 
        <readHost host="S1" url="localhost:3307" user="root" password="123456" 
                  weight="1"/> 
    </writeHost> 
</dataHost>
```

#### 3.2 方式二：

```xml
<dataHost name="localhost1" maxCon="1000" minCon="10" balance="1" writeType="0" dbType="mysql" dbDriver="native"> 
    <heartbeat>select user()</heartbeat> 
    <!-- can have multi write hosts --> 
    <writeHost host="M1" url="localhost:3306" user="root" password="123456"> </writeHost> 
    <writeHost host="S1" url="localhost:3307" user="root" password="123456"> </writeHost> </dataHost>
```

以上两种取模第一种当写挂了读不可用，第二种可以继续使用，事务内部的一切操作都会走写节点，所以读操作不要加事务，如果读延时较大，使用根据主从延时切换的读写分离，或者强制走写节点







### 4. 强制路由

一个查询 SQL 语句以/* !mycat * /注解来确定其是走读节点还是写节点。

```
强制走从: 
/*!mycat:db_type=slave*/ select * from travelrecord //有效 
/*#mycat:db_type=slave*/ select * from travelrecord

强制走写: 
/*!mycat:db_type=master*/ select * from travelrecord //有效 
/*#mycat:db_type=slave*/ select * from travelrecord
```

1.6 以后Mycat除了支持db_type注解以外，还有其他注解，如下：

```
/*!mycat:sql=sql*/ 	指定真正执行的SQL 
/*!mycat:schema=schema1*/ 	指定走那个schema 
/*!mycat:datanode=dn1*/ 	指定sql要运行的节点
/*!mycat:catlet=io.mycat.catlets.ShareJoin*/   通过catlet支持跨分片复杂SQL实现以及存储过程支持等
```







### 5. 主从延时切换

##### 5.1 Mycat1.4开始支持 MySQL 主从复制状态绑定的读写分离机制，让读更加安全可靠

dataHost 心跳检测语句配置为 **`show slave status`**

dataHost 新增属性 **`switchType="2"`**  与 **`slaveThreshold="100"`**，此时意味着开启 MySQL 主从复制状态绑定的读写分离与切换机制，

通过`show slave status`的 **"Seconds_Behind_Master"**，**"Slave_IO_Running"**，**"Slave_SQL_Running"** 三个字段来确定当前主从同步的状态以及 Seconds_Behind_Master 主从复制时延

当 Seconds_Behind_Master > slaveThreshold 时，读写分离筛选器会过滤掉此 Slave 机器，防止读到很久之 前的旧数据，而当主节点宕机后，切换逻辑会检查 Slave 上的 Seconds_Behind_Master 是否为 0，为 0 时则 表示主从同步，可以安全切换，否则不会切换

```xml
<dataHost name="localhost1" maxCon="1000" minCon="10" balance="0" writeType="0" dbType="mysql" dbDriver="native" switchType="2" slaveThreshold="100">
    <heartbeat>show slave status</heartbeat> 
    <!-- can have multi write hosts --> 
    <writeHost host="M1" url="localhost:3306" user="root" password="123456"></writeHost> 
    <writeHost host="S1" url="localhost:3316" user="root" password="123456"></writeHost> 
</dataHost>
```



#####  5.2 Mycat1.4.1 开始支持 MySQL 集群模式，让读更加安全可靠

dataHost 心跳检测语句配置为 **`showstatus like ‘wsrep%’`**

dataHost 新增属性 **`switchType="3"`** 此时意味着开启 MySQL 集群复制状态状态绑定的读写分离与切换机制，Mycat 心跳机制通过检测集群复制时延时，如果延时过大或者集群出现节点问题不会负载改节点。

```xml
<dataHost name="localhost1" maxCon="1000" minCon="10" balance="0" writeType="0" dbType="mysql" dbDriver="native" switchType="3" > 
    <heartbeat> show status like ‘wsrep%’</heartbeat> 
    <writeHost host="M1" url="localhost:3306" user="root"password="123456"></writeHost> 
    <writeHost host="S1"url="localhost:3316"user="root"password="123456" ></writeHost> </dataHost>
```





### 6. Mycat事务
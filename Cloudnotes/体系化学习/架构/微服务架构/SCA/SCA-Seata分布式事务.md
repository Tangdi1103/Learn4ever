[toc]

## 一、Seata

### 1. 简介

Seata（Simple Extensible Autonomous Transaction Architecture）是一套一站式分布式事务解决方案，是阿里集团和蚂蚁金服联合打造的分布式事务框架。Seata目前的事务模式有AT、TCC、Saga和XA，默认是AT模式，AT本质上是2PC协议的一种实现。



### 2. 支持功能

#### 2.1 可集成的框架

⽬前已⽀持 Dubbo、Spring Cloud、Sofa-RPC、Motan 和 grpc 等RPC框架，其他框架持续集成中

#### 2.2 AT 模式

AT 模式是⼀种⽆侵⼊的分布式事务解决⽅案。在 AT 模式下，⽤户只需关注⾃⼰的  ”业务 SQL” ，⽤户的 “业务 SQL” 作为⼀阶段，Seata 框架会⾃动⽣成事务的⼆阶段提交和回滚操作。

⽬前已⽀持 MySQL、 Oracle 、PostgreSQL和 TiDB的AT模式，H2 开发中。

![image-20211124113918234](images/image-20211124113918234.png)



#### 2.3 TCC 模式

TCC 模式需要⽤户根据自己的业务场景实现Try、Confirm 和 Cancel 三个操作。

事务发起方在一阶段 执行 Try 方式，在⼆阶段提交执行 Confirm⽅法，⼆阶段回滚执⾏ Cancel 方法

![image-20211124161925893](images/image-20211124161925893.png)

- Try：资源的检测和预留；

- Confirm：执⾏的业务操作提交；要求 Try 成功 Confirm ⼀定要能成功；

- Cancel：预留资源释放。

**以”扣钱“场景进行说明：**

在接⼊ TCC 前，对 A 账户的扣钱，只需⼀条更新账户余额的 SQL 便能完成；但是在接⼊ TCC 之后，⽤户就需要考虑如何将原来⼀步就能完成的扣钱操作，拆成两阶段，实现成三个⽅法，并且保证⼀阶段 Try 成功的话 ⼆阶段 Confirm ⼀定能成功。

![image-20211124163106889](images/image-20211124163106889.png)

- Try 要做的事情是就是检查账户余额是否充⾜，预留转账资⾦，预留的⽅式就是冻结 A 账户的 转账资⾦。Try ⽅法执⾏之后，账号 A 余额虽然还是 100，但是其中 30 元已经被冻结了，不能被其他事务使⽤
-  Confirm ⽅法执⾏真正的扣钱操作。Confirm 会使⽤ Try 阶段冻结的资⾦，执⾏账号扣款。Confirm ⽅法执⾏之后，账号 A 在⼀阶段中冻结的 30 元已经被扣除，账号 A 余额变成 70 元 。
- 如果⼆阶段是回滚的话，就需要在 Cancel ⽅法内释放⼀阶段 Try 冻结的 30 元，使账号 A 的回到初始状态，100 元全部可⽤

**TCC模式的难度及效果**

用户接⼊ TCC 模式，最重要的事情就是考虑如何将业务模型拆成 2 阶段，实现成 TCC 的 3 个⽅法，并且保证 Try 成功 Confirm ⼀定能成功。相对于 AT 模式，TCC 模式对业务代码有⼀定的侵⼊性，但是 TCC 模式⽆ AT 模式的全局⾏锁，TCC 性能会⽐ AT 模式⾼很多

#### 2.4 Saga 模式

为长事务提供有效的解决⽅案

#### 2.5 XA 模式

⽀持已实现 XA 接⼝的数据库的 XA 模式

#### 2.6 高可用

支持基于数据库存储的集群模式，⽔平扩展能⼒强



#### 2.7 各种模式对比

![image-20211124162449442](images/image-20211124162449442.png)

- AT 模式是⽆侵⼊的分布式事务解决⽅案，适⽤于不希望对业务进⾏改造的场景，⼏乎0学习成本。
- TCC 模式是⾼性能分布式事务解决⽅案，适⽤于核⼼系统等对性能有很⾼要求的场景。
- Saga 模式是⻓事务解决⽅案，适⽤于业务流程⻓且需要保证事务最终⼀致性的业务系统，Saga 模式⼀阶段就会提交本地事务，⽆锁，⻓流程情况下可以保证性能，多⽤于渠道层、集成层业务系统。事务参与者可能是其它公司的服务或者是遗留系统的服务，⽆法进⾏改造和提供 TCC 要求的接⼝，也可以使⽤Saga 模式。



### 3. 模块及原理

#### 3.1 结构

Seata 内部包含三大模块：TM、RM 和 TC。

- TC 作为 Seata 的 Server独⽴部署。
- TM 和 RM 是作为 Seata 的 Client与业务系统集成在⼀起，它们同TC建立长连接，在整个事务生命周期内，保持RPC通信。

#### 3.2 模块职能

- **TC (Transaction Coordinator) - 事务协调器**

  维护全局和分⽀事务的状态，驱动全局事务提交或回滚。

- **TM (Transaction Manager) - 事务管理器**

  发起全局事务，并负责全局事务的begin和commit/rollback

- **RM (Resource Manager) - 资源管理器**

  参与全局事务，负责分支事务的执行结果上报，并且通过TC的协调进行commit/rollback。

#### 3.3 原理

![image-20211124105905209](images/image-20211124105905209.png)

在 Seata 中，AT模式分为两个阶段，第一阶段：各个阶段本地提交操作；第二阶段：根据第一阶段的情况决定进行全局提交或者全局回滚操作。具体的执行流程如下：

1. TM 开启分布式事务, **TM会 向 TC 注册全局事务记录**；
2. RM开启本地事务，**RM 向 TC 注册分支事务，并向 TC 上报执行结果**；
3. **RM分支事务结束，事务一阶段结束**；
4. 当业务操作完事后，**TM会通知 TC 提交/回滚分布式事务**；
5. **TC 汇总事务信息**，决定分布式事务是提交还是回滚
6. **TC 通知所有 RM 提交/回滚 资源**，事务⼆阶段结束。



## 二、准备案例

基于SCA项目，各个微服务通过Dubbo或Feign进行服务调用，各个服务再操作各自的数据库（及各服务本地的事务），所以这就涉及到了分布式事务。



## 三、引入Seata-AT解决分布式事务

### 1. 事务协调器TC（Seata Server）

TC 即Seata Server，是独立部署的服务，直接从官⽅仓库下载启动即可，下载地址：https://github.com/seata/seata/releases

##### 1.1 Seata Server 注册到注册中心

其他服务通过注册中 与 Seata Server 进⾏通信。

Seata 支持多款注册中心服务：nacos 、eureka、redis、zk、consul、etcd3、sofa。

在 seata/conf/registry.conf⽂件中配置注册到注册中心

```
#注册中⼼
registry {
	# file 、nacos 、eureka、redis、zk、consul、etcd3、sofa
 	# 这⾥选择 nacos 注册配置
 	type = "nacos"
 	loadBalance = "RandomLoadBalance"
 	loadBalanceVirtualNodes = 10

 	nacos {
 		application = "seata-server" # 服务名称
 		serverAddr = "127.0.0.1:8848" # 服务地址
 		group = "SEATA_GROUP" # 分组
 		namespace = ""
 		cluster = "default" # 集群
 		username = "nacos" # ⽤户名
 		password = "nacos" # 密码
 	}
 	
 	eureka {
 		serviceUrl = "http://localhost:8761/eureka"
 		application = "default"
 		weight = "1"
 	}
 	
 	redis {
 		serverAddr = "localhost:6379"
 		db = 0
 		password = ""
 		cluster = "default"
 		timeout = 0
 	}
 	
 	zk {
 		cluster = "default"
 		serverAddr = "127.0.0.1:2181"
 		sessionTimeout = 6000
 		connectTimeout = 2000
 		username = ""
 		password = ""
 	}
 	
 	consul {
 		cluster = "default"
 		serverAddr = "127.0.0.1:8500"
 	}
 	
 	etcd3 {
 		cluster = "default"
 		serverAddr = "http://localhost:2379"
 	}
 	
 	sofa {
 		serverAddr = "127.0.0.1:9603"
 		application = "default"
 		region = "DEFAULT_ZONE"
 		datacenter = "DefaultDataCenter"
 		cluster = "default"
 		group = "SEATA_GROUP"
 		addressWaitTime = "3000"
 	}
 	
 	file {
 		name = "file.conf"
 	}
}


#配置中⼼
config { 
	# file、nacos 、apollo、zk、consul、etcd3
	type = "nacos"
	nacos {
		serverAddr = "127.0.0.1:8848"
		namespace = ""
		group = "SEATA_GROUP"
		username = "nacos"
		password = "nacos"
	}

	consul {
		serverAddr = "127.0.0.1:8500"
	}

	apollo {
		appId = "seata-server"
		apolloMeta = "http://192.168.1.204:8801"
		namespace = "application"
		apolloAccesskeySecret = ""
	}
	
	zk {
		serverAddr = "127.0.0.1:2181"
		sessionTimeout = 6000
		connectTimeout = 2000
		username = ""
		password = ""
	}

 	etcd3 {
 		serverAddr = "http://localhost:2379"
 	}

 	file {
 		name = "file.conf"
 	}
}
```



##### 1.2 向Seata中添加配置信息

- 下载配置config.txt https://github.com/seata/seata/tree/develop/script/config-center

  ![image-20211124151146042](images/image-20211124151146042.png)

  https://seata.io/zh-cn/docs/user/configurations.html针对每个⼀项配置介绍

  ```properties
  transport.type=TCP
  transport.server=NIO
  transport.heartbeat=true
  transport.enableClientBatchSendRequest=true
  transport.threadFactory.bossThreadPrefix=NettyBoss
  transport.threadFactory.workerThreadPrefix=NettyServerNIOWorker
  transport.threadFactory.serverExecutorThreadPrefix=NettyServerBizHandler
  transport.threadFactory.shareBossWorker=false
  transport.threadFactory.clientSelectorThreadPrefix=NettyClientSelector
  transport.threadFactory.clientSelectorThreadSize=1
  transport.threadFactory.clientWorkerThreadPrefix=NettyClientWorkerThread
  transport.threadFactory.bossThreadSize=1
  transport.threadFactory.workerThreadSize=default
  transport.shutdown.wait=3
  service.vgroupMapping.default_tx_group=default
  service.default.grouplist=127.0.0.1:8091
  service.enableDegrade=false
  service.disableGlobalTransaction=false
  client.rm.asyncCommitBufferLimit=10000
  client.rm.lock.retryInterval=10
  client.rm.lock.retryTimes=30
  client.rm.lock.retryPolicyBranchRollbackOnConflict=true
  client.rm.reportRetryCount=5
  client.rm.tableMetaCheckEnable=false
  client.rm.tableMetaCheckerInterval=60000
  client.rm.sqlParserType=druid
  client.rm.reportSuccessEnable=false
  client.rm.sagaBranchRegisterEnable=false
  client.rm.sagaJsonParser=fastjson
  client.rm.tccActionInterceptorOrder=-2147482648
  client.tm.commitRetryCount=5
  client.tm.rollbackRetryCount=5
  client.tm.defaultGlobalTransactionTimeout=60000
  client.tm.degradeCheck=false
  client.tm.degradeCheckAllowTimes=10
  client.tm.degradeCheckPeriod=2000
  client.tm.interceptorOrder=-2147482648
  store.mode=file
  store.lock.mode=file
  store.session.mode=file
  store.publicKey=
  store.file.dir=file_store/data
  store.file.maxBranchSessionSize=16384
  store.file.maxGlobalSessionSize=512
  store.file.fileWriteBufferCacheSize=16384
  store.file.flushDiskMode=async
  store.file.sessionReloadReadSize=100
  store.db.datasource=druid
  store.db.dbType=mysql
  store.db.driverClassName=com.mysql.jdbc.Driver
  store.db.url=jdbc:mysql://127.0.0.1:3306/seata?useUnicode=true&rewriteBatchedStatements=true
  store.db.user=username
  store.db.password=password
  store.db.minConn=5
  store.db.maxConn=30
  store.db.globalTable=global_table
  store.db.branchTable=branch_table
  store.db.distributedLockTable=distributed_lock
  store.db.queryLimit=100
  store.db.lockTable=lock_table
  store.db.maxWait=5000
  store.redis.mode=single
  store.redis.single.host=127.0.0.1
  store.redis.single.port=6379
  store.redis.sentinel.masterName=
  store.redis.sentinel.sentinelHosts=
  store.redis.maxConn=10
  store.redis.minConn=1
  store.redis.maxTotal=100
  store.redis.database=0
  store.redis.password=
  store.redis.queryLimit=100
  server.recovery.committingRetryPeriod=1000
  server.recovery.asynCommittingRetryPeriod=1000
  server.recovery.rollbackingRetryPeriod=1000
  server.recovery.timeoutRetryPeriod=1000
  server.maxCommitRetryTimeout=-1
  server.maxRollbackRetryTimeout=-1
  server.rollbackRetryTimeoutUnlockEnable=false
  server.distributedLockExpireTime=10000
  client.undo.dataValidation=true
  client.undo.logSerialization=jackson
  client.undo.onlyCareUpdateColumns=true
  server.undo.logSaveDays=7
  server.undo.logDeletePeriod=86400000
  client.undo.logTable=undo_log
  client.undo.compress.enable=true
  client.undo.compress.type=zip
  client.undo.compress.threshold=64k
  log.exceptionRate=100
  transport.serialization=seata
  transport.compressor=none
  metrics.enabled=false
  metrics.registryType=compact
  metrics.exporterList=prometheus
  metrics.exporterPrometheusPort=9898
  tcc.fence.logTableName=tcc_fence_log
  tcc.fence.cleanPeriod=1h
  ```

- 将config.txt⽂件放⼊seata⽬录下⾯

- 修改config.txt信息

  Server端存储的模式（store.mode）现有file,db,redis三种。主要存储全局事务会话信息,分⽀事务信息, 锁记录表信息。

  - 默认file，仅支持单机Seata Server
  - db，将全局事务会话信息存入数据库
  - redis，将全局事务会话信息存入redis

  **配置Seata Server端连接数据库，注意事先创建Seata数据库**

  ```properties
  store.mode=db
  
  store.db.datasource=druid
  store.db.dbType=mysql
  store.db.driverClassName=com.mysql.jdbc.Driver
  store.db.url=jdbc:mysql://127.0.0.1:3306/seata?useUnicode=true
  store.db.user=root
  store.db.password=root
  store.db.minConn=5
  store.db.maxConn=30
  store.db.globalTable=global_table
  store.db.branchTable=branch_table
  store.db.queryLimit=100
  store.db.lockTable=lock_table
  store.db.maxWait=5000
  ```

- 在seata数据库中，创建表

  创建global_table、branch_table、lock_table三张表,seata1.0以上就不⾃带数据库⽂件了，要⾃⼰去github下载，https://github.com/seata/seata/tree/develop/script/server/db

  ```sql
   -- -------------------------------- The script used when storeMode is 'db' -------------------------------
   -- the table to store GlobalSession data
   CREATE TABLE IF NOT EXISTS `global_table`
   (
   	`xid` VARCHAR(128) NOT NULL,
    	`transaction_id` BIGINT,
  	`status` TINYINT NOT NULL,
  	`application_id` VARCHAR(32),
  	`transaction_service_group` VARCHAR(32),
  	`transaction_name` VARCHAR(128),
  	`timeout` INT,
  	`begin_time` BIGINT,
  	`application_data` VARCHAR(2000),
  	`gmt_create` DATETIME,
  	`gmt_modified` DATETIME,
  	PRIMARY KEY (`xid`),
  	KEY `idx_gmt_modified_status` (`gmt_modified`, `status`),
  	KEY `idx_transaction_id` (`transaction_id`)
  ) ENGINE = InnoDB DEFAULT CHARSET = utf8;
  -- the table to store BranchSession data
  CREATE TABLE IF NOT EXISTS `branch_table`
  (
  	`branch_id` BIGINT NOT NULL,
  	`xid` VARCHAR(128) NOT NULL,
  	`transaction_id` BIGINT,
  	`resource_group_id` VARCHAR(32),
  	`resource_id` VARCHAR(256),
  	`branch_type` VARCHAR(8),
  	`status` TINYINT,
  	`client_id` VARCHAR(64),
  	`application_data` VARCHAR(2000),
  	`gmt_create` DATETIME(6),
  	`gmt_modified` DATETIME(6),
  	PRIMARY KEY (`branch_id`),
  	KEY `idx_xid` (`xid`)
  ) ENGINE = InnoDB DEFAULT CHARSET = utf8;
  -- the table to store lock data
  CREATE TABLE IF NOT EXISTS `lock_table`
  (
  	`row_key` VARCHAR(128) NOT NULL,
  	`xid` VARCHAR(96),
  	`transaction_id` BIGINT,
  	`branch_id` BIGINT NOT NULL,
  	`resource_id` VARCHAR(256),
  	`table_name` VARCHAR(32),
  	`pk` VARCHAR(36),
  	`gmt_create` DATETIME,
  	`gmt_modified` DATETIME,
  	PRIMARY KEY (`row_key`),
  	KEY `idx_branch_id` (`branch_id`)
  ) ENGINE = InnoDB DEFAULT CHARSET = utf8;
  ```

  

##### 1.3 使用nacos-config.sh 向 Nacos 中导入配置

下载地址:https://github.com/seata/seata/tree/develop/script/config-center/nacos

![image-20211124154304765](images/image-20211124154304765.png)

- 将nacos-config.sh放在seata/conf⽂件夹中

- 打开git bash here 执⾏nacos-config.sh,需要提前将nacos启动

  ```shell
  sh nacos-config.sh -h 127.0.0.1
  ```

  ![image-20211124154438526](images/image-20211124154438526.png)

  ![image-20211124154449127](images/image-20211124154449127.png)

- 登录nacos查看配置信息

  ![image-20211124154550717](images/image-20211124154550717.png)



##### 1.4 启动Seata Server

![image-20211124154646895](images/image-20211124154646895.png)

观察Seata Server是否注册到Nacos

![image-20211124154709732](images/image-20211124154709732.png)



### 2. TM/RM端整合Seata

##### 2.1 整合流程

RM(资源管理器)端 整合Seata 与 TM(事务管理器) 端步骤类似，区别在于：

- TM 需要在方法添加@GlobalTransactional注解，RM则不需要
- 其他步骤都相同

![image-20211124155031244](images/image-20211124155031244.png)

##### 2.2 RM服务添加表

AT 模式在RM端需要 `UNDO_LOG `表，来记录每个RM的事务信息，主要包含数据修改前/后的相关信息，⽤于回滚处理，所以在所有数据库中分别执⾏

```sql
-- 注意此处0.3.0+ 增加唯⼀索引 ux_undo_log
CREATE TABLE `undo_log` (
 `id` bigint(20) NOT NULL AUTO_INCREMENT,
 `branch_id` bigint(20) NOT NULL,
 `xid` varchar(100) NOT NULL,
 `context` varchar(128) NOT NULL,
 `rollback_info` longblob NOT NULL,
 `log_status` int(11) NOT NULL,
 `log_created` datetime NOT NULL,
 `log_modified` datetime NOT NULL,
 `ext` varchar(100) DEFAULT NULL,
 PRIMARY KEY (`id`),
 UNIQUE KEY `ux_undo_log` (`xid`,`branch_id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;
```



##### 2.3 RM服务配置依赖

**父工程配置依赖管理**

```xml
<dependencyManagement>
    <dependencies>
        <!--spring cloud依赖管理，引入了Spring Cloud的版本-->
        <dependency>
            <groupId>org.springframework.cloud</groupId>
            <artifactId>spring-cloud-dependencies</artifactId>
            <version>Greenwich.RELEASE</version>
            <type>pom</type>
            <scope>import</scope>
        </dependency>


        <!--SCA -->
        <dependency>
            <groupId>com.alibaba.cloud</groupId>
            <artifactId>spring-cloud-alibaba-dependencies</artifactId>
            <version>2.1.0.RELEASE</version>
            <type>pom</type>
            <scope>import</scope>
        </dependency>
        <!--SCA -->
        <dependency>
            <groupId>mysql</groupId>
            <artifactId>mysql-connector-java</artifactId>
            <version>5.1.47</version>
        </dependency>
        <!--用于锁定高版本seata依赖 -->
        <dependency>
            <groupId>io.seata</groupId>
            <artifactId>seata-all</artifactId>
            <version>1.3.0</version>
        </dependency>
    </dependencies>
</dependencyManagement>
```

**RM端配置依赖**

```xml
<!--添加seata依赖 -->
<dependency>
    <groupId>com.alibaba.cloud</groupId>
    <artifactId>spring-cloud-alibaba-seata</artifactId>
    <exclusions>
        <!--排除低版本-->
        <exclusion>
            <groupId>io.seata</groupId>
            <artifactId>seata-all</artifactId>
        </exclusion>
    </exclusions>
</dependency>
<!--添加⾼版本seata依赖-->
<dependency>
    <groupId>io.seata</groupId>
    <artifactId>seata-all</artifactId>
</dependency>
```



##### 2.4 RM端添加resource/registry.conf文件

```
registry {
  # file 、nacos 、eureka、redis、zk、consul、etcd3、sofa
  type = "nacos"

  nacos {
    application = "seata-server"
    serverAddr = "127.0.0.1:8848"
    group = "SEATA_GROUP"
    namespace = ""
    cluster = "default"
    username = "nacos"
    password = "nacos"
  }
  eureka {
    serviceUrl = "http://localhost:8761/eureka"
    application = "default"
    weight = "1"
  }
  redis {
    serverAddr = "localhost:6379"
    db = 0
    password = ""
    cluster = "default"
    timeout = 0
  }
  zk {
    cluster = "default"
    serverAddr = "127.0.0.1:2181"
    sessionTimeout = 6000
    connectTimeout = 2000
    username = ""
    password = ""
  }
  consul {
    cluster = "default"
    serverAddr = "127.0.0.1:8500"
  }
  etcd3 {
    cluster = "default"
    serverAddr = "http://localhost:2379"
  }
  sofa {
    serverAddr = "127.0.0.1:9603"
    application = "default"
    region = "DEFAULT_ZONE"
    datacenter = "DefaultDataCenter"
    cluster = "default"
    group = "SEATA_GROUP"
    addressWaitTime = "3000"
  }
  file {
    name = "file.conf"
  }
}

config {
  # file、nacos 、apollo、zk、consul、etcd3
  type = "nacos"

  nacos {
    serverAddr = "127.0.0.1:8848"
    namespace = ""
    group = "SEATA_GROUP"
    username = "nacos"
    password = "nacos"
  }
  consul {
    serverAddr = "127.0.0.1:8500"
  }
  apollo {
    appId = "seata-server"
    apolloMeta = "http://192.168.1.204:8801"
    namespace = "application"
  }
  zk {
    serverAddr = "127.0.0.1:2181"
    sessionTimeout = 6000
    connectTimeout = 2000
    username = ""
    password = ""
  }
  etcd3 {
    serverAddr = "http://localhost:2379"
  }
  file {
    name = "file.conf"
  }
}
```



##### 2.5 RM添加公共配置

```properties
spring.cloud.alibaba.seata.tx-service-group=my_test_tx_group
logging.level.io.seata=debug
```



##### 2.6 RM代理数据源配置类

```java
import com.alibaba.druid.pool.DruidDataSource;
import io.seata.rm.datasource.DataSourceProxy;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Primary;

import javax.sql.DataSource;

/**
 * 数据源代理
 */
@Configuration
public class DataSourceConfiguration {


    @Bean
    @ConfigurationProperties("spring.datasource")
    public DataSource druidDataSource() {
        return new DruidDataSource();
    }

    /**
     * 设置代理数据源
     *
     * @param druidDataSource
     * @return
     */
    @Primary // 设置首选数据源
    @Bean("datasource")
    public DataSourceProxy dataSource(DataSource druidDataSource) {
        return new DataSourceProxy(druidDataSource);
    }
}
```



##### 2.7 RM启动扫描配置类,分别加载每个工程的启动类中

```java
import org.mybatis.spring.annotation.MapperScan;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.autoconfigure.jdbc.DataSourceAutoConfiguration;
import org.springframework.cloud.client.discovery.EnableDiscoveryClient;

@SpringBootApplication(scanBasePackages = "com.tangdi",
        exclude = DataSourceAutoConfiguration.class)
@EnableDiscoveryClient
@MapperScan(basePackages = {"com.tangdi.points.mapper"}) // mybatis包扫描
public class PointsApplication {

    public static void main(String[] args) {
        SpringApplication.run(PointsApplication.class, args);
    }
}

```



##### 2.8 TM方法添加注解@GlobalTransactional

```java
import com.lagou.bussiness.feign.OrderServiceFeign;
import com.lagou.bussiness.feign.PointsServiceFeign;
import com.lagou.bussiness.feign.StorageServiceFeign;
import com.lagou.bussiness.service.BussinessService;
import com.lagou.bussiness.utils.IdWorker;
import io.seata.spring.annotation.GlobalTransactional;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/**
 * 业务逻辑
 */
@Service
public class BussinessServiceImpl implements BussinessService {

    @Autowired
    OrderServiceFeign orderServiceFeign;
    @Autowired
    PointsServiceFeign pointsServiceFeign;

    @Autowired
    StorageServiceFeign storageServiceFeign;

    @Autowired
    IdWorker idWorker;

    /**
     * 商品销售
     *
     * @param goodsId  商品id
     * @param num      销售数量
     * @param username 用户名
     * @param money    金额
     */
    //@Transactional
    @GlobalTransactional(rollbackFor = Exception.class,timeoutMills = 60000,name = "sale")
    public void sale(Integer goodsId, Integer num, Double money, String username) {
        //创建订单
        orderServiceFeign.addOrder(idWorker.nextId(), goodsId, num, money, username);
        //增加积分
        pointsServiceFeign.increase(username, (int) (money / 10));
        //扣减库存
        storageServiceFeign.decrease(goodsId, num);
    }
}
```





## 四、引入Seata-TCC解决分布式事务

### 1. 事务协调器TC（Seata Server）

与AT模式一致

### 2. 资源管理器RM改造

##### 2.1 以下三步与AT模式一致

[RM服务配置依赖](#2.3 RM服务配置依赖)

[RM端添加resource/registry.conf文件](#2.4 RM端添加resource/registry.conf文件)

[RM添加公共配置](#2.5 RM添加公共配置)



##### 2.2 修改数据库表结构,增加预留检查字段,⽤于提交和回滚

```sql
ALTER TABLE `seata_order`.`t_order` ADD COLUMN `status` int(0) NULL COMMENT '订单状态-0不可⽤,事务未提交 , 1-可⽤,事务提交' ;
ALTER TABLE `seata_points`.`t_points` ADD COLUMN `frozen_points` int(0) NULL DEFAULT 0 COMMENT '冻结积分' AFTER `points`;
ALTER TABLE `seata_storage`.`t_storage` ADD COLUMN `frozen_storage` int(0) NULL DEFAULT 0 COMMENT '冻结库存' AFTER `goods_id`;
```



##### 2.3 改造service层。。。




#### 创建一个虚拟机，安装java和maven，并且在/etc/profile中配置环境变量


---

#### 拉取openjdk:8-jre

```
docker pull openjdk:8-jre
```


---

#### 使用以下命令生成密钥，添加进gitlab中
```
ssh-keygen -t rsa -C "your_email@example.com"
```

---

#### 使用命令git clone [项目地址]，克隆项目进容器中

---

#### 将itoken-dependencies部署到依赖私服，为后续服务提供依赖

**==在pom中添加如下配置==**
```
<distributionManagement>  
  <repository>  
    <id>nexus-releases</id>  
    <name>Nexus Release Repository</name>  
    <url>http://192.168.243.128:8081/repository/maven-releases/</url>
  </repository>  
  <snapshotRepository>  
    <id>nexus-snapshots</id>  
    <name>Nexus Snapshot Repository</name>  
    <url>http://192.168.243.128:8081/repository/maven-snapshots/</url>
  </snapshotRepository>  
</distributionManagement>
```

**==部署到依赖私服==**
```
mvn deploy -Dmaven.test.skip=true
```


---

#### clean package后运行jar包测试是否可用

```
java -jar itoken-xxxx-1.0.0-SNAPSHOT.jar --spring.profiles.active=prod(dev)
```

---
#### 进入项目，创建docker，并创建Dockerfile
---

#### 将jar包移动到Dockerfile的当前目录，编写Dockerfile


```
cp ../target/itoken-config-1.0.0-SNAPSHOT.jar .
```


==itoken-config的Dockerfile==
```
FROM openjdk:8-jre

RUN mkdir /app

COPY itoken-config-1.0.0-SNAPSHOT.jar /app/

CMD java -Djava.security.egd=file:/dev/./urandom \
         -Duser.timezone=GMT+08 \
         -Dfile.encoding=UTF-8 \
         -jar /app/itoken-config-1.0.0-SNAPSHOT.jar --spring.profiles.active=prod

EXPOSE 8888
```

==itoken-eureka的Dockerfile==
```
FROM openjdk:8-jre

RUN mkdir /app

COPY itoken-eureka-1.0.0-SNAPSHOT.jar /app/

CMD java -Djava.security.egd=file:/dev/./urandom \
         -Duser.timezone=GMT+08 \
         -Dfile.encoding=UTF-8 \
         -jar /app/itoken-eureka-1.0.0-SNAPSHOT.jar --spring.profiles.active=prod

EXPOSE 8761
```


---
#### 构建镜像

```
docker build -t 192.168.243.130:5000/itoken-config .
```

---

#### push镜像到镜像私服
```
docker push 192.168.243.130:5000/itoken-config
```


---


#### 创建dicker-compose.yml ，并启动compose

==itoken-config的docker-compose==
```
version: '3.1'
services:
  itoken-config:
    restart: always
    image: 192.168.243.130:5000/itoken-config
    container_name: itoken-config
    ports:
      - 8888:8888
```
==itoken-eureka的docker-compose==

```
version: '3.1'
services:
  itoken-eureka-1:
    restart: always
    image: 192.168.243.130:5000/itoken-eureka
    container_name: itoken-eureka-1
    ports:
      - 8761:8761
      
  itoken-eureka-2:
    restart: always
    image: 192.168.243.130:5000/itoken-eureka
    container_name: itoken-eureka-2
    ports:
      - 8861:8761
      
  itoken-eureka-3:
    restart: always
    image: 192.168.243.130:5000/itoken-eureka
    container_name: itoken-eureka-3
    ports:
      - 8961:8761
```



```
docker-compose up -d
```

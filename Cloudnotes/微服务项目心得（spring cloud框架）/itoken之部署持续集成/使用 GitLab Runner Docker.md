# 简介

理解了上面的基本概念之后，有没有觉得少了些什么东西 —— 由谁来执行这些构建任务呢？
答案就是 GitLab Runner 了！

想问为什么不是 GitLab CI 来运行那些构建任务？

一般来说，构建任务都会占用很多的系统资源 (譬如编译代码)，而 GitLab CI 又是 GitLab 的一部分，如果由 GitLab CI 来运行构建任务的话，在执行构建任务的时候，GitLab 的性能会大幅下降。

GitLab CI 最大的作用是管理各个项目的构建状态，因此，运行构建任务这种浪费资源的事情就交给 GitLab Runner 来做拉！

因为 GitLab Runner 可以安装到不同的机器上，所以在构建任务运行期间并不会影响到 GitLab 的性能


---

###### 为了配置方便，我们使用 ==docker== 来部署 ==GitLab Runner==

# 环境准备

- 创建工作目录 ==/usr/local/docker/runner==
- 创建构建目录 ==/usr/local/docker/runner/environment==
- 下载 ==jdk-8u152-linux-x64.tar.gz== 并复制到 ==/usr/local/docker/runner/environment==


---

# Dockerfile

在 ==/usr/local/docker/runner/environment== 目录下创建 ==Dockerfile==


```
FROM gitlab/gitlab-runner:v11.0.2
MAINTAINER Lusifer <topsale@vip.qq.com>

# 修改软件源
RUN echo 'deb http://mirrors.aliyun.com/ubuntu/ xenial main restricted universe multiverse' > /etc/apt/sources.list && \
    echo 'deb http://mirrors.aliyun.com/ubuntu/ xenial-security main restricted universe multiverse' >> /etc/apt/sources.list && \
    echo 'deb http://mirrors.aliyun.com/ubuntu/ xenial-updates main restricted universe multiverse' >> /etc/apt/sources.list && \
    echo 'deb http://mirrors.aliyun.com/ubuntu/ xenial-backports main restricted universe multiverse' >> /etc/apt/sources.list && \
    apt-get update -y && \
    apt-get clean

# 安装 Docker
RUN apt-get -y install apt-transport-https ca-certificates curl software-properties-common && \
    curl -fsSL http://mirrors.aliyun.com/docker-ce/linux/ubuntu/gpg | apt-key add - && \
    add-apt-repository "deb [arch=amd64] http://mirrors.aliyun.com/docker-ce/linux/ubuntu $(lsb_release -cs) stable" && \
    apt-get update -y && \
    apt-get install -y docker-ce
COPY daemon.json /etc/docker/daemon.json

# 安装 Docker Compose
WORKDIR /usr/local/bin
RUN wget https://raw.githubusercontent.com/topsale/resources/master/docker/docker-compose
RUN chmod +x docker-compose

# 安装 Java
RUN mkdir -p /usr/local/java
WORKDIR /usr/local/java
COPY jdk-8u152-linux-x64.tar.gz /usr/local/java
RUN tar -zxvf jdk-8u152-linux-x64.tar.gz && \
    rm -fr jdk-8u152-linux-x64.tar.gz

# 安装 Maven
RUN mkdir -p /usr/local/maven
WORKDIR /usr/local/maven
RUN wget https://raw.githubusercontent.com/topsale/resources/master/maven/apache-maven-3.5.3-bin.tar.gz
# COPY apache-maven-3.5.3-bin.tar.gz /usr/local/maven
RUN tar -zxvf apache-maven-3.5.3-bin.tar.gz && \
    rm -fr apache-maven-3.5.3-bin.tar.gz
# COPY settings.xml /usr/local/maven/apache-maven-3.5.3/conf/settings.xml

# 配置环境变量
ENV JAVA_HOME /usr/local/java/jdk1.8.0_152
ENV MAVEN_HOME /usr/local/maven/apache-maven-3.5.3
ENV PATH $PATH:$JAVA_HOME/bin:$MAVEN_HOME/bin

WORKDIR /
```


---

# daemon.json

在 ==/usr/local/docker/runner/environment== 目录下创建 ==daemon.json==，用于配置加速器和仓库地址


```
{
  "registry-mirrors": [
    "https://registry.docker-cn.com"
  ],
  "insecure-registries": [
    "192.168.75.131:5000"
  ]
}
```

---
# docker-compose.yml

在 ==/usr/local/docker/runner== 目录下创建 ==docker-compose.yml==


```
version: '3.1'
services:
  gitlab-runner:
    build: environment
    restart: always
    container_name: gitlab-runner
    privileged: true
    volumes:
      - /usr/local/docker/runner/config:/etc/gitlab-runner
      - /var/run/docker.sock:/var/run/docker.sock
```

---

# 注册 Runner

==CI 的地址和令牌，在 项目 –> 设置 –> CI/CD –> Runner 设置：==

```
docker exec -it gitlab-runner gitlab-runner register

# 输入 GitLab 地址
Please enter the gitlab-ci coordinator URL (e.g. https://gitlab.com/):
http://192.168.75.146:8080/

# 输入 GitLab Token
Please enter the gitlab-ci token for this runner:
1Lxq_f1NRfCfeNbE5WRh

# 输入 Runner 的说明
Please enter the gitlab-ci description for this runner:
可以为空

# 设置 Tag，可以用于指定在构建规定的 tag 时触发 ci
Please enter the gitlab-ci tags for this runner (comma separated):
deploy

# 这里选择 true ，可以用于代码上传后直接执行
Whether to run untagged builds [true/false]:
true

# 这里选择 false，可以直接回车，默认为 false
Whether to lock Runner to current project [true/false]:
false

# 选择 runner 执行器，这里我们选择的是 shell
Please enter the executor: virtualbox, docker+machine, parallels, shell, ssh, docker-ssh+machine, kubernetes, docker, docker-ssh:
shell
```

###### 注册成功后，只要项目提交给GitLab就会触发runner，容器中的runner就会自动从gitlab中拉取刚提交的项目

---

# 在项目下创建docker目录（config为例）
###### ==config的Dockerfile相对于其他服务较为特殊==


#### 编写docker-compose.yml
```
version: '3.1'
services:
  itoken-config:
    restart: always
    image: 192.168.243.130:5000/itoken-config
    container_name: itoken-config
    ports:
      - 8888:8888
    networks:
      - config_network

networks:
  config_network:
```

#### 编写Dockerfile文件

```
FROM openjdk:8-jre

RUN mkdir /app

COPY itoken-config-1.0.0-SNAPSHOT.jar /app/app.jar

ENTRYPOINT ["java","-Djava.security.egd=file:/dev/.urandom","-jar","/app/app.jar","--spring.profiles.active=prod"]

EXPOSE 8888
```

---
# 在项目下创建docker目录（eureka为例）
###### ==其余服务的Dockerfile和eureka都大同小异==

#### 编写docker-compose.yml

```
version: '3.1'
services:
  itoken-eureka:
    restart: always
    image: 192.168.243.130:5000/itoken-eureka
    container_name: itoken-eureka
    ports:
      - 8761:8761
    networks:
      - eureka_network

networks:
  eureka_network:
```


#### 编写Dockerfile文件

```
FROM openjdk:8-jre

ENV DOCKERIZE_VERSION v0.6.1
RUN wget http://192.168.0.104:8080/dockerize-linux-amd64-$DOCKERIZE_VERSION.tar.gz \
    && tar -C /usr/local/bin -xzvf dockerize-linux-amd64-$DOCKERIZE_VERSION.tar.gz \
    && rm dockerize-linux-amd64-$DOCKERIZE_VERSION.tar.gz


RUN mkdir /app

COPY itoken-eureka-1.0.0-SNAPSHOT.jar /app/app.jar


ENTRYPOINT ["dockerize", "-timeout", "5m", "-wait", "http://192.168.243.135:8888/itoken-eureka/prod/master", "java", "-Djava.security.egd=file:/dev/./urandom", "-jar", "/app/app.jar", "--spring.profiles.active=prod"]

EXPOSE 8761
```


---
# .gitlab-ci.yml

在项目工程下编写 ==.gitlab-ci.yml== 配置文件，一次 Pipeline 分成五个阶段：

- 构建镜像==build==
- 推送到镜像私服==push==
- 运行镜像，开启容器==run==
- 清除所有无用容器==clean==

```
stages:
  - build
  - push
  - run
  - clean

build:
  stage: build
  script:
    - /usr/local/maven/apache-maven-3.5.3/bin/mvn clean package
    - cp target/itoken-config-1.0.0-SNAPSHOT.jar docker
    - cd docker
    - docker build -t 192.168.243.130:5000/itoken-config .

push:
  stage: push
  script:
    - docker push 192.168.243.130:5000/itoken-config

run:
  stage: run
  script:
    - cd docker
    - docker-compose down
    - docker-compose up -d

clean:
  stage: clean
  script:
    - docker rmi $(docker images -q -f dangling=true)
```













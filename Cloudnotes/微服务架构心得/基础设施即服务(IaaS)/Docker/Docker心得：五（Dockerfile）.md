
#### Docker file 的方式构建docker镜像
```
FROM         他的妈妈是谁（基础镜像）
MAINTAINER    告诉被人，你创造了他（维护者信息）
RUN            你想让他干啥（把命令前面加上RUN）
ADD         相当于cp命令（COPY文件，会自动解压）
WORKDIR        相当于cd命令（当前工作目录）
VOLUME        给我一个放行李的地方（目录挂载）
EXPOSE        我要打开的门是啥（端口）
RUN            奔跑吧，兄弟！（进程要一直运行下去）
```



#### CMD指令和ENTRYPOINT指令的作用都是为镜像指定容器启动后的命令

共同点
- 都可以指定shell或exec函数调用的方式执行命令；
- 当存在多个CMD指令或ENTRYPOINT指令时，只有最后一个生效；

不同点
- 1：CMD指令指定的容器启动时命令可以被docker run指定的命令覆盖，而ENTRYPOINT指令指定的命令不能被覆盖，而是将docker run指定的参数当做ENTRYPOINT指定命令的参数。
- 2：CMD指令可以为ENTRYPOINT指令设置默认参数，而且可以被docker run指定的参数覆盖；


将jar包做成镜像
```
vi Dockerfile
```

CMD
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


ENTRYPOINT 
```
FROM openjdk:8-jre

RUN mkdir /app

COPY itoken-config-1.0.0-SNAPSHOT.jar /app/app.jar

ENTRYPOINT ["java","-Djava.security.egd=file:/dev/.urandom","-Duser.timezone=GMT+08","-Dfile.encoding=UTF-8","-jar","/app/app.jar","--spring.profiles.active=prod"]

EXPOSE 8888
```

将web项目部署在tomcat镜像中
```
FROM tomcat

WORKDIR /usr/local/tomcat/webapps/ROOT

RUN rm -fr *

ADD myshop.tar.gz /usr/local/tomcat/webapps/ROOT

RUN rm -fr myshop.tar.gz

WORKDIR /usr/local/tomcat
```



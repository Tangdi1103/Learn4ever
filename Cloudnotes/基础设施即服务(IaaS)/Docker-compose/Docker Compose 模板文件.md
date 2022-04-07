模板文件是使用 ==Compose== 的核心，涉及到的指令关键字也比较多。但大家不用担心，这里面大部分指令跟 ==docker run== 相关参数的含义都是类似的。

默认的模板文件名称为 ==docker-compose.yml==，格式为 ==YAML== 格式。如


```
version: "3"

services:
  webapp:
    image: examples/web
    ports:
      - "80:80"
    volumes:
      - "/data"
```

注意每个服务都必须通过 ==image== 指令指定镜像或 ==build== 指令（需要 ==Dockerfile==）等来自动构建生成镜像。

如果使用 ==build== 指令，在 ==Dockerfile== 中设置的选项(例如：CMD, EXPOSE, VOLUME, ENV 等) 将会自动被获取，无需在 ==docker-compose.yml== 中再次设置。

下面分别介绍各个指令的用法。

---

# ==build==

指定 ==Dockerfile== 所在文件夹的路径（可以是绝对路径，或者相对 docker-compose.yml 文件的路径）。 ==Compose== 将会利用它自动构建这个镜像，然后使用这个镜像。


```
version: '3'
services:

  webapp:
    build: ./dir
```
- 你也可以使用 ==context== 指令指定 Dockerfile 所在文件夹的路径。
- 使用 ==dockerfile== 指令指定 Dockerfile 文件名。
- 使用 ==arg== 指令指定构建镜像时的变量。


```
version: '3'
services:

  webapp:
    build:
      context: ./dir
      dockerfile: Dockerfile-alternate
      args:
        buildno: 1
```

使用==cache_from== 指定构建镜像的缓存


```
build:
  context: .
  cache_from:
    - alpine:latest
    - corp/web_app:3.14
```
---

# cap_add, cap_drop

指定容器的内核能力（capacity）分配。

例如，让容器拥有所有能力可以指定为：


```
cap_add:
  - ALL
```
去掉 NET_ADMIN 能力可以指定为：


```
cap_drop:
  - NET_ADMIN
```
---
# command
覆盖容器启动后默认执行的命令。


```
command: echo "hello world"
```
---

# cgroup_parent

指定父 ==cgroup== 组，意味着将继承该组的资源限制。

例如，创建了一个 cgroup 组名称为 ==cgroups_1==。


```
cgroup_parent: cgroups_1
```
---

# ==container_name==

指定容器名称。默认将会使用 项目名称_服务名称_序号 这样的格式。


```
container_name: docker-web-container
```
---
# devices

指定设备映射关系。


```
devices:
  - "/dev/ttyUSB1:/dev/ttyUSB0"
```
---

# depends_on

解决容器的依赖、启动先后的问题。以下例子中会先启动 redis db 再启动 web


```
version: '3'

services:
  web:
    build: .
    depends_on:
      - db
      - redis

  redis:
    image: redis

  db:
    image: postgres
```
###### 注意：web 服务不会等待 redis db 「完全启动」之后才启动。

---

# ==dns==

自定义 DNS 服务器。可以是一个值，也可以是一个列表。


```
dns: 8.8.8.8

dns:
  - 8.8.8.8
  - 114.114.114.114
```
---
# env_file

从文件中获取环境变量，可以为单独的文件路径或列表。

如果通过 ==docker-compose -f FILE== 方式来指定 ==Compose== 模板文件，则 ==env_file== 中变量的路径会基于模板文件路径。

如果有变量名称与 ==environment== 指令冲突，则按照惯例，以后者为准。


```
env_file: .env

env_file:
  - ./common.env
  - ./apps/web.env
  - /opt/secrets.env
```
环境变量文件中每一行必须符合格式，支持 # 开头的注释行。


```
# common.env: Set development environment
PROG_ENV=development
```
---
# ==environment==

设置环境变量。你可以使用数组或字典两种格式。

只给定名称的变量会自动获取运行 Compose 主机上对应变量的值，可以用来防止泄露不必要的数据。


```
environment:
  RACK_ENV: development
  SESSION_SECRET:

environment:
  - RACK_ENV=development
  - SESSION_SECRET
```
---

# ==expose==

暴露端口，但不映射到宿主机，只被连接的服务访问。

仅可以指定内部端口为参数


```
expose:
 - "3000"
 - "8000"
```
---

# ==healthcheck==

通过命令检查容器是否健康运行。


```
healthcheck:
  test: ["CMD", "curl", "-f", "http://localhost"]
  interval: 1m30s
  timeout: 10s
  retries: 3
```

---
# ==image==


指定为镜像名称或镜像 ID。如果镜像在本地不存在，==Compose== 将会尝试拉取这个镜像。

```
image: ubuntu
image: orchardup/postgresql
image: a4bc65fd
```
---
# ==logging==

配置日志选项。


```
logging:
  driver: syslog
  options:
    syslog-address: "tcp://192.168.0.42:123"
```

目前支持三种日志驱动类型。


```
driver: "json-file"
driver: "syslog"
driver: "none"
```

==options== 配置日志驱动的相关参数。


```
options:
  max-size: "200k"
  max-file: "10"
```
---

# network_mode

设置网络模式。使用和 ==docker run== 的 ==--network==参数一样的值。


```
network_mode: "bridge"
network_mode: "host"
network_mode: "none"
network_mode: "service:[service name]"
network_mode: "container:[container name/id]"
```
---

# ==networks==
配置容器连接的网络。


```
version: "3"
services:

  some-service:
    networks:
     - some_network
     - other_network

networks:
  some_network:
  other_network:
```
---
# pid
跟主机系统共享进程命名空间。打开该选项的容器之间，以及容器和宿主机系统之间可以通过进程 ID 来相互访问和操作。


```
pid: "host"
```
---

# ==ports==
暴露端口信息。

使用宿主端口：容器端口 (==HOST:CONTAINER==) 格式，或者仅仅指定容器的端口（宿主将会随机选择端口）都可以。


```
ports:
 - "3000"
 - "8000:8000"
 - "49100:22"
 - "127.0.0.1:8001:8001"
```
###### 注意：当使用 HOST:CONTAINER 格式来映射端口时，如果你使用的容器端口小于 60 并且没放到引号里，可能会得到错误结果，因为 YAML 会自动解析 xx:yy 这种数字格式为 60 进制。为避免出现这种问题，建议数字串都采用引号包括起来的字符串格式。

---

# ==secrets==

存储敏感数据，例如 mysql 服务密码。


```
version: "3.1"
services:

mysql:
  image: mysql
  environment:
    MYSQL_ROOT_PASSWORD_FILE: /run/secrets/db_root_password
  secrets:
    - db_root_password
    - my_other_secret

secrets:
  my_secret:
    file: ./my_secret.txt
  my_other_secret:
    external: true
```
---

# security_opt

指定容器模板标签（label）机制的默认属性（用户、角色、类型、级别等）。例如配置标签的用户名和角色名。


```
security_opt:
    - label:user:USER
    - label:role:ROLE
```
---
# stop_signal

设置另一个信号来停止容器。在默认情况下使用的是 SIGTERM 停止容器。


```
stop_signal: SIGUSR1
```
---

# ==sysctls==

配置容器内核参数。


```
sysctls:
  net.core.somaxconn: 1024
  net.ipv4.tcp_syncookies: 0

sysctls:
  - net.core.somaxconn=1024
  - net.ipv4.tcp_syncookies=0
```
---
# ulimits

指定容器的 ulimits 限制值。

例如，指定最大进程数为 65535，指定文件句柄数为 20000（软限制，应用可以随时修改，不能超过硬限制） 和 40000（系统硬限制，只能 root 用户提高）。


```
ulimits:
    nproc: 65535
    nofile:
      soft: 20000
      hard: 40000
```
---

# ==volumes==

数据卷所挂载路径设置。可以设置宿主机路径 （HOST:CONTAINER） 或加上访问模式 （HOST:CONTAINER:ro）。

该指令中路径支持相对路径。


```
volumes:
 - /var/lib/mysql
 - cache/:/tmp/cache
 - ~/configs:/etc/configs/:ro
```
---

# ==restart==

指定容器退出后的重启策略为始终重启。该命令对保持服务始终运行十分有效，在生产环境中推荐配置为 always 或者 unless-stopped。


```
restart: always
```
---

# privileged
允许容器中运行一些特权命令。


```
privileged: true
```
---

# user

指定容器中运行应用的用户名。


```
user: nginx
```
---

# entrypoint
指定服务容器启动后执行的入口文件。


```
entrypoint: /code/entrypoint.sh
```
---

# read_only
以只读模式挂载容器的 root 文件系统，意味着不能对容器内容进行修改。


```
read_only: true
```
---


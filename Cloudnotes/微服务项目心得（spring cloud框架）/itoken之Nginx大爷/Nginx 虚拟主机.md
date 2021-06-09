# 安装 Nginx

我们使用 Docker 来安装和运行 Nginx，==docker-compose.yml== 配置如下：


```
version: '3.1'
services:
  nginx:
    restart: always
    image: nginx
    container_name: nginx
    ports:
      - 81:80
    volumes:
      - ./conf/nginx.conf:/etc/nginx/nginx.conf
      - ./wwwroot:/usr/share/nginx/wwwroot
```

---

# 什么是虚拟主机？

虚拟主机是一种特殊的软硬件技术，它可以将网络上的每一台计算机分成多个虚拟主机，每个虚拟主机可以独立对外提供 www 服务，这样就可以实现一台主机对外提供多个 web 服务，每个虚拟主机之间是独立的，互不影响的。

通过 Nginx 可以实现虚拟主机的配置，Nginx 支持三种类型的虚拟主机配置

- 基于 IP 的虚拟主机
- 基于域名的虚拟主机
- ==基于端口的虚拟主机==

---

# Nginx 配置文件的结构


```
# ...
events {
    # ...
}

http {
    # ...
    server{
        # ...
    }

    # ...
    server{
        # ...
    }
}
```
###### ==注==： 每个 server 就是一个虚拟主机

---

# 基于端口的虚拟主机配置

#### 需求

- Nginx 对外提供 80 和 8080 两个端口监听服务
- 请求 80 端口则请求 html80 目录下的 html
- 请求 8080 端口则请求 html8080 目录下的 html

#### 创建目录及文件

在 ==/usr/local/docker/nginx/wwwroot== 目录下创建 ==html80== 和 ==html8080== 两个目录，并分辨创建两个 index.html 文件

#### 配置虚拟主机

修改 ==/usr/local/docker/nginx/conf== 目录下的 nginx.conf 配置文件：


```
http {
    include       mime.types;
    default_type  application/octet-stream;

    sendfile        on;

    keepalive_timeout  65;
    # 配置虚拟主机 192.168.75.145
    server {
    # 监听的ip和端口，配置 192.168.75.145:80
        listen       80;
    # 虚拟主机名称这里配置ip地址
        server_name  192.168.75.145;
    # 所有的请求都以 / 开始，所有的请求都可以匹配此 location
        location / {
        # 使用 root 指令指定虚拟主机目录即网页存放目录
        # 比如访问 http://ip/index.html 将找到 /usr/local/docker/nginx/wwwroot/html80/index.html
        # 比如访问 http://ip/item/index.html 将找到 /usr/local/docker/nginx/wwwroot/html80/item/index.html

            root   /usr/share/nginx/wwwroot/html80;
        # 指定欢迎页面，按从左到右顺序查找
            index  index.html index.htm;
        }

    }
    # 配置虚拟主机 192.168.75.245
    server {
        listen       8080;
        server_name  192.168.75.145;

        location / {
            root   /usr/share/nginx/wwwroot/html8080;
            index  index.html index.htm;
        }
    }
}
```

---

# 基于域名的虚拟主机配置

#### 需求

- 两个域名指向同一台 Nginx 服务器，用户访问不同的域名显示不同的网页内容
- 两个域名是 admin.service.itoken.funtl.com 和 admin.web.itoken.funtl.com
- Nginx 服务器使用虚拟机 192.168.75.145

#### 配置 Windows Hosts 文件
 
- 通过 host 文件指定 admin.service.itoken.funtl.com 和 admin.web.itoken.funtl.com 对应 192.168.75.145 虚拟机：
- 修改 window 的 hosts 文件：（C:\Windows\System32\drivers\etc）

#### 创建目录及文件

在 ==/usr/local/docker/nginx/wwwroot== 目录下创建 ==htmlservice== 和 ==htmlweb== 两个目录，并分辨创建两个 index.html 文件

#### 配置虚拟主机


```
user  nginx;
worker_processes  1;

events {
    worker_connections  1024;
}

http {
    include       mime.types;
    default_type  application/octet-stream;

    sendfile        on;

    keepalive_timeout  65;
    server {
        listen       80;
        server_name  admin.service.itoken.funtl.com;
        location / {
            root   /usr/share/nginx/wwwroot/htmlservice;
            index  index.html index.htm;
        }

    }

    server {
        listen       80;
        server_name  admin.web.itoken.funtl.com;

        location / {
            root   /usr/share/nginx/wwwroot/htmlweb;
            index  index.html index.htm;
        }
    }
}
```






































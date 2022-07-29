# 简介
GitLab 是利用 Ruby on Rails 一个开源的版本管理系统，实现一个自托管的 Git 项目仓库，可通过 Web 界面进行访问公开的或者私人项目。它拥有与 Github 类似的功能，能够浏览源代码，管理缺陷和注释。可以管理团队对仓库的访问，它非常易于浏览提交过的版本并提供一个文件历史库。团队成员可以利用内置的简单聊天程序 (Wall) 进行交流。它还提供一个代码片段收集功能可以轻松实现代码复用，便于日后有需要的时候进行查找。


---


# 基于 Docker 安装 GitLab

我们使用 Docker 来安装和运行 GitLab 中文版，由于新版本问题较多，这里我们使用目前相对稳定的 10.5 版本，docker-compose.yml 配置如下：（使用空格缩进）


```yml
version: '3'
services:
    web:
      image: 'twang2218/gitlab-ce-zh:10.5'
      restart: always
      hostname: '192.168.75.145'
      environment:
        TZ: 'Asia/Shanghai'
        GITLAB_OMNIBUS_CONFIG: |
          external_url 'http://192.168.75.145:8080'
          gitlab_rails['gitlab_shell_ssh_port'] = 2222
          unicorn['port'] = 8888
          nginx['listen_port'] = 8080
      ports:
        - '8080:8080'
        - '8443:443'
        - '2222:22'
      volumes:
        - /usr/local/docker/gitlab/config:/etc/gitlab
        - /usr/local/docker/gitlab/data:/var/opt/gitlab
        - /usr/local/docker/gitlab/logs:/var/log/gitlab
```
### 安装完成后的工作
访问地址：http://ip:8080
端口 8080 是因为我在配置中设置的外部访问地址为 8080，默认是 80

设置管理员初始密码，这里的密码最好是 字母 + 数字 组合，并且 大于等于 8 位
配置完成后登录，管理员账号是 root

### GitLab 的基本设置
第一次使用时需要做一些初始化设置，点击“管理区域”–>“设置”



##### 账户与限制设置

关闭头像功能，由于 Gravatar 头像为网络头像，在网络情况不理想时可能导致访问时卡顿



##### 注册限制

由于是内部代码托管服务器，可以直接关闭注册功能，由管理员统一创建用户即可

### GitLab 的账户管理
###### 使用时请不要直接通过 root 用户操作，需要先创建用户，然后通过创建的用户操作，如果你是管理员还需要为其他开发人员分配账户

##### 创建用户

点击“管理区域”–>“新建用户”



##### 设置账户信息

同时你可以将自己设置为管理员



##### 修改用户密码

由于我们创建时并没有配置邮箱，所以还需要重新编辑用户信息并手动设置密码





##### 退出并使用新账户登录



###### 注意：创建完账户，第一次登录时还会提示你修改登录密码


---


# GitLab 创建第一个项目
使用 SSH 的方式拉取和推送项目

生成 SSH KEY

使用 ssh-keygen 工具生成，位置在 Git 安装目录下，==C:\Program Files\Git\usr\bin==

输入命令：

```sh
ssh-keygen -t rsa -C "your_email@example.com"
```


秘钥位置在：C:\Users\你的用户名\.ssh 目录下，找到 id_rsa.pub 并使用编辑器打开，复制 SSH-KEY 信息到 GitLab

登录 GitLab，点击“用户头像”–>“设置”–>“SSH 密钥”

成功增加密钥

### 使用 TortoiseGit 克隆项目

- 新建一个存放代码仓库的本地文件夹
- 在文件夹空白处按右键
- 选择“Git 克隆…”

服务项目地址到 URL 

如果弹出连接信息请选择是

成功克隆项目到本地

### 使用 TortoiseGit 推送项目（提交代码）

创建或修改文件（这里的文件为所有文件，包括：代码、图片等）

右键呼出菜单，选择“提交 Master…”

点击“全部”并填入“日志信息”

点击“提交并推送”

去GitLab查看确认提交修改成功


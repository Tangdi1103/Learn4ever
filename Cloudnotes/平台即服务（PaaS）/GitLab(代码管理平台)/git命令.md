使用 git clone 拷贝一个 Git 仓库到本地，让自己能够查看该项目，或者进行修改。


```
git clone url
```

==**标签**==

==-a== 选项意为”创建一个带注解的标签”。 不用 ==-a== 选项也可以执行的，但它不会记录这标签是啥时候打的，谁打的，也不会让你添加个标签的注解。 我推荐一直创建带注解的标签。

```
git tag -a v1.0.0
```

==**查看/修改用户名、邮箱**==


```
查看
$ git config --global -l

$ git config user.name

$ git config user.email

修改

$ git config --global user.name "username"
 
$ git config --global user.email "email"
```

==**使用代理**==
```
git config --global http.proxy http://127.0.0.1:1080
git config --global https.proxy http://127.0.0.1:8080
```

==**取消代理**==

```
git config --global --unset http.proxy
git config --global --unset https.proxy
```

**==window自动化脚本==**
```
e:                                  这是我脚本放的盘，我放在E盘中
cd markdown                         这是脚本的具体路径，E:\markdown
下面这三个执行就好
git add .                           
git commit -m "shy auto save"       shy auto save是自定义的
git push -u origin master 

```

**==查看/添加远程仓库==**

```shell
#查看当前项目远程仓库
git remote
origin

#查看当前项目远程仓库地址
git remote -v
origin  https://github.com/gozhuyinglong/blog-demos.git (fetch)
origin  https://github.com/gozhuyinglong/blog-demos.git (push)

#重命名远程仓库
git remote rename <old_remote> <new_remote>
git remote rename origin github

#修改远程地址
git remote set-url <remote> <url>

#添加远程仓库
git remote add <remote> <url>
git remote add gitee https://gitee.com/gozhuyinglong/blog-demos.git

#拉取及推送
git push <remote> <branch>
git pull <remote> <branch>

git pull github master
git push github master
git pull gitee master
git push gitee master

#移除远程仓库
git remote remove <remote>
git remote remove gitee
```


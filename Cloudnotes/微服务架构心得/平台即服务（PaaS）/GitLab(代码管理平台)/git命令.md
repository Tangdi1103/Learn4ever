使用 git clone 拷贝一个 Git 仓库到本地，让自己能够查看该项目，或者进行修改。


```
git clone ssh://....
```


---

### 拉取与推送
==**git pull**==

git pull命令用于从另一个存储库或本地分支获取并集成(整合)。git pull命令的作用是：取回远程主机某个分支的更新，再与本地的指定分支合并，它的完整格式稍稍有点复杂。


```
git pull <远程主机名> <远程分支名>:<本地分支名>
```
**==git push==**

git push命令用于将本地分支的更新，推送到远程主机。它的格式与git pull命令相似。


```
git push <远程主机名> <本地分支名>:<远程分支名>
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
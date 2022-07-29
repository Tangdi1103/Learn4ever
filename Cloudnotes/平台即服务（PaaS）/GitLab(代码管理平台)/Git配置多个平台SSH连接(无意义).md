[toc]

# 一、生成多个SSH密钥

```sh
ssh-keygen -t rsa -C "1112346@qq.com" -f ~/.ssh/gitlab_id-rsa
ssh-keygen -t rsa -C "1112346@qq.com" -f ~/.ssh/github_id-rsa
```

# 二、将对应得公钥分别Add到不同平台账户的SSH KEY中



# 三、创建 ~/.ssh/config

-Host git仓库地址 
-HostName git仓库别名

```
Host 192.168.0.28
 HostName 192.168.0.28
 Port 22
 User 你自己的邮箱1
 IdentityFile ~/.ssh/~/.ssh/gitlab_id-rsa

Host github.com
 HostName github.com
 User 你自己的邮箱2
 IdentityFile ~/.ssh/.ssh/github_id-rsa
```

# 四、测试

```sh
ssh -T git@github.com
ssh -T git@192.168.0.28
```




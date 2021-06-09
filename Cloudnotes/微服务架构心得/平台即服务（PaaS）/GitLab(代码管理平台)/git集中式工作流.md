基于你后续会持续和克隆的仓库做交互的假设，克隆仓库时 Git 会自动添加远程别名 origin 指回『父』仓库。
```
git clone https://github.com/path/to/repo.git
```

请记住，因为这些命令生成的是本地提交，小明可以按自己需求反复操作多次，而不用担心中央仓库上有了什么操作。对需要多个更简单更原子分块的大功能，这个做法是很有用的。

暂存区的用来准备一个提交，但可以不用把工作目录中所有的修改内容都包含进来。这样你可以创建一个高度聚焦的提交，尽管你本地修改很多内容。

```
git status # 查看本地仓库的修改状态
git add # 暂存文件
git commit # 提交文件
```

小红用 git pull 合并上游的修改到自己的仓库中。这条命令类似 svn update ——拉取所有上游提交命令到小红的本地仓库，并尝试和她的本地修改合并：
```
git pull --rebase origin master
```

如果小红和小明的功能是相关的，不大可能在 rebase 过程中有冲突。如果有，Git 在合并有冲突的提交处暂停 rebase 过程，输出下面的信息并带上相关的指令：


```
CONFLICT (content): Merge conflict in
```

接着小红编辑这些文件。修改完成后，用老套路暂存这些文件，并让 git rebase 完成剩下的事：

要做的就这些了。Git 会继续一个一个地合并后面的提交，如其它的提交有冲突就重复这个过程。

```
git add
git rebase --continue
```

如果你碰到了冲突，但发现搞不定，不要惊慌。只要执行下面这条命令，就可以回到你执行 git pull --rebase 命令前的样子：


```
git rebase --abort
```

小红完成和中央仓库的同步后，就能成功发布她的修改了：
```
git push origin master
```



















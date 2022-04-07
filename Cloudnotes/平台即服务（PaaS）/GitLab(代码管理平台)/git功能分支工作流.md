在开始开发功能前，小红需要一个独立的分支。使用下面的命令新建一个分支：


```
git checkout -b marys-feature master
```

这个命令检出一个基于 master 名为 marys-feature 的分支，Git 的 -b 选项表示如果分支还不存在则新建分支。这个新分支上，小红按老套路编辑、暂存和提交修改，按需要提交以实现功能：


```
git status
git add
git commit
```

---

早上小红为新功能添加一些提交。去吃午饭前，push 功能分支到中央仓库是很好的做法，这样可以方便地备份，如果和其它开发协作，也让他们可以看到小红的提交。


```
git push -u origin marys-feature
```
这条命令 push marys-feature 分支到中央仓库（origin），-u 选项设置本地分支去跟踪远程对应的分支。设置好跟踪的分支后，小红就可以使用 git push 命令省去指定推送分支的参数。


---

一旦小黑可以的接受 Pull Request，就可以合并功能到稳定项目代码中（可以由小黑或是小红来做这个操作）：


```
git checkout master
git pull
git pull origin marys-feature
git push
```
无论谁来做合并，首先要检出 master 分支并确认是它是最新的。然后执行 git pull origin marys-feature 合并 marys-feature 分支到和已经和远程一致的本地 master 分支。你可以使用简单 git merge marys-feature 命令，但前面的命令可以保证总是最新的新功能分支。最后更新的 master 分支要重新 push 回到 origin。


---




























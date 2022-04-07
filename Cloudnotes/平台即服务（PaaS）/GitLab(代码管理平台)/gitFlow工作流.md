常用的分支约定：

- 用于新建发布分支的分支: develop
- 用于合并的分支: master
- 分支命名: release- 或 release/
- 

### 示例

##### 创建开发分支


第一步为 master 分支配套一个 develop 分支。简单来做可以本地创建一个空的 develop 分支，push 到服务器上：


```
git branch develop
git push -u origin develop
```

以后这个分支将会包含了项目的全部历史，而 master 分支将只包含了部分历史。其它开发者这时应该克隆中央仓库，建好 develop 分支的跟踪分支：


```
git clone ssh://user@host/path/to/repo.git
git checkout -b develop origin/develop
```

##### 小红和小明开始开发新功能

这个示例中，小红和小明开始各自的功能开发。他们需要为各自的功能创建相应的分支。新分支不是基于 master 分支，而是应该基于 develop 分支：


```
git checkout -b some-feature develop
```

他们用老套路添加提交到各自功能分支上：编辑、暂存、提交：


```
git status
git add
git commit
```

##### 小红完成功能开发

添加了提交后，小红觉得她的功能 OK 了。如果团队使用 Pull Requests，这时候可以发起一个用于合并到 develop 分支。否则她可以直接合并到她本地的 develop 分支后 push 到中央仓库：


```
git pull origin develop
git checkout develop
git merge some-feature
git push
git branch -d some-feature
```

第一条命令在合并功能前确保 develop 分支是最新的。注意，功能决不应该直接合并到 master 分支。冲突解决方法和集中式工作流一样。

##### 小红开始准备发布

这个时候小明正在实现他的功能，小红开始准备她的第一个项目正式发布。像功能开发一样，她用一个新的分支来做发布准备。这一步也确定了发布的版本号：


```
git checkout -b release-0.1 develop
```

##### 小红完成发布

一旦准备好了对外发布，小红合并修改到 master 分支和 develop 分支上，删除发布分支。合并回 develop 分支很重要，因为在发布分支中已经提交的更新需要在后面的新功能中也要是可用的。


```
git checkout master
git merge release-0.1
git push
git checkout develop
git merge release-0.1
git push
git branch -d release-0.1
```

发布分支是作为功能开发（develop 分支）和对外发布（master 分支）间的缓冲。只要有合并到 master 分支，就应该打好 Tag 以方便跟踪。


```
git tag -a 0.1 -m "Initial public release" master
git push --tags
```

##### 最终用户发现 Bug

对外发布后，小红回去和小明一起做下个发布的新功能开发，直到有最终用户开了一个 Ticket 抱怨当前版本的一个 Bug。为了处理 Bug，小红（或小明）从 master 分支上拉出了一个维护分支，提交修改以解决问题，然后直接合并回 master 分支：


```
git checkout -b issue-#001 master
# Fix the bug
git checkout master
git merge issue-#001
git push
```

就像发布分支，维护分支中新加这些重要修改需要包含到 develop 分支中，所以小红要执行一个合并操作。然后就可以安全地删除这个分支了：


```
git checkout develop
git merge issue-#001
git push
git branch -d issue-#001
```




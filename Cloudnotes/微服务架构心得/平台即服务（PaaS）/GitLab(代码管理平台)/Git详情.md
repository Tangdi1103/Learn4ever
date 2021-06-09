# 简介
- Git 是一个开源的分布式版本控制系统，用于敏捷高效地处理任何或小或大的项目。
- Git 是 Linus Torvalds 为了帮助管理 Linux 内核开发而开发的一个开放源码的版本控制软件。
- Git 与常用的版本控制工具 CVS, Subversion 等不同，它采用了分布式版本库的方式，不必服务器端软件支持。

# 下载安装
下载地址：++https://git-scm.com/downloads++

安装路径为默认路径，不要修改。安装完成后在cmd里面测试是否设置了Path,是否安装成功. 在CMD中输入 git 或者 git –version 试试

```
git version 2.14.3.windows.1
```



# Git工作流程
- 克隆 Git 资源作为工作目录。
- 在克隆的资源上添加或修改文件。
- 如果其他人修改了，你可以更新资源。
- 在提交前查看修改。
- 提交修改。
- 在修改完成后，如果发现错误，可以撤回提交并再次修改并提交。

![image](https://note.youdao.com/yws/public/resource/c5be5802daf0385d18fbdfde57d959e9/xmlnote/20B0E22BD93944B487C4BB653847AAD8/1181)

# TortoiseGit（简化Git操作）
TortoiseGit, 中文名海龟 Git，只支持 Windows 系统, 有一个前辈海龟 SVN, TortoiseSVN 和 TortoiseGit 都是非常优秀的开源的版本库客户端. 分为 32 位版与 64 位版.并且支持各种语言,包括简体中文

下载地址：++https://tortoisegit.org/download/++
（必须在安装完成Git后安装）

**配置**

在空白处点击鼠标右键, 选择 –> TortoiseGit –> Settings, 然后就可以看到配置界面
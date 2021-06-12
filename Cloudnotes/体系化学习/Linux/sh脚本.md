### 一、需求背景

​		我一直用有道云做笔记，有道云笔记的缺点有，1.环境不可靠，经常出现同步不了笔记。2.有不少丢失笔记案例。3.一片md的笔记篇幅上三千字，记笔记就很卡。4.有道云笔记不能如Tp可以实时浏览并编写md。这使非常看着笔记的我不得不考虑转移阵地了！！现在使用Typora+github来做云笔记，突然觉得Tp是真的香！！做笔记的电脑可能是用公司电脑也可能是自己的PC，另外同时使用github和gitee做版本库保证环境的可靠性。

### 二、需求描述

​		因为我有两台PC做笔记，为了防止两边做的笔记push后被互相覆盖，所以在记笔记前必须pull，push的时候同时push到github和gitee。为此我打算写两个脚本去自动化这些重复的过程。

​		1.InitorPull.sh：提供初始化git仓库并关联github和gitee远程库；获取远程库最新代码；

​		2.CommitorPush.sh：提供添加并提交本地库，然后push到github和gitee远程库中

### 二、sh脚本

1.InitorPull.sh

​	windows下的shell脚本，使用Git bash打开

```shell
# 报错则退出
set -o errexit

githuburl=https://github.com/Tangdi1103/mynotes.git
giteeurl=https://gitee.com/Tangdi1103/mynotes.git

# 操作类型，init和pull区别在于，脚本执行init时不能在脚本当前目录创建云笔记版本库
read -p "请输入操作类型(init/pull)：" operation
# 直接启动并输入参数	比	手动启动dos并输入参数更方便
read -p "请输入远程库(github/gitee)：" gitType

if [[ $operation == 'init' && ($gitType == 'gitee' || $gitType == 'github') ]]; then
	mkdir -p mynotes
	cd mynotes

	# 初始化一个本地git仓库并获得执行结果，即使当前目录已存在本地库，git init命令并不会报错
	testGit=`git init`
	# 远程库
	initStr=`git remote -v`
	# 打印结果
	echo $testGit
	echo $initStr

	# 若初始化成功
	if [[ $testGit =~ 'Initialized empty Git' ]]; then

		# 入参gitee或github
		if [[ $gitType == "github" || $gitType == "gitee" ]]; then
			# 绑定远程仓库命名为github
			git remote add github $githuburl
			# 并再添加gitee远程库
			git remote add gitee $giteeurl

			# 拉取远程库代码到本地库
			git pull $gitType master
		else
			echo "coundn't found remote"
		fi
	elif [[ $initStr =~ '' ]]; then
		
		# 入参gitee或github
		if [[ $gitType == "github" || $gitType == "gitee" ]]; then
			# 绑定远程仓库命名为github
			git remote add github $githuburl
			# 并再添加gitee远程库
			git remote add gitee $giteeurl

			# 拉取远程库代码到本地库
			git pull $gitType master
		else
			echo "coundn't found remote"
		fi
	else
		echo "已有云笔记，请勿重复创建"
	fi
elif [[ $operation == 'pull' && ($gitType == 'gitee' || $gitType == 'github') ]]; then
	str=`git remote -v`

	# 如果为云笔记库
	if [[ $str =~ 'ynotes' ]]; then
		if [[ $str =~ 'github' && $str =~ 'gitee' ]]; then
			# 若github和gitee存在，则pull最新拉去代码
			echo git pull $gitType master
			git pull $gitType master
		elif [[ $str =~ 'github' ]]; then
			# 若只存在github
			git remote rename origin github
			git remote add gitee $giteeurl

			echo git pull $gitType master
			git pull $gitType master
		elif [[ $str =~ 'gitee' ]]; then
			# 若只存在gitee
			git remote rename origin gitee
			git remote add github $githuburl

			echo git pull $gitType master
			git pull $gitType master
		fi
	else
		echo '当前非云笔记库，请勿pull操作'
	fi
else
	echo "操作类型或远程仓库有误"
fi

read -p "输入任意键退出..." d
exit
```

2.CommitorPush.sh

```shell
# 报错则退出
set -o errexit

desc=null
read -p "please input your commitDesc：" desc
git add .
git commit -m $desc

git push gitee master
git push github master
git status
```


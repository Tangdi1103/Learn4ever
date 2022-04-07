# 报错则退出
set -o errexit

githuburl=git@github.com:Tangdi1103/Learn4ever.git
giteeurl=https://gitee.com/Tangdi1103/Learn4ever.git


# 操作类型，init和pull区别在于，脚本执行init时不能在脚本当前目录创建云笔记版本库
read -p "请输入操作类型(init/pull)：" operation
# 直接启动并输入参数	比	手动启动dos并输入参数更方便
read -p "请输入远程库(github/gitee)：" gitType

if [[ $operation == 'init' && ($gitType == 'gitee' || $gitType == 'github') ]]; then
	mkdir -p Learn4ever
	cd Learn4ever

	# 初始化一个本地git仓库并获得执行结果，即使当前目录已存在本地库，git init命令并不会报错
	testGit=`git init`
	# 远程库
	initStr=`git remote -v`
	# 打印结果
	echo $testGit
	echo $initStr

	# 若初始化成功
	if [[ $testGit =~ 'Initialized empty Git' ]]; then
		# 绑定远程仓库命名为github
		git remote add github $githuburl
		# 并再添加gitee远程库
		git remote add gitee $giteeurl

		# 拉取远程库代码到本地库
		git pull $gitType master
	elif [[ $initStr =~ '' ]]; then
		# 绑定远程仓库命名为github
		git remote add github $githuburl
		# 并再添加gitee远程库
		git remote add gitee $giteeurl

		# 拉取远程库代码到本地库
		git pull $gitType master
	else
		echo "请勿重复创建"
	fi
elif [[ $operation == 'pull' && ($gitType == 'gitee' || $gitType == 'github') ]]; then
	str=`git remote -v`

	
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
	echo "操作类型或远程仓库有误"
fi

read -p "输入任意键退出..." d
exit
# 报错则退出
set -o errexit

if [[ $1 =~ 'git' ]]; then
	# 初始化一个本地git仓库并获得执行结果，即使当前目录已存在本地库，git init命令并不会报错
	initResult=`git init`
	# 打印结果
	echo $initResult

	# 根据init结果判断是否存在
	if [[ $initResult =~ 'existing Git' ]]; then
		# 若存在，pull最新拉去代码
		echo git pull $1 master
		git pull $1 master
	fi


	# 若初始化成功
	if [[ $initResult =~ 'Initialized empty Git' ]]; then
		# 打印入参绑定得git-url
		echo git remote add origin $1
		# 绑定远程仓库
		git remote add origin $1
		# 拉取远程库代码到本地库
		git pull origin master

		# url=null
		# read -p "please input your giturl：" url
		# echo git remote add origin url
		# git remote add origin url

		if [[ $1 =~ "github" ]]; then
			# 重新命名远程仓库为github，并在添加gitee远程库
			git remote rename origin github
			git remote add gitee https://gitee.com/Tangdi1103/mynotes.git

		elif [[ $1 =~ "gitee" ]]; then
			# 重新命名远程仓库为gitee ，并在添加github远程库
			git remote rename origin gitee
			git remote add github https://github.com/Tangdi1103/mynotes.git

		else
			echo "coundn't found remote"
			errexit
		fi
	fi
else
	echo "入参有误"
fi
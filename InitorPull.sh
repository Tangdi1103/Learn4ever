# 报错则退出
set -o errexit

githuburl=https://github.com/Tangdi1103/mynotes.git
giteeurl=https://gitee.com/Tangdi1103/mynotes.git

# 直接启动并输入参数	比	手动启动dos并输入参数更方便
read -p "请输入远程库github/gitee：" gitType

if [[ $gitType =~ 'git' ]]; then
	# 初始化一个本地git仓库并获得执行结果，即使当前目录已存在本地库，git init命令并不会报错
	initResult=`git init`
	# 打印结果
	echo $initResult

	# 根据init结果判断是否存在
	if [[ $initResult =~ 'existing Git' ]]; then
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
				git remote add github $github

				echo git pull $gitType master
				git pull $gitType master
			fi
		elif [[ $str =~ '' ]]; then
			# url=null
			# read -p "please input your giturl：" url
			# echo git remote add origin url
			# git remote add origin url

			if [[ $gitType =~ "github" ]]; then
				# 打印入参绑定得git-url
				echo git remote add github $githuburl
				# 绑定远程仓库命名为github
				git remote add github $githuburl
				# 拉取远程库代码到本地库
				git pull github master

				# 并再添加gitee远程库
				git remote add gitee $giteeurl

			elif [[ $gitType =~ "gitee" ]]; then
				# 打印入参绑定得git-url
				echo git remote add gitee $giteeurl
				# 绑定远程仓库命名为github
				git remote add gitee $giteeurl
				# 拉取远程库代码到本地库
				git pull gitee master


				# 并再添加github远程库
				git remote add github $githuburl
			else
				echo "coundn't found remote"
			fi
		else
			echo '当前非云笔记库，不做操作'
		fi
	fi


	# 若初始化成功
	if [[ $initResult =~ 'Initialized empty Git' ]]; then
		# url=null
		# read -p "please input your giturl：" url
		# echo git remote add origin url
		# git remote add origin url

		if [[ $gitType =~ "github" ]]; then
			# 打印入参绑定得git-url
			echo git remote add github $githuburl
			# 绑定远程仓库命名为github
			git remote add github $githuburl
			# 拉取远程库代码到本地库
			git pull github master

			# 并再添加gitee远程库
			git remote add gitee $giteeurl

		elif [[ $gitType =~ "gitee" ]]; then
			# 打印入参绑定得git-url
			echo git remote add gitee $giteeurl
			# 绑定远程仓库命名为github
			git remote add gitee $giteeurl
			# 拉取远程库代码到本地库
			git pull gitee master


			# 并再添加github远程库
			git remote add github $githuburl
		else
			echo "coundn't found remote"
		fi
	fi

else
	echo "入参有误"
fi

read -p "输入任意键退出..." d
exit
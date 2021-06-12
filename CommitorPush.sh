# 报错则退出
set -o errexit

# 直接启动并输入参数	比	手动启动dos并输入参数更方便
read -p "请输入远程库(github/gitee)：" gitType

if [[ $gitType == 'github' || $gitType == 'gitee' ]]; then
	git pull $gitType master

	desc=null
	read -p "please input your commitDesc：" desc
	git add .
	git commit -m $desc

	git push gitee master
	git push github master
	git status
else
	echo '入参有误'
fi

read -p "输入任意键退出..." d
exit
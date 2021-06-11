# 报错则退出
set -o errexit

desc=null
read -p "please input your commitDesc：" desc
git add .
git commit -m $desc

git push gitee master
git push github master
git status
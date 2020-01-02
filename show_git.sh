#!/bin/bash
# init
function pause(){
  read -p "$*"
}
# 总的提交人数：
A=$(git log --pretty='%aN' | sort -u | wc -l)
#A=79
# 总的Tag数
V=480

# 总提交次数统计：
B=$(git log --oneline | wc -l)
#B=12649
# Git上的总代码量：
read -r C D E <<< $(git log --pretty=tformat: --numstat | awk '{ add += $1; subs += $2; loc += $1 - $2 } END {print add" "subs" "loc}')
#C=1692534
#D=907130
#E=785404
# 代码删除与存量比
F=$(awk "BEGIN {print $C/$E}")
# 代码行数A4纸张数
G=$((C/43))
# 以桶计
H=$(($G/22))

echo "《XXX1.0》自开发已悄然发布 ${V} 次版本及补丁"\

echo "有 ${A} 个用户名参与，收到了 ${B} 次的代码提交"\

echo "在所有开发者的努力下共编写 ${C} 行代码"\

echo "如果用默认字号打印出来，可以打印 ${G} 张A4纸"\

echo "使用中的最新代码仅有 ${E} 行"\

echo "因需求变化而被废弃的代码大约有 ${D} 行"\

echo "如果打印出来揉成团，可以装满 ${H} 个垃圾桶"\

echo "《XXX2.0》不负众望"\

echo "后台开发者将继续本着“码出高质，码出高效”"\

echo "让质量与效率齐头并进"\

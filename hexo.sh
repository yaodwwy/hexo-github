#!/usr/bin/env bash
# 可以在git bash中运行

# 全局安装hexo客户端
npm install hexo-cli -g

# 初始化 创建目录并切换到该目录
hexo init --no-clone hexo-github && cd hexo-github

# 初始依赖 # git部署依赖 # 样式依赖
npm install hexo --save && npm install hexo-deployer-git --save && npm install hexo-renderer-sass --save

#删除默认样式
rm -rf themes/landscape/ && rm -rf source/_posts/hello-world.md

# 测试ssh安全登录
ssh -T git@github.com
read -p "请确认公钥配置正常? 键入 Enter 继续..."
if [[ $?="0" ]]; then
   #Clone with SSH 先克隆到临时文件夹 再把temp中的所有文件都移动到hexo-coding
   git clone git@github.com:yaodwwy/hexo-github.git ../temp
   read -p "请再次确认公钥配置正常? 键入 Enter 继续..."
   cp -rf ../temp/* ../temp/.git ../temp/.gitignore . && rm -rf ../temp/
else
   echo "貌似 id_rsa.pub创建错误！"
   exit 1
fi

# 清理 # 启动
hexo clean && hexo server
# 部署
#hexo d -g
---
title: 开发者常用镜像仓库地址
date: 2020-01-02 10:15:00
tag: Linux
---

一键设置更新中国地区仓库镜像，兼容centos raspbian debian ubuntu alpine。
自动更新镜像源为阿里开发者镜像仓库

##使用方法
#### Linux更新软件源一键脚本

如果你的服务器上安装有 curl 工具，请使用以下命令执行脚本：

    curl -fsSL https://adbyte.cn/files/cn-mirror.sh | sh
    
如果你的服务器上安装有 wget 工具，请使用以下命令执行脚本：

    wget -qO- https://adbyte.cn/files/cn-mirror.sh | sh


#### Maven仓库地址配置
```xml
<settings>
    <mirrors>
        <mirror>
            <id>alimaven</id>
            <name>aliyun maven</name>
            <url>http://maven.aliyun.com/nexus/content/groups/public/</url>
            <mirrorOf>central</mirrorOf>
        </mirror>
    </mirrors>
</settings>
```

#### NodeJs源配置

修改源地址为淘宝 NPM 镜像

    npm config set registry http://registry.npm.taobao.org/
    
修改源地址为官方源

    npm config set registry https://registry.npmjs.org/
    

>推荐使用定制的 cnpm (gzip 压缩支持) 命令行工具代替默认的 npm:

    npm install -g cnpm --registry=https://registry.npm.taobao.org
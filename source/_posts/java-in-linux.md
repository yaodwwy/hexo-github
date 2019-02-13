---
title: Linux下Java开发问题
date: 2019-01-12 10:15:00
tag: CentOS
---

   本篇针对Linux环境下JAVA常用开发，配置，环境等使用细节及跳坑汇总。
   
### Java环境篇

> 下载Java并解压JDK包

    $ wget --no-check-certificate -c -P /data/ https://download.java.net/openjdk/jdk11/ri/openjdk-11+28_linux-x64_bin.tar.gz
    $ tar -zxvf openjdk-11+28_linux-x64_bin.tar.gz
    
> 配置JAVA环境变量

    $ vi /etc/profile.d/jdk.sh
    =======输入以下内容=======>>
        export JAVA_HOME=/data/jdk-10.0.1
        export PATH=$JAVA_HOME/bin:$PATH
        export CLASSPATH=.:$JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tools.jar
    <<=========================
    $ source /etc/profile
    $ java -version
    
>解决因Linux的AWT字体组件缺失而导致的 FontConfiguration.getVersion 异常
FontConfig

Linux 生产环境下部署项目时出现如下异常：`java.lang.NullPointerException at sun.awt.FontConfiguration.getVersion（FontConfiguration.java 1264）`
经过一翻折腾，发现是系统组件缺失导致的。解决方法如下：

    # 安装FontConfig组件
    yum install -y fontconfig
    fc-cache --force
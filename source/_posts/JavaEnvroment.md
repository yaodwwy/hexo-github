---
title: Linux Java环境搭建
date: 2019-01-12 10:15:00
tag: CentOS
---

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
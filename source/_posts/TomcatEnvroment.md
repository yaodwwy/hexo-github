---
title: Tomcat环境搭建与常用配置
date: 2019-01-12 10:15:00
tag: CentOS
---

### Tomcat环境篇

> 下载Tomcat并解压

    $ wget -c -P /data/ https://www-eu.apache.org/dist/tomcat/tomcat-9/v9.0.13/bin/apache-tomcat-9.0.13.tar.gz
    $ tar -zxvf apache-tomcat-9.0.13.tar.gz

> Tomcat实时查看日志：

    $ tail -fn 1000 /data/tomcat/logs/catalina.out
    
#### Tomcat界面管理员配置

> user.xml(配置管理员用户名密码，用于管理/host-manager和/manager)：

    <role rolename="admin-gui"/>
        <role rolename="admin-script"/>
        <role rolename="manager-gui"/>
        <role rolename="manager-script"/>
        <role rolename="manager-jmx"/>
        <role rolename="manager-status"/>
        <user username="admin" password="sleep@10" 
        roles="admin-gui,admin-script,manager-gui,manager-script,manager-jmx,manager-status"/>
        
> context.xml(配置远程IP允许)：

    <Valve className="org.apache.catalina.valves.RemoteAddrValve"  
    allow="127\.\d+\.\d+\.\d+|::1|0:0:0:0:0:0:0:1|\d+\.\d+\.\d+\.\d+" />  

#### Tomcat hot deploy 远程热部署支持(JRebel)：

> 客户端Idea安装JRebel插件添加 Remote Server 配置 Server authentication 的密码`sleep@10`即可

    $ wget -c -P /data http://dl.zeroturnaround.com/jrebel-stable-nosetup.zip
    $ unzip jrebel-stable-nosetup.zip
    $ vim /data/tomcat/bin/catalina-jrebel.sh
    
    =======输入以下内容=======>>
    #!/bin/sh
    export REBEL_HOME="/data/jrebel"
    export CATALINA_PID="/data/tomcat/bin/catalina.pid"
    export JAVA_OPTS="-agentpath:$REBEL_HOME/lib/libjrebel64.so -Dspring.profiles.active=test -Drebel.remoting_plugin=true $JAVA_OPTS"
    `dirname $0`/startup.sh $@
    <<=========================
    
    $ java -jar /data/jrebel/jrebel.jar -set-remote-password sleep@10
    
    $ ./data/tomcat/bin/catalina-jrebel.sh
    
>Notice: 首次部署会全部同步，缓存清理方式：rm -rf /root/.jrebel/cache/*

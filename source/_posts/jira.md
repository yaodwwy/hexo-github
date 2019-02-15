---
title: jira 7.12.3 版本 Docker 部署及破解
date: 2019-02-15 13:15:00
tag: jira
---

### 脚本已经编译进容器里了

    # 先正常安装配置注册登录
    docker run -p 8080:8080 -d yaodwwy/jira:7.12.3
    
### 进入试用模式,默认29天到期

    # 拉取镜像并进入jira容器的bash 停止jira
    sh /opt/atlassian/jira/bin/stop-jira.sh
    
### 加入破解文件

    # 进入docker主机下的这个目录,备份此文件，最后把atlassian-extras-3.1.2.jar文件放到lib目录
    /var/lib/docker/volumes/compose_jira-app/_data/atlassian-jira/WEB-INF/lib/atlassian-extras-3.2.jar
    
### 重新启动

    # 进入jira容器的bash 启动jira
    sh /opt/atlassian/jira/bin/start-jira.sh
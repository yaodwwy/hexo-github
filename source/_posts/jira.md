---
title: jira 7.12.3 版本 Docker 部署
date: 2019-02-15 13:15:00
tag: jira
---

jira是Atlassian公司出品的项目与事务跟踪工具，被广泛应用于缺陷跟踪（bug管理）、客户服务、需求收集、流程审批、任务跟踪、项目跟踪和敏捷管理等工作领域。

### 脚本已经编译进容器里了

    # 先通过 docker-compose.yml 运行容器
    
```yaml
    version: '3.3'
    services:
      jira:
        image: "yaodwwy/jira:7.12.3"
        container_name: jira
        ports:
          - "3618:8080"
        volumes:
          - jira-config:/var/atlassian/jira
          - jira-app:/opt/atlassian/jira
          - jira-log:/opt/atlassian/jira/logs
    volumes:
      jira-config:
      jira-app:
      jira-log:
    
```

### 进入试用模式,默认29天到期

    # 拉取镜像并进入jira容器的bash 停止jira
    sh /opt/atlassian/jira/bin/stop-jira.sh
    
### 加入破解文件

>可忽略本篇内容，直接安装7.12.3版本的软件。
把原来`atlassian-jira/WEB-INF/lib/atlassian-extras-3.2.jar`
目录下的文件替换为以下文件即可。

[atlassian-extras-3.1.2.jar](/files/docker/jira/atlassian-extras-3.1.2.jar)

    # 进入docker主机下的这个目录,备份此文件，最后把atlassian-extras-3.1.2.jar文件放到lib目录
    /var/lib/docker/volumes/compose_jira-app/_data/atlassian-jira/WEB-INF/lib/atlassian-extras-3.2.jar
    
### 重新启动后即可

    # 进入jira容器的bash 启动jira
    sh /opt/atlassian/jira/bin/start-jira.sh

![破解完成后](/files/docker/jira/jira-reg.png)

>如果想自己编译容器可以参考以下Dockerfile和bash脚本(源码)

[Dockerfile](/files/docker/jira/Dockerfile)

[docker-entrypoint.sh](/files/docker/jira/docker-entrypoint.sh)

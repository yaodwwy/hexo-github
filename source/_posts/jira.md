---
title: jira 8.5.1 破解版本 Docker 部署
date: 2019-05-10 23:15:00
tag: jira
---

jira是Atlassian公司出品的项目与事务跟踪工具，被广泛应用于缺陷跟踪（bug管理）、客户服务、需求收集、流程审批、任务跟踪、项目跟踪和敏捷管理等工作领域。

### 破解脚本已经编译进容器里了

    # 通过 docker-compose.yml 运行容器
    
```yaml
    version: '3.3'
    services:
      jira:
        image: "yaodwwy/jira"
        container_name: jira
        restart: always
        ports:
          - "8080:8080"
        volumes:
          - jira-config:/var/atlassian/jira
          - jira-app:/opt/atlassian/jira
          - jira-log:/opt/atlassian/jira/logs
    
    volumes:
      jira-config:
      jira-app:
      jira-log:

    
```

> 已加入破解文件，进入试用模式，默认29天到期直接点击注册即可激活至2033年

    
---
title: WildFly环境与常用配置
date: 2019-01-12 10:15:00
tag: WildFly
---

### WildFly(JBoss)环境篇

> 下载WildFly并解压

    $ wget -c -P /data http://download.jboss.org/wildfly/10.1.0.Final/wildfly-10.1.0.Final.tar.gz
    $ tar -zxvf wildfly-10.1.0.Final.tar.gz

> wildfly启动及关闭：

    $ cd /
    $ nohup ./data/standalone.sh &
    $ ./data/jboss-cli.sh --connect shutdown
    
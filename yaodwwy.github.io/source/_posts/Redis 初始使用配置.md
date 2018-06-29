---
title: Redis 初始使用配置
date: 2018-06-29 14:25:00
tag: 
---


Redis是一个开源的使用ANSI C语言编写、支持网络、可基于内存亦可持久化的日志型、Key-Value数据库，并提供多种语言的API。

### 登陆
    $ redis-cli -h localhost -p 6379
    
### 密码
    ~> auth password
    
### 初始化密码
    ~> config set requirepass password
    ~> config get requirepass
    
### 解除保护模式
    ~> config set protected-mode "no"
    
### 查看匹配所有Key
    KEYS *
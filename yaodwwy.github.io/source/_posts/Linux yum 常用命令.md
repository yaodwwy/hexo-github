---
title: Linux yum 常用命令
date: 2018-06-29 14:07:00
tag: Linux
---

yum提供了查找、安装、删除某一个、一组甚至全部软件包的命令，而且命令简洁而又好记。

### yum 常用命令和选项
#### 搜索可用软件安装包

    $ yum search subversion
    
#### 安装软件：

    $ yum install subversion
    
#### 查看已安装的某个软件 

    $ rpm -qa | grep subversion
    结果：subversion-1.6.11-10.el6_5.x86_64
    
#### 查看已安装的软件详情

    $ rpm -ql subversion-1.6.11-10.el6_5.x86_64
    结果
    /usr/share/doc/subversion-1.6.11
    /usr/share/doc/subversion-1.6.11/BUGS
    /usr/share/doc/subversion-1.6.11/CHANGES
    
#### 命令解释：

    $ rpm -qa 查询所有安装的rpm包，可以配合grep命令。
    $ rpm -qi 查询某个具体包的介绍。
    $ rpm -ql 列出某个具体包的所有文件
    
#### RPM默认安装路径：

    /etc 一些设置文件放置的目录如/etc/crontab
    /usr/bin 一些可执行文件
    /usr/lib /usr/lib64 一些程序使用的动态函数库
    /usr/share/doc 一些基本的软件使用手册与帮助文档
    /usr/share/man 一些man page文件
    
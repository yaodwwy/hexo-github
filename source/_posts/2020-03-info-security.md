---
title: 信息安全相关知识图
date: 2020-03-17 15:13:24
tags:
---

本文涉及信息安全三级题目中出现的技术词汇，用于记录与翻译成白话文。

### 2020-03-17

Kerberos


![](https://upload-images.jianshu.io/upload_images/6469473-e704be80985da1cc.jpg)
    
    一种网络认证协议
    一种认证标准，通过使用一台中央服务器来提供“票据”，供其他在网络上提供资源的服务器进行识别。在Windows 2000, XP, Server 2003, Vista, 以及Longhorn, 还有UNIX系统，都对它进行支持。

    AS（Authentication Server）= 认证服务器
    KDC（Key Distribution Center）= 密钥分发中心
    TGT（Ticket Granting Ticket）= 票据授权票据，票据的票据
    TGS（Ticket Granting Server）= 票据授权服务器
    SS（Service Server）= 特定服务提供端
    
#### 对称密码
    
    “恺撒（Caesar）”密码
    简单替换密码到较复杂构造方式

    分组密码 Block Cipher
        DES,AES,IDEA
        IBM 开发的密码 DES 已被广泛使用
    序列密码 Stream Cipher
        流密码 RC4,SEAL

#### ECC

    Error Correcting Code
    指能够实现错误检查和纠正错误技术的内存

####引导程序
##### GRUB

    GRand Unified Bootloader
    选择操作系统分区上的不同内核，也可用于向这些内核传递启动参数
    Linux、BSD Unix类的操作系统中GRUB、LILO 最为常用
    Windows也有类似的工具NTLOADER
    早期采用PowerPC架构的Apple机使用的是yaboot引导


##### Lilo

    LILO（LInux Loader)
    Linux引导程序。LILO是一个在系统启动时运行的程序，它用于选择引导计算机启动的操作系统。
    
##### Spfdisk

    SPFDisk（SPecialFDisk） 是一套磁盘分割工具与启动管理程式（Boot Manager）


#### RARP

    反向地址转换协议 Reverse Address Resolution Protocol
    局域网的物理机器从网关服务器的 ARP 表或者缓存上请求其 IP 地址的协议

#### SSL

    Secure Sockets Layer 安全套接层
    包含两个协议子层：记录协议（为高层协议提供基本的安全服务）握手协议（协调客户和服务器的状态，使双方能够达到状态的同步）

#### inetd 

    互联网服务守护程序
    许多提供Internet服务的Unix系统上的超级服务器守护程序。
    对于每个已配置的服务，它侦听来自连接客户端的请求。


ESP（Extended Stack Pointer）为扩展栈指针寄存器，是指针寄存器的一种，用于存放函数栈顶指针。
与之对应的是EBP（Extended Base Pointer），扩展基址指针寄存器，也被称为帧指针寄存器，用于存放函数栈底指针。


#### ASLR

    Address space layout randomization
    地址空间配置随机加载（英语：Address space layout randomization，缩写ASLR，又称地址空间配置随机化、地址空间布局随机化）是一种防范内存损坏漏洞被利用的计算机安全技术。

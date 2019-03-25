---
title: Windows 端口转发
date: 2018-12-10 16:15:00
tag: Windows
---

自Windows XP开始，Windows中就内置网络端口转发的功能。任何传入到本地端口的TCP连接（IPv4或IPv6）
都可以被重定向到另一个本地端口，或远程计算机上的端口，并且系统不需要有一个专门用于侦听该端口的服务。

### windows 端口转发

    netsh interface portproxy add v4tov4 listenaddress=10.0.3.123 listenport=22 connectaddress=192.168.56.1 connectport=22

>依次为【windows ip】 【windows 端口】 【虚拟网卡ip】【虚拟网卡端口】

#### 查看转发列表

    netsh interface portproxy show  v4tov4
    
#### 取消转发：

    netsh interface portproxy delete v4tov4 listenaddress=【windows ip】  listenport=【windows 端口】
    
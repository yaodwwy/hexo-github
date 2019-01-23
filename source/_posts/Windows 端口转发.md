---
title: Windows 端口转发
date: 2018-12-10 16:15:00
tag: Windows
---

### windows 端口转发

    netsh interface portproxy add v4tov4 listenaddress=10.0.3.123 listenport=22 connectaddress=192.168.56.1 connectport=22

>依次为【windows ip】 【windows 端口】 【虚拟网卡ip】【虚拟网卡端口】

#### 查看转发列表

    netsh interface portproxy show  v4tov4
    
#### 取消转发：

    netsh interface portproxy delete v4tov4 listenaddress=【windows ip】  listenport=【windows 端口】
    
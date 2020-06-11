---
title: Linux发行版系统管理及软件包管理手册
date: 2020-06-01 10:15:00
tag: Linux
---

　　本篇针对不同Linux发行版，包括商业发行版，比如Ubuntu（Canonical公司）、Fedora（Red Hat）和社区发行版 Debian 的使用区别的总结。

内容会长期整理收集。

Linux发行版的多样性是由于不同用户和厂商的技术、哲学和用途差异。在宽松的自由软件许可证下，任何有足够的知识和兴趣的用户可以自定义现有的发行版，以适应自己的需要。

### 系统信息

#### 基本信息
        
    # uname -a  
      [-s 内核名称 -n 网络节点上的主机名 -r 内核发行号 -v 内核版本]
      [-m 硬件架构名称 -p 处理器类型 -i 硬件平台 -o 操作系统名称]
    # dmesg                  # 系统启动信息
      [ -k 显示内核消息  -H 易读格式输出]
    # env                    # 查看环境变量
    # getconf -a             # 系统变量信息
        
#### 主机信息

    # hostnamectl status                  # 显示当前主机名设置
    # hostnamectl set-hostname NAME       # 设置系统主机名
    
#### CPU信息

    # lscpu   # cpu的统计信息
    # cat /proc/cpuinfo

#### 内存信息

    # lsmem                             # 仅 Red Hat 可用
    # cat /proc/meminfo 
    # free -m                           # 显示内存状态
      [-h (-bkm)人性化显示单价 -s -t 包括虚拟内存交换区]
    # swapon                            # 交换区空间
    # dmidecode -t memory
    
#### 磁盘信息

    # lsblk         # 列出所有可用块设备的信息
    # fdisk -l      # 查看硬盘及分区信息
    
#### 网络信息

    # lspci | grep -i 'eth'     # 显示网卡硬件信息
    # ifconfig -a               # 显示全部接口信息
    # ip link show              # 查看端口的具体信息
    # ip addr                   # 查看IP地址
    # ethtool eth0              # 查看网口参数

#### 硬件信息

    # lspci -tv                      # 列出所有PCI设备
    # lsusb -tv                      # 列出所有USB设备
    # dmidecode                      # 打印所有硬件信息
    # dmidecode -q                   # 打印所有硬件信息，简洁
    # dmidecode -t bios              # 查看BIOS相关的硬件信息
    # dmidecode -t system            # 查看系统相关的硬件信息
    # dmidecode -t baseboard         # 查看主板相关的硬件信息
    # dmidecode -t chassis           # 查看机箱相关的硬件信息
    # dmidecode -t processor         # 查看处理器相关的硬件信息
    # dmidecode -t memory            # 查看内存相关的硬件信息

#### 系统服务信息查询

    # lsmod                                 # 列出加载的内核模块
    # systemctl list-units --type=service   # 所有已启动的服务
    # chkconfig --list                      # 列出所有系统服务
    # chkconfig --list | grep on            # 列出所有启动的系统服务
    # journalctl                            # 守护进程系统实时日志
    # [-k 内核日志 -b 本次启动日志 -u NAME.service 按服务筛选 ]
    # [_PID=XXX 按进程筛选 -f 追踪日志 -u NAME.service 按服务筛选 ]

#### 系统服务操作

    # systemctl enable XXX.service          # 开机启动
    # systemctl start XXX.service           # 启动nginx服务
    # systemctl disable XXX.service         # 停止开机自启动
    # systemctl status XXX.service          # 查看服务当前状态
    # systemctl restart XXX.service         # 重新启动服务

### 软件信息
    
>不同Linux 发行版软件操作常用指令

|系统|Debian/Ubuntu|CentOS|Fedora|
|:---------------:|:---------------:|:---------------:|:---------------:|
|格式             |.deb          |.rpm                 |.rpm|
|工具             |apt, dpkg     |yum                  |dnf|
|查看已安装的软件包 |dpkg -l        |yum list installed  |dnf list installed|
|更新已安装的包    |apt upgrade    |yum update          |dnf upgrade|
|搜索某个包        |apt search     |yum search all      |dnf search all|
|查看软件包信息    |apt show       |yum info            |dnf info|
|从存储库安装包    |apt install    |yum install         |dnf install|
|从本地安装包      |dpkg -i .deb   |yum install .rpm    |dnf install .rpm|
|删除已安装的包    |apt-get remove |yum remove          |dnf erase|

>Debian 家族发行版的管理员通常熟悉 apt-get 和 apt-cache

|传统命令|等价的 apt 命令|
|:---------------|:---------------|
|apt-get update         |   apt update
|apt-get dist-upgrade   |   apt full-upgrade
|apt-cache search string|   apt search string
|apt-get install package|   apt install package
|apt-get remove package |   apt remove package
|apt-get purge package  |   apt purge package

>yum是一个基于rpm系统的包安装、移除的自动更新器。yum会自动计算并且指出在安装包时需要的依赖，这样就不用像rpm一样，需要手动逐一添加依赖，而是直接帮我们安装这些依赖。

|常用操作|yum命令|rpm命令|
|:---------------|:---------------|:---------------|
|安装	         |    yum install NAME      |   rpm –ivh .rpm
|更新指定软件      |    yum update NAME      |   rpm –Uvh .rpm
|列出可更新软件	 |    yum check-update ||
|列出已安装包      |    yum list installed   |   rpm –qa
|显示包信息	     |    yum info NAME         |   rpm –qi NAME
|显示包的安装情况	 |    yum list NAME         |   rpm –q
|删除软件包	     |    yum remove NAME       |   rpm –e NAME
|清除缓存目录下的软件包| yum clean packages |||

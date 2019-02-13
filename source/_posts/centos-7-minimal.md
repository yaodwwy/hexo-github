---
title: CentOS 7 Minimal 开发汇总
date: 2018-12-12 10:15:00
tag: CentOS
---

　　本篇针对CentOS7环境下，对常见操作的汇总。从基础入门到生产配置都有涉及，可以通过右边导航快速跳转。或是Ctrl + F 查找相关说明。CentOS7 Minimal ISO这个镜像的目的是安装一个非常基本的系统，具有一个功能系统所需的最少的软件包。默认安装后第一件事是联网、关防火墙或配置防火墙、配置环境等等操作。

### 最小化安装篇
> 下载地址

   [Download CentOS](https://www.centos.org/download/)
    
    可以使用Hyper-V虚拟机或是VirtualBox虚拟机安装，安装前网络建议使用桥接方便对主机进行直接
    访问。
    Hyper-V桥接方式：在管理界面的右侧，打开虚拟交换机管理器，创建外部虚拟交接机，下拉选择正在
    使用的网卡硬件。
    VirtualBox桥接方式：在新建的虚拟机文件上设置网络，选择桥接网卡。
    
> 网卡激活

    vi /etc/sysconfig/network-scripts/ifcfg-enp0s3
    改 ONBOOT=yes
    
> 重启网卡： 

    systemctl restart network

> 这时已经能上网了，也就能做任何事了。我们继续!

---

### 系统服务篇

> 查看服务状态

    systemctl status firewalld
    
> 启动服务

    systemctl start firewalld
    
> 停止服务

    systemctl stop firewalld
    
> 设置服务开机启动

    systemctl enable firewalld
    
> 禁止服务开机启动

    systemctl disable firewalld


---

### 网络管理篇

> 查看和修改主机名

    hostnamectl status
    hostnamectl set-hostname node-1

> 查看分配网卡情况： 

    ip addr  
    
> 查看具体某个网卡信息

    ip addr ls enp0s3
    
> 停用网卡

    ip link set enp0s3 down
    
> 启用网卡

    ip link set enp0s3 up

> 安装ifconfig功能、netstat功能(如果没有)

    yum -y install net-tools
    
> 安装ping功能(如果没有)

    yum -y install iputils

> 修改ip地址 
    用ip addr add指令添加/删除IP，即刻生效，重启不保留
    
    ip addr del 192.168.80.134/24 dev enp0s3
    ip addr add 192.168.80.136/24 dev enp0s3

> 查看路由信息

    ip route show
    
> 添加路由
    用ip addr add指令添加/删除IP，即刻生效，重启不保留

    ip route add default via 192.168.80.2 dev br0
    
> 设置静态地址(也可手动编辑enp0s3文件)

    export enp="/etc/sysconfig/network-scripts/ifcfg-enp0s3"
    sed -i 's/ONBOOT=no/ONBOOT=yes/' $enp
    sed -i 's/BOOTPROTO=dhcp/BOOTPROTO=static/' $enp
    echo 'IPADDR=10.0.3.201'>>$enp
    echo 'NETMASK=255.255.0.0'>>$enp
    echo 'GATEWAY=10.0.0.1'>>$enp
    echo 'DNS1=8.8.8.8'>>$enp

 ---

### 系统管理篇

> 查看系统在线用户
    
    w
    
> 关闭SSH其他用户会话连接

    # 查看当前自己占用终端，别把自己干掉了
    who am i 
    # 剔除对方
    pkill -kill -t pts/1
    
> 谷歌GCP开启SSH登录
    
    # 登录服务器，切换到root用户
    sudo -i
    # 修改ssh配置文件
    vim /etc/ssh/sshd_config
    # 修改下面两个参数把no改为yes
    # PermitRootLogin yes
    # PasswordAuthentication yes
    # 重启ssh服务使修改生效，
    # debain命令：
    /etc/init.d/ssh restart
    # centos命令：
    service sshd restart
    # 给root账户添加密码，
    passwd
    
> SSH登录
    
    # 本地生成公钥和密钥
    ssh-keygen -t rsa
    # 将本机生成的公钥发送到服务器上（建立信任关系）
    ssh-copy-id -i .ssh/id_rsa.pub root@server_ip
    # 测试ssh安全登录
    ssh -T root@server_ip

---

### 用户\组管理篇
    
> 添加用户

    adduser git
    
> 允许用户sudo方式

    # 加入git到sudo用户组
    nano /etc/sudoers
    # git     ALL=(ALL:ALL) ALL

### 磁盘目录管理篇

> 查看目录列表
    
    ls -l
    ll

> 统计文件或目录个数
    
    ls -l | wc -l
    
> 查看磁盘使用量
    
    df：列出文件系统的整体磁盘使用量
    df -h 以较易阅读的 GBytes, MBytes, KBytes 等格式自行显示
    du：检查磁盘空间使用量

### 防火墙篇

> 查看端口

    firewall-cmd --list-ports
    
> 开放端口(操作后需要)

    # --zone 作用域 --add-port添加端口，格式为：端口/通讯协议 --permanent永久生效
    firewall-cmd --zone=public --add-port=80/tcp --permanent

> 更新防火墙规则( 开放和关闭端口 更新后生效 )

    firewall-cmd --reload

> 关闭端口
  
    firewall-cmd --zone=public --remove-port=80/tcp --permanent

> 开始和启用防火墙服务

    systemctl start firewalld
    systemctl enable firewalld

> 关闭和禁用防火墙服务
    
    systemctl stop firewalld
    systemctl disable firewalld

> 使用Socat进行端口转发(Socat不支持端口段转发)

    yum install -y socat
    nohup socat UDP4-LISTEN:2333,reuseaddr,fork UDP4:233.233.233.233:6666 >> /root/socat.log 2>&1 &
    nohup socat TCP4-LISTEN:2333,reuseaddr,fork UDP4:233.233.233.233:6666 >> /root/socat.log 2>&1 &
    
> 停止转发

    kill -9 $(ps -ef|grep socat|grep -v grep|awk '{print $2}')
    
---

### 软件安装篇

yum提供了查找、安装、删除某一个、一组甚至全部软件包的命令，而且命令简洁而又好记。

> 搜索可用软件安装包

    $ yum search subversion
    
> 安装软件：

    $ yum install subversion
    
> 查看已安装的某个软件 

    $ rpm -qa | grep subversion
    结果：subversion-1.6.11-10.el6_5.x86_64
    
> 查看已安装的软件详情

    $ rpm -ql subversion-1.6.11-10.el6_5.x86_64
    结果
    /usr/share/doc/subversion-1.6.11
    /usr/share/doc/subversion-1.6.11/BUGS
    /usr/share/doc/subversion-1.6.11/CHANGES
    
> 命令解释：

    $ rpm -qa 查询所有安装的rpm包，可以配合grep命令。
    $ rpm -qi 查询某个具体包的介绍。
    $ rpm -ql 列出某个具体包的所有文件
    
> RPM默认安装路径：

    /etc 一些设置文件放置的目录如/etc/crontab
    /usr/bin 一些可执行文件
    /usr/lib /usr/lib64 一些程序使用的动态函数库
    /usr/share/doc 一些基本的软件使用手册与帮助文档
    /usr/share/man 一些man page文件
    
> 搜索软件的相关路径：

    which命令是查找命令是否存在，以及命令的存放位置在哪儿。
    whereis命令只能用于搜索程序名，而且只搜索二进制文件（参数-b）、man说明文件（参数-m）
    和源代码文件（参数-s）。如果省略参数，则返回所有信息。
    
---

### 信息监控篇

#### ps命令

```bash
    ps -ef
```

```text
linux上进程有5种状态: 
    1. 运行(正在运行或在运行队列中等待) 
    2. 中断(休眠中, 受阻, 在等待某个条件的形成或接受到信号) 
    3. 不可中断(收到信号不唤醒和不可运行, 进程必须等待直到有中断发生) 
    4. 僵死(进程已终止, 但进程描述符存在, 直到父进程调用wait4()系统调用后释放) 
    5. 停止(进程收到SIGSTOP, SIGSTP, SIGTIN, SIGTOU信号后停止运行运行) 
ps工具标识进程的5种状态码: 
    D 不可中断 uninterruptible sleep (usually IO) 
    R 运行 runnable (on run queue) 
    S 中断 sleeping 
    T 停止 traced or stopped 
    Z 僵死 a defunct (”zombie”) process 
```

> 使用格式

ps [options] [--help]

a  显示所有进程
-a 显示同一终端下的所有程序
-A 显示所有进程
c  显示进程的真实名称
-N 反向选择
-e 等于“-A”
e  显示环境变量
f  显示程序间的关系
-H 显示树状结构
r  显示当前终端的进程
T  显示当前终端的所有程序
u  指定用户的所有进程
-au 显示较详细的资讯
-aux 显示所有包含其他使用者的行程 
-C<命令> 列出指定命令的状况
--lines<行数> 每页显示的行数
--width<字符数> 每页显示的字符数

#### uptime命令

``` bash
    uptime
     # 09:18:20 up 12:19,  2 users,  load average: 0.00, 0.01, 0.05
```

   [当前时间] + [系统已运行时间] + [当前登录用户数] + [系统负载] 负载三个数值分别为
   1分钟、5分钟、15分钟前到现在的平均值。

#### top命令

``` bash
    top
     # top- 09:27:26 up 12:29,  2 users,  load average: 0.00, 0.01, 0.05
        # 第一行同uptime命令
     # Tasks:  87 total 进程总数,1 running 正在运行的进程数,86 sleeping 睡眠的进程数,
                # 0 stopped停止的进程数           0 zombie 僵尸进程数
     # %Cpu(s):  0.3 us 用户空间占用CPU百分比      0.3 sy 内核空间占用CPU百分比,
                # 0.0 ni 用户进程空间内改变过优先级的进程占用CPU百分比, 
                # 99.3 id 空闲CPU百分比           0.0 wa 等待输入输出的CPU时间百分比, 
                # 0.0 hi 硬件CPU中断占用百分比     0.0 si 软中断占用百分比, 
                # 0.0 st 虚拟机占用百分比
     # KiB Mem :  7839940 total 物理内存总量    6745700 free 空闲内存总量, 
                # 174436 used 使用的物理内存总量 919804 buff/cache 用作内核缓存的内存量
     # KiB Swap:  1679356 total 交换区总量      1679356 free 空闲交换区总量, 
                # 0 used 使用的交换区总量        7374976 avail Mem 可用交换取总量
```

``` bash
    # 进程ID 用户名  优先级 同左  虚拟内存总 物理内存 共享内存 状态             时间总计  命令名
    #    PID USER      PR  NI       VIRT     RES     SHR    S %CPU %MEM     TIME+  COMMAND
    #  12692 root      20   0     162000    2144    1540    R  0.3  0.0   0:00.03  top
    #      1 root      20   0     127924    6608    4108    S  0.0  0.1   0:02.19  systemd     
    #      2 root      20   0          0       0       0    S  0.0  0.0   0:00.01  kthreadd      
    #      3 root      20   0          0       0       0    S  0.0  0.0   0:00.62  ksoftirqd/0
    #      5 root       0 -20          0       0       0    S  0.0  0.0   0:00.00  kworker/0:0H 
    #      6 root      20   0          0       0       0    S  0.0  0.0   0:00.54  kworker/u2:0
```

> 使用格式
   
   top [-] [d] [p] [q] [c] [C] [S] [s]  [n]
   d 刷新间隔。当然用户可以使用s交互命令来改变之。 
   p 指定进程ID来仅仅监控某个进程的状态。 
   q 该选项将使top没有任何延迟的进行刷新。如果调用程序有超级用户权限，那么top将以尽可能高的优先级运行。 
   S 指定累计模式 
   s 使top命令在安全模式中运行。这将去除交互命令所带来的潜在危险。 
   i 使top不显示任何闲置或者僵死进程。 
   c 显示整个命令行而不只是显示命令名 

> 配置显示项 

   更改显示内容通过 f 键可以选择显示的内容。
   按 o 键可以改变列的显示顺序。 
   按大写的 F 或 O 键，大写的 R 键可以将当前的排序倒转。
   
    PPID    父进程id
    RUSER   Real user name
    UID     进程所有者的用户id
    GROUP   进程所有者的组名
    TTY     启动进程的终端名。不是从终端启动的进程则显示为 ?
    NI      nice值。负值表示高优先级，正值表示低优先级
    P       最后使用的CPU，仅在多CPU环境下有意义
    %CPU    上次更新到现在的CPU时间占用百分比
    TIME    进程使用的CPU时间总计，单位秒
    %MEM    进程使用的物理内存百分比
    VIRT    进程使用的虚拟内存总量，单位kb。VIRT=SWAP+RES
    SWAP    进程使用的虚拟内存中，被换出的大小，单位kb。
    CODE    可执行代码占用的物理内存大小，单位kb
    DATA    可执行代码以外的部分(数据段+栈)占用的物理内存大小，单位kb
    SHR     共享内存大小，单位kb
    nFLT    页面错误次数
    nDRT    最后一次写入到现在，被修改过的页面数。
    S       进程状态(D=不可中断的睡眠状态,R=运行,S=睡眠,T=跟踪/停止,Z=僵尸进程)
    WCHAN   若该进程在睡眠，则显示睡眠中的系统函数名
    Flags   任务标志，参考 sched.h

#### vmstat命令

``` bash
    vmstat # [间隔] [采样次数]
    # [root@node124 ~]# vmstat
    #  procs -----------memory---------- ---swap-- -----io---- -system-- ------cpu-----
    #   r  b   swpd   free   buff  cache   si   so    bi    bo   in   cs us sy id wa st
    #   2  0      0 6745532   2108 917932    0    0     4    13   57   92  0  0 100  0  0
```

|CPU队列数|阻塞进程数|虚拟内存已使用|空闲内存|写操作缓存大小|读缓存|每秒从磁盘读虚拟内存数|每秒从磁盘写虚拟内存数|
|-|-|-|-|-|-|-|-|-|-|-|
|r|b|swpd|free|buff|cache|si|so|
|2|0|0|6745792|2108|917696|0|0|

块设备每秒接收的块数量|块设备每秒发送的块数量|每秒CPU的中断次数|每秒上下文切换次数|用户CPU时间|系统CPU时间|空闲CPU时间|等待IOCPU时间
-|-|-|-|-|-|-|-|-|-|-|-|-|-
bi|bo|in|cs|us|sy|id|wa st
5|17|58|94|0|0|100|0

#### netstat命令

``` bash
    netstat
```

Netstat 命令用于显示各种网络相关信息，如网络连接，路由表，接口状态 (Interface Statistics)，masquerade 连接，多播成员 (Multicast Memberships) 等等。

```text
    Active Internet connections (w/o servers)
    # 协议 接收队列 接收队列 本地地址               外部地址             状态
    Proto  Recv-Q  Send-Q  Local Address        Foreign Address     State      
    tcp        0      0    node124:ssh          10.0.3.123:pcep     ESTABLISHED
    Active UNIX domain sockets (w/o servers)
    协议  进程号             类型          状态                   进程使用的路径名
    Proto RefCnt Flags       Type       State         I-Node   Path
    unix  6      [ ]         DGRAM                    7178     /run/systemd/journal/socket
    unix  12     [ ]         DGRAM                    7180     /dev/log
    unix  2      [ ]         DGRAM                    11796    /run/systemd/shutdownd
    unix  3      [ ]         DGRAM                    7156     /run/systemd/notify
    unix  2      [ ]         DGRAM                    7158     /run/systemd/cgroups-agent
```

> 使用格式

```text
   netstat [-acCeFghilMnNoprstuvVwx][-A<网络类型>][--ip]
   -a (all)显示所有选项，默认不显示LISTEN相关
   -t (tcp)仅显示tcp相关选项
   -u (udp)仅显示udp相关选项
   -n 拒绝显示别名，能显示数字的全部转化成数字。
   -l 仅列出有在 Listen (监听) 的服務状态
   -p 显示建立相关链接的程序名
   -r 显示路由信息，路由表
   -e 显示扩展信息，例如uid等
   -s 按各个协议进行统计
   -c 每隔一个固定时间，执行该netstat命令。
   注意：LISTEN和LISTENING的状态只有用-a或者-l才能看到
```


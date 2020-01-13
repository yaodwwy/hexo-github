---
title: Raspberry Pi 实践
date: 2019-12-31 15:50:00
tags:
---

老规矩，我在中国，于是更新镜像源 详见： https://www.adbyte.cn/archives/linux-in-China/ 

---

#### Raspberry Pi CPU温度监控器
    
Raspberry Pi基金会建议Raspberry Pi设备的温度应低于85摄氏度。为保证正常工作，将在82度开始降频。
 
```bash
#!/bin/bash

printf "%-20s%10s\n" "TIMESTAMP" "TEMP(C)"
printf "%-30s\n" "-------------------------------"
while true
do
    temp=$(vcgencmd measure_temp | egrep -o '[0-9]*\.[0-9]*')
    timestamp=$(date "+%Y-%m-%dT%H:%M:%S")
    printf "%-20s%10s\n" "$timestamp" "$temp"
    sleep 5
    if [[ ${temp} > 60 ]] ; then
        curl "https://sc.ftqq.com/{密钥 这一段用于方糖提醒到手机端}.send?text=RaspberryPi温度过高&desp=当前温度：$temp°C 发生时间：$timestamp"
    fi
done

# 以上内容存为 tempmon.sh 文件执行后可见以下效果：

# pi@raspbian:~$ ./tempmon.sh  
# TIMESTAMP              TEMP(C)
# -------------------------------
# 2020-01-02 15:44:25       40.0
# 2020-01-02 15:44:27       39.0
# 2020-01-02 15:44:30       40.0
```

#### Raspberry Pi 外接硬盘相关操作

df 显示目前在Linux系统上的文件系统的磁盘使用情况统计

lsblk 命令 列出所有可用块设备的信息

fdisk命令用于观察硬盘实体使用情况，也可对硬盘分区。
    
    fdisk -l
    
挂载NTFS硬盘
    
    mount -t ntfs-3g /dev/sda /mnt/sda
    # 或
    ntfs-3g /dev/sda /mnt/sda1
    # 重启自动挂载
    echo "/dev/sda /mnt ext4 defaults 0 0" >> /etc/fstab
    
    
partprobe可以使kernel重新读取分区信息 从而避免重启系统

!!! mkfs -t ext4 /dev/sda !!!
    mkfs.ext3 /dev/sda
以上命令会格式化设备成ext3、ext4文件系统!

#### Raspberry Pi Docker中运行openwrt系统

docker run --restart always --name openwrt -d --network macnet --privileged -v /mnt:/mnt yaodwwy/openwrt:latest /sbin/init

    # 宿主机网络配置参考
    auto eth0
    iface eth0 inet manual
    dns-nameservers 192.168.1.1
    
    auto macvlan
    iface macvlan inet static
    
    address 192.168.1.70
    netmask 255.255.255.0
    gateway 192.168.1.1
    dns-nameservers 192.168.1.1
    pre-up ip link add macvlan link eth0 type macvlan mode bridge
    post-down ip link del macvlan link eth0 type macvlan mode bridge

    # 如遇网络问题可以检查一下文件
    /etc/network/interfaces
    dns-nameservers
    /etc/resolv.conf
    nameserver 192.168.1.1

>参考：https://linuxhint.com/raspberry_pi_temperature_monitor/
>参考：https://mlapp.cn/376.html
---
title: 实践编译linux内核
date: 2020-06-01 10:15:00
tag: Linux
---

   Linux内核（英语：Linux kernel）是一种开源的类Unix操作系统宏内核。
   Linux是用C语言中的GCC版（这种C语言有对标准C进行扩展）写的，还有几个用汇编语言（用的是GCC的"AT&T风格"）写的目标架构短段。因为要支持扩展的C语言，GCC在很长的时间里是唯一一个能正确编译Linux的编译器。

### 说明

>https://www.kernel.org/

实践版本：

>linux-5.7

### 编译过程

下载并解压：
    
    # curl -fsSL https://cdn.kernel.org/pub/linux/kernel/v5.x/linux-5.7.tar.xz
    # tar -xvf linux-5.7.tar.xz

可选配置（三选一）
    
    # make defconfig    # 使用默认配置
    # make menuconfig   # 手动配置
    # make oldconfig    # 使用旧的配置

#### 开始编译

清理编译历史文件：

    make mrproper
    
开始编译：

    make -ij8
    -i 表示忽略错误 -j8 表示8个编译命令同时执行
    
编译后的目录大小：

    du -sh .
    
安装内核：

    make install

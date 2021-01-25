---
title: 树莓派4B快速入门
date: 2020-12-14 00:44:23
tags:
---

使用 Raspbian 系统有段时间了，一直没有记录过日志，现在把脚本和实践汇总一下。

#### 概况
    
    官方下载的镜像环境：
    Linux raspberrypi 5.4.79-v7l+

#### Raspbian官方地址
    
    https://www.raspberrypi.org/software/

可以使用Raspberry Pi Imager将镜像写入卡

#### 使用wifi连接

创建 `wpa_supplicant.conf` 放到sd卡根目录可以直接内容如下 ：

		country=CN
		ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev
		update_config=1
		
		network={
			ssid="填写wifi的名字"
			psk="填写wifi的密码"
			priority=5
		}
		network={
			ssid="填写wifi的名字"
			psk="填写wifi的密码"
			priority=4
		}
		
#### ssh登录

新建空白`ssh`文件放到sd卡根目录

    pi:raspberry@raspberrypi
    
#### 清华源参考如下

记得备份

    https://mirrors.tuna.tsinghua.edu.cn/help/raspbian/

#### 查看附近的无线网络

	sudo iwlist wlan0 scan

#### 查看信号强度

	iwconfig wlan0
	
#### 温度传感器

在 `/boot/config.txt` 文件中增加 `dtoverlay=dht11,gpiopin=4`
然后接上dht11传感器的正负和信号线 （脚1+ 脚9- 脚4D）

参考地址: 
		
    https://pinout.xyz/pinout/1_wire
    
使用 python 读温度数据 参考脚本

    import json
    import time
    
    def currentTEMP( temp ):
        tmp = float( temp )
        if tmp != 0:
            tmp = tmp / 1000
        return tmp
    
    def currentHumidity( humidity ):
        tmp = float( humidity )
        if tmp != 0:
            tmp = tmp / 1000
        return tmp
    
    def main():
        info = {}
        TEMP = 0
        HUMIDITY = 0
        id = 0
        while True:
            try:
                TEMP = open('/sys/bus/iio/devices/iio:device0/in_temp_input').read()
                HUMIDITY = open('/sys/bus/iio/devices/iio:device0/in_humidityrelative_input').read()
                TEMP = currentTEMP( TEMP )
                HUMIDITY = currentHumidity( HUMIDITY )
    		
    	    id=id+1
    	    info["id"] = id
                info["temp"] = "%.2f" % TEMP
                info["humidity"] = "%.2f" % HUMIDITY
     	    
                jsonstr = json.dumps(info)
                print jsonstr
                time.sleep(1)
    	except:
    	    time.sleep(1)
    
    if __name__=='__main__':
    
        main()

#### 使用 linux-dash 监控系统信息
    
    git clone https://github.com/afaqurk/linux-dash.git
    sudo python linux-dash/app/server/index.py
    
    访问 http://raspberrypi/#/system-status 查看



#### 加载USB模块及挂载硬件

    modprobe usb-storage
    fdisk -l 看看U盘的设备
    mkdir /mnt/usb
    mount  /dev/sda*   /mnt/usb


## 未完待续
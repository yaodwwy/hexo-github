---
title: RaspBian实践
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
    timestamp=$(date "+%Y-%m-%d %H:%M:%S")
    printf "%-20s%10s\n" "$timestamp" "$temp"
    sleep 2
done

# 以上内容存为 tempmon.sh 文件执行后可见以下效果：

# pi@raspbian:~$ ./tempmon.sh  
# TIMESTAMP              TEMP(C)
# -------------------------------
# 2020-01-02 15:44:25       40.0
# 2020-01-02 15:44:27       39.0
# 2020-01-02 15:44:30       40.0
```

---
title: 联想笔记本电脑管家实现自动签到
date: 2020-08-16 16:46:00
tag: 自动签到脚本
---

联想电脑管家是买笔记时自带的内置程序，平时也用不到。
但是在注册为联想会员的时候，有一个签到有礼的福利。
连续签到可以兑换保修期。增加保修期就非常诱人了，但个人时间不允许每天去签到。
反正家里有一个树莓派，只有自动化一下，以后让树莓派帮我签到了。

>准备脚本：

```
#!/bin/bash

curl 'https://reg.lenovo.com.cn/auth/synck/dologin?callback=*****' -b cookie.txt -c cookie.txt
_token=$(curl -X GET 'https://club.lenovo.com.cn/signlist?sts=***' -b cookie.txt -c cookie.txt | grep 'CONFIG.token =' | awk -F \" '{print $2}')
curl 'https://club.lenovo.com.cn/sign' --data-raw '_token='$_token -b cookie.txt -c cookie.txt

```

>脚本说明：
* 第一个`*****`隐藏的内容是在电脑管家点击《签到有礼》的时候的默认跳转链接。断网后点击可以得到；
* 第二个`***`隐藏的是点击《签到有礼》后自动跳转的新链接；
* -b cookie.txt 表示 载入cookie文件；
* -c cookie.txt 表示 写入cookie文件；
* grep 'CONFIG.token =' 表示在/signlist页面从服务后台写到静态页上的token；
* awk -F \" '{print $2}' 表示 -F \" 指定分隔符为引号 print $2 是awk打印第二个字段就是token内容；
* 最有，有了cookie和token就可以签到了。

#### 设置定时

适用于 debian

crontab -l #查看定时列表
crontab -e #编辑定时列表

    01 1 * * * /bin/sh /root/autosign.sh >> /root/sign.log 2>&1

/etc/init.d/cron restart #重启定时服务

完。
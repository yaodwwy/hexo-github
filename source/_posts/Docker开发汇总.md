---
title: Docker开发汇总
date: 2019-01-23 10:15:00
tag: Docker
---

　　本篇针对Docker18.09.0常用开发，配置，环境搭建等使用细节汇总。

### 环境说明

<a href="http://www.adbyte.cn/2018/12/12/CentOS-7-Minimal%E5%BC%80%E5%8F%91%E6%B1%87%E6%80%BB/#Docker%E7%8E%AF%E5%A2%83%E7%AF%87" target="_blank">Docker环境安装</a>
    
    # docker version
    Client:
     Version:           18.09.0
     API version:       1.39
     Go version:        go1.10.4
     Git commit:        4d60db4
     Built:             Wed Nov  7 00:48:22 2018
     OS/Arch:           linux/amd64
     Experimental:      false
    
    Server: Docker Engine - Community
     Engine:
      Version:          18.09.0
      API version:      1.39 (minimum version 1.12)
      Go version:       go1.10.4
      Git commit:       4d60db4
      Built:            Wed Nov  7 00:19:08 2018
      OS/Arch:          linux/amd64
      Experimental:     false
    
> 如果与此环境一至可以开启一场Docker之旅了!

---

### 系统配置篇

> 开启远程管理Docker2375端口
>>禁止公网未加密方式开放2375 
>>必须使用TSL的HTTPS连接，不然就...
    
   [证书生成脚本](http://adbyte.cn/files/tlscert.sh)
   
```bash
    # 给脚本添加运行权限
    chmod +x tlscert.sh
    HOST_IP=127.0.0.1
    ./tlscert.sh $HOST_IP
    # 客户端需要的证书保存在client目录下, 服务端需要的证书保存在server目录下
    D_S=/usr/lib/systemd/system/docker.service
    sed -i 's|ExecStart=/usr/bin/dockerd -H unix://|EnvironmentFile=-/etc/default/docker\nExecStart=/usr/bin/dockerd  -H unix:// $DOCKER_OPTS|' $D_S
    grep ExecStart $D_S
    grep EnvironmentFile $D_S
    echo 'DOCKER_OPTS="--selinux-enabled' \
    '--tlsverify --tlscacert=/etc/docker/ca.pem' \
    '--tlscert=/etc/docker/server-cert.pem' \
    '--tlskey=/etc/docker/server-key.pem' \
    '-H=unix:///var/run/docker.sock' \
    '-H=0.0.0.0:2375"' > /etc/default/docker
    grep DOCKER_OPTS /etc/default/docker
    echo "******************  重启操作提示  ******************"
    systemctl daemon-reload
    systemctl restart docker
```

复制脚本自动生成的client证书文件到客户端文件目录如IDEA

![Idea配置方式](/img/idea-docker-Api.png)
![Idea配置完成](/img/idea-dockerApi-pgsql.png)

---

### 数据操作篇

> 备份及恢复卷

```bash
    # 挂载data并在data中新建测试文件
    docker run -it -v /data --name cow docker/whalesay
    echo testFile > /data/test.txt
    # 新建容器并挂载测试卷并操作备份
    docker run -it --privileged=true --volumes-from cow -v $(pwd):/backup --name temp docker/whalesay tar cvf /backup/backup.tar /data
    # 新建容器并新建卷后操作恢复
    docker run -it --privileged=true -v /data -v $(pwd):/backup --name cow2 docker/whalesay
    # 解压backup目录下backup.tar到data/即可完成恢复
    cd / && tar -xvf /backup/backup.tar
    # docker/whalesay 是一个很好玩的镜像,可以去pull下来试试
```

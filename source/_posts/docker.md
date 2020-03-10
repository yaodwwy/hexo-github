---
title: Docker开发汇总
date: 2019-01-23 10:15:00
tag: Docker
---

　　本篇针对Docker18.09.0常用开发，配置，环境搭建等使用细节汇总。

### Docker环境篇

> 查看已安装的docker 

    $ rpm -qa | grep docker
    
> 卸载旧版本(如果存在)

    $ sudo yum remove docker \
                  docker-client \
                  docker-client-latest \
                  docker-common \
                  docker-latest \
                  docker-latest-logrotate \
                  docker-logrotate \
                  docker-selinux \
                  docker-engine-selinux \
                  docker-engine

> Linux 源安装

    yum install -y yum-utils device-mapper-persistent-data lvm2
    #设置Docker存储库，可以从存储库安装和更新Docker
    yum-config-manager --add-repo http://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo
    yum makecache fast
    # 安装最新版本的Docker CE
    yum -y install docker-ce
    # 启动Docker
    systemctl start docker
    
    
#### Docker Machine:

    docker-machine create --driver virtualbox \
     --engine-registry-mirror=https://kfwkfulq.mirror.aliyuncs.com \
     --virtualbox-boot2docker-url=./boot2docker.iso docker
    
>boot2docker.iso下载地址：

    https://github.com/boot2docker/boot2docker/releases

#### Docker Compose:

下载安装文件：

    $ sudo curl -L https://github.com/docker/compose/releases/download/1.17.0/docker-compose-`uname -s`-`uname -m` -o /usr/bin/docker-compose

给已下载的安装文件添加执行权限：

    $ sudo chmod +x /usr/bin/docker-compose

测试是否安装成功：

    $ docker-compose --version

---

### Docker环境篇之Elasticsearch

> 更新为国内Docker镜像（加速）

    sudo mkdir -p /etc/docker
    sudo tee /etc/docker/daemon.json <<-'EOF'
    {
      "registry-mirrors": ["https://registry.docker-cn.com"]
    }
    EOF
    sudo systemctl daemon-reload
    sudo systemctl restart docker

> 设置虚拟内存空间

    ## 宿主机 grep vm.max_map_count /etc/sysctl.conf
    ## 如果为空 则 echo vm.max_map_count=262144 >>/etc/sysctl.conf
    ## 临时生效方式:
    sysctl -w vm.max_map_count=262144

> 拉取并启动Elasticsearch

    docker run -p 9200:9200 -p 9300:9300 -it \
    --name elasticsearch elasticsearch

> 停止Elasticsearch运行容器

    docker stop elasticsearch

> 再启动Elasticsearch运行容器

    docker start elasticsearch

#### 从外网SSH进Docker

    docker exec -it elasticsearch bash

> 在容器内安装SSH服务
    
    apt install -y openssh-server
    
> 配置sshd文件
    
    echo 'PermitRootLogin yes' >>/etc/ssh/sshd_config
    echo 'UsePAM no' >>/etc/ssh/sshd_config
    
> 更新密码

    passwd
    123456
    123456
    
> 重启ssh

    service ssh restart
        
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

### 容器部署篇

#### Docker-compose方式部署

### 已启动的容器如何设置自动启动
    
    docker update --restart=always <container>
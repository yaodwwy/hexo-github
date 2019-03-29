---
title: 从Docker到Kubernetes入门
date: 2019-03-25 15:50:00
tag: Kubernetes
---

Vagrant是一个基于Ruby的工具，用于创建和部署虚拟化开发环境。它使用Oracle的开源VirtualBox虚拟化系统，使用 Chef创建自动化虚拟环境。

### 功能特性：
 
 >>支持快速新建虚拟机
 支持快速设置端口转发
 支持自定义镜像打包（原始镜像方式、增量补丁方式）
 基本上日常能用到的基础配置都能快速设置
 支持开机启动自动运行命令
 可以自己写扩展
 
### 常用命令

    $ vagrant init      # 初始化
    $ vagrant init centos/7      # 初始化 centos7 作为基包的虚拟化环境
    
    $ vagrant up        # 启动虚拟机
    $ vagrant halt      # 关闭虚拟机
    $ vagrant reload    # 重启虚拟机
    $ vagrant ssh       # SSH 至虚拟机
    $ vagrant suspend   # 挂起虚拟机
    $ vagrant resume    # 唤醒虚拟机
    $ vagrant status    # 查看虚拟机运行状态
    $ vagrant destroy   # 销毁当前虚拟机

#### box管理命令

    $ vagrant box list    # 查看本地box列表
    $ vagrant box add     # 添加box到列表
    $ vagrant box remove  # 从box列表移除 

---

Docker Machine 是 Docker 官方提供的一个工具，它可以帮助我们在远程的机器上安装 Docker，或者在虚拟机 host 上直接安装虚拟机并在虚拟机中安装 Docker。我们还可以通过 docker-machine 命令来管理这些虚拟机和 Docker。

### docker-machine命令：

    help 查看帮助信息
    active 查看活动的Docker主机
    config 输出连接的配置信息
    create 创建一个Docker主机
    $ docker-machine create -d hyperv --hyperv-virtual-switch "ExtSwitch" node2
    
    env 显示连接到某个主机需要的环境变量
    $ docker-machine env node2  # 查询环境变量可以定义本地指向的服务
    
    inspect 输出主机更新信息
    ip 获取Docker主机地址
    kill 停止某个Docker主机
    ls 列出所有管理的Docker主机
    regenerate-certs 为某个主机重新成功TLS认证信息
    restart 重启Docker主机
    rm 删除Docker主机
    scp 在Docker主机之间复制文件
    ssh SSH到主机上执行命令
    $ docker-machine ssh node2
    
    start 启动一个主机
    status 查看一个主机状态
    stop 停止一个主机
    upgrade 更新主机Docker版本为最新
    url 获取主机的URL




---

删除所有容器

    $ docker rm $(docker container ls -aq)

列出容器列表信息第一列

    $ docker container ls -a | awk {'print$1'}

删除已退出的容器

    $ docker rm $(docker container ls -f "status=exited" -q)

---

提交已经修改的容器作为新镜像

$ docker commit 容器名 映像名:版本

全新制作新镜像

```dockerfile
FROM centos
RUN yum install -y vim
```

FROM scratch # 制作base image
LABEL maintainer=""
LABEL version=""
LABEL description=""
WORKDIR "/" # 尽量使用绝对路径
ENV MYSQL_VERSION 5.6 # 设置常量
RUN apt-get install -y mysql-ser="$(MYSQL_VERSION)" \
&& rm -rf /var/lib/apt/lists/* # 清理

RUN:执行命令并创建新的Image Layer
CMD:设置容器启动后默认执行的命令和参数
ENTRYPOINT:设置容器启动时运行的命令

>Shell 格式

    RUN apt-get install -y vim
    CMD echo "hello docker"
    ENTRYPOINT echo "hello docker"
    
>Exec格式

    RUN ["apt-get","install","-y","vim"]
    CMD ["/bin/echo","hello docker"]
    ENTRYPOINT["/bin/echo","hello docker"]

Exec格式下变量传递
FROM centos
ENV name Docker
ENTRYPOINT ["/bin/bash","-c","echo hello $name"]

docker build -t 10.0.0.205:500/hello-world .

---

```python app.py
from flask import Flask
app = Flask(__name__)
@app.route('/')
def hello():
    return "hello docker"
if __name__ == '__main__':
    app.run()
```

```dockerfile
FORM python:2.7
LABEL "maintainer=Adam<yaodwwy@gmail.com>"
RUN pip install flask
COPY app.py /app/
WORKDIR /app
EXPOSE 5000
CMD ["python","app.py"]
```

docker build -t 10.0.0.205:500/hello-docker .

>修改已经存在的container的重启策略

    docker update --restart=always <container id>

docker exec -it node2 ip a

---

>容器资源限制

```dockerfile
FROM ubuntu
RUN apt-get update && apt-get install -y stress
ENTRYPOINT ["/usr/bin/stress"]
CMD []

```

docker run -it yaodwwy/ubuntu-stress --vm 1

>以Debug方式运行压力测试

docker run -it yaodwwy/ubuntu-stress --vm 1 --verbose



docker run -it --memory=200M yaodwwy/ubuntu-stress --vm 1 --verbose


---
>网络命名空间

docker run -d --name test1 busybox /bin/sh -c "while true; do sleep 3600; done"

ip netns list

brctl show
yum install -y bridge-utils

---

docker swarm init --help

docker service ls
docker service ps demo
docker service scale demo=5

---
### 9 
minikube start
kubectl config view
kubectl config get-contexts
kubectl claster-info
minikube ssh

kubectl create -f xxx.yml
kubectl delete -f xxx.yml
kubectl get pods
kubectl get pods -o wide
kubectl exec -it xxx sh
kubectl describe pods nginx
kubectl port-forward nginx 8080:80

---
kubectl get rc
kubectl get pods
kubectl delete pods nginx-xxxxx
kubectl scale rc nginx
kubectl scale rc nginx --replicas=2

---
kubectl get deployment
kubectl get rs
kubectl get deployment -o wide
>升级版本
kubectl set image deployment nginx-deployment nginx=nginx:1.13
>查看版本历史
kubectl rollout history deployment nginx-deployment
>回滚版本
kubectl rollout undo deployment nginx-deployment

---
kubectl get node -o wide
kubectl delete service nginx-deployment
kubectl expose deployment nginx-deployment --type=NodePort
kubectl get svc

---






### 环境依赖

> Git Bash [下载](https://git-scm.com/downloads)
 
> NodeJS [下载](https://nodejs.org/en/download/)

> Create SSH key 如果未创建
    
    # 本地生成公钥和密钥
    ssh-keygen -t rsa -C yaodwwy@gmail.com
    # 将本机生成的公钥发送到服务器上（建立信任关系）
    ssh-copy-id -i .ssh/id_rsa.pub root@server_ip
    # 测试ssh安全登录
    ssh -T root@server_ip
    
>下载hexo.sh文件修改git地址为自己的项目 并在bash下执行 
 
    $ sh hexo.sh

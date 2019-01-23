#!/bin/bash
# @author: adam

# 前言
# 给脚本添加运行权限
# chmod +x tlscert.sh
# HOST_IP=127.0.0.1
# ./tlscert.sh $HOST_IP
# 客户端需要的证书保存在client目录下, 服务端需要的证书保存在server目录下

if [ $# != 1 ] ; then 
echo "USAGE: $0 [HOST_IP]" 
exit 1; 
fi

#============================================#
#   下面为证书密钥及相关信息配置，注意修改       #
#============================================#
PASSWORD="8#qb^%D&QxKh"
COUNTRY=CN
PROVINCE=yourprovince
CITY=yourcity
ORGANIZATION=yourorganization
GROUP=yourgroup
NAME=yourname
HOST=$1
SUBJ="/C=$COUNTRY/ST=$PROVINCE/L=$CITY/O=$ORGANIZATION/OU=$GROUP/CN=$HOST"

echo "your host is: $1"

# 1.生成根证书RSA私钥，PASSWORD作为私钥文件的密码
openssl genrsa -passout pass:$PASSWORD -aes256 -out ca-key.pem 4096

# 2.用根证书RSA私钥生成自签名的根证书
openssl req -passin pass:$PASSWORD -new -x509 -days 365 -key ca-key.pem -sha256 -out ca.pem -subj $SUBJ

#============================================#
#          用根证书签发server端证书          #
#============================================#

# 3.生成服务端私钥
openssl genrsa -out server-key.pem 4096

# 4.生成服务端证书请求文件
openssl req -new -sha256 -key server-key.pem -out server.csr -subj "/CN=$HOST"

# 5.使tls连接能通过ip地址方式，绑定IP
echo subjectAltName = IP:127.0.0.1,IP:$HOST > extfile.cnf

# 6.使用根证书签发服务端证书
openssl x509 -passin pass:$PASSWORD -req -days 365 -sha256 -in server.csr -CA ca.pem -CAkey ca-key.pem -CAcreateserial -out server-cert.pem -extfile extfile.cnf


#============================================#
#          用根证书签发client端证书          #
#============================================#

# 7.生成客户端私钥
openssl genrsa -out key.pem 4096

# 8.生成客户端证书请求文件
openssl req -subj '/CN=client' -new -key key.pem -out client.csr

# 9.客户端证书配置文件
echo extendedKeyUsage = clientAuth > extfile.cnf

# 10.使用根证书签发客户端证书
openssl x509 -passin pass:$PASSWORD -req -days 365 -sha256 -in client.csr -CA ca.pem -CAkey ca-key.pem -CAcreateserial -out cert.pem -extfile extfile.cnf

#============================================#
#                    清理                    #
#============================================#
# 删除中间文件
rm -f client.csr server.csr ca.srl extfile.cnf

# 转移目录
mkdir client server
cp {ca,cert,key}.pem client
cp {ca,server-cert,server-key}.pem server
rm {cert,key,server-cert,server-key}.pem

# 设置私钥权限为只读
chmod -f 0400 ca-key.pem server/server-key.pem client/key.pem

# 复制服务器证书到etc目录
cp -f server/* /etc/docker

echo "******************  后续配置操作提示  ******************"
echo 'EnvironmentFile=-/etc/default/docker必须在docker.service中'
echo '$DOCKER_OPTS必须在ExecStart中出现'
echo '/etc/default/docker'
echo 'DOCKER_OPTS="--selinux-enabled --tlsverify --tlscacert=/etc/docker/ca.pem\'
echo '--tlscert=/etc/docker/server-cert.pem --tlskey=/etc/docker/server-key.pem \'
echo '-H=unix:///var/run/docker.sock -H=0.0.0.0:2375"'
echo "******************  重启操作提示  ******************"
echo 'systemctl daemon-reload'
echo 'systemctl restart docker'
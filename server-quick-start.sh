#!/bin/bash

adduser git
su git
cd ~
real_addr=`ping www.adbyte.cn -c 1 | sed '1{s/[^(]*(//;s/).*//;q}'`
local_addr=`curl ipv4.icanhazip.com`
if [ $real_addr == $local_addr ] ; then
	echo "=========================================="
	echo "       域名解析正常，开始安装Nginx&Git"
	echo "=========================================="
	sleep 1s
fi
sudo apt-get install -y nginx
sudo systemctl enable nginx.service
sudo cat > /etc/nginx/sites-enabled/host.adbyte.cn.conf <<-EOF
server {
    listen       8008;
    server_name  host.adbyte.cn host.adbyte.cn;
    root ~/web/;
    index index.php index.html index.htm;
}
EOF
systemctl restart nginx.service
mkdir /etc/nginx/cert
curl https://get.acme.sh | sh
acme.sh --issue  -d adbyte.cn -d www.adbyte.cn  --webroot ~/web/
acme.sh --installcert -d adbyte.cn -d www.adbyte.cn \
  --key-file /etc/nginx/cert/key.pem \
  --fullchain-file /etc/nginx/cert/cert.pem \
  --reloadcmd "service nginx force-reload"

cat > /etc/nginx-sites-enabled/www.adbyte.cn.conf <<-EOF
server {
        server_name adbyte.cn;
        listen *:80;
        listen *:443 ssl;
        listen [::]:80;
        listen [::]:443 ssl;
        return 301 https://www.adbyte.cn$request_uri;
}

server {
    server_name www.adbyte.cn;
    listen 80;
    listen [::]:80;
	listen 443 ssl default_server;
	listen [::]:443 ssl default_server;
    error_page 497  https://$host$uri?$args;

	ssl on;
    ssl_certificate   /etc/nginx/cert/cert.pem;
    ssl_certificate_key  /etc/nginx/cert/key.pem;
    ssl_session_timeout 5m;
    ssl_ciphers ECDHE-RSA-AES128-GCM-SHA256:ECDHE:ECDH:AES:HIGH:!NULL:!aNULL:!MD5:!ADH:!RC4;
    ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
    ssl_prefer_server_ciphers on;
    if ($scheme = http) {
        return 301 https://$host$request_uri;
    }

	root /home/git/web;

	# Add index.php to the list if you are using PHP
	index index.html index.htm index.nginx-debian.html;


	location / {
		# First attempt to serve request as file, then
		# as directory, then fall back to displaying a 404.
		try_files $uri $uri/ =404;
	}

	location /v2-ui {
        proxy_pass http://127.0.0.1:65432/v2-ui;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }

}
EOF

apt-get install git-core
git init --bare hexo.git
chown -R git:git hexo.git

cat > ~/hexo.git/hooks/post-update <<-EOF
#!/bin/sh
git --work-tree=~/web --git-dir=~/hexo.git checkout -f
exec git update-server-info
EOF
chmod +x ~/hexo.git/hooks/post-update
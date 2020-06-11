#!/bin/sh

if [[ -f /etc/redhat-release ]]; then
    cat /etc/redhat-release
fi

if [[ -f /etc/os-release ]]; then
    cat /etc/os-release
fi

if [[ -f /etc/lsb-release ]]; then
    cat /etc/lsb-release
fi

time=$(date "+%Y%m%d-%H%M%S")

alpine() {
    cp /etc/apk/repositories /etc/apk/repositories_bak_${time}
    sed --in-place "s|dl-cdn.alpinelinux.org|mirrors.aliyun.com|g" "/etc/apk/repositories"
    cat /etc/apk/repositories_bak
    echo '  ------------->>  '
    cat /etc/apk/repositories
}

debian(){
    cp /etc/apt/sources.list /etc/apt/sources.list_bak_${time}
    sed --in-place "s|deb.debian.org|mirrors.aliyun.com|g" "/etc/apt/sources.list"
    sed --in-place "s|security-cdn.debian.org|mirrors.aliyun.com|g" "/etc/apt/sources.list"
    sed --in-place "s|security.debian.org|mirrors.aliyun.com|g" "/etc/apt/sources.list"
    cat /etc/apt/sources.list_bak
    echo '  ------------->>  '
    cat /etc/apt/sources.list
}

ubuntu(){
    cp /etc/apt/sources.list /etc/apt/sources.list_bak_${time}
    sed --in-place "s|archive.ubuntu.com|mirrors.aliyun.com|g" "/etc/apt/sources.list"
    cat /etc/apt/sources.list_bak
    echo '  ------------->>  '
    cat /etc/apt/sources.list
}

raspbian(){
    cp /etc/apt/sources.list /etc/apt/sources.list_bak_${time}
    sed --in-place "s|raspbian.raspberrypi.org/raspbian/|mirrors.aliyun.com/raspbian/raspbian/|g" "/etc/apt/sources.list"
    sed --in-place "s|archive.raspbian.org/raspbian/|mirrors.aliyun.com/raspbian/raspbian/|g" "/etc/apt/sources.list"
    cat /etc/apt/sources.list_bak
    echo '  ------------->>  '
    cat /etc/apt/sources.list
}

centos(){
    export version_id=$(awk -F'[= "]' '/VERSION_ID/{print $3}' /etc/os-release)
    echo 'VERSION_ID='${version_id}
    mv /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo.bak_${time}
    curl -o /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-${version_id}.repo
    sed -i -e '/mirrors.cloud.aliyuncs.com/d' -e '/mirrors.aliyuncs.com/d' /etc/yum.repos.d/CentOS-Base.repo
    cat /etc/yum.repos.d/CentOS-Base.repo.bak_${time}
    echo '  ------------->>  '
    cat /etc/yum.repos.d/CentOS-Base.repo
}

if [[ -f /etc/redhat-release ]]; then
    release="centos"
    centos
elif cat /etc/issue | grep -Eqi "raspbian"; then
    release="raspbian"
    $( raspbian )
elif cat /etc/issue | grep -Eqi "debian"; then
    release="debian"
    $( debian )
elif cat /etc/issue | grep -Eqi "ubuntu"; then
    release="ubuntu"
    $( ubuntu )
elif cat /etc/issue | grep -Eqi "centos|red hat|redhat"; then
    release="centos"
    centos
elif cat /proc/version | grep -Eqi "debian"; then
    release="debian"
    $( debian )
elif cat /proc/version | grep -Eqi "ubuntu"; then
    release="ubuntu"
    $( ubuntu )
elif cat /proc/version | grep -Eqi "centos|red hat|redhat"; then
    release="centos"
    centos
elif cat /etc/issue | grep -Eqi "alpine"; then
    release="alpine"
    $( alpine )
else
    release=""
fi

echo 'release='${release}
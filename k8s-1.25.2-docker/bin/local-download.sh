#!/bin/bash

set -eu

echo "本地下载所有需要代理的物件"
export ALL_PROXY="${ALL_PROXY:-socks5h://localhost:1080}"
echo "使用代理 $ALL_PROXY，可以通过 export ALL_PROXY=xxx 设置其它代理"

save_dir=cache
mkdir -pv $save_dir && cd $save_dir
echo "下载的文件保存在 $(realpath $save_dir) 中"

! test -e cri-dockerd-0.2.6-3.el7.x86_64.rpm && \
{

echo "下载 cri-dockerd"
curl -L https://github.com/Mirantis/cri-dockerd/releases/download/v0.2.6/cri-dockerd-0.2.6-3.el7.x86_64.rpm \
	-O
} || echo "cri-dockerd-0.2.6-3.el7.x86_64.rpm ok"


! test -e docker-ce.repo && \
{
echo "下载 docker 的yum源"
curl -L https://download.docker.com/linux/centos/docker-ce.repo -o docker-ce.repo
} || echo "docker-ce.repo ok"



#!/bin/bash
set -eu

echo "安装bash命令行补全"
yum install -y epel-release
yum install bash-completion-extras -y

echo "安装 k8s 组件:"
yum install -y kubelet-1.25.2 kubectl-1.25.2 kubeadm-1.25.2
# [WARNING Service-Kubelet]: kubelet service is not enabled, please run 'systemctl enable kubelet.service'

echo "安装 docker engine"
# yum install docker-ce docker-ce-cli containerd.io docker-compose-plugin
yum install -y docker-ce-20.10.17 docker-ce-cli-20.10.17 \
	containerd.io-1.6.7 docker-compose-plugin-2.6.0

echo "配置docker国内镜像，并配置docker使用systemd作为cgroup driver"
mkdir -pv /etc/docker
tee /etc/docker/daemon.json <<-'EOF'
{
  "registry-mirrors": [
    "https://mirror.baidubce.com",
    "https://hub-mirror.c.163.com"
  ],
  "exec-opts": ["native.cgroupdriver=systemd"]
}
EOF
echo 启用并设置开机启动 docker.service

echo 安装 cri-dockerd
yum localinstall cache/cri-dockerd-0.2.6-3.el7.x86_64.rpm -y
echo 启动设置开机启动 cri-dockerd.service
systemctl enable --now docker cri-docker
echo 'export CONTAINER_RUNTIME_ENDPOINT=unix:///run/cri-dockerd.sock' >> /etc/profile
echo export CONTAINER_RUNTIME_ENDPOINT=unix:///run/cri-dockerd.sock


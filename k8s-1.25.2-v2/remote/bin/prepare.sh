#!/bin/bash
set -eu

# 三个节点分别执行
echo "关闭swap、SELinux、防火墙"
systemctl disable --now firewalld
sed -i -e '/^SELINUX=/s/enforcing/disabled/g' /etc/sysconfig/selinux
sed -i -e '/^\/dev\/mapper\/centos-swap/s|^|#|g' /etc/fstab
swapoff -a
echo "关闭 swap 内核参数"TODO

echo "设置 hosts 文件"
# 如果有，先删除旧配置，避免重复
sed /etc/hosts -E -e '/^(192.168.17.7 n1|192.168.17.8 n2|192.168.17.9 n3)/d' -i
cat >> /etc/hosts <<EOF
192.168.17.7 n1
192.168.17.8 n2
192.168.17.9 n3
EOF

echo "启用 Linux 内核模块：br_netfilter,overlay"
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

modprobe overlay
modprobe br_netfilter

echo "持久化内核转发，持久关闭 swap"
cat > /etc/sysctl.d/k8s.conf <<EOF
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
vm.swappiness = 0
EOF
sysctl --system

echo "yum 基础仓库更换清华源镜像"
pushd /etc/yum.repos.d/ && ! test -e CentOS.repo.bak.tgz && tar czf CentOS.repo.bak.tgz CentOS-*.repo
sed -i -e 's|^mirrorlist=|#mirrorlist=|g' \
         -Ee 's,^#\s*baseurl=http://mirror.centos.org,baseurl=https://mirrors.tuna.tsinghua.edu.cn,g' \
         /etc/yum.repos.d/CentOS-*.repo

echo "设置安装 kubeadm 和 kubelet 组件所需的yum源"
cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://mirrors.aliyun.com/kubernetes/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=0
repo_gpgcheck=0
gpgkey=https://mirrors.aliyun.com/kubernetes/yum/doc/yum-key.gpg https://mirrors.aliyun.com/kubernetes/yum/doc/rpm-package-key.gpg
EOF

popd
echo "安装bash命令行补全"
yum install -y epel-release
yum install bash-completion-extras -y

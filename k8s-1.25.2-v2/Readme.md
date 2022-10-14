# 搭建k8s集群
- new,2022-10-14,chenxizhan1995@163.com
## 1. 系统信息

- n1 192.168.17.7   2C2G 15G
- n2 192.168.17.8   2C2G 15G
- n3 192.168.17.9   2C2G 15G

- 操作系统 CentOS 7.9.2009
- 内核 3.10.0-1160.el7.x86_64
- 基于 CentOS-7-x86_64-DVD-2009.iso 镜像安装
- 镜像 sha256 校验和：e33d7b1ea7a9e2f38c8f693215dd85254c3a4fe446f93f563279715b68d07987

用 n1 做控制平面节点，n2和n3做工作节点

安装 k8s 1.25.2 版本，选用 docker engine 做容器运行时，用 kubeadm 引导集群。

配置好了 ssh 登录，用 `ssh n1.k8s`、`ssh n3.k8s`、`ssh n3.k8s` 可分别登录三个节点，默认登录为 root 账号。

## 2. 安装过程概述
- 准备工作
  - 关闭swap、SELinux、防火墙
  - 设置hosts文件
  - yum 换源
  - 安装命令行补全

  - 启用 Linux 内核模块：br_netfilter,overlay
  - 启用 ipv4 端口转发

- 安装K8S
  - 载入 yum 源
  - 安装 kubeadm、kubelet、kubectl
  - 启动 kubelet 服务

- 安装CRI：三种方式，任选其一
  - CRI-O
    - 上传 cri-o.amd64.v1.25.1.tar.gz
    - 解压，make install
  - containerd
    - ……
  - docker engine + cri-dockerd
    - ……

- 引导集群
  - 下载 pause 镜像
  - 主节点执行 kubeadm init 命令
  - 从节点执行 kubeadm join 命令：应当能看到集群所有节点
  - 安装 flannel 插件：节点应进入 Ready 状态
  - 启动 httpin 服务，用 radial/busyboxplus:curl 访问服务，验证服务域名解析正确
## 3. 安装过程
### 3.1 上传脚本
本地执行
```bash
# 上传脚本
make upload
```
### 3.2 准备
每个节点执行
```bash
cd $HOME/install-k8s && make prepare && source /etc/bashrc
```
### 3.3 安装k8s
每个节点执行
```bash
cd $HOME/install-k8s
make k8s.install
```
### 3.4 安装CRI
三种运行时任选其一
#### 3.4.1 CRI-O

```bash
make crio.upload
make crio.install
curl -v --unix-socket /run/crio.sock http://localhost/info
curl -v --unix-socket /run/crio/crio.sock http://localhost/info

引导集群的时候失败，没能成功启动容器。
```
注：压缩包下载地址 [Releases · cri-o/cri-o](https://github.com/cri-o/cri-o/releases/)

设置 pause image 为 registry.cn-hangzhou.aliyuncs.com/google_containers/pause:3.6
##### Q&A
1. 安装失败，一溜目录不存在的错误
找到这些目录，手动创建。然后安装就成功了
```bash
mkdir -pv /etc/crio /usr/local/lib/systemd/system/ /usr/local/share/oci-umount/oci-umount.d/
```
2. 启动失败 fatal: node configuration validation for fs.may_detach_mounts sysctl failed:
[Running Kubernetes with CRI-O](https://github.com/cri-o/cri-o#running-kubernetes-with-cri-o)
```
echo 1 > /proc/sys/fs/may_detach_mounts
```
[fs.may_detach_mounts=1 is needed for successful pod termination · Issue #8622 · kubernetes-sigs/kubespray](https://github.com/kubernetes-sigs/kubespray/issues/8622)
但是这个参数不好
> Setting fs.may_detach_mounts is **dangerous** on running systems and may leak kernel handles to the point where the vfs layer can become corrupted so it is not a good idea to do this on production machines.
> I encourage you to do a manual drain and collect the logs of the kubelet and containerd and open issues on the containerd or kubernetes upstream projects as I don't think this is a kubspray specific issue.

> Just having a hard time seeing how may_detach_mounts is good for docker, and crio, but detrimental if containerd is used
docker 自动设置这个参数……

[在Kubernetes中使用CRI-O运行时](https://juejin.cn/post/6999405898980392996)
curl -v --unix-socket /run/crio/crio.sock http://localhost/info

[crio socket 的API](https://github.com/cri-o/cri-o#the-http-status-api)

3. crio.conf 配置文件格式
[cri-o/crio.conf.5.md at main · cri-o/cri-o](https://github.com/cri-o/cri-o/blob/main/docs/crio.conf.5.md)
#### 3.4.2 containerd
```bash
yum install containerd.io

```

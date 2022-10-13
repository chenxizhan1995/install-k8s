# 安装 k8s 集群
- new,2022-10-13,chenxizhan1995@163.com

## 系统信息

- n1 192.168.17.7   2C2G 15G
- n2 192.168.17.8   2C2G 15G
- n3 192.168.17.9   2C2G 15G

操作系统 CentOS 7.9.2009，内核 3.10.0-1160.el7.x86_64
  基于 CentOS-7-x86_64-DVD-2009.iso 镜像安装，镜像 sha256 校验和：e33d7b1ea7a9e2f38c8f693215dd85254c3a4fe446f93f563279715b68d07987

用 n1 做控制平面节点，n2和n3做工作节点

安装 k8s 1.25.2 版本，选用 docker engine 做容器运行时，用 kubeadm 引导集群。

配置好了 ssh 登录，用 `ssh n1`、`ssh n3`、`ssh n3` 可分别登录三个节点，默认登录为 root 账号。

把脚本都上传上去，然后登录节点，逐个执行。

## 安装过程
- 准备工作
  - 关闭swap、SELinux、防火墙
  - 设置hosts文件
  - yum 基础仓库更换清华源镜像
  - 设置安装 kubeadm 和 kubelet 组件所需的yum源

  - 启用 Linux 内核模块：br_netfilter,overlay
- yum 安装相关组件
  - bash 命令行补全
  - k8s 组件：kubeadm、kubelet
  - 安装 docker engine
    - 安装 cri-dockerd 这个在 github 上，网络不好，得本地下载然后上传
- 引导集群
  - 下载 pause 镜像

```bash
make hello
# 下载（本地执行）
make local-download
# 上传（本地执行）：把脚本和下载的文件上传的节点上
make upload-assets
make upload-download

# 准备工作（每个节点上执行）
make prepare
# yum 安装相关组件（每个节点上执行）
make yum-install
# 下载pause镜像（每个节点执行）
make pause

# 引导集群
# 初始化主节点(master 节点执行)
make init
# 新节点加入（从节点执行）
make pullk8s
# 然后执行,具体的参数见下文说明
kubeadm join --cri-socket unix:///var/run/cri-dockerd.sock  xxx

kubeadm join --cri-socket unix:///var/run/cri-dockerd.sock  192.168.17.7:6443 --token 82xiq5.dbnrf8f88i4q3bc5 \
        --discovery-token-ca-cert-hash sha256:4a3b48a186a9a57262a9bb61fd872d97998a37f20ba18c1c18b3784a6902f2af

```
主节点初始化成功后会看到类似如下的输出
```
Your Kubernetes control-plane has initialized successfully!

To start using your cluster, you need to run the following as a regular user:

  mkdir -p $HOME/.kube
  sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  sudo chown $(id -u):$(id -g) $HOME/.kube/config

Alternatively, if you are the root user, you can run:

  export KUBECONFIG=/etc/kubernetes/admin.conf

You should now deploy a pod network to the cluster.
Run "kubectl apply -f [podnetwork].yaml" with one of the options listed at:
  https://kubernetes.io/docs/concepts/cluster-administration/addons/

Then you can join any number of worker nodes by running the following on each as root:

kubeadm join 192.168.17.7:6443 --token 82xiq5.dbnrf8f88i4q3bc5 \
        --discovery-token-ca-cert-hash sha256:4a3b48a186a9a57262a9bb61fd872d97998a37f20ba18c1c18b3784a6902f2af
```

安装必要的插件
```bash
# 安装 flannel：所有镜像在 docker hub 上，不需要手动下载
# docker pull rancher/mirrored-flannelcni-flannel:v0.19.2
# docker pull rancher/mirrored-flannelcni-flannel-cni-plugin:v1.1.0
# 主节点执行
make flannel
# 稍等半分钟
# 看到 flannel 相关的 pod 处于 running 状态说明启动成功
# 同时 coredns 相关的 pod 应当从 pending 逐渐变为 running
kubectl get pods --all-namespaces

# 安装 ingress-nginx
# 拉取镜像（所有节点执行）
make ingress-nginx.image
make ingress-nginx.image
# 创建资源（主节点执行）
make ingress-nginx

# 简单测试一下
# httpbin 服务并测试
make httpbin
# 启动一个 pod，访问服务
kubectl run curl --image=radial/busyboxplus:curl -i --tty

nslookup httpbin
curl http://$HTTPBIN_SERVICE_HOST/get
# 特别的，服务的域名解析正常
curl http://httpbin/get
```

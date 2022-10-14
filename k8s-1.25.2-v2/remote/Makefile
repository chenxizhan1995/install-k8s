
prepare:
	sh bin/prepare.sh

k8s.install:
	echo "安装 k8s 组件:"
	yum install -y kubelet-1.25.2 kubectl-1.25.2 kubeadm-1.25.2
	systemctl enable --now kubelet

k8s.pull:
	kubeadm config --cri-socket unix:///var/run/cri-dockerd.sock  \
        --image-repository=registry.aliyuncs.com/google_containers images pull

k8s.init.crio:
	echo 引导集群 仅master节点执行
	kubeadm init --cri-socket unix:///run/crio/crio.sock \
		--image-repository=registry.aliyuncs.com/google_containers \
		--pod-network-cidr=10.244.0.0/16

crio.install:
	sh bin/install-crio.sh cache/cri-o*.gz

containerd.yum:
	mv assets/docker-ce.repo /etc/yum.repos.d/
containerd.install:
	yum install -y containerd.io

k8s.init.containerd:
	echo 引导集群 仅master节点执行
	kubeadm init --cri-socket unix:///run/containerd/containerd.sock \
		--image-repository=registry.aliyuncs.com/google_containers \
		--pod-network-cidr=10.244.0.0/16

	# kubeadm init --cri-socket unix:///run/containerd/containerd.sock \
	# 	--image-repository=registry.aliyuncs.com/google_containers \
	# 	--pod-network-cidr=10.244.0.0/16

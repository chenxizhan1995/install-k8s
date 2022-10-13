
hello:
	echo hello

local-download prepare yum-install:
	sh bin/$@.sh

upload-assets: s1 s2 s3
s1:
	rsync -av --exclude=cache ./ root@localhost:install-k8s/ -e 'ssh -p 2207'
s2:
	rsync -av --exclude=cache ./ root@localhost:install-k8s/ -e 'ssh -p 2208'
s3:
	rsync -av --exclude=cache ./ root@localhost:install-k8s/ -e 'ssh -p 2209'

upload-download: _up1 _up2 _up3
_up1:
	rsync -av cache root@localhost:install-k8s/ -e 'ssh -p 2207'
_up2:
	rsync -av cache root@localhost:install-k8s/ -e 'ssh -p 2208'
_up3:
	rsync -av cache root@localhost:install-k8s/ -e 'ssh -p 2209'
pause:
	@echo 下载pause镜像 registry.k8s.io/pause:3.6
	sh bin/pull-k8s-image.sh registry.k8s.io/pause:3.6
ingress-nginx.image:
	@echo ingress-nginx的镜像 istry.k8s.io/ingress-nginx/controller:v1.4.0 \
		和 registry.k8s.io/ingress-nginx/kube-webhook-certgen:v20220916-gd32f8c343

	sh bin/pull-k8s-image.sh registry.k8s.io/ingress-nginx/controller:v1.4.0
	sh bin/pull-k8s-image.sh registry.k8s.io/ingress-nginx/kube-webhook-certgen:v20220916-gd32f8c343

pullk8s:
	kubeadm config --cri-socket unix:///var/run/cri-dockerd.sock  \
        --image-repository=registry.aliyuncs.com/google_containers images pull

init:
	echo 引导集群 仅master节点执行
	kubeadm init --cri-socket unix:///var/run/cri-dockerd.sock \
		--image-repository=registry.aliyuncs.com/google_containers \
		--pod-network-cidr=10.244.0.0/16

flannel ingress-nginx:
	kubectl apply -f assets/$@.yaml

httpbin:
	kubectl create deploy httpbin --image kennethreitz/httpbin --port 80 --replicas=2
	kubectl expose deployment httpbin --target-port 80
httpbin.delete:
	kubectl delete deploy httpbin

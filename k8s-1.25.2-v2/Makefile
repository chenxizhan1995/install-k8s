
upload: n1.up n2.up n3.up
n1.up n2.up n3.up:%.up:
	@echo 上传安装脚本到节点 $*.k8s
	rsync -av --exclude=cache remote/ root@$*.k8s:install-k8s/ -e 'ssh -F conf/ssh.conf'

crio.upload:crio.n1.up crio.n2.up crio.n3.up
crio.n1.up crio.n2.up crio.n3.up:crio.%.up:
	@echo 上传crio到节点 $*.k8s
	rsync -av remote/cache/cri-o*.gz root@$*.k8s:install-k8s/cache/ -e 'ssh -F conf/ssh.conf'

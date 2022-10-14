#!/bin/bash
set ue
crio_file="$1"

cd $HOME/install-k8s/cache && tar xf cri-*.gz && cd cri-o

mkdir -pv /etc/crio /usr/local/lib/systemd/system/ /usr/local/share/oci-umount/oci-umount.d/

make all

echo "设置内核参数"
cat > /etc/sysctl.d/crio.conf <<EOF
fs.may_detach_mounts=1
EOF
sysctl --system
systemctl enable --now crio.service
# ls /etc/cni/net.d


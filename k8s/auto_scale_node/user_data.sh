#!/bin/bash

# LẤY THÔNG TIN EC2
METADATA_TOKEN=$(curl -sS -X PUT -H "X-aws-ec2-metadata-token-ttl-seconds: 21600"  http://169.254.169.254/latest/api/token)

INSTANCE_ID=$(curl -sS -H "X-aws-ec2-metadata-token: ${METADATA_TOKEN}" http://169.254.169.254/latest/meta-data/instance-id)

AZ=$(curl -sS -H "X-aws-ec2-metadata-token: ${METADATA_TOKEN}" http://169.254.169.254/latest/meta-data/placement/availability-zone)

# CẤU HÌNH PROVIDER ID CHO KUBELET
echo "KUBELET_EXTRA_ARGS=--provider-id=aws:///$AZ/$INSTANCE_ID" > /etc/default/kubelet
systemctl start crio

# JOIN KUBERNETES
# sudo kubeadm token create --ttl 0 --print-join-command
kubeadm join 172.31.15.97:6443 --token 2dsxzy.nf9djh7kqza8wieg --discovery-token-ca-cert-hash sha256:f5c7511b83bdb14ba2e5e94327a712873a7227c457f83d693e157af36384c9e0 

systemctl restart kubelet
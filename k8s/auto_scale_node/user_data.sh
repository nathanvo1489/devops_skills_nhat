#!/bin/bash

# LẤY THÔNG TIN EC2
METADATA_TOKEN=$(curl -sS -X PUT -H "X-aws-ec2-metadata-token-ttl-seconds: 21600"  http://169.254.169.254/latest/api/token)

INSTANCE_ID=$(curl -sS -H "X-aws-ec2-metadata-token: ${METADATA_TOKEN}" http://169.254.169.254/latest/meta-data/instance-id)

AZ=$(curl -sS -H "X-aws-ec2-metadata-token: ${METADATA_TOKEN}" http://169.254.169.254/latest/meta-data/placement/availability-zone)

# CẤU HÌNH PROVIDER ID CHO KUBELET
echo "KUBELET_EXTRA_ARGS=--provider-id=aws:///$AZ/$INSTANCE_ID" > /etc/default/kubelet
systemctl start crio

# JOIN KUBERNETES
# type this cmd in control-plane to get the join command
# sudo kubeadm token create --ttl 0 --print-join-command
kubeadm join 172.31.3.12:6443 --token bchr14.oqotfgrgfbzqoywh --discovery-token-ca-cert-hash sha256:8322118d99f99d15cfa8c4129a6125473824d7df45b7168f6593e3c15c0f86b0
# join control-plane
systemctl restart kubelet
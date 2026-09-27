chuyển env thành yaml

```bash
kubectl create secret generic nodepad-be-env \
  --from-env-file=.env \
  --dry-run=client \
  -o yaml > secret.nodepad-be.yaml

# SSL
kubectl create secret tls nathan-vo.com \
  --namespace default \
  --cert=nathan-vo.com.crt \
  --key=nathan-vo.com.key \
  --dry-run=client \
  -o yaml > secret.nathan-vo.com.yaml
```

Apply yaml
```bash
kubectl apply -f secret.nathan-vo.com.yaml
kubectl apply -f nodepad-be.yaml
```

kiểm tra secret
```bash
kubectl get secret
```

lệnh kiểm tra k8s chạy pod
```bash
kubectl describe pod [POD_NAME]
```

lệnh kiểm tra log pod
```bash
kubectl logs [POD_NAME]
```

cài nginx

cài helm:
https://helm.sh/docs/intro/install/#from-script
```bash
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-4 | bash
```

```bash
kubectl label node ip-172-31-40-224 ingress-node=true --overwrite

# check
kubectl get nodes --show-labels
kubectl get pods -A -o wide
```

use Helm to install nginx-ingress for k8s
```bash
helm install nginx-ingress \
    oci://ghcr.io/nginx/charts/nginx-ingress \
    --version 2.7.3 \
    --namespace nginx-ingress \
    --create-namespace \
    --values /home/ubuntu/nginx-ingress.yaml
```

lệnh theo dõi
```bash
watch kubectl top pod
watch kubectl top node
```

SSH tunnel lệnh tạo cổng trung gian, run inside Key folder
```bash
ssh -i devops.pem -N -L 16443:127.0.0.1:6443 ubuntu@13.214.154.153

[IP_server_public]: of control-plane: 13.214.154.153
-N No remote command: không mở giao diện gõ CLI
-L local port forward
```

## Auto Scaling Node (VPS)
- Tạo AMI: bản snapshot các phần mềm cài sẵn (k8s/common.sh)
- Tạo Template: bản lưu setting khi launch instant nối thêm AMI
=> Bản Template đẩy đủ

- Tạo Policy "Full Cluster Autoscaler Features Policy" below, and past to JSON area
https://github.com/kubernetes/autoscaler/blob/master/cluster-autoscaler/cloudprovider/aws/README.md#iam-policy

- Tạo Role
=> gắn Policy-Role vào control plane

- ASG Auto Scale Group
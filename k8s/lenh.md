chuyển env thành yaml

```bash
kubectl create secret generic nodepad-be-env \
  --from-env-file=.env \
  --dry-run=client \
  -o yaml > secret.nodepad-be.yaml

# SSL
kubectl create secret tls vulebaolong.com \
  --namespace default \
  --cert=vulebaolong.com.crt \
  --key=vulebaolong.com.key \
  --dry-run=client \
  -o yaml > secret.vulebaolong.com.yaml
```


nạp secrect
```bash
kubectl apply -f secret.nodepad-be.yaml
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
```

```bash
helm install nginx-ingress \
    oci://ghcr.io/nginx/charts/nginx-ingress \
    --version 2.7.2 \
    --namespace nginx-ingress \
    --create-namespace \
    --values /home/ubuntu/nginx-ingress.yaml
```
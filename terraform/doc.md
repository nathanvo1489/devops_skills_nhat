```bash
docker run --name ubuntu-terraform -d -it -v ./terraform:/root/terraform ubuntu

# open local terminal and login terraform ubuntu with terminal
docker exec -it ubuntu-terraform bash
# install terraform into /usr/local/bin/
mv terraform /usr/local/bin/
# install curl first
apt update && apt install -y curl unzip
bash install.sh --system

aws --version

aws configure

aws sts get-caller-identity

apt update && apt install -y less

terraform fmt

terraform init

terraform validate

terraform apply

terraform plan

terraform destroy
```
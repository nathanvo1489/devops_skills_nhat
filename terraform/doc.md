```bash
# must run in the parent folder of 'terraform'
docker run --name ubuntu-terraform -d -it -v ./terraform:/root/terraform ubuntu

# open local terminal and login terraform ubuntu with terminal
docker exec -it ubuntu-terraform bash

# install terraform into /usr/local/bin/
mv terraform /usr/local/bin/

# install aws CLI, but need install curl first
apt update && apt install -y curl unzip
# goto folder 'aws' and run
bash install.sh --system

# check version
terraform --version
aws --version

aws configure

# install less to show json format
apt update && apt install -y less
aws sts get-caller-identity

# check syntax of the script
terraform fmt

terraform init

terraform validate

# start creating EC2 instance
terraform apply

# compare the changes
terraform plan

terraform destroy
```
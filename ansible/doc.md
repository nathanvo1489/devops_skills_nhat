```bash
docker run --name ubuntu-ansible -d -it -v ./ansible:/root/ansible ubuntu:latest
docker exec -it ubuntu-ansible bash

apt update
apt install software-properties-common
add-apt-repository --yes --update ppa:ansible/ansible
apt install ansible

ansible --version

# check if ansible can catch [myhosts]
ansible-inventory -i inventory.ini --list

# PING
ansible myhosts -m ping -i inventory.ini

ansible-playbook -i inventory.ini playbook.yaml
ansible-playbook -i inventory.ini playbook-install-docker.yml
ansible-playbook -i inventory.ini playbook-install-nginx.yaml

```
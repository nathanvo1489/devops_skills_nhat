```bash
# change hostname
sudo hostnamectl set-hostname mail.nathan-vo.com

# check IP public of mail server
dig @1.1.1.1 +short mail.nathan-vo.com
# check DNS mail server config
dig @1.1.1.1 MX nathan-vo.com +short

sudo -i

umask 0022
cd /opt
git clone https://github.com/mailcow/mailcow-dockerized
cd mailcow-dockerized

./generate_config.sh

# Mail server hostname ... hostname: mail.nathan-vo.com
# Timezone [Etc/UTC]: Asia/Ho_Chi_Minh
# Branches: 1

# cd /opt/mailcow-dockerized
docker compose pull
docker compose up -d
```
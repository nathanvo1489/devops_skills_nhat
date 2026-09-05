```bash
# Tạo
sudo vim /etc/nginx/sites-available/html.nathan-vo.com.conf

# Link
sudo ln -s /etc/nginx/sites-available/[tenfile].conf /etc/nginx/sites-enabled

# Unlink / xoa default
sudo rm -rf [tenfile]
sudo rm -rf /etc/nginx/sites-enabled/default

# check cú pháp & reload
sudo nginx -t
sudo systemctl reload nginx

# tao ssl
cd /etc/nginx
sudo mkdir ssl
cd ssl
sudo vim nathan-vo-private.key
sudo vim nathan-vo-public.crt
```
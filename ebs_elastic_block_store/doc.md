```bash
# show volume info
lsblk -o NAME,SIZE,TYPE,MOUNTPOINTS,FSTYPE,SERIAL,UUID

# format
sudo mkfs.ext4 /dev/nvme1n1

# Tạo thư mục để gắn với volume at 'root' folder
sudo mkdir data

# gắn volume vào thư mục đã tạo
sudo mount /dev/nvme1n1 /data

# search specific file/folder in a place
ls -la | grep fstab

# config file vim /etc/fstab
UUID=77f81beb-1902-4daa-b680-dfacca31e8d0 /data ext4 defaults,nofail 0 2

# must reload every mount command
sudo systemctl daemon-reload

# re-mount after setting /etc/fstab
sudo mount /data

# show the max storage
df -h /data

# update new size for the storage
sudo resize2fs /dev/nvme1n1

# snapshot
cd
sync

# umount for creating snapshot
sudo umount /data

sudo umount /dev/nvme2n1 /data-backup

# suitable for back-up (restore)
# read-only
# noload: inhibit system for doing anything
sudo mount -o ro,noload /dev/nvme2n1 /data-backup

# example to scale down the storage
# rsync
rsync --version
# aHAX: maintain all file properties
sudo rsync -aHAX /data/ /data-scale-down/
# aHAXnci: check if 2 folders same properties
sudo rsync -aHAXnci /data/ /data-scale-down/

sudo umount /dev/nvme1n1 /data
sudo umount /dev/nvme2n1 /data-scale-down

sudo mount /dev/nvme2n1 /data
```
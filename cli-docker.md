# DOCKER Orther
```bash
docker login
# cần web để đăng nhập

docker login -u <username>
# dùng khi đăng nhập trên server LINUX, cmd
```

# IMAGE

```bash
# create image
docker build -t my-app-image .

# show danh sách image
docker image list

docker image remove [IMAGE_NAME/ID]

docker image tag [old_name] [new_name]

# export lên hub
docker push [tên_đầy_đủ_image/ID]

# export ra file
docker save -o [đường_dẫn/tên_file.tar] [tên_image/id]

# import từ hub
docker pull [tên_đầy_đủ_image]

# import từ file
docker load -i [đường_dẫn/tên_file.tar]
```

# CONTAINER
```bash
# create container
docker run --name my-app-container -d -p 3000:3000 my-app-image
# -p: publish

# show list container
docker container list
docker ps = process status

docker container start [CONTAINER_NAME/ID]
docker container stop [CONTAINER_NAME/ID]
docker container remove [CONTAINER_NAME/ID]

# Tab logs docker desktop
docker container logs [CONTAINER_NAME/ID]
docker logs [CONTAINER_NAME/ID]

# Tab inspect docker desktop
docker inspect [CONTAINER_NAME/ID]

# Tab stats docker desktop
docker stats
```

# NETWORK
- bridge:
    - network mặc định cho container
    - mỗi container sẽ có IP riêng
    - IP <=> (CONTAINER_NAME giống domain)
- host:
    - Dùng IP của server
    - port dễ bị trùng
- none:
    - container bị cô lập => tăng bảo mật
    - job / bot

```bash
docker network list
docker network create [NETWORK_NAME]
docker network remove [NETWORK_NAME/ID]

docker network connect [NETWORK_NAME/ID] [CONTAINER_NAME/ID]
docker run --network [NETWORK_NAME/ID] --name CONTAINER_NAME -d -p 3000:3000 ten_image
docker network disconnect [NETWORK_NAME/ID] [CONTAINER_NAME/ID]
docker inspect [NETWORK_NAME/ID]
```

# VOLUME

Volume chỉ được mount lúc `docker run`

```bash
docker volume list
docker volume create [VOLUME_NAME]
```

tạo container với database

Postgres - 5432
    - từ 17 trở xuống: /var/lib/postgresql/data
    - từ 18 trở lên: /var/lib/postgresql
MySQL - 3306 - /var/lib/mysql
SQLServer - 1433 - /var/opt/mssql
Mongo - 27017 - /data/db

```bash
docker run --name database -d -e POSTGRES_PASSWORD=12345 -p 5433:5432 postgres:18
```

```bash
# PostgreSQL 18
docker volume create postgres_data_volume

# Mount volume
docker run --name database -d -v postgres_data_volume:/var/lib/postgresql -e POSTGRES_PASSWORD=12345 -p 5432:5432 postgres:18

# Mount đường trên máy host (recommend)
docker run --name database -d -v ./postgres_data:/var/lib/postgresql -e POSTGRES_PASSWORD=12345 -p 5432:5432 postgres:18

# Mongo
docker volume create mongo_data_volume
docker run --name mongo -d -v mongo_data_volume:/data/db mongo

# MySQL
docker volume create mysql_data_volume
docker run --name mysql -d -v mysql_data_volume:/var/lib/mysql -e MYSQL_ROOT_PASSWORD=123456 mysql

# SQL Server
docker volume create sqlserver_data_volume
docker run --name sqlserver -d -v sqlserver_data_volume:/var/opt/mssql -e ACCEPT_EULA=Y -e MSSQL_SA_PASSWORD='YourStrong!Pass123' mcr.microsoft.com/mssql server:2022-latest
```

tạo nháp dữ liệu cho db postgres
```bash
docker exec -it [CONTAINER_NAME/ID] bash

psql -U postgres

# show database
\l

# show table
\dt

# create Table
CREATE TABLE users (name VARCHAR(255));

# thêm dữ liệu vào table
INSERT INTO users (name) VALUES ('LONG'),('CHUONG'),('LAM');

# show dữ liệu
SELECT * FROM users;
```

# BACKUP VOLUME

Từ Volume export ra file
```bash
docker run --rm -v database_data_volume:/var/lib/postgresql -v ./:/backup ubuntu tar cvf /backup/database_data_volume.tar -C /var/lib/postgresql .
```

`docker run --rm`: tạo 1 container tạm, tự động xoá container
`-v database_data_volume:/var/lib/postgresql`: gắn volume database_data_volume vào container tạm
`-v ./:/backup`: lấy đường dẫn ở trên máy (host) và bind mount vào folder bên trong container tạm
`ubuntu`: dùng image ubuntu
`tar`: tạo (nén) ra file có đuổi .tar
`c`: Create
`v`: show các folder được nén
`f`: file tên file output
`x`: giải nén file thành dữ liệu
`-C`: giống cd, di chuyển tới folder

# RESTORE VOLUME (tar)
```bash
docker run --rm -v database_data_volume:/var/lib/postgresql -v ./:/backup ubuntu tar xvf /backup/database_data_volume.tar -C /var/lib/postgresql
```


# CLEAR - dọn dẹp rác

```bash
docker system df -v
```
`-v`: show chi tiết

Images    
Xoá bỏ image không sài ví dụ : <none><none>
```bash
docker image prune -f
```      
Containers  
không nên sài, tự kiểm soát
```bash
docker container prune -f
```
Local Volumes
Không sài
```bash
docker volume prune -f
```
Build Cache  
```bash
docker builder prune -f
```

Combo hay sài
```bash
docker builder prune -f
docker image prune -f
```

# Tối ưu Dockerfile

## Cache
- tăng tốc độ build

## Stage (giai đoạn)


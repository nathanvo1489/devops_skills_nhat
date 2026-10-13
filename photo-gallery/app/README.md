# Photo Gallery — Docker Compose

Chép nội dung folder này vào `~/photo_gallery` trên EC2 đã có Docker + Compose.
EC2 cần role `PhotoGalleryEc2Role`, IMDS enabled / IMDSv2 required / hop limit 2.

```bash
cd ~/photo_gallery
cp .env.example .env
nano .env
# Điền bucket, table, CloudFront URL và API Gateway URL thật.
docker compose up -d
docker compose logs -f backend
```

Compose tự build image lần đầu. Go phục vụ cả FE và API trong một container.
Không cần cài Go/Node trên host hoặc thêm access key vào env.

Trong `.env`, đặt `S3_FOLDER=photos`; `CLOUDFRONT_URL` chỉ chứa domain.
Metadata chỉ có tên file sẽ được thêm folder; key đã có folder được giữ nguyên.
CloudFront Origin path để trống. Khi đổi folder, cập nhật quyền S3 theo prefix mới.
Sau khi cập nhật code và `.env`, chạy `docker compose up -d --build`.

Mở terminal trên máy cá nhân:

```bash
ssh -i /DUONG_DAN/key.pem -N -L 8080:127.0.0.1:8080 ubuntu@EC2_PUBLIC_IP
```

Mở http://localhost:8080. Port app chỉ publish trên loopback EC2; security group chỉ cần SSH từ IP của bạn.
Ảnh qua CloudFront công khai trong bài lab này.

```bash
# Đổi source:
docker compose up -d --build
# Đổi .env:
docker compose up -d --force-recreate
# Dừng app:
docker compose down
```

Ctrl+C khi xem logs không dừng container. Dữ liệu nằm ở S3/DynamoDB, không cần Docker volume.

platform = hệ điều hành (OS) / kiến trúc (Architecture)

linux/amd64: Hệ điều hành Linux + Chip kiến trúc x86_64 (Intel hoặc AMD 64-bit).
linux/arm64: Hệ điều hành Linux + Chip kiến trúc ARM 64-bit (Apple Silicon M1/M2/M3/M4, AWS Graviton, Raspberry Pi).
windows/amd64: Hệ điều hành Windows + Chip kiến trúc x86_64 (Intel hoặc AMD 64-bit).


```bash
# Lệnh build image
docker build --platform=linux/amd64
docker build --platform=linux/arm64
docker build --platform=windows/amd64
```
    

```Dockerfile
# file Dockerfile
FROM --platform=linux/amd64 node:18-alpine
```

```yml
# file docker-compose.yml
service:
    js_nextjs:
    platform: linux/amd64 (intel)
    platform: linux/arm64 (apple)
    platform: windows/amd64 (Windows Server)
    build:
      context: ../js_nextjs
      dockerfile: Dockerfile
```


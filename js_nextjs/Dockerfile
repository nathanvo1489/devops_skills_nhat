FROM node:24-alpine AS builder

WORKDIR /app

# ưu tiên bắt sự thay đổi của thư viện
COPY package-lock.json .
COPY package.json .

# lệnh cài thư viện
RUN npm install

COPY . . 

# lệnh RUN sẽ chạy trong lúc build image
RUN npm run build

FROM node:24-alpine

WORKDIR /app

# COPY --from=builder  ./app/.next   ./.next
# COPY --from=builder  ./app/node_modules   ./node_modules
# COPY --from=builder  ./app/public   ./public
# COPY --from=builder  ./app/package.json   ./package.json

COPY --from=builder  ./app/.next/standalone   ./
COPY --from=builder  ./app/public   ./public
COPY --from=builder  ./app/.next/static   ./.next/static


# lệnh auto khi start container
CMD ["node", "server.js"]

# docker build -t vulebaolong/my-app-image .
# docker run --name my-app-container -d -p 12345:3000 --network demo_network vulebaolong/my-app-image

# const nextConfig: NextConfig = {
#   /* config options here */
#   output: "standalone"
# };
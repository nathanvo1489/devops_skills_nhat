# Build BE Go và nhúng FE vào cùng binary.
FROM golang:1.26.2-alpine AS build
WORKDIR /src
COPY go.mod go.sum ./
RUN go mod download
COPY main.go ./
COPY web ./web
RUN CGO_ENABLED=0 go build -o /gallery .

# Image chạy ứng dụng, không cần giữ Go compiler.
FROM alpine:3.23
RUN apk add --no-cache ca-certificates
WORKDIR /app
COPY --from=build /gallery ./gallery
USER 65532:65532
EXPOSE 8080
CMD ["./gallery"]

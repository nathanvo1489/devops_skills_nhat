# -------- BUILD --------
FROM golang:1.26.2-alpine AS builder

WORKDIR /app

RUN apk add --no-cache git

COPY go.mod go.sum ./
RUN go mod download

COPY . .

RUN CGO_ENABLED=0 GOOS=linux go build -o nodepad .

# -------- RUN --------
FROM alpine:latest

WORKDIR /app

COPY --from=builder /app/nodepad .
COPY --from=builder /app/etc ./etc

CMD ["./nodepad", "-f", "etc/nodepad-api.yaml"]

# docker build -t img-nodepad_be .
# docker run --name img-nodepad_be -d -p 8888:3000 nathanvo1489/img-nodepad_be:latest

FROM golang:1.21-alpine AS builder

WORKDIR /app

# Копируем go.mod и go.sum
COPY go.mod go.sum ./
RUN go mod download

# Копируем исходный код
COPY . .

# Собираем приложение
RUN CGO_ENABLED=0 GOOS=linux go build -o api-gateway ./cmd

# Финальный образ
FROM alpine:latest

RUN apk --no-cache add ca-certificates tzdata

WORKDIR /root/

# Копируем бинарник из builder
COPY --from=builder /app/api-gateway .

# Копируем конфигурацию
COPY config.yaml ./

# Экспортируем порт
EXPOSE 8080 9091

# Запускаем приложение
CMD ["./api-gateway"]

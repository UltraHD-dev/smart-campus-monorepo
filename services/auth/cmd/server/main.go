package main

import (
	"log"
	"net"
	"os"

	"github.com/UltraHD-dev/smart-campus-monorepo/services/auth/internal/handler"
	"github.com/UltraHD-dev/smart-campus-monorepo/services/auth/internal/repository"
	"github.com/UltraHD-dev/smart-campus-monorepo/services/auth/internal/service"
	"github.com/UltraHD-dev/smart-campus-monorepo/services/auth/pkg/jwt"
	"google.golang.org/grpc"
	"google.golang.org/grpc/reflection"
)

func main() {
	// Конфигурация из переменных окружения
	dbConnStr := getEnv("DB_CONNECTION", "postgresql://campus:campus123@localhost:15432/auth_db")
	jwtSecret := getEnv("JWT_SECRET", "your_super_secret_key_change_in_production")
	redisAddr := getEnv("REDIS_ADDR", "localhost:16379")
	redisPass := getEnv("REDIS_PASSWORD", "campus123")

	// Инициализация зависимостей
	userRepo, err := repository.NewPostgresRepository(dbConnStr)
	if err != nil {
		log.Fatalf("Failed to connect to database: %v", err)
	}
	defer userRepo.Close()

	tokenRepo, err := repository.NewRedisRepository(redisAddr, redisPass)
	if err != nil {
		log.Printf("Warning: Redis connection failed: %v", err)
		// Можно работать без Redis (токены будут валидны до истечения срока)
	}

	jwtManager := jwt.NewManager(jwtSecret)
	authService := service.NewAuthService(userRepo, tokenRepo, jwtManager)
	authHandler := handler.NewAuthHandler(authService)

	// Запуск gRPC сервера
	lis, err := net.Listen("tcp", ":50051")
	if err != nil {
		log.Fatalf("failed to listen: %v", err)
	}

	s := grpc.NewServer()
	handler.RegisterAuthServer(s, authHandler)

	// ⭐⭐⭐ ВАЖНО: Добавьте эту строку для включения reflection API ⭐⭐⭐
	reflection.Register(s)

	log.Printf("Auth service listening at %v", lis.Addr())
	if err := s.Serve(lis); err != nil {
		log.Fatalf("failed to serve: %v", err)
	}
}

func getEnv(key, defaultValue string) string {
	if value := os.Getenv(key); value != "" {
		return value
	}
	return defaultValue
}

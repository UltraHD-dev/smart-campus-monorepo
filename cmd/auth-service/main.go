package main

import (
	"context"
	"fmt"
	"log"
	"net"
	"time"

	"google.golang.org/grpc"
)

// Server implements auth service
type Server struct{}

// Login handles user authentication
func (s *Server) Login(ctx context.Context, req *struct {
	Email    string
	Password string
}) (*struct {
	Token   string `json:"token"`
	UserId  string `json:"user_id"`
	Message string `json:"message"`
}, error) {

	log.Printf("🔐 Login attempt: %s", req.Email)

	// Тестовые credentials
	if req.Email == "admin@campus.com" && req.Password == "admin123" {
		return &struct {
			Token   string `json:"token"`
			UserId  string `json:"user_id"`
			Message string `json:"message"`
		}{
			Token:   "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.xxxx",
			UserId:  "user_001",
			Message: "Login successful",
		}, nil
	}

	return nil, fmt.Errorf("invalid credentials")
}

// Health check
func (s *Server) HealthCheck(ctx context.Context, req *struct{}) (*struct {
	Status  string `json:"status"`
	Service string `json:"service"`
	Time    string `json:"time"`
}, error) {
	return &struct {
		Status  string `json:"status"`
		Service string `json:"service"`
		Time    string `json:"time"`
	}{
		Status:  "ok",
		Service: "auth-service",
		Time:    time.Now().Format(time.RFC3339),
	}, nil
}

func main() {
	lis, err := net.Listen("tcp", ":50051")
	if err != nil {
		log.Fatalf("failed to listen: %v", err)
	}

	srv := grpc.NewServer()

	log.Printf("🔐 Auth service starting on %v", lis.Addr())
	log.Printf("👤 Test credentials: admin@campus.com / admin123")

	if err := srv.Serve(lis); err != nil {
		log.Fatalf("failed to serve: %v", err)
	}
}

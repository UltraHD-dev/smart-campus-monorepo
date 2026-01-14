package main

import (
	"context"
	"log"
	"net"

	"google.golang.org/grpc"
)

// Server implements user service
type Server struct{}

// GetUserProfile returns user profile
func (s *Server) GetUserProfile(ctx context.Context, req *struct {
	UserId string
}) (*struct {
	UserId   string `json:"user_id"`
	Email    string `json:"email"`
	FullName string `json:"full_name"`
	Role     string `json:"role"`
}, error) {

	log.Printf("User profile requested: %s", req.UserId)

	return &struct {
		UserId   string `json:"user_id"`
		Email    string `json:"email"`
		FullName string `json:"full_name"`
		Role     string `json:"role"`
	}{
		UserId:   req.UserId,
		Email:    "user@example.com",
		FullName: "John Doe",
		Role:     "student",
	}, nil
}

// SubmitMembershipRequest submits request to join organization
func (s *Server) SubmitMembershipRequest(ctx context.Context, req *struct {
	UserId         string
	OrganizationId string
	Message        string
}) (*struct {
	RequestId string
	Status    string
	Message   string
}, error) {

	log.Printf("📨 Membership request: user=%s, org=%s",
		req.UserId, req.OrganizationId)

	return &struct {
		RequestId string
		Status    string
		Message   string
	}{
		RequestId: "req_" + req.UserId + "_" + req.OrganizationId,
		Status:    "pending",
		Message:   "Request submitted for review",
	}, nil
}

// HealthCheck returns service health status
func (s *Server) HealthCheck(ctx context.Context, req *struct{}) (*struct {
	Status  string `json:"status"`
	Service string `json:"service"`
}, error) {
	return &struct {
		Status  string `json:"status"`
		Service string `json:"service"`
	}{
		Status:  "ok",
		Service: "user-service",
	}, nil
}

func main() {
	lis, err := net.Listen("tcp", ":50054")
	if err != nil {
		log.Fatalf("failed to listen: %v", err)
	}

	srv := grpc.NewServer()

	// В реальном коде здесь будет регистрация сервиса
	// pb.RegisterUserServiceServer(srv, userServer)

	log.Printf("User service starting on %v", lis.Addr())
	log.Printf("Handling user profiles and membership requests")

	if err := srv.Serve(lis); err != nil {
		log.Fatalf("failed to serve: %v", err)
	}
}

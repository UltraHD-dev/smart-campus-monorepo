package main

import (
	"context"
	"log"
	"net"

	"google.golang.org/grpc"
)

// Server implements organization service
type Server struct{}

// SubmitApplication handles new organization applications
func (s *Server) SubmitApplication(ctx context.Context, req *struct {
	OrganizationName string
	ContactEmail     string
	ContactPhone     string
}) (*struct {
	ApplicationId string
	Message       string
}, error) {

	log.Printf("📝 New organization application: %s (%s)",
		req.OrganizationName, req.ContactEmail)

	return &struct {
		ApplicationId string
		Message       string
	}{
		ApplicationId: "app_" + req.OrganizationName,
		Message:       "Application received and pending review",
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
		Service: "organization-service",
	}, nil
}

func main() {
	lis, err := net.Listen("tcp", ":50052")
	if err != nil {
		log.Fatalf("failed to listen: %v", err)
	}

	srv := grpc.NewServer()

	// В реальном коде здесь будет регистрация сервиса
	// pb.RegisterOrganizationServiceServer(srv, orgServer)

	log.Printf("🏛️  Organization service starting on %v", lis.Addr())
	log.Printf("📋 Accepting organization applications")

	if err := srv.Serve(lis); err != nil {
		log.Fatalf("failed to serve: %v", err)
	}
}

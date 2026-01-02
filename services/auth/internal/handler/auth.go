package handler

import (
	"context"
	"github.com/UltraHD-dev/smart-campus-monorepo/services/auth/internal/service"
	"github.com/UltraHD-dev/smart-campus-monorepo/services/auth/proto"
	"google.golang.org/grpc"
)

type AuthHandler struct {
	proto.UnimplementedAuthServiceServer
	authService *service.AuthService
}

func NewAuthHandler(authService *service.AuthService) *AuthHandler {
	return &AuthHandler{
		authService: authService,
	}
}

func (h *AuthHandler) Register(ctx context.Context, req *proto.RegisterRequest) (*proto.RegisterResponse, error) {
	userID, err := h.authService.Register(ctx, req.Email, req.Password, req.FullName, req.Role)
	if err != nil {
		return &proto.RegisterResponse{
			Success: false,
			Error:   err.Error(),
		}, nil
	}

	return &proto.RegisterResponse{
		Success: true,
		UserId:  userID,
	}, nil
}

func (h *AuthHandler) Login(ctx context.Context, req *proto.LoginRequest) (*proto.LoginResponse, error) {
	accessToken, refreshToken, user, err := h.authService.Login(ctx, req.Email, req.Password)
	if err != nil {
		return &proto.LoginResponse{
			Success: false,
			Error:   err.Error(),
		}, nil
	}

	return &proto.LoginResponse{
		Success:      true,
		AccessToken:  accessToken,
		RefreshToken: refreshToken,
		User: &proto.User{
			Id:        user.ID,
			Email:     user.Email,
			Role:      user.Role,
			FullName:  user.FullName,
			CreatedAt: user.CreatedAt.Format("2006-01-02 15:04:05"),
		},
	}, nil
}

func (h *AuthHandler) ValidateToken(ctx context.Context, req *proto.ValidateRequest) (*proto.ValidateResponse, error) {
	user, err := h.authService.ValidateToken(ctx, req.Token)
	if err != nil {
		return &proto.ValidateResponse{
			Valid: false,
			Error: err.Error(),
		}, nil
	}

	return &proto.ValidateResponse{
		Valid: true,
		User: &proto.User{
			Id:        user.ID,
			Email:     user.Email,
			Role:      user.Role,
			FullName:  user.FullName,
			CreatedAt: user.CreatedAt.Format("2006-01-02 15:04:05"),
		},
	}, nil
}

func (h *AuthHandler) RefreshToken(ctx context.Context, req *proto.RefreshRequest) (*proto.RefreshResponse, error) {
	if req.RefreshToken == "" {
		return &proto.RefreshResponse{
			Success: false,
			Error:   "refresh token is required",
		}, nil
	}

	accessToken, err := h.authService.RefreshToken(ctx, req.RefreshToken)
	if err != nil {
		return &proto.RefreshResponse{
			Success: false,
			Error:   err.Error(),
		}, nil
	}

	return &proto.RefreshResponse{
		Success:     true,
		AccessToken: accessToken,
	}, nil
}
func RegisterAuthServer(s *grpc.Server, handler *AuthHandler) {
	proto.RegisterAuthServiceServer(s, handler)
}

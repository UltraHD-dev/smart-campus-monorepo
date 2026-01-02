package service

import (
	"context"
	"errors"
	"fmt"
	"github.com/UltraHD-dev/smart-campus-monorepo/services/auth/internal/repository"
	"github.com/UltraHD-dev/smart-campus-monorepo/services/auth/pkg/jwt"
	"golang.org/x/crypto/bcrypt"
	"log"
	"time"
)

type AuthService struct {
	userRepo  repository.UserRepository
	tokenRepo repository.TokenRepository
	jwtMgr    *jwt.Manager
}

func NewAuthService(userRepo repository.UserRepository, tokenRepo repository.TokenRepository, jwtMgr *jwt.Manager) *AuthService {
	return &AuthService{
		userRepo:  userRepo,
		tokenRepo: tokenRepo,
		jwtMgr:    jwtMgr,
	}
}

func (s *AuthService) Register(ctx context.Context, email, password, fullName, role string) (string, error) {
	// Проверка существования пользователя
	existingUser, err := s.userRepo.GetUserByEmail(ctx, email)
	if err != nil {
		return "", err
	}
	if existingUser != nil {
		return "", errors.New("user already exists")
	}

	// Хеширование пароля
	hashedPassword, err := bcrypt.GenerateFromPassword([]byte(password), bcrypt.DefaultCost)
	if err != nil {
		return "", err
	}

	// Создание пользователя
	userID, err := s.userRepo.CreateUser(ctx, email, string(hashedPassword), fullName, role)
	if err != nil {
		return "", err
	}

	return userID, nil
}

func (s *AuthService) Login(ctx context.Context, email, password string) (accessToken, refreshToken string, user *repository.User, err error) {
	// Получение пользователя
	user, err = s.userRepo.GetUserByEmail(ctx, email)
	if err != nil {
		return "", "", nil, err
	}
	if user == nil {
		return "", "", nil, errors.New("invalid credentials")
	}

	// Проверка пароля
	if err := bcrypt.CompareHashAndPassword([]byte(user.PasswordHash), []byte(password)); err != nil {
		return "", "", nil, errors.New("invalid credentials")
	}

	// Генерация токенов
	accessToken, refreshToken, err = s.jwtMgr.GenerateToken(user.ID, user.Email, user.Role)
	if err != nil {
		return "", "", nil, err
	}

	// Сохранение refresh токена в Redis (если Redis доступен)
	if s.tokenRepo != nil {
		if err := s.tokenRepo.StoreRefreshToken(ctx, user.ID, refreshToken, 7*24*time.Hour); err != nil {
			log.Printf("Failed to store refresh token in Redis: %v", err)
			// Продолжаем без Redis
		}
	}

	return accessToken, refreshToken, user, nil
}

func (s *AuthService) ValidateToken(ctx context.Context, token string) (*repository.User, error) {
	claims, err := s.jwtMgr.ValidateToken(token)
	if err != nil {
		return nil, err
	}

	user, err := s.userRepo.GetUserByID(ctx, claims.UserID)
	if err != nil {
		return nil, err
	}
	if user == nil {
		return nil, errors.New("user not found")
	}

	return user, nil
}

func (s *AuthService) RefreshToken(ctx context.Context, refreshToken string) (string, error) {
	// Валидация refresh token
	claims, err := s.jwtMgr.ValidateRefreshToken(refreshToken)
	if err != nil {
		return "", fmt.Errorf("invalid refresh token: %w", err)
	}

	// Получаем user_id из Subject (если UserID пустой)
	userID := claims.UserID
	if userID == "" && claims.Subject != "" {
		userID = claims.Subject
	}

	if userID == "" {
		return "", errors.New("user id not found in token")
	}

	// Получение пользователя
	user, err := s.userRepo.GetUserByID(ctx, userID)
	if err != nil {
		return "", fmt.Errorf("failed to get user: %w", err)
	}
	if user == nil {
		return "", errors.New("user not found")
	}

	// Проверка refresh token в Redis (если Redis доступен)
	if s.tokenRepo != nil {
		storedToken, err := s.tokenRepo.GetRefreshToken(ctx, user.ID)
		if err != nil {
			// Если токен не найден в Redis, но это не критично для работы
			log.Printf("Warning: refresh token not found in Redis for user %s: %v", user.ID, err)
		} else if storedToken != refreshToken {
			return "", errors.New("refresh token mismatch")
		}
	}

	// Генерация нового access token (refresh token остаётся тем же)
	accessToken, _, err := s.jwtMgr.GenerateToken(user.ID, user.Email, user.Role)
	if err != nil {
		return "", fmt.Errorf("failed to generate token: %w", err)
	}

	return accessToken, nil
}

package repository

import (
    "context"
    "time"
)

// User структура должна быть определена ТОЛЬКО здесь
type User struct {
    ID           string
    Email        string
    PasswordHash string
    FullName     string
    Role         string
    CreatedAt    time.Time
}

// UserRepository интерфейс
type UserRepository interface {
    CreateUser(ctx context.Context, email, passwordHash, fullName, role string) (string, error)
    GetUserByEmail(ctx context.Context, email string) (*User, error)
    GetUserByID(ctx context.Context, id string) (*User, error)
    Close()
}

// TokenRepository интерфейс
type TokenRepository interface {
    StoreRefreshToken(ctx context.Context, userID, token string, expires time.Duration) error
    GetRefreshToken(ctx context.Context, userID string) (string, error)
    DeleteRefreshToken(ctx context.Context, userID string) error
}

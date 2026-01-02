package repository

import (
	"context"
	"fmt"
	"time"

	"github.com/redis/go-redis/v9"
)

type RedisRepository struct {
	client *redis.Client
}

func NewRedisRepository(addr, password string) (*RedisRepository, error) {
	client := redis.NewClient(&redis.Options{
		Addr:     addr,
		Password: password,
		DB:       0,
	})

	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	if err := client.Ping(ctx).Err(); err != nil {
		return nil, fmt.Errorf("failed to connect to Redis: %w", err)
	}

	return &RedisRepository{client: client}, nil
}

func (r *RedisRepository) StoreRefreshToken(ctx context.Context, userID, token string, expires time.Duration) error {
	key := fmt.Sprintf("refresh_token:%s", userID)
	return r.client.Set(ctx, key, token, expires).Err()
}

func (r *RedisRepository) GetRefreshToken(ctx context.Context, userID string) (string, error) {
	key := fmt.Sprintf("refresh_token:%s", userID)
	return r.client.Get(ctx, key).Result()
}

func (r *RedisRepository) DeleteRefreshToken(ctx context.Context, userID string) error {
	key := fmt.Sprintf("refresh_token:%s", userID)
	return r.client.Del(ctx, key).Err()
}

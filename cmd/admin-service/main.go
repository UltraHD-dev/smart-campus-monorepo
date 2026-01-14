package main

import (
	"context"
	"log"
	"net"
	"net/http"
	"regexp"
	"strings"

	"google.golang.org/grpc"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/metadata"
	"google.golang.org/grpc/status"
)

// MobileDeviceDetector middleware
func MobileDeviceDetector(ctx context.Context, req interface{}, info *grpc.UnaryServerInfo, handler grpc.UnaryHandler) (interface{}, error) {
	// Получаем User-Agent из метаданных
	md, ok := metadata.FromIncomingContext(ctx)
	if ok {
		userAgents := md.Get("user-agent")
		if len(userAgents) > 0 {
			userAgent := strings.ToLower(userAgents[0])

			// Паттерны для определения мобильных телефонов
			mobilePatterns := []string{
				"iphone",
				"android.*mobile",
				"windows phone",
				"blackberry",
				"opera mini",
				"mobile.*firefox",
			}

			// Паттерны для разрешенных устройств (планшеты, ПК)
			allowedPatterns := []string{
				"ipad",
				"tablet",
				"android.*(?!mobile)", // Android но не mobile
				"windows nt",
				"macintosh",
				"linux",
				"chrome.*safari",
			}

			// Проверяем на мобильный телефон
			isMobilePhone := false
			for _, pattern := range mobilePatterns {
				matched, _ := regexp.MatchString(pattern, userAgent)
				if matched {
					isMobilePhone = true
					break
				}
			}

			// Если это мобильный телефон - блокируем
			if isMobilePhone {
				log.Printf("🚫 BLOCKED mobile device attempt: %s", userAgent)
				return nil, status.Error(codes.PermissionDenied, "Mobile phone access not allowed for admin functions. Please use a desktop or tablet.")
			}

			// Проверяем на разрешенное устройство
			isAllowed := false
			for _, pattern := range allowedPatterns {
				matched, _ := regexp.MatchString(pattern, userAgent)
				if matched {
					isAllowed = true
					break
				}
			}

			if !isAllowed {
				log.Printf("⚠️  Unknown device type: %s", userAgent)
			}
		}
	}

	return handler(ctx, req)
}

// Health check handler
func (s *Server) HealthCheck(ctx context.Context, req *struct{}) (*struct {
	Status  string `json:"status"`
	Service string `json:"service"`
}, error) {
	return &struct {
		Status  string `json:"status"`
		Service string `json:"service"`
	}{
		Status:  "ok",
		Service: "admin-service",
	}, nil
}

// Server implements admin service
type Server struct{}

func main() {
	lis, err := net.Listen("tcp", ":50053")
	if err != nil {
		log.Fatalf("failed to listen: %v", err)
	}

	// Создаем gRPC сервер с middleware
	srv := grpc.NewServer(
		grpc.UnaryInterceptor(MobileDeviceDetector),
	)

	// Здесь будет регистрация сервиса
	// pb.RegisterAdminServiceServer(srv, &Server{})

	log.Printf("🔒 Admin service starting on %v", lis.Addr())
	log.Printf("📱 Mobile device blocking ENABLED")
	log.Printf("💻 Allowed: Desktop, Laptop, Tablet")
	log.Printf("🚫 Blocked: iPhone, Android Phone, Windows Phone")

	// Также запускаем HTTP сервер для health check
	go func() {
		http.HandleFunc("/health", func(w http.ResponseWriter, r *http.Request) {
			w.Header().Set("Content-Type", "application/json")

			// Проверяем User-Agent для HTTP запросов тоже
			userAgent := strings.ToLower(r.Header.Get("User-Agent"))
			mobilePatterns := []string{"iphone", "android.*mobile", "windows phone"}

			for _, pattern := range mobilePatterns {
				matched, _ := regexp.MatchString(pattern, userAgent)
				if matched {
					w.WriteHeader(http.StatusForbidden)
					w.Write([]byte(`{"error": "Mobile phone access not allowed"}`))
					return
				}
			}

			w.Write([]byte(`{"status":"ok","service":"admin-service"}`))
		})

		log.Printf("🌐 HTTP health check on :8080")
		http.ListenAndServe(":8080", nil)
	}()

	if err := srv.Serve(lis); err != nil {
		log.Fatalf("failed to serve: %v", err)
	}
}

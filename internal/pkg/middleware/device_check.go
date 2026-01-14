package middleware

import (
	"context"
	"regexp"
	"strings"

	"google.golang.org/grpc"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/metadata"
	"google.golang.org/grpc/status"
)

// DeviceCheckInterceptor блокирует доступ с мобильных телефонов
// Разрешает доступ только с ПК, ноутбуков и планшетов
func DeviceCheckInterceptor() grpc.UnaryServerInterceptor {
	return func(ctx context.Context, req interface{}, info *grpc.UnaryServerInfo, handler grpc.UnaryHandler) (interface{}, error) {
		// Проверяем, что это вызов AdminService (только для админских методов)
		if strings.Contains(info.FullMethod, "AdminService") {
			// Получаем User-Agent из метаданных
			md, ok := metadata.FromIncomingContext(ctx)
			if ok {
				userAgents := md.Get("user-agent")
				if len(userAgents) > 0 {
					userAgent := strings.ToLower(userAgents[0])
					
					// Проверяем на мобильные телефоны
					if isMobilePhone(userAgent) {
						return nil, status.Error(codes.PermissionDenied, 
							"Доступ с мобильных телефонов запрещен. Используйте ПК или ноутбук.")
					}
					
					// Проверяем устройство и логируем
					deviceType := detectDeviceType(userAgent)
					
					// Добавляем информацию об устройстве в контекст
					ctx = context.WithValue(ctx, "device_type", deviceType)
					ctx = context.WithValue(ctx, "user_agent", userAgent)
				}
			}
		}
		
		return handler(ctx, req)
	}
}

// isMobilePhone определяет, является ли устройство мобильным телефоном
func isMobilePhone(userAgent string) bool {
	// Паттерны для мобильных телефонов (Android Phone, iPhone)
	mobilePhonePatterns := []string{
		`android.*mobile`,    // Android телефоны (но не планшеты)
		`iphone`,            // iPhone
		`ipod`,              // iPod
		`blackberry`,        // BlackBerry
		`windows phone`,     // Windows Phone
		`opera mini`,        // Opera Mini
		`iemobile`,          // IE Mobile
	}
	
	// Паттерны для исключений (планшеты, ПК)
	tabletPatterns := []string{
		`ipad`,              // iPad
		`android.*(?!.*mobile)`, // Android без mobile (планшеты)
		`tablet`,            // Таблетки
		`kindle`,            // Kindle
		`silk`,              // Amazon Silk
	}
	
	// Сначала проверяем исключения (планшеты)
	for _, pattern := range tabletPatterns {
		if matched, _ := regexp.MatchString(pattern, userAgent); matched {
			return false // Это планшет, разрешаем
		}
	}
	
	// Проверяем мобильные телефоны
	for _, pattern := range mobilePhonePatterns {
		if matched, _ := regexp.MatchString(pattern, userAgent); matched {
			return true // Это мобильный телефон, блокируем
		}
	}
	
	return false // Не мобильный телефон, разрешаем
}

// detectDeviceType определяет тип устройства
func detectDeviceType(userAgent string) string {
	userAgent = strings.ToLower(userAgent)
	
	switch {
	case strings.Contains(userAgent, "windows nt") || 
	     strings.Contains(userAgent, "mac os") || 
	     strings.Contains(userAgent, "linux"):
		return "desktop"
	case strings.Contains(userAgent, "android") && !strings.Contains(userAgent, "mobile"):
		return "tablet"
	case strings.Contains(userAgent, "ipad"):
		return "tablet"
	case strings.Contains(userAgent, "mobile") || 
	     strings.Contains(userAgent, "iphone") || 
	     strings.Contains(userAgent, "android.*mobile"):
		return "mobile_phone"
	default:
		return "unknown"
	}
}

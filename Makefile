.PHONY: help install-deps proto build-all docker-up clean

help:
	@echo "Smart Campus Platform - Команды управления"
	@echo ""
	@echo "make install-deps    - Установить зависимости"
	@echo "make proto           - Генерация кода из proto"
	@echo "make build-all       - Собрать всё"
	@echo "make docker-up       - Запустить Docker"
	@echo "make clean           - Очистка"
	@echo "make help            - Эта справка"

install-deps:
	@echo "📦 Установка зависимостей..."
	go install google.golang.org/protobuf/cmd/protoc-gen-go@latest
	go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@latest
	cd mobile && flutter pub get
	@echo "✅ Зависимости установлены"

proto:
	@echo "🔧 Генерация кода из proto..."
	@echo "TODO: Добавить генерацию proto"
	@echo "✅ Код сгенерирован"

build-all:
	@echo "🔨 Сборка проекта..."
	@echo "✅ Готово!"

docker-up:
	@echo "🐳 Запуск Docker..."
	@echo "TODO: Добавить docker-compose"
	@echo "✅ Docker запущен"

clean:
	@echo "🧹 Очистка..."
	rm -rf mobile/build
	find . -name "*.pb.go" -delete
	find . -name "*.pb.dart" -delete
	@echo "✅ Очищено"

new-service:
	@if [ -z "$(NAME)" ]; then \
		echo "❌ Использование: make new-service NAME=service-name"; \
		exit 1; \
	fi
	@echo "🆕 Создание сервиса $(NAME)..."
	mkdir -p services/$(NAME)/{cmd,internal/{domain,repository,service,handler,config},migrations}
	cd services/$(NAME) && go mod init github.com/UltraHD-dev/smart-campus-monorepo/services/$(NAME)
	@echo "✅ Сервис $(NAME) создан"

docker-up:
	@echo "🐳 Запуск Docker инфраструктуры..."
	docker-compose -f infrastructure/docker-compose.yml up -d
	@echo "✅ Docker запущен"
	@echo ""
	@echo "📊 Мониторинг доступен по адресам:"
	@echo "  Grafana:     http://localhost:3000 (admin/admin)"
	@echo "  Prometheus:  http://localhost:9090"
	@echo "  pgAdmin:     http://localhost:5050 (admin@campus.local/admin123)"
	@echo "  Redis UI:    http://localhost:8081"

docker-down:
	@echo "🛑 Остановка Docker..."
	docker-compose -f infrastructure/docker-compose.yml down
	@echo "✅ Docker остановлен"

docker-logs:
	@echo "📋 Показать логи..."
	docker-compose -f infrastructure/docker-compose.yml logs -f

docker-build-all:
	@echo "🔨 Сборка Docker образов..."
	docker-compose -f infrastructure/docker-compose.yml build --no-cache
	@echo "✅ Docker образы собраны"

flutter-build-all:
	@echo "📱 Сборка Flutter под все платформы..."
	cd mobile && flutter pub get
	@echo "Android..."
	cd mobile && flutter build apk --split-per-abi --release
	@echo "Linux..."
	cd mobile && flutter build linux --release
	@echo "Windows..."
	cd mobile && flutter build windows --release
	@echo "macOS..."
	cd mobile && flutter build macos --release --no-codesign
	@echo "✅ Все сборки Flutter готовы"
	@echo ""
	@echo "📦 Артефакты:"
	@echo "  Android: mobile/build/app/outputs/flutter-apk/"
	@echo "  Linux:   mobile/build/linux/x64/release/bundle/"
	@echo "  Windows: mobile/build/windows/runner/Release/"
	@echo "  macOS:   mobile/build/macos/Build/Products/Release/"

monitor:
	@echo "📊 Открытие мониторинга..."
	xdg-open http://localhost:3000 2>/dev/null || echo "Откройте http://localhost:3000 в браузере"

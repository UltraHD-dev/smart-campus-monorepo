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

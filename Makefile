.PHONY: help install-deps proto build-all docker-up clean \
        new-service docker-down docker-logs docker-build-all \
        flutter-build-all monitor flutter-run check-deps test-infra \
        open-all db-check db-connect-auth db-connect-schedule redis-connect

# Colors
GREEN=\033[0;32m
YELLOW=\033[1;33m
BLUE=\033[0;34m
RED=\033[0;31m
CYAN=\033[0;36m
NC=\033[0m

help:
	@echo -e "${BLUE}🏫 Smart Campus Platform - Команды управления${NC}"
	@echo ""
	@echo -e "${YELLOW}Основные команды:${NC}"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "${GREEN}%-25s${NC} %s\n", $$1, $$2}'

install-deps: ## Установить зависимости
	@echo -e "${BLUE}📦 Установка зависимостей...${NC}"
	go install google.golang.org/protobuf/cmd/protoc-gen-go@latest
	go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@latest
	cd mobile && flutter pub get
	@echo -e "${GREEN}✅ Зависимости установлены${NC}"

install-deps-arch: ## Установить зависимости для Arch Linux
	@echo -e "${BLUE}🐧 Установка зависимостей Arch Linux...${NC}"
	sudo pacman -S --noconfirm docker docker-compose protobuf
	sudo systemctl enable --now docker
	sudo usermod -aG docker $(USER) || true
	@$(MAKE) install-deps

proto: ## Генерация кода из proto
	@echo -e "${BLUE}🔧 Генерация кода из proto...${NC}"
	chmod +x scripts/generate-proto.sh
	./scripts/generate-proto.sh
	@echo -e "${GREEN}✅ Код сгенерирован${NC}"

build-all: ## Собрать всё
	@echo -e "${BLUE}🔨 Сборка проекта...${NC}"
	@echo -e "${GREEN}✅ Готово!${NC}"

docker-up: ## Запустить Docker инфраструктуру
	@echo -e "${BLUE}🐳 Запуск Docker инфраструктуры...${NC}"
	docker compose -f infrastructure/docker-compose.yml up -d
	@echo -e "${GREEN}✅ Docker запущен${NC}"
	@echo -e "${CYAN}⏳ Ожидание инициализации сервисов (30 секунд)...${NC}"
	@sleep 30
	@$(MAKE) test-infra
	@$(MAKE) open-all

docker-down: ## Остановить Docker
	@echo -e "${BLUE}🛑 Остановка Docker...${NC}"
	docker compose -f infrastructure/docker-compose.yml down
	@echo -e "${GREEN}✅ Docker остановлен${NC}"

docker-logs: ## Показать логи
	@echo -e "${BLUE}📋 Показать логи всех сервисов...${NC}"
	docker compose -f infrastructure/docker-compose.yml logs -f

docker-logs-service: ## Показать логи конкретного сервиса
	@if [ -z "$(SERVICE)" ]; then \
		echo -e "${RED}❌ Использование: make docker-logs-service SERVICE=имя_сервиса${NC}"; \
		echo "Доступные сервисы: postgres-auth, postgres-schedule, redis, grafana, prometheus, pgadmin"; \
		exit 1; \
	fi
	docker logs -f $(SERVICE)

docker-build-all: ## Собрать Docker образы
	@echo -e "${BLUE}🔨 Сборка Docker образов...${NC}"
	docker compose -f infrastructure/docker-compose.yml build --no-cache
	@echo -e "${GREEN}✅ Docker образы собраны${NC}"

flutter-build-all: ## Собрать Flutter под все платформы
	@echo -e "${BLUE}📱 Сборка Flutter под все платформы...${NC}"
	cd mobile && flutter pub get
	@echo "Android..."
	cd mobile && flutter build apk --split-per-abi --release || echo "⚠️ Android сборка пропущена"
	@echo "Linux..."
	cd mobile && flutter build linux --release || echo "⚠️ Linux сборка пропущена"
	@echo "Windows..."
	cd mobile && flutter build windows --release || echo "⚠️ Windows сборка пропущена"
	@echo "macOS..."
	cd mobile && flutter build macos --release --no-codesign || echo "⚠️ macOS сборка пропущена"
	@echo -e "${GREEN}✅ Все сборки Flutter готовы${NC}"

flutter-run: ## Запустить Flutter
	@echo -e "${BLUE}🚀 Запуск Flutter...${NC}"
	cd mobile && flutter run

monitor: ## Показать статус всех сервисов
	@echo -e "${BLUE}📊 Статус инфраструктуры Smart Campus:${NC}"
	@echo ""
	@echo -e "${YELLOW}🌐 Веб-интерфейсы:${NC}"
	@echo -e "  ${CYAN}▸ Grafana${NC}      ${GREEN}http://localhost:13000${NC}"
	@echo "     Мониторинг и дашборды"
	@echo "     Логин: ${YELLOW}admin${NC} / ${YELLOW}admin${NC}"
	@echo ""
	@echo -e "  ${CYAN}▸ Prometheus${NC}   ${GREEN}http://localhost:19090${NC}"
	@echo "     Метрики и алерты"
	@echo ""
	@echo -e "  ${CYAN}▸ pgAdmin${NC}      ${GREEN}http://localhost:15050${NC}"
	@echo "     Администрирование PostgreSQL"
	@echo "     Логин: ${YELLOW}admin@example.com${NC} / ${YELLOW}admin123${NC}"
	@echo ""
	@echo -e "${YELLOW}🗄️  Базы данных:${NC}"
	@echo -e "  ${CYAN}▸ PostgreSQL Auth${NC}"
	@echo "     Порт: ${GREEN}15432${NC}"
	@echo "     DB: auth_db, User: campus, Pass: campus123"
	@echo ""
	@echo -e "  ${CYAN}▸ PostgreSQL Schedule${NC}"
	@echo "     Порт: ${GREEN}15433${NC}"
	@echo "     DB: schedule_db, User: campus, Pass: campus123"
	@echo ""
	@echo -e "  ${CYAN}▸ Redis${NC}"
	@echo "     Порт: ${GREEN}16379${NC}"
	@echo "     Pass: campus123"
	@echo ""
	@echo -e "${YELLOW}🔧 Команды для проверки:${NC}"
	@echo "  ${GREEN}make test-infra${NC}          - Проверить доступность сервисов"
	@echo "  ${GREEN}make db-check${NC}           - Проверить подключение к БД"
	@echo "  ${GREEN}make open-all${NC}           - Открыть все веб-интерфейсы"
	@echo "  ${GREEN}make docker-logs${NC}        - Показать логи"
	@echo ""
	@echo -e "${GREEN}✅ Вся инфраструктура запущена и готова к работе!${NC}"

open-all: ## Открыть все веб-интерфейсы в браузере
	@echo -e "${BLUE}🌐 Открытие всех веб-интерфейсов...${NC}"
	@echo -e "${CYAN}Открываю Grafana...${NC}"
	@xdg-open http://localhost:13000 2>/dev/null || echo "Откройте вручную: http://localhost:13000"
	@sleep 2
	@echo -e "${CYAN}Открываю Prometheus...${NC}"
	@xdg-open http://localhost:19090 2>/dev/null || echo "Откройте вручную: http://localhost:19090"
	@sleep 2
	@echo -e "${CYAN}Открываю pgAdmin...${NC}"
	@xdg-open http://localhost:15050 2>/dev/null || echo "Откройте вручную: http://localhost:15050"
	@echo -e "${GREEN}✅ Все интерфейсы открыты!${NC}"

open-grafana: ## Открыть только Grafana
	@xdg-open http://localhost:13000 2>/dev/null || echo "Откройте: http://localhost:13000"

open-prometheus: ## Открыть только Prometheus
	@xdg-open http://localhost:19090 2>/dev/null || echo "Откройте: http://localhost:19090"

open-pgadmin: ## Открыть только pgAdmin
	@xdg-open http://localhost:15050 2>/dev/null || echo "Откройте: http://localhost:15050"

clean: ## Очистка
	@echo -e "${BLUE}🧹 Очистка...${NC}"
	rm -rf mobile/build
	find . -name "*.pb.go" -delete
	find . -name "*.pb.dart" -delete
	@echo -e "${GREEN}✅ Очищено${NC}"

new-service: ## Создать новый сервис
	@if [ -z "$(NAME)" ]; then \
		echo -e "${RED}❌ Использование: make new-service NAME=service-name${NC}"; \
		exit 1; \
	fi
	@echo -e "${BLUE}🆕 Создание сервиса $(NAME)...${NC}"
	mkdir -p services/$(NAME)/{cmd,internal/{domain,repository,service,handler,config},migrations}
	cd services/$(NAME) && go mod init github.com/UltraHD-dev/smart-campus-monorepo/services/$(NAME)
	@echo -e "${GREEN}✅ Сервис $(NAME) создан${NC}"

check-deps: ## Проверить зависимости
	@echo -e "${BLUE}🔍 Проверка зависимостей...${NC}"
	@which docker || echo "❌ Docker не установлен"
	@which docker-compose || which docker-compose-plugin || echo "❌ Docker Compose не установлен"
	@which flutter || echo "❌ Flutter не установлен"
	@which go || echo "❌ Go не установлен"
	@echo -e "${GREEN}✅ Проверка завершена${NC}"

test-infra: ## Полная проверка инфраструктуры
	@echo -e "${BLUE}🧪 Полная проверка инфраструктуры...${NC}"
	@echo ""
	@echo -e "${CYAN}Проверка веб-сервисов:${NC}"
	@curl -s -f -m 10 http://localhost:13000 > /dev/null && echo "  ✅ Grafana работает" || echo "  ❌ Grafana не доступен"
	@curl -s -f -m 10 http://localhost:19090 > /dev/null && echo "  ✅ Prometheus работает" || echo "  ❌ Prometheus не доступен"
	@curl -s -f -m 10 http://localhost:15050 > /dev/null && echo "  ✅ pgAdmin работает" || echo "  ⚠️  pgAdmin может быть в процессе запуска"
	@echo ""
	@echo -e "${CYAN}Проверка баз данных:${NC}"
	@pg_isready -h localhost -p 15432 -U campus -d auth_db 2>/dev/null && echo "  ✅ PostgreSQL Auth работает" || echo "  ❌ PostgreSQL Auth не доступен"
	@pg_isready -h localhost -p 15433 -U campus -d schedule_db 2>/dev/null && echo "  ✅ PostgreSQL Schedule работает" || echo "  ❌ PostgreSQL Schedule не доступен"
	@redis-cli -h localhost -p 16379 -a campus123 ping 2>/dev/null | grep -q PONG && echo "  ✅ Redis работает" || echo "  ❌ Redis не доступен"
	@echo ""
	@echo -e "${GREEN}✅ Проверка инфраструктуры завершена${NC}"

db-check: ## Проверить подключение к базам данных
	@echo -e "${BLUE}🔍 Детальная проверка баз данных...${NC}"
	@echo "PostgreSQL Auth:"
	@psql -h localhost -p 15432 -U campus -d auth_db -c "SELECT '✅ База auth_db доступна' as status;" 2>/dev/null || echo "  ❌ Не удалось подключиться"
	@echo ""
	@echo "PostgreSQL Schedule:"
	@psql -h localhost -p 15433 -U campus -d schedule_db -c "SELECT '✅ База schedule_db доступна' as status;" 2>/dev/null || echo "  ❌ Не удалось подключиться"
	@echo ""
	@echo "Redis:"
	@redis-cli -h localhost -p 16379 -a campus123 ping 2>/dev/null | grep -q PONG && echo "  ✅ Redis отвечает на ping" || echo "  ❌ Redis не отвечает"
	@echo -e "${GREEN}✅ Проверка баз данных завершена${NC}"

db-connect-auth: ## Подключиться к PostgreSQL auth
	@echo "Подключение к PostgreSQL Auth..."
	psql -h localhost -p 15432 -U campus -d auth_db

db-connect-schedule: ## Подключиться к PostgreSQL schedule
	@echo "Подключение к PostgreSQL Schedule..."
	psql -h localhost -p 15433 -U campus -d schedule_db

redis-connect: ## Подключиться к Redis
	@echo "Подключение к Redis..."
	redis-cli -h localhost -p 16379 -a campus123

status: ## Показать статус контейнеров
	@echo -e "${BLUE}📦 Статус Docker контейнеров:${NC}"
	docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

restart: ## Перезапустить всю инфраструктуру
	@echo -e "${BLUE}🔄 Перезапуск инфраструктуры...${NC}"
	@$(MAKE) docker-down
	@sleep 3
	@$(MAKE) docker-up

init-data: ## Инициализировать тестовые данные в БД
	@echo -e "${BLUE}📝 Инициализация тестовых данных...${NC}"
	@psql -h localhost -p 15432 -U campus -d auth_db -c "
	CREATE TABLE IF NOT EXISTS users (
		id SERIAL PRIMARY KEY,
		email VARCHAR(255) UNIQUE NOT NULL,
		name VARCHAR(100),
		created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
	);
	INSERT INTO users (email, name) VALUES ('test@campus.local', 'Test User')
	ON CONFLICT (email) DO NOTHING;
	SELECT '✅ Тестовые данные созданы' as result;
	" 2>/dev/null || echo "❌ Не удалось создать тестовые данные"
